//
//  FSKeychainManager.h
//  Pods
//
//  Created by Ferdly Sethio on 9/12/15.
//
//

#import "FSManager.h"

#define FSKeychainSave(obj, key) [[FSKeychainManager sharedManager] setObject:obj forKey:key]
#define FSKeychainLoad(key) [[FSKeychainManager sharedManager] objectForKey:key]
#define FSKeychainRemove(key) FSKeychainSave(nil, key)

@interface FSKeychainManager : FSManager

- (void)setObject:(id)object forKey:(NSString *)aKey;
- (id)objectForKey:(NSString *)aKey;
- (void)removeAllObjects;

@end
