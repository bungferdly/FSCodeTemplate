//
//  FSManager.m
//  Pods
//
//  Created by Ferdly Sethio on 9/9/15.
//
//

#import "FSManager.h"

@interface FSManager()

@property (strong, nonatomic) NSHashTable *delegates;

@end

@implementation FSManager

- (UIWindow *)window
{
    return [UIApplication sharedApplication].delegate.window;
}

+ (NSMutableDictionary *)instances
{
    static NSMutableDictionary *instances;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instances = [NSMutableDictionary dictionary];
    });
    return instances;
}

+ (NSArray *)allManagers
{
    return [[self instances] allValues];
}

+ (instancetype)sharedManager
{
    NSString *className = NSStringFromClass([self class]);
    FSManager *instance = [[self instances] objectForKey:className];
    if (!instance) {
        instance = [[self alloc] init];
        [[self instances] setObject:instance forKey:className];
        [instance didLoad];
    }
    return instance;
}

- (instancetype)init
{
    self = [super init];
    self.delegates = [NSHashTable weakObjectsHashTable];
    return self;
}

- (void)addDelegate:(id)delegate
{
    if (![self.delegates containsObject:delegate]) {
        [self.delegates addObject:delegate];
    }
}

- (void)removeDelegate:(id)delegate
{
    [self.delegates removeObject:delegate];
}

- (void)didLoad
{
    
}

@end
