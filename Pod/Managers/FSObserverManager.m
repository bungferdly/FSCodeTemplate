//
//  FSObserverManager.m
//  Pods
//
//  Created by Ferdly on 3/10/16.
//
//

#import "FSObserverManager.h"
#import <objc/runtime.h>

@interface FSObserver : NSObject

@property (strong, nonatomic) void (^changeBlock)(id, id, id);
@property (strong, nonatomic) id observed;
@property (strong, nonatomic) NSString *keyPath;
@property (weak, nonatomic) id observer;
@property (strong, nonatomic) NSString *keyAssociated;

@end

@implementation FSObserver

- (void)addObserver:(id)observer forObject:(id)observed andKeyPath:(NSString *)keyPath changeBlock:(void (^)(id, id, id))changeBlock
{
    self.observed = observed;
    self.keyPath = keyPath;
    self.changeBlock = changeBlock;
    self.observer = observer;
    self.keyAssociated = [[NSProcessInfo processInfo] globallyUniqueString];
    objc_setAssociatedObject(observer, [self.keyAssociated cStringUsingEncoding:NSUTF8StringEncoding], self, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    [observed addObserver:self forKeyPath:keyPath options:NSKeyValueObservingOptionNew|NSKeyValueObservingOptionOld context:nil];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSString *,id> *)change context:(void *)context
{
    self.changeBlock(self.observer, change[@"new"], change[@"old"]);
}

- (void)stop
{
    if (self.observer) {
        objc_setAssociatedObject(self.observer, [self.keyAssociated cStringUsingEncoding:NSUTF8StringEncoding], nil, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    }
    [self.observed removeObserver:self forKeyPath:self.keyPath];
    self.observed = nil;
    self.keyPath = nil;
    self.changeBlock = nil;
    self.observer = nil;
}

- (void)dealloc
{
    [self stop];
}

@end

@interface FSObserverManager ()

@property (strong, nonatomic) NSHashTable *observers;

@end

@implementation FSObserverManager

- (void)didLoad
{
    self.observers = [NSHashTable weakObjectsHashTable];
}

- (void)addObserver:(id)observer forObject:(id)observed andKeyPath:(NSString *)keyPath changeBlock:(void (^)(id, id, id))changeBlock
{
    FSObserver *obs = [FSObserver new];
    [obs addObserver:observer forObject:observed andKeyPath:keyPath changeBlock:changeBlock];
    [self.observers addObject:obs];
}

- (void)removeObserver:(id)observer
{
    NSHashTable *copyObservers = [self.observers copy];
    for (FSObserver *obs in copyObservers) {
        if (obs.observer == observer) {
            [obs stop];
            [self.observers removeObject:obs];
        }
    }
}

@end
