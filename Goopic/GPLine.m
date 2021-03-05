//
//  GPLine.m
//  Goopic
//
//  Created by andrei.marincas on 25/08/14.
//  Copyright (c) 2014 JUPITER. All rights reserved.
//

#import "GPLine.h"

@implementation GPLine

- (instancetype)init
{
    self = [super init];
    
    if (self)
    {
        [self initialize];
    }
    
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    
    if (self)
    {
        [self initialize];
    }
    
    return self;
}

- (void)initialize
{
    self.backgroundColor = [UIColor clearColor];
    self.opaque = NO;
    self.userInteractionEnabled = NO;
    
    self.linePosition = LinePositionMiddle;
    self.lineWidth = 1.0f;
    self.lineColor = [UIColor blackColor];
    self.lineStyle = LineStyleContinuous;
    self.dashLength = 10;
}

- (void)drawRect:(CGRect)rect
{
    [super drawRect:rect];
    
    CGContextRef ctx = UIGraphicsGetCurrentContext();
    CGContextSaveGState(ctx);
    
    CGContextSetLineCap(ctx, kCGLineCapRound);
    CGContextSetLineWidth(ctx, self.lineWidth);
    
    CGContextSetStrokeColorWithColor(ctx, [self.lineColor CGColor]);
    
    switch (self.lineStyle)
    {
        case LineStyleContinuous:
        {
            CGContextSetLineDash(ctx, 0, NULL, 0);
        }
            break;
            
        case LineStyleInterrupted:
        {
            const CGFloat lengths[] = { self.dashLength, self.dashLength };
            CGContextSetLineDash(ctx, 0, lengths, 2);
        }
            break;
            
        default:
            break;
    }
    
    CGContextBeginPath(ctx);
    
    switch (self.linePosition)
    {
        case LinePositionTop:
        {
            CGContextMoveToPoint(ctx, 0, self.lineWidth / 2);
            CGContextAddLineToPoint(ctx, self.frame.size.width, self.lineWidth / 2);
        }
            break;
            
        case LinePositionMiddle:
        {
//            CGContextMoveToPoint(ctx, 1.25f, (int)self.frame.size.height / 2 + .25f);
//            CGContextAddLineToPoint(ctx, self.frame.size.width - 1.25f, (int)self.frame.size.height / 2 + .25f);
            
            CGContextMoveToPoint(ctx, 0.0f, (int)(self.frame.size.height / 2) + 0.25f);
            CGContextAddLineToPoint(ctx, self.frame.size.width, (int)(self.frame.size.height / 2) + 0.25f);
        }
            break;
            
        case LinePositionBottom:
        {
//            CGContextMoveToPoint(ctx, 0.25f, self.frame.size.height - 0.25f);
//            CGContextAddLineToPoint(ctx, self.frame.size.width - 0.25f, self.frame.size.height - 0.25f);
            
            CGContextMoveToPoint(ctx, 0, self.frame.size.height - self.lineWidth / 2);
            CGContextAddLineToPoint(ctx, self.frame.size.width, self.frame.size.height - self.lineWidth / 2);
            
            GPLog(@"bottom point y: %f for line width: %f", (self.frame.size.height - self.lineWidth / 2), self.lineWidth);
        }
            break;
            
        case LinePositionLeft:
        {
            CGContextMoveToPoint(ctx, 1.25f, 1.25f);
            CGContextAddLineToPoint(ctx, 1.25f, self.frame.size.height - 1.25f);
        }
            break;
            
        case LinePositionCenter:
        {
            CGContextMoveToPoint(ctx, (int)self.frame.size.width / 2 + .25f, 1.25f);
            CGContextAddLineToPoint(ctx, (int)self.frame.size.width / 2 + .25f, self.frame.size.height - 1.25f);
        }
            break;
            
        case LinePositionRight:
        {
            CGContextMoveToPoint(ctx, self.frame.size.width - 1.25f, 1.25f);
            CGContextAddLineToPoint(ctx, self.frame.size.width - 1.25f, self.frame.size.height - 1.25f);
        }
            break;
            
        default:
            break;
    }
    
    CGContextStrokePath(ctx);
    CGContextRestoreGState(ctx);
}

@end
