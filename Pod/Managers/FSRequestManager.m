//
//  FSRequestManager.m
//  Pods
//
//  Created by Ferdly Sethio on 9/10/15.
//
//

#import "FSRequestManager.h"
#import "FSKeychainManager.h"
#import "FSJSONParserManager.h"
#import <SVProgressHUD/SVProgressHUD.h>
#import <TMCache/TMCache.h>
#import <NSURL+QueryDictionary/NSURL+QueryDictionary.h>
#import <AFNetworking/AFNetworking.h>
#import "FSCodeTemplate.h"
#import "FSWebController.h"
#import "FSAccountManager.h"

#define FSRequestManagerIndefiniteRequests @"FSRequestManagerIndefiniteRequests"
#define FSRequestManagerCacheName @"FSRequestManagerCacheName"

@interface AFHTTPRequestOperationManager(FS)

- (AFHTTPRequestOperation *)HTTPRequestOperationWithHTTPMethod:(NSString *)method
                                                     URLString:(NSString *)URLString
                                                    parameters:(id)parameters
                                                       success:(void (^)(AFHTTPRequestOperation *operation, id responseObject))success
                                                       failure:(void (^)(AFHTTPRequestOperation *operation, NSError *error))failure;

@end

@interface NSDictionary (FS)

- (id)fs_valueForJSONComplexKey:(NSString *)JSONComplexKey;

@end

@interface FSRequest() <NSCoding>

@property (readonly, nonatomic) NSString *fullPath;
@property (strong, nonatomic) AFHTTPRequestOperation *operation;
@property (strong, nonatomic) FSResponse *response;
@property (assign, nonatomic) NSInteger retrying;
@property (strong, nonatomic) void (^completion)(FSResponse *);
@property (strong, nonatomic) NSMutableDictionary *httpHeaderFields;

@end

@interface FSResponse()

@property (strong, nonatomic) NSString *cacheKey;
@property (assign, nonatomic) BOOL fromCache;

@end

@interface FSRequestManager() <FSAccountManagerDelegate>

@property (strong, nonatomic) AFHTTPRequestOperationManager *httpRequest;
@property (strong, nonatomic) AFHTTPRequestOperationManager *jsonRequest;
@property (strong, nonatomic) TMDiskCache *diskCache;
@property (strong, nonatomic) NSMutableArray *requests;
@property (strong, nonatomic) NSMapTable *responses;

@end

@implementation FSRequestManager

- (void)didLoad
{
    self.requests = [NSMutableArray array];
    self.responses = [NSMapTable strongToWeakObjectsMapTable];
    self.errorMessageComplexKey = @"error";
    self.diskCache = [[TMDiskCache alloc] initWithName:FSRequestManagerCacheName];
    
    [[AFNetworkReachabilityManager sharedManager] setReachabilityStatusChangeBlock:^(AFNetworkReachabilityStatus status) {
        if (status == AFNetworkReachabilityStatusReachableViaWWAN || status == AFNetworkReachabilityStatusReachableViaWiFi) {
            [self restartIndefiniteRequests];
        }
    }];
    
    [[FSAccountManager sharedManager] addDelegate:self];
}

- (void)setBaseURL:(NSString *)baseURL
{
    if (!self.httpRequest || ![_baseURL isEqualToString:baseURL]) {
        self.httpRequest = [[AFHTTPRequestOperationManager alloc] initWithBaseURL:[NSURL URLWithString:baseURL]];
        self.jsonRequest = [[AFHTTPRequestOperationManager alloc] initWithBaseURL:[NSURL URLWithString:baseURL]];
        self.jsonRequest.requestSerializer = [AFJSONRequestSerializer serializer];
    }
    _baseURL = baseURL;
}

