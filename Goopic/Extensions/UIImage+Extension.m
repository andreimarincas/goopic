//
//  UIImage+Extension.m
//  Goopic
//
//  Created by andrei.marincas on 27/08/14.
//  Copyright (c) 2014 JUPITER. All rights reserved.
//

#import "UIImage+Extension.h"

@implementation UIImage (Extension)

+ (UIImage *)imageWithImage:(UIImage *)image scale:(CGFloat)scale
{
    GPLogIN();
    
    if (!image || scale < 0)
    {
        GPLogWarn(@"Cannot scale image: %@ to scale factor: %f", [image description], scale);
        
        GPLogOUT();
        return nil;
    }
    
    if (scale == 1)
    {
        GPLogOUT();
        return [UIImage imageWithCGImage:image.CGImage];
    }
    
    CGSize newSize = CGSizeIntegral(CGSizeMake(scale * image.size.width, scale * image.size.height));
    UIGraphicsBeginImageContext(CGSizeMake(newSize.width, newSize.height));
    [image drawInRect:CGRectMake(0, 0, newSize.width, newSize.height)];
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return newImage;
    GPLogOUT();
}

@end
