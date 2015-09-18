//
//  FSEFirstController.m
//  FSExample
//
//  Created by Ferdly Sethio on 9/9/15.
//  Copyright (c) 2015 Ferdly Sethio. All rights reserved.
//

#import "FSEFirstController.h"
#import "FSESecondController.h"

@implementation FSEFirstController

- (IBAction)gotoSecondController:(id)sender
{
    FSESecondController *secondController = [FSESecondController fs_newController];
    [self.navigationController pushViewController:secondController animated:YES];
}

@end
