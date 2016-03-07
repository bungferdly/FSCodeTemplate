//
//  FSImageController.h
//  Test
//
//  Created by Ferdly on 2/16/16.
//  Copyright © 2016 Ferdly. All rights reserved.
//

#import "FSPageController.h"

@interface FSImageController : FSPageController

@property (strong, nonatomic) NSArray *images; //can be NSString, NSURL, or UIImage

- (void)presentFromViewController:(UIViewController *)controller andImageView:(UIImageView *)imageView;

@end

@interface FSImageChildController : UIViewController

@property (strong, nonatomic) IBOutlet UIScrollView *scrollView;
@property (strong, nonatomic) IBOutlet UIImageView *imageView;

@end
