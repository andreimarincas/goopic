//
//  UIImageView+Extension.h
//  Goopic
//
//  Created by andrei.marincas on 02/09/14.
//  Copyright (c) 2014 JUPITER. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIImageView (Extension)

- (CGRect)frameThatFitsImageSize:(CGSize)imageSize;

- (void)sizeToFitImageSize:(CGSize)imageSize;

@end
