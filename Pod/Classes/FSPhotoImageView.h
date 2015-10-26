//
//  AvatarView.h
//  VoicePing
//
//  Created by Ferdly Sethio on 3/11/15.
//  Copyright (c) 2015 2359 Media Pte Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface FSPhotoImageView : UIImageView

@property (strong, nonatomic) void (^didChangeImage)(FSPhotoImageView *imageView);
@property (readonly, nonatomic) UIImage *photoImage;

@end
