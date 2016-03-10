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
    FSRequestCachePolicyNetworkOnly = -1,
    FSRequestCachePolicyCacheThenNetwork,
    FSRequestCachePolicyCacheOnly,
    FSRequestCachePolicyCacheIfNoNetwork
} FSRequestCachePolicy;

typedef enum : NSUInteger {
    FSContentTypeJSON,
    FSContentTypeForm
} FSContentType;

typedef enum : NSUInteger {
    FSRequestDelayNone = 0,
    FSRequestDelayLimited = 1,
    FSRequestDelayForever = 3,
} FSRequestDelay;

@protocol AFMultipartFormData;

@interface FSRequest : NSObject

@property (strong, nonatomic) NSString *path;
@property (strong, nonatomic) NSDictionary *parameters;
@property (strong, nonatomic) id body;
@property (assign, nonatomic) FSRequestMethod method;
@property (assign, nonatomic) FSRequestCachePolicy cachePolicy;
@property (assign, nonatomic) BOOL errorHidden;
@property (assign, nonatomic) FSContentType contentType;
@property (strong, nonatomic) NSString *hudTitle;
@property (strong, nonatomic) NSString *hudSuccessTitle;
@property (readonly, nonatomic) NSMutableDictionary *httpHeaderFields;
@property (strong, nonatomic) void (^constructingBodyBlock)(id <AFMultipartFormData> formData);
@property (assign, nonatomic) NSInteger retryCount;

@end

@interface FSResponse : NSObject

@property (readonly, nonatomic) BOOL fromCache;
@property (strong, nonatomic) id object;
@property (readonly, nonatomic) NSMutableDictionary *dictionaryObject;
@property (readonly, nonatomic) NSMutableArray *arrayObject;
@property (strong, nonatomic) NSError *error;
@property (strong, nonatomic) NSHTTPURLResponse *httpResponse;

- (void)save;

@end

@interface FSRequestManager : FSManager

@property (strong, nonatomic) NSString *baseURL;
@property (strong, nonatomic) NSArray *resultCompexKeys;
@property (strong, nonatomic) NSArray *errorMessageComplexKeys;
@property (assign, nonatomic) BOOL showDebugDetails;

- (void)startRequest:(FSRequest *)request withCompletion:(void(^)(FSResponse *response))completion;
- (void)cleanup;

@end

@protocol FSRequestManagerDelegate <NSObject>

@optional
- (FSRequestDelay)requestManagerRequestShouldDelayRequest:(FSRequest *)request;
- (void)requestManagerWillStartRequest:(FSRequest *)request fromCache:(BOOL)fromCache;
- (void)requestManagerdidFinishRequest:(FSRequest *)request withResponse:(FSResponse *)response;

@end
