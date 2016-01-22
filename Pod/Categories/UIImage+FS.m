//
//  UIImage+FS.m
//  Pods
//
//  Created by Ferdly on 12/18/15.
//
//

#import "UIImage+FS.h"

@implementation UIImage (FS)

+ (UIImage *)fs_imageNamed:(NSString *)name
{
    static NSMutableDictionary *cache;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        cache = [NSMutableDictionary dictionary];
    });
    if (!name) {
        return nil;
    }
    if (!cache[name]) {
        UIImage *image = [UIImage imageNamed:name];
        if (image) {
            cache[name] = image;
        }
    }
    return cache[name];
}

- (UIImage *)fs_imageWithColor:(UIColor *)color
{
    UIGraphicsBeginImageContextWithOptions(self.size, NO, self.scale);
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextTranslateCTM(context, 0, self.size.height);
    CGContextScaleCTM(context, 1.0, -1.0);
    CGContextSetBlendMode(context, kCGBlendModeNormal);
    CGRect rect = CGRectMake(0, 0, self.size.width, self.size.height);
    CGContextClipToMask(context, rect, self.CGImage);
    [color setFill];
    CGContextFillRect(context, rect);
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return newImage;
}

@end
