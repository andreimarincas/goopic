//
//  CALayer+Extension.h
//  Goopic
//
//  Created by andrei.marincas on 06/09/14.
//  Copyright (c) 2014 JUPITER. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>

@interface CALayer (Extension)

+ (void)performWithoutAnimation:(Block)actionsWithoutAnimation;
- (void)bringSublayerToFront:(CALayer *)layer;

@end