- (void)startRequest:(FSRequest *)object withCompletion:(void (^)(FSResponse *))completion
{
    NSParameterAssert(self.baseURL);
    NSParameterAssert(object);
    
    //setup fullpath
    NSString *fullPath = object.fullPath;
    NSParameterAssert(fullPath);
    
    //setup cache block
    void (^cacheBlock)() = ^(FSResponse *networkResponse) {
        if (object.retrying == 0 && object.cachePolicy != FSRequestCachePolicyNetworkOnly && completion) {
            for (id delegate in self.delegates) {
                if ([delegate respondsToSelector:@selector(requestManagerWillStartRequest:fromCache:)]) {
                    [delegate requestManagerWillStartRequest:object fromCache:YES];
                }
            }
            [self loadResponseWithPath:fullPath completion:^(FSResponse *response) {
                if (response.object || object.cachePolicy == FSRequestCachePolicyCacheOnly) {
                    for (id delegate in self.delegates) {
                        if ([delegate respondsToSelector:@selector(requestManagerdidFinishRequest:withResponse:)]) {
                            [delegate requestManagerdidFinishRequest:object withResponse:response];
                        }
                    }
                    completion(response);
                } else if (object.cachePolicy == FSRequestCachePolicyCacheIfNoNetwork) {
                    completion(networkResponse);
                }
            }];
        }
    };
    
    //setup success block
    void (^successBlock)(AFHTTPRequestOperation *operation, id responseObject) = ^(AFHTTPRequestOperation *operation, id data) {
        [self removeRequest:object];
        [self logOperation:operation];
        
        data = [[FSJSONParserManager sharedManager] parseJSON:data];
        
        FSResponse *response = [[FSResponse alloc] init];
        response.cacheKey = fullPath;
        
        if ([data isKindOfClass:[NSDictionary class]] && self.errorMessageComplexKey.length) {
            id error = [(NSDictionary *)data fs_valueForJSONComplexKey:self.errorMessageComplexKey];
            if (error) {
                response.error = [NSError errorWithDomain:NSCocoaErrorDomain
                                                     code:operation.response.statusCode
                                                 userInfo:@{NSLocalizedDescriptionKey : error}];
            }
        } else {
            response.error = nil;
        }
        if (!response.error && data) {
            response.object = data;
            if (object.method == FSRequestMethodGET) {
                if (object.cachePolicy != FSRequestCachePolicyNetworkOnly) {
                    [self saveResponse:response];
                }
            }
        }
        
        object.response = response;
        
        for (id delegate in self.delegates) {
            if ([delegate respondsToSelector:@selector(requestManagerdidFinishRequest:withResponse:)]) {
                [delegate requestManagerdidFinishRequest:object withResponse:response];
            }
        }
        if (completion) {
            completion(response);
        }
    };
    
    //setup failure block
    void (^failedBlock)(AFHTTPRequestOperation *operation, NSError *error) = ^(AFHTTPRequestOperation *operation, NSError *error) {
        [self removeRequest:object];
        [self logOperation:operation];
        
        if (operation.cancelled) {
            return;
        }
        
        if (object.retryCount > 0 && object.retrying < object.retryCount) {
            object.retrying++;
            [self startRequest:object withCompletion:completion];
            return;
        }
        object.retrying = 0;
        
        FSResponse *response = [[FSResponse alloc] init];
        response.error = error;
        response.httpResponse = operation.response;
        object.response = response;
        
        if (object.retryCount < 0 && (error.code <= 0 || error.code == 408)) {
            [self.requests addObject:object];
        }
        
        if (response.error && object.cachePolicy == FSRequestCachePolicyCacheIfNoNetwork) {
            cacheBlock(response);
        } else {
            for (id delegate in self.delegates) {
                if ([delegate respondsToSelector:@selector(requestManagerdidFinishRequest:withResponse:)]) {
                    [delegate requestManagerdidFinishRequest:object withResponse:response];
                }
            }
            
            if (completion) {
                completion(response);
            }
        }
    };
    
    if (object.cachePolicy == FSRequestCachePolicyCacheOnly) {
        if (object.method == FSRequestMethodDELETE) {
            [self.diskCache removeObjectForKey:fullPath block:^(TMDiskCache *cache, NSString *key, id<NSCoding> object, NSURL *fileURL) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    if (completion) {
                        completion(nil);
                    }
                });
            }];
            return;
        } else if (object.method == FSRequestMethodPOST) {
            FSResponse *response = [[FSResponse alloc] init];
            response.cacheKey = fullPath;
            response.object = object.body;
            [self saveResponse:response];
            if (completion) {
                completion(nil);
            }
            return;
        }
    } else if (object.cachePolicy != FSRequestCachePolicyNetworkOnly) {
        if (object.method == FSRequestMethodPOST) {
            object.cachePolicy = FSRequestCachePolicyNetworkOnly;
        }
    }
    
    //load response from cache
    if (object.cachePolicy != FSRequestCachePolicyCacheIfNoNetwork) {
        cacheBlock(nil);
    }
    
    //do not proceed further if offline request
    if (object.cachePolicy == FSRequestCachePolicyCacheOnly) {
        return;
    }
    
    //handle refresh token
    if (object.retrying < 30) {
        BOOL shouldRetryingRequest = NO;
        object.completion = completion;
        for (id delegate in self.delegates) {
            if ([delegate respondsToSelector:@selector(requestManagerRequestShouldDelayRequest:)]) {
                shouldRetryingRequest |= [delegate requestManagerRequestShouldDelayRequest:object];
            }
        }
        if (shouldRetryingRequest) {
            [self performSelector:@selector(restartRequest:) withObject:object afterDelay:1];
            return;
        }
    }
    
    for (id delegate in self.delegates) {
        if ([delegate respondsToSelector:@selector(requestManagerWillStartRequest:fromCache:)]) {
            [delegate requestManagerWillStartRequest:object fromCache:NO];
        }
    }
    
    [self cancelRequest:object];
    [self addRequest:object];
    
    AFHTTPRequestOperationManager *requestManager = object.contentType == FSContentTypeForm ? self.httpRequest : self.jsonRequest;
    //setup headers
    for (NSString *key in object.httpHeaderFields) {
        [requestManager.requestSerializer setValue:object.httpHeaderFields[key] forHTTPHeaderField:key];
    }
    
    //setup method
    NSString *method = @"GET";
    if (object.method == FSRequestMethodPOST) {
        method = @"POST";
    } else if (object.method == FSRequestMethodPUT) {
        method = @"PUT";
    } else if (object.method == FSRequestMethodDELETE) {
        method = @"DELETE";
    }
    
    //process online request
    if (object.constructingBodyBlock) {
        object.operation = [requestManager POST:fullPath parameters:object.body constructingBodyWithBlock:object.constructingBodyBlock success:successBlock failure:failedBlock];
    } else {
        object.operation = [requestManager HTTPRequestOperationWithHTTPMethod:method URLString:fullPath parameters:object.body success:successBlock failure:failedBlock];
        [requestManager.operationQueue addOperation:object.operation];
    }
}

