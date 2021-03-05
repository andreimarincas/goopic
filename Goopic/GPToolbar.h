//
//  GPToolbar.h
//  Goopic
//
//  Created by andrei.marincas on 24/08/14.
//  Copyright (c) 2014 JUPITER. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GPLine.h"


@class GPToolbar;


@protocol GPToolbarDelegate <NSObject>

- (void)toolbar:(GPToolbar *)toolbar didSelectButton:(UIButton *)button;

@end

@interface GPToolbar : UIView
{
    NSMutableArray *_leftButtons;
    NSMutableArray *_rightButtons;
}

@property (nonatomic, readonly) NSArray *buttons;

@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic) NSString *title;

@property (nonatomic, strong) GPLine *line;

@property (nonatomic) GPPosition style; // top or bottom

// style: top or bottom
- (instancetype)initWithStyle:(GPPosition)style;

- (void)addButtonWithType:(GPToolbarButtonType)buttonType toLeftOrRight:(GPPosition)leftOrRight;

- (void)updateUI;

+ (CGFloat)preferredHeight;

@end
