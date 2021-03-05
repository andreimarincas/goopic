//
//  GPButton.h
//  Goopic
//
//  Created by andrei.marincas on 27/08/14.
//  Copyright (c) 2014 JUPITER. All rights reserved.
//

#import <UIKit/UIKit.h>


@class GPButton;


@interface GPButtonStateTransitionView : UIView

@property (nonatomic, strong) UILabel *label;
@property (nonatomic, strong) UIImageView *imageView;

- (instancetype)initWithButton:(GPButton *)button state:(UIControlState)state;

@end


@interface GPButton : UIButton

@property (nonatomic) BOOL forceHighlight;
@property (nonatomic) UIEdgeInsets hitTestEdgeInsets; // set positive values

@property (nonatomic) BOOL animateHighlightStateChange;
@property (nonatomic, strong) GPButtonStateTransitionView *viewForNormalState;
@property (nonatomic, strong) GPButtonStateTransitionView *viewForHighlightState;

@property (nonatomic, weak) GPButton *connectedButton;

@property (nonatomic) BOOL smallButton;

- (instancetype)init;

- (void)connectTo:(GPButton *)button;

@end
