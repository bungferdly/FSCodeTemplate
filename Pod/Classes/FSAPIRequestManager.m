//
//  FSRequestManager.m
//  Pods
//
//  Created by Ferdly Sethio on 9/10/15.
//
//

#import "FSAPIRequestManager.h"
#import "FSKeychainManager.h"
#import "FSJSONParserManager.h"
#import <Mantle/Mantle.h>
#import <SVProgressHUD/SVProgressHUD.h>
#import <TMCache/TMCache.h>
#import <NSURL+QueryDictionary/NSURL+QueryDictionary.h>
#import <AFNetworking/AFNetworking.h>
#import "FSCodeTemplate.h"

#define kFSAPIRequestIndefiniteRequests @"kFSAPIRequestIndefiniteRequests"
#define kFSAPIRequestCacheName @"kFSAPIRequestCache"

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

@interface FSRequest()

@property (strong, nonatomic) AFHTTPRequestOperation *operation;
@property (strong, nonatomic) FSResponse *response;
@property (assign, nonatomic) NSInteger retrying;

@end

@interface FSResponse()

@property (strong, nonatomic) NSString *cacheKey;
@property (assign, nonatomic) BOOL fromCache;
@property (strong, nonatomic) id object;
@property (strong, nonatomic) NSString *errorMessage;

@end

@interface FSAPIRequestManager()

@property (strong, nonatomic) AFHTTPRequestOperationManager *httpRequest;
@property (strong, nonatomic) TMDiskCache *diskCache;
@property (strong, nonatomic) NSMutableArray *requests;
@property (strong, nonatomic) NSMapTable *responses;

@end

@implementation FSAPIRequestManager

- (void)didLoad
{
    self.requests = [NSMutableArray array];
    self.responses = [NSMapTable strongToWeakObjectsMapTable];
    self.errorMessageComplexKey = @"error";
    self.diskCache = [[TMDiskCache alloc] initWithName:kFSAPIRequestCacheName];
    
    [[AFNetworkReachabilityManager sharedManager] setReachabilityStatusChangeBlock:^void(AFNetworkReachabilityStatus status) {
        if (status == AFNetworkReachabilityStatusReachableViaWWAN || status == AFNetworkReachabilityStatusReachableViaWiFi) {
            [self restartIndefiniteRequests];
        }
    }];
    [[AFNetworkReachabilityManager sharedManager] startMonitoring];
    [self performSelector:@selector(loadIndefiniteRequests) withObject:nil afterDelay:0];
}

- (void)startRequest:(FSRequest *)object withCompletion:(void (^)(FSResponse *))completion
{
    NSParameterAssert(self.baseURL);
    NSParameterAssert(object);
    
    if (!self.httpRequest) {
        self.httpRequest = [[AFHTTPRequestOperationManager alloc] initWithBaseURL:[NSURL URLWithString:self.baseURL]];
    }
    
    BOOL shouldStartRequest = YES;
    for (id delegate in self.delegates) {
        if ([delegate respondsToSelector:@selector(shouldStartRequest:withCompletion:)]) {
            shouldStartRequest &= [delegate shouldStartRequest:object withCompletion:completion];
        }
    }
    if (!shouldStartRequest) {
        return;
    }
    
    if (object.method != FSRequestMethodGET) {
        object.cachePolicy = FSRequestCachePolicyNetworkOnly;
    }
    
    //setup fullpath
    NSString *fullPath = object.path;
    NSParameterAssert(fullPath);
    if (object.parameters) {
        fullPath = [NSString stringWithFormat:@"%@?%@", fullPath, [object.parameters uq_URLQueryString]];
    }
    
    //load response from cache
    if (object.cachePolicy != FSRequestCachePolicyNetworkOnly && completion) {
        [self loadResponseWithPath:fullPath completion:^(FSResponse *response) {
            if (response || object.cachePolicy == FSRequestCachePolicyCacheOnly) {
                completion(response);
            }
        }];
    }
    
    //do not proceed further if offline request
    if (object.cachePolicy == FSRequestCachePolicyCacheOnly) {
        return;
    }
    
    //setup response block
    FSResponse * (^responseBlock)(id responseObject, BOOL save) = ^(id data, BOOL save) {
        FSResponse *response = [[FSResponse alloc] init];
        response.cacheKey = fullPath;
        
        if ([data isKindOfClass:[NSDictionary class]] && self.errorMessageComplexKey.length) {
            response.errorMessage = [(NSDictionary *)data fs_valueForJSONComplexKey:self.errorMessageComplexKey];
        } else {
            response.errorMessage = nil;
        }
        if (!response.errorMessage && data) {
            response.object = data;
            if (save) {
                if (object.cachePolicy != FSRequestCachePolicyNetworkOnly) {
                    [self saveResponse:response];
                }
            }
        }
        
        object.response = response;
        return response;
    };
    
    //setup success block
    void (^successBlock)(AFHTTPRequestOperation *operation, id responseObject) = ^(AFHTTPRequestOperation *operation, id data) {
        [self removeRequest:object];
        
        FSLog(@"\nAPI : %@\nResponse : %@\n\n", fullPath, data);
        
        data = [[FSJSONParserManager sharedManager] parseJSON:data];
        id response = responseBlock(data, object.method == FSRequestMethodGET);
        
        for (id delegate in self.delegates) {
            if ([delegate respondsToSelector:@selector(didFinishRequest:withResponse:)]) {
                [delegate didFinishRequest:object withResponse:response];
            }
        }
        if (completion) {
            completion(response);
        }
    };
    
    //setup failure block
    void (^failedBlock)(AFHTTPRequestOperation *operation, NSError *error) = ^(AFHTTPRequestOperation *operation, NSError *error) {
        [self removeRequest:object];
        
        FSLog(@"\nAPI : %@\nError : %@\n\n", fullPath, error);
        
        if (operation.cancelled) {
            return;
        }
        
        if (object.retrying < object.retryCount || (object.retrying < 3 && object.retryCount < 0)) {
            object.retrying++;
            [self startRequest:object withCompletion:completion];
            return;
        }
        object.retrying = 0;
        
        FSResponse *response = [[FSResponse alloc] init];
        response.errorMessage = [error localizedDescription];
        object.response = response;
        
        if (object.retryCount < 0 && (error.code <= 0 || error.code == 408)) {
            [self.requests addObject:object];
        }
        
        for (id delegate in self.delegates) {
            if ([delegate respondsToSelector:@selector(didFinishRequest:withResponse:)]) {
                [delegate didFinishRequest:object withResponse:response];
            }
        }
        
        if (completion) {
            completion(response);
        }
    };
    
    [self cancelIdenticalRequest:object];
    [self addRequest:object];
    
    //setup headers
    for (NSString *key in object.httpHeaderFields) {
        [self.httpRequest.requestSerializer setValue:object.httpHeaderFields[key] forHTTPHeaderField:key];
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
        object.operation = [self.httpRequest POST:fullPath parameters:object.body constructingBodyWithBlock:object.constructingBodyBlock success:successBlock failure:failedBlock];
    } else {
        object.operation = [self.httpRequest HTTPRequestOperationWithHTTPMethod:method URLString:fullPath parameters:object.body success:successBlock failure:failedBlock];
        [self.httpRequest.operationQueue addOperation:object.operation];
    }
}

