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
    self.keys = [[NSMutableArray alloc] initWithArray:[self objectForKey:FSKeychainKeys]];
    [[FSAccountManager sharedManager] addDelegate:self];
}

- (FXKeychain *)keychain
{
    if (!_keychain) {
        _keychain = [FXKeychain defaultKeychain];
        if (![[NSUserDefaults standardUserDefaults] boolForKey:FSKeychainInstalled]) {
            [self removeAllObjects];
            [[NSUserDefaults standardUserDefaults] setBool:YES forKey:FSKeychainInstalled];
        }
    }
    return _keychain;
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

@interface FSSharedKeychainManager() {
    FXKeychain *_sharedKeychain;
}

@end

@implementation FSSharedKeychainManager

- (FXKeychain *)keychain
{
    if (!_sharedKeychain) {
        NSDictionary *query = [NSDictionary dictionaryWithObjectsAndKeys:
                               (__bridge NSString *)kSecClassGenericPassword, (__bridge NSString *)kSecClass,
                               @"bundleSeedID", kSecAttrAccount,
                               @"", kSecAttrService,
                               (id)kCFBooleanTrue, kSecReturnAttributes,
                               nil];
        CFDictionaryRef result = nil;
        OSStatus status = SecItemCopyMatching((__bridge CFDictionaryRef)query, (CFTypeRef *)&result);
        if (status == errSecItemNotFound)
            status = SecItemAdd((__bridge CFDictionaryRef)query, (CFTypeRef *)&result);
        if (status == errSecSuccess) {
            NSString *accessGroup = [(__bridge NSDictionary *)result objectForKey:(__bridge NSString *)kSecAttrAccessGroup];
            NSMutableArray *components = [accessGroup componentsSeparatedByString:@"."];
            if (components.count > 1) {
                [components removeObjectAtIndex:0];
                NSString *accessGroupBundleID = [components componentsJoinedByString:@"."];
                NSString *bundleID = [[NSBundle mainBundle] objectForInfoDictionaryKey:(NSString *)kCFBundleIdentifierKey];
                if (![accessGroupBundleID isEqualToString:bundleID]) {
                    _sharedKeychain = [[FXKeychain alloc] initWithService:accessGroup accessGroup:accessGroup];
                }
            }
        }
        if (!_sharedKeychain) {
            _sharedKeychain = super.keychain;
        }
    }
    return _sharedKeychain;
}

- (void)accountManagerDidLoggedOut:(id)userInfo
{
    
}

@end
