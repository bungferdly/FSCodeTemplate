//
//  FSRequestManager.h
//  Pods
//
//  Created by Ferdly Sethio on 9/10/15.
//
//

#import "FSManager.h"
#import <AFNetworking/AFNetworking.h>

typedef enum : NSUInteger {
    FSRequestMethodGET,
    FSRequestMethodPOST,
    FSRequestMethodPUT,
    FSRequestMethodDELETE
} FSRequestMethod;

typedef enum : NSInteger {
    FSRequestCachePolicyNone = -1,
    FSRequestCachePolicySaveToMemory,
    FSRequestCachePolicySaveToDisk
} FSRequestCachePolicy;

@interface FSRequest : NSObject

@property (strong, nonatomic) NSString *cachePath;
@property (strong, nonatomic) NSString *path;
@property (strong, nonatomic) NSDictionary *parameters;
@property (strong, nonatomic) id body;
@property (strong, nonatomic) NSString *hudTitle;
@property (strong, nonatomic) NSString *hudSuccessTitle;
@property (assign, nonatomic) FSRequestMethod method;
@property (assign, nonatomic) FSRequestCachePolicy cachePolicy;
@property (strong, nonatomic) void (^constructingBodyBlock)(id <AFMultipartFormData> formData);
@property (assign, nonatomic) NSInteger retryCount;

@end

@interface FSResponse : NSObject

@property (readonly, nonatomic) NSString *cacheKey;
@property (readonly, nonatomic) BOOL fromCache;
@property (readonly, nonatomic) NSObject *object;
@property (readonly, nonatomic) NSMutableArray *objects;
@property (readonly, nonatomic) NSString *errorMessage;

@end

@interface FSAPIRequestManager : FSManager

@property (strong, nonatomic) NSString *baseURL;
@property (strong, nonatomic) NSString *accessTokenComplexKey;
@property (strong, nonatomic) NSString *errorMessageComplexKey;

- (void)startRequest:(FSRequest *)request withCompletion:(void(^)(FSResponse *response))completion;
- (void)clearCache:(BOOL)includeDiskCache;

@end
