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
#import <Mantle/NSDictionary+MTLJSONKeyPath.h>
#import <SVProgressHUD/SVProgressHUD.h>
#import <TMCache/TMCache.h>
#import <NSURL+QueryDictionary/NSURL+QueryDictionary.h>

#ifdef DEBUG
    #define FSLog(...) NSLog(@"%s(%p) %@", __PRETTY_FUNCTION__, self, [NSString stringWithFormat:__VA_ARGS__])
#else
    #define FSLog(...) ((void)0)
#endif
#define kFSAPIRequestAccessToken @"kFSAPIRequestAccessToken"
#define kFSAPIRequestIndefiniteRequests @"kFSAPIRequestIndefiniteRequests"
#define kFSAPIRequestCacheName @"kFSAPIRequestCache"

@interface AFHTTPRequestOperationManager(FS)

- (AFHTTPRequestOperation *)HTTPRequestOperationWithHTTPMethod:(NSString *)method
                                                     URLString:(NSString *)URLString
                                                    parameters:(id)parameters
                                                       success:(void (^)(AFHTTPRequestOperation *operation, id responseObject))success
                                                       failure:(void (^)(AFHTTPRequestOperation *operation, NSError *error))failure;

@end

@interface FSRequest()

@property (strong, nonatomic) AFHTTPRequestOperation *operation;
@property (strong, nonatomic) FSResponse *response;
@property (assign, nonatomic) NSInteger retrying;

@end

@interface FSResponse()

@property (strong, nonatomic) NSString *cacheKey;
@property (assign, nonatomic) BOOL fromCache;
@property (strong, nonatomic) NSObject *object;
@property (strong, nonatomic) NSMutableArray *objects;
@property (strong, nonatomic) NSString *errorMessage;

@end

@interface FSAPIRequestManager()

@property (strong, nonatomic) AFHTTPRequestOperationManager *httpRequest;
@property (strong, nonatomic) TMDiskCache *diskCache;
@property (strong, nonatomic) NSMutableArray *requests;
@property (strong, nonatomic) NSMutableDictionary *responses;

@end

@implementation FSAPIRequestManager

- (void)didLoad
{
    self.requests = [NSMutableArray array];
    self.accessTokenComplexKey = @"access_token";
    self.errorMessageComplexKey = @"error";
    self.diskCache = [[TMDiskCache alloc] initWithName:kFSAPIRequestCacheName];
    
    [[AFNetworkReachabilityManager sharedManager] setReachabilityStatusChangeBlock:^void(AFNetworkReachabilityStatus status) {
        if (status == AFNetworkReachabilityStatusReachableViaWWAN || status == AFNetworkReachabilityStatusReachableViaWiFi) {
            [self restartIndefiniteRequests];
        }
    }];
    [[AFNetworkReachabilityManager sharedManager] startMonitoring];
    [self loadIndefiniteRequests];
}

- (void)startRequest:(FSRequest *)object withCompletion:(void (^)(FSResponse *))completion
{
    NSParameterAssert(self.baseURL);
    NSParameterAssert(object);
    
    if (!self.httpRequest) {
        self.httpRequest = [[AFHTTPRequestOperationManager alloc] initWithBaseURL:[NSURL URLWithString:self.baseURL]];
    }
    
    //setup fullpath
    NSString *fullPath = object.path ?: object.cachePath;
    
    NSParameterAssert(fullPath);
    
    if (object.parameters) {
        fullPath = [NSString stringWithFormat:@"%@?%@", fullPath, [object.parameters uq_URLQueryString]];
    }
    
    if (object.method == FSRequestMethodGET && object.cachePolicy != FSRequestCachePolicyNone && completion) {
        [self loadResponseWithPath:fullPath completion:completion];
    }
    
    //setup response block
    FSResponse * (^responseBlock)(id responseObject, BOOL save) = ^(id data, BOOL save) {
        FSResponse *response = [[FSResponse alloc] init];
        response.cacheKey = fullPath;
        
        if ([data isKindOfClass:[NSDictionary class]]) {
            response.errorMessage = [(NSDictionary *)data mtl_valueForJSONKeyPath:self.errorMessageComplexKey success:nil error:nil];
        } else {
            response.errorMessage = nil;
        }
        if (!response.errorMessage && data) {
            if ([data isKindOfClass:[NSDictionary class]] && self.accessTokenComplexKey) {
                NSString *accessToken = [data mtl_valueForJSONKeyPath:self.accessTokenComplexKey success:nil error:nil];
                if (accessToken) {
                    FSKeychainSave(accessToken, kFSAPIRequestAccessToken);
                }
            }
            if ([data isKindOfClass:[NSArray class]]) {
                response.objects = data;
            } else {
                response.object = data;
            }
            if (save) {
                if (object.cachePolicy != FSRequestCachePolicyNone) {
                    [self.responses setObject:response forKey:fullPath];
                }
                if (object.cachePolicy == FSRequestCachePolicySaveToDisk) {
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
        if (completion) {
            completion(responseBlock(data, object.method == FSRequestMethodGET));
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
        if (completion) {
            completion(response);
        }
    };
    
    [self cancelIdenticalRequest:object];
    [self addRequest:object];
    
    //process offline request
    if (object.cachePath) {
        if (object.method == FSRequestMethodPOST) {
            responseBlock(object.body, YES);
            successBlock(nil, @"success");
        }
        return;
    }
    
    //setup accesstoken
    NSString *accessToken = FSKeychainLoad(kFSAPIRequestAccessToken);
    if (accessToken) {
        [self.httpRequest.requestSerializer setValue:[NSString stringWithFormat:@"Bearer %@", accessToken] forHTTPHeaderField:@"Authorization"];
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
        if (req.retryCount >= 0) {
            [SVProgressHUD showErrorWithStatus:NSLocalizedString(req.response.errorMessage, nil) maskType:SVProgressHUDMaskTypeBlack];
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

- (void)clearCache:(BOOL)includeDiskCache
{
    [self.responses removeAllObjects];
    if (includeDiskCache) {
        [self.diskCache removeAllObjects];
    }
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
    id object = response.objects ?: response.object;
    if (!object) {
        return;
    }
    id JSON = [[FSJSONParserManager sharedManager] parseHierarchicalObject:object];
    if (JSON) {
        [self.diskCache setObject:JSON forKey:response.cacheKey];
    }
}

- (void)loadResponseWithPath:(NSString *)path completion:(void(^)(FSResponse *response))completion
{
    if (self.responses[path]) {
        completion([self cacheResponseFromResponse:self.responses[path]]);
    }else {
        [self.diskCache objectForKey:path block:^(TMDiskCache *cache, NSString *key, id<NSCoding> object, NSURL *fileURL) {
            if (object) {
                FSResponse *response = [[FSResponse alloc] init];
                response.cacheKey = path;
                if (!self.responses[path]) {
                    [self.responses setObject:response forKey:path];
                }
                id result = [[FSJSONParserManager sharedManager] parseJSON:object];
                if ([result isKindOfClass:[NSArray class]]) {
                    response.objects = result;
                } else {
                    response.object = result;
                }
                completion([self cacheResponseFromResponse:response]);
            }
        }];
    }
}

- (FSResponse *)cacheResponseFromResponse:(FSResponse *)response
{
    FSResponse *cacheResponse = [[FSResponse alloc] init];
    cacheResponse.cacheKey = response.cacheKey;
    cacheResponse.object = response.object;
    cacheResponse.objects = response.objects;
    cacheResponse.fromCache = YES;
    return cacheResponse;
}

@end

@implementation FSRequest

@end

@implementation FSResponse

@end
