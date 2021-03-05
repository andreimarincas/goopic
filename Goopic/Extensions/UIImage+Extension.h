//
//  UIImage+Extension.h
//  Goopic
//
//  Created by andrei.marincas on 27/08/14.
//  Copyright (c) 2014 JUPITER. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIImage (Extension)

// scale : [0, 1]
+ (UIImage *)imageWithImage:(UIImage *)image scale:(CGFloat)scale;

@end
