//
//  FSManager.h
//  Pods
//
//  Created by Ferdly Sethio on 9/9/15.
//
//

#import <UIKit/UIKit.h>

@interface FSManager : UIResponder <UIApplicationDelegate>

@property (readonly, nonatomic) NSHashTable *delegates;

+ (instancetype)sharedManager;
+ (NSArray *)allManagers;

- (void)addDelegate:(id)delegate;
- (void)removeDelegate:(id)delegate;

@end

@interface FSManager(override)

- (void)didLoad;

@end
