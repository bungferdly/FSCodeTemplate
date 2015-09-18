//
//  FSKeychainManager.m
//  Pods
//
//  Created by Ferdly Sethio on 9/12/15.
//
//

#import "FSKeychainManager.h"
#import <FXKeychain/FXKeychain.h>

NSString * const kFSRegisteredKeys = @"kFSRegisteredKeys";

@interface FSKeychainManager()

@property (strong, nonatomic) NSMutableArray *keys;
@property (strong, nonatomic) FXKeychain *keychain;

@end

@implementation FSKeychainManager

- (NSString *)keychainGroup
{
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
    if (status != errSecSuccess)
        return [[NSBundle mainBundle] bundleIdentifier];
    NSString *accessGroup = [(__bridge NSDictionary *)result objectForKey:(__bridge NSString *)kSecAttrAccessGroup];
    CFRelease(result);
    return accessGroup;
}

- (void)didLoad
{
    NSString *keychainGroup = [self keychainGroup];
    self.keychain = [[FXKeychain alloc] initWithService:keychainGroup accessGroup:keychainGroup];
    self.keys = [[NSMutableArray alloc] initWithArray:[self objectForKey:kFSRegisteredKeys]];
}

- (id)objectForKey:(NSString *)aKey
{
    id data = [self.keychain objectForKey:aKey];
    if ([data isKindOfClass:[NSData class]]) {
        data = [NSKeyedUnarchiver unarchiveObjectWithData:data];
    }
    if (![self.keys containsObject:aKey]) {
        [self.keys addObject:aKey];
        [self setObject:self.keys forKey:kFSRegisteredKeys];
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
}

@end
