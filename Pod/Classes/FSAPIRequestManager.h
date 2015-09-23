//
//  FSRequestManager.h
//  Pods
//
//  Created by Ferdly Sethio on 9/10/15.
//
//

#import "FSManager.h"

typedef enum : NSUInteger {
    FSRequestMethodGET,
    FSRequestMethodPOST,
    FSRequestMethodPUT,
    FSRequestMethodDELETE
} FSRequestMethod;

typedef enum : NSInteger {
    FSRequestCachePolicyNetworkOnly = -1,
    FSRequestCachePolicyCacheThenNetwork,
    FSRequestCachePolicyCacheOnly
} FSRequestCachePolicy;

@protocol AFMultipartFormData;

@interface FSRequest : NSObject

@property (strong, nonatomic) NSString *path;
@property (strong, nonatomic) NSDictionary *parameters;
@property (strong, nonatomic) id body;
@property (assign, nonatomic) FSRequestMethod method;
@property (assign, nonatomic) FSRequestCachePolicy cachePolicy;
@property (assign, nonatomic) BOOL errorHidden;
@property (strong, nonatomic) NSString *hudTitle;
@property (strong, nonatomic) NSString *hudSuccessTitle;
@property (strong, nonatomic) NSDictionary *httpHeaderFields;
@property (strong, nonatomic) void (^constructingBodyBlock)(id <AFMultipartFormData> formData);
@property (assign, nonatomic) NSInteger retryCount;

@end

@interface FSResponse : NSObject

@property (readonly, nonatomic) BOOL fromCache;
@property (readonly, nonatomic) id object;
@property (readonly, nonatomic) NSMutableDictionary *dictionaryObject;
@property (readonly, nonatomic) NSMutableArray *arrayObject;
@property (readonly, nonatomic) NSString *errorMessage;

- (void)save;

@end

@interface FSAPIRequestManager : FSManager

@property (strong, nonatomic) NSString *baseURL;
@property (strong, nonatomic) NSString *resultCompexKey;
@property (strong, nonatomic) NSString *errorMessageComplexKey;

- (void)startRequest:(FSRequest *)request withCompletion:(void(^)(FSResponse *response))completion;
- (void)clearCache;

@end

@protocol FSAPIRequestManagerDelegate <NSObject>

- (BOOL)shouldStartRequest:(FSRequest *)request withCompletion:(void(^)(FSResponse *response))completion;
- (void)didFinishRequest:(FSRequest *)request withResponse:(FSResponse *)response;

@end
