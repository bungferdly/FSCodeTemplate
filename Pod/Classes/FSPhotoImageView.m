//
//  AvatarView.m
//  VoicePing
//
//  Created by Ferdly Sethio on 3/11/15.
//  Copyright (c) 2015 2359 Media Pte Ltd. All rights reserved.
//

#import "FSPhotoImageView.h"
#import "UIViewController+FS.h"
#import <SDWebImage/UIImageView+WebCache.h>
#import "FSAlertController.h"

@interface FSPhotoImageView()<UIImagePickerControllerDelegate,UINavigationControllerDelegate>

@property (strong, nonatomic) UIControl *changeImageControl;
@property (strong, nonatomic) UIImage *photoImage;

@end

@implementation FSPhotoImageView

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    
    self.changeImageControl = [[UIControl alloc] init];
    self.changeImageControl.frame = self.bounds;
    self.changeImageControl.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
    self.changeImageControl.backgroundColor = [UIColor clearColor];
    [self.changeImageControl addTarget:self action:@selector(showActionSheet) forControlEvents:UIControlEventTouchUpInside];
    [self.changeImageControl addTarget:self action:@selector(touchUp) forControlEvents:UIControlEventTouchUpOutside | UIControlEventTouchUpInside | UIControlEventTouchDragExit];
    [self.changeImageControl addTarget:self action:@selector(touchDown) forControlEvents:UIControlEventTouchDown | UIControlEventTouchDragEnter];
    [self addSubview:self.changeImageControl];
    
    return self;
}

- (void)setImage:(UIImage *)image
{
    [super setImage:image];
    self.photoImage = nil;
}

- (void)touchDown
{
    self.changeImageControl.backgroundColor = [UIColor colorWithWhite:0 alpha:0.3];
}

- (void)touchUp
{
    [UIView animateWithDuration:0.1 animations:^{
        self.changeImageControl.backgroundColor = [UIColor clearColor];
    }];
}

- (void)showActionSheet
{
    [FSAlertController showWithTitle:nil message:nil cancelButtonTitle:NSLocalizedString(@"Cancel", nil) destructiveButtonTitle:nil
                   otherButtonTitles:@[NSLocalizedString(@"Take Photo", nil), NSLocalizedString(@"Choose From Gallery", nil)]
                           container:self tapBlock:^(FSAlertController * _Nonnull controller, NSInteger buttonIndex) {
                               if (buttonIndex == controller.firstOtherButtonIndex) {
                                   [self showImagePicker:UIImagePickerControllerSourceTypeCamera];
                               } else if (buttonIndex == controller.firstOtherButtonIndex + 1) {
                                   [self showImagePicker:UIImagePickerControllerSourceTypePhotoLibrary];
                               }
                           }];
}

- (void)showImagePicker:(UIImagePickerControllerSourceType)sourceType
{
    UIImagePickerController *picker = [[UIImagePickerController alloc] init];
    picker.delegate = self;
    picker.allowsEditing = YES;
    picker.sourceType = sourceType;
    
    [[UIViewController fs_topViewController] presentViewController:picker animated:YES completion:NULL];
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    self.image = info[UIImagePickerControllerEditedImage];
    self.photoImage = self.image;
    [picker dismissViewControllerAnimated:YES completion:NULL];
    
    if (self.didChangeImage) {
        self.didChangeImage(self);
    }
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    [picker dismissViewControllerAnimated:YES completion:NULL];
}

@end
