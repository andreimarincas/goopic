//
//  GPLine.h
//  Goopic
//
//  Created by andrei.marincas on 25/08/14.
//  Copyright (c) 2014 JUPITER. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef enum : NSUInteger
{
    LinePositionTop = 0,
    LinePositionMiddle,
    LinePositionBottom,
    LinePositionLeft,
    LinePositionCenter,
    LinePositionRight
} LinePosition;

typedef enum : NSUInteger
{
    LineStyleContinuous = 0,
    LineStyleInterrupted
} LineStyle;


@interface GPLine : UIView

@property (nonatomic)           LinePosition      linePosition;
@property (nonatomic)           CGFloat           lineWidth;
@property (nonatomic, strong)   UIColor         * lineColor;
@property (nonatomic)           LineStyle         lineStyle;
@property (nonatomic)           CGFloat           dashLength;

- (instancetype)init;
- (instancetype)initWithFrame:(CGRect)frame;

@end
