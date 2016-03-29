//
//  FSObserverManager.h
//  Pods
//
//  Created by Ferdly on 3/10/16.
//
//

#import <FSCodeTemplate/FSCodeTemplate.h>

#define FSObserve(object, key, changes) [[FSObserverManager sharedManager] addObserver:self forObject:object andKeyPath:key changeBlock:^(typeof(self) self, id value, id oldValue) {changes;}];
#define FSObserveRemove() [[FSObserverManager sharedManager] removeObserver:self];

@interface FSObserverManager : FSManager

- (void)addObserver:(id)observer forObject:(id)observed andKeyPath:(NSString *)keyPath changeBlock:(void(^)(id self, id value, id oldValue))changeBlock;
- (void)removeObserver:(id)observer;

@end