- (void)calculateHUD:(FSRequest *)req
{
    for (FSRequest *request in self.requests) {
        if (request.operation.isExecuting && request.hudTitle) {
            [SVProgressHUD showWithStatus:NSLocalizedString(request.hudTitle, nil) maskType:SVProgressHUDMaskTypeBlack];
            return;
        }
    }
    if (req.response.errorMessage) {
        if (req.retryCount >= 0 && !req.errorHidden) {
            [SVProgressHUD showErrorWithStatus:NSLocalizedString([req.response.errorMessage description], nil) maskType:SVProgressHUDMaskTypeBlack];
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

- (void)clearCache
{
    [self.responses removeAllObjects];
    [self.diskCache removeAllObjects];
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
    [self.requests removeObject:request];
    [self performSelector:@selector(calculateHUD:) withObject:request afterDelay:0];
}

- (void)cancelIdenticalRequest:(FSRequest *)request
{
    NSUInteger i = 0;
    while (i < self.requests.count) {
        FSRequest *request2 = self.requests[i];
        if (request == request2) {
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
    for (FSRequest *request in self.requests) {
        if (!request.operation.isExecuting && request.retryCount < 0) {
            [self startRequest:request withCompletion:nil];
        }
    }
}

- (void)saveIndefiniteRequests
{
    NSMutableArray *allData = [@[] mutableCopy];
    for (FSRequest *request in self.requests) {
        if (request.retryCount < 0) {
            NSMutableDictionary *data = [@{} mutableCopy];
            [data setObject:request.path forKey:@"path"];
            if (request.parameters) {
                [data setObject:request.parameters forKey:@"parameters"];
            }
            if (request.body) {
                [data setObject:request.body forKey:@"body"];
            }
            if (request.hudTitle) {
                [data setObject:request.hudTitle forKey:@"hudTitle"];
            }
            if (request.hudSuccessTitle) {
                [data setObject:request.hudSuccessTitle forKey:@"hudSuccessTitle"];
            }
            [data setObject:@(request.method) forKey:@"method"];
            [data setObject:@(request.cachePolicy) forKey:@"cachePolicy"];
            [allData addObject:data];
        }
    }
    [self.diskCache setObject:allData forKey:kFSAPIRequestIndefiniteRequests];
}

- (void)loadIndefiniteRequests
{
    [self.diskCache objectForKey:kFSAPIRequestIndefiniteRequests block:^(TMDiskCache *cache, NSString *key, NSArray *object, NSURL *fileURL) {
        for (NSDictionary *data in object) {
            FSRequest *request = [[FSRequest alloc] init];
            request.retryCount = -1;
            [request setValuesForKeysWithDictionary:data];
            [self startRequest:request withCompletion:nil];
        }
    }];
}

#pragma mark - Response

- (void)saveResponse:(FSResponse *)response
{
    if (!response.object) {
        return;
    }
    [self.responses setObject:response forKey:response.cacheKey];
    
    id JSON = [[FSJSONParserManager sharedManager] parseHierarchicalObject:response.object];
    if (JSON) {
        [self.diskCache setObject:JSON forKey:response.cacheKey];
    }
}

- (void)loadResponseWithPath:(NSString *)path completion:(void(^)(FSResponse *response))completion
{
    if ([self.responses objectForKey:path]) {
        completion([self cacheResponseFromResponse:[self.responses objectForKey:path]]);
    }else {
        [self.diskCache objectForKey:path block:^(TMDiskCache *cache, NSString *key, id<NSCoding> object, NSURL *fileURL) {
            if (object) {
                FSResponse *response = [[FSResponse alloc] init];
                response.cacheKey = path;
                if (![self.responses objectForKey:path]) {
                    [self.responses setObject:response forKey:path];
                }
                response.object = [[FSJSONParserManager sharedManager] parseJSON:object];
                completion([self cacheResponseFromResponse:response]);
            } else {
                completion(nil);
            }
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

@end

@implementation FSRequest

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
    [[FSAPIRequestManager sharedManager] saveResponse:self];
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
