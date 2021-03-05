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

- (void)toolbar:(GPToolbar *)toolbar didSelectButtonWithType:(GPToolbarButtonType)type;
- (void)toolbar:(GPToolbar *)toolbar didTapTitle:(UILabel *)titleLabel;

@end

@interface GPToolbar : UIView
{
    NSMutableArray *_leftButtons;
    NSMutableArray *_rightButtons;
}

@property (nonatomic, readonly) NSArray *buttons;

@property (nonatomic, strong) UIButton *middleButton;

@property (nonatomic, strong) UIButton *backButton;

@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic) NSString *title;

@property (nonatomic, strong) UILabel *dateLabel;
@property (nonatomic) NSString *date;

@property (nonatomic, strong) GPLine *line;

@property (nonatomic) GPPosition style; // top or bottom

@property (nonatomic, weak) id <GPToolbarDelegate> delegate;

// style: top or bottom
- (instancetype)initWithStyle:(GPPosition)style;

- (void)addButtonWithType:(GPToolbarButtonType)buttonType toLeftOrRight:(GPPosition)leftOrRight;

- (void)setMiddleButtonType:(GPToolbarButtonType)type;
- (void)setBackButtonType:(GPToolbarButtonType)type;

- (void)updateUI;

- (CGFloat)preferredHeight;

- (void)hideDate:(BOOL)animated;
- (void)hideDateAnimated;

- (void)showDate:(BOOL)animated;

@end