- (void)logOperation:(AFHTTPRequestOperation *)operation
{
#ifdef DEBUG
    FSLog(@"\n%@ : %@%@%@\nRESPONSE (%d) : %@\n\n",
          operation.request.HTTPMethod,
          operation.request.URL,
          operation.request.HTTPBody.length ? @"\nBODY : " : @"",
          operation.request.HTTPBody.length ? [[NSString alloc] initWithData:operation.request.HTTPBody encoding:NSUTF8StringEncoding] : @"",
          (int)operation.response.statusCode,
          operation.responseString);
#endif
}

- (void)restartRequest:(FSRequest *)request
{
    request.retrying++;
    [self startRequest:request withCompletion:request.completion];
}

- (void)calculateHUD:(FSRequest *)req
{
    for (FSRequest *request in self.requests) {
        if (request.operation.isExecuting && request.hudTitle) {
            [SVProgressHUD showWithStatus:NSLocalizedString(request.hudTitle, nil) maskType:SVProgressHUDMaskTypeBlack];
            return;
        }
    }
    if (req.response.error) {
        if (req.retryCount >= 0 && !req.errorHidden) {
            [SVProgressHUD dismiss];
            
            NSData *errDetails = self.showDebugDetails ? req.response.error.userInfo[@"com.alamofire.serialization.response.error.data"] : nil;
            [FSAlertController showWithTitle:NSLocalizedString(@"Error",nil) message:[req.response.error localizedDescription]
                           cancelButtonTitle:NSLocalizedString(@"Dismiss", nil) destructiveButtonTitle:nil
                           otherButtonTitles:errDetails ? @[@"Debug Details"] : nil container:nil
                                    tapBlock:^(FSAlertController * _Nonnull controller, NSInteger buttonIndex) {
                                        if (buttonIndex == controller.firstOtherButtonIndex) {
                                            FSWebController *wc = [FSWebController fs_newController];
                                            wc.navigationItem.title = @"Error Details";
                                            [wc view];
                                            [wc.webView loadHTMLString:[[NSString alloc] initWithData:errDetails encoding:NSUTF8StringEncoding]
                                                               baseURL:[NSURL URLWithString:self.baseURL]];
                                            
                                            UINavigationController *nc = [[UINavigationController alloc] initWithRootViewController:wc];
                                            [[UIViewController fs_topViewController] presentViewController:nc animated:YES completion:nil];
                                        }
                                    }];
        }
        req.response = nil;
        return;
    } else if (req.hudSuccessTitle) {
        [SVProgressHUD showSuccessWithStatus:NSLocalizedString(req.hudSuccessTitle, nil) maskType:SVProgressHUDMaskTypeBlack];
        return;
    }
    if (req.hudTitle && req.retrying >= req.retryCount) {
        [SVProgressHUD dismiss];
    }
    req.response = nil;
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    [self saveIndefiniteRequests];
}

