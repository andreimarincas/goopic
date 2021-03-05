//
//  UIImageView+Extension.m
//  Goopic
//
//  Created by andrei.marincas on 02/09/14.
//  Copyright (c) 2014 JUPITER. All rights reserved.
//

#import "UIImageView+Extension.h"

@implementation UIImageView (Extension)

- (CGRect)frameThatFitsImageSize:(CGSize)imageSize
{
    CGRect frame = CGRectZero;
    
    if ((imageSize.width > 0) && (imageSize.height > 0) && (self.frame.size.width > 0) && (self.frame.size.height > 0))
    {
        CGFloat r = imageSize.width / imageSize.height;
        CGFloat R = self.frame.size.width / self.frame.size.height;
        
        if (r == R) // equal
        {
            frame = self.bounds;
        }
        else
        {
            if (self.contentMode == UIViewContentModeScaleAspectFit)
            {
                if (r < R) // portrait
                {
                    CGSize actualImageSize = CGSizeMake(r * self.frame.size.height, self.frame.size.height);
                    frame = CGRectMake((self.frame.size.width - actualImageSize.width) / 2, 0, actualImageSize.width, actualImageSize.height);
                }
                else // r > R (landscape)
                {
                    CGSize actualImageSize = CGSizeMake(self.frame.size.width, self.frame.size.width / r);
                    frame = CGRectMake(0, (self.frame.size.height - actualImageSize.height) / 2, actualImageSize.width, actualImageSize.height);
                }
            }
            else if (self.contentMode == UIViewContentModeScaleAspectFill)
            {
                if (r < R) // portrait
                {
                    CGSize actualImageSize = CGSizeMake(self.frame.size.width, self.frame.size.width / r);
                    frame = CGRectMake(0, (self.frame.size.height - actualImageSize.height) / 2, actualImageSize.width, actualImageSize.height);
                }
                else // r > R (landscape)
                {
                    CGSize actualImageSize = CGSizeMake(r * self.frame.size.height, self.frame.size.height);
                    frame = CGRectMake((self.frame.size.width - actualImageSize.width) / 2, 0, actualImageSize.width, actualImageSize.height);
                }
            }
        }
    }
    
    return frame;
}

- (void)sizeToFitImageSize:(CGSize)imageSize
{
    CGRect actualImageFrame = [self frameThatFitsImageSize:imageSize];
    CGSize actualImageSize = actualImageFrame.size;
    CGPoint center = self.center;
    self.frame = CGRectMake(0, 0, actualImageSize.width, actualImageSize.height);
    self.center = center;
}

@end
