//
//  FSKeychainManager.m
//  Pods
//
//  Created by Ferdly Sethio on 9/12/15.
//
//

#import "FSKeychainManager.h"
#import <FXKeychain/FXKeychain.h>
#import "FSAccountManager.h"

NSString * const FSKeychainKeys = @"FSKeychainKeys";
NSString * const FSKeychainInstalled = @"FSKeychainInstalled";

@interface FSKeychainManager() <FSAccountManagerDelegate>

@property (strong, nonatomic) NSMutableArray *keys;
@property (strong, nonatomic) FXKeychain *keychain;

@end

@implementation FSKeychainManager

- (void)didLoad
{
    self.keychain = [FXKeychain defaultKeychain];
    self.keys = [[NSMutableArray alloc] initWithArray:[self objectForKey:FSKeychainKeys]];
    
    if (![[NSUserDefaults standardUserDefaults] boolForKey:FSKeychainInstalled]) {
        [self removeAllObjects];
        [[NSUserDefaults standardUserDefaults] setBool:YES forKey:FSKeychainInstalled];
    }
    
    [[FSAccountManager sharedManager] addDelegate:self];
}

- (id)objectForKey:(NSString *)aKey
{
    id data = [self.keychain objectForKey:aKey];
    if ([data isKindOfClass:[NSData class]]) {
        data = [NSKeyedUnarchiver unarchiveObjectWithData:data];
    }
    if (![self.keys containsObject:aKey]) {
        [self.keys addObject:aKey];
        [self setObject:self.keys forKey:FSKeychainKeys];
    }
    return data;
}

- (void)setObject:(id)object forKey:(NSString *)aKey
{
    if (!object) {
        if ([self.keys containsObject:aKey]) {
            [self.keys removeObject:aKey];
            [self setObject:self.keys forKey:aKey];
        }
        [self.keychain removeObjectForKey:aKey];
    } else {
        if (![self.keys containsObject:aKey]) {
            [self.keys addObject:aKey];
            [self setObject:self.keys forKey:aKey];
        }
        if ([object isKindOfClass:[NSArray class]] || [object isKindOfClass:[NSDictionary class]]) {
            object = [NSKeyedArchiver archivedDataWithRootObject:object];
        }
        [self.keychain setObject:object forKey:aKey];
    }
}

- (void)removeAllObjects
{
    for (NSString *key in self.keys) {
        [self.keychain removeObjectForKey:key];
    }
    [self.keys removeAllObjects];
    [self.keychain removeObjectForKey:FSKeychainKeys];
}

- (void)accountManagerDidLoggedOut:(id)userInfo
{
    [self removeAllObjects];
}

@end