#pragma mark - Request

- (void)addRequest:(FSRequest *)request
{
    if ([self.requests containsObject:request]) {
        return;
    }
    [self.requests addObject:request];
    [self performSelector:@selector(calculateHUD:) withObject:request afterDelay:0];
}

- (void)removeRequest:(FSRequest *)request
{
    if (![self.requests containsObject:request]) {
        return;
    }
    request.completion = nil;
    [self.requests removeObject:request];
    [self performSelector:@selector(calculateHUD:) withObject:request afterDelay:0];
}

- (void)cancelRequest:(FSRequest *)request
{
    NSUInteger i = 0;
    while (i < self.requests.count) {
        FSRequest *request2 = self.requests[i];
        if (request == request2 || [request.fullPath isEqual:request2.fullPath]) {
            [request2.operation cancel];
            [self removeRequest:request2];
        } else {
            i++;
        }
    }
}

#pragma mark - Indefinite Requests

- (void)restartIndefiniteRequests
{
    NSArray *requests = [self.requests copy];
    for (FSRequest *request in requests) {
        if (!request.operation.isExecuting && request.retryCount < 0) {
            [self startRequest:request withCompletion:nil];
        }
    }
}

- (void)saveIndefiniteRequests
{
    NSMutableArray *requests = [@[] mutableCopy];
    for (FSRequest *request in self.requests) {
        if (request.retryCount < 0) {
            [requests addObject:request];
        }
    }
    [self.diskCache setObject:requests forKey:FSRequestManagerIndefiniteRequests];
}

- (void)loadIndefiniteRequests
{
    [self.diskCache objectForKey:FSRequestManagerIndefiniteRequests block:^(TMDiskCache *cache, NSString *key, NSArray *object, NSURL *fileURL) {
        dispatch_async(dispatch_get_main_queue(), ^{
            for (FSRequest *request in object) {
                [self startRequest:request withCompletion:nil];
            }
            [self.diskCache removeObjectForKey:FSRequestManagerIndefiniteRequests];
        });
    }];
}

#pragma mark - Response

- (void)saveResponse:(FSResponse *)response
{
    if (!response.object) {
        return;
    }
    [self.responses setObject:response forKey:response.cacheKey];
    [self.diskCache setObject:[NSKeyedArchiver archivedDataWithRootObject:response.object]
                       forKey:response.cacheKey];
}

- (void)loadResponseWithPath:(NSString *)path completion:(void(^)(FSResponse *response))completion
{
    if ([self.responses objectForKey:path]) {
        completion([self cacheResponseFromResponse:[self.responses objectForKey:path]]);
    }else {
        [self.diskCache objectForKey:path block:^(TMDiskCache *cache, NSString *key, id<NSCoding> object, NSURL *fileURL) {
            dispatch_async(dispatch_get_main_queue(), ^{
                FSResponse *response = [[FSResponse alloc] init];
                response.cacheKey = path;
                if (object) {
                    if (![self.responses objectForKey:path]) {
                        [self.responses setObject:response forKey:path];
                    }
                    response.object = [NSKeyedUnarchiver unarchiveObjectWithData:(NSData *)object];
                }
                completion([self cacheResponseFromResponse:response]);
            });
        }];
    }
}

- (FSResponse *)cacheResponseFromResponse:(FSResponse *)response
{
    FSResponse *cacheResponse = [[FSResponse alloc] init];
    cacheResponse.cacheKey = response.cacheKey;
    cacheResponse.object = response.object;
    cacheResponse.fromCache = YES;
    return cacheResponse;
}

#pragma mark - Account Cycle

- (void)accountManagerDidLoggedIn:(id)userInfo
{
    [self loadIndefiniteRequests];
    [[AFNetworkReachabilityManager sharedManager] startMonitoring];
}

- (void)accountManagerDidLoggedOut:(id)userInfo
{
    [self cleanup];
    [[AFNetworkReachabilityManager sharedManager] stopMonitoring];
}

- (void)cleanup
{
    while (self.requests.count) {
        FSRequest *request = self.requests[0];
        [self.requests removeObject:request];
        [request.operation cancel];
    }
    [self.responses removeAllObjects];
    [self.diskCache removeAllObjects];
}

@end

#pragma mark -

@implementation FSRequest

- (NSString *)fullPath
{
    NSString *fullPath = self.path;
    if (self.parameters.count) {
        fullPath = [NSString stringWithFormat:@"%@?%@", fullPath, [self.parameters uq_URLQueryString]];
    }
    return fullPath;
}

+ (NSArray *)savedKeys
{
    return @[@"path", @"parameters", @"body", @"method", @"retryCount",
             @"cachePolicy", @"errorHidden", @"contentType",
             @"hudTitle", @"hudSuccessTitle", @"httpHeaderFields"];
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder
{
    self = [super init];
    for (NSString *key in [self.class savedKeys]) {
        [self setValue:[aDecoder decodeObjectForKey:key] forKey:key];
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder
{
    for (NSString *key in [self.class savedKeys]) {
        [aCoder encodeObject:[self valueForKey:key] forKey:key];
    }
}

- (instancetype)init
{
    self = [super init];
    self.httpHeaderFields = [NSMutableDictionary dictionary];
    return self;
}

@end

@implementation FSResponse

- (NSMutableDictionary *)dictionaryObject
{
    return [self.object isKindOfClass:[NSMutableDictionary class]] ? self.object : nil;
}

- (NSMutableArray *)arrayObject
{
    return [self.object isKindOfClass:[NSArray class]] ? self.object : nil;
}

- (void)save
{
    [[FSRequestManager sharedManager] saveResponse:self];
}

@end

@implementation NSDictionary (FS)

- (id)fs_valueForJSONComplexKey:(NSString *)JSONComplexKey
{
    NSArray *components = [JSONComplexKey componentsSeparatedByString:@"."];
    id result = self;
    for (NSString *component in components) {
        if (result == nil || result == NSNull.null) break;
        if (![result isKindOfClass:NSDictionary.class]) {
            return nil;
        }
        result = result[component];
    }
    return result;
}

@end
