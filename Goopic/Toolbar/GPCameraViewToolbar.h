//
//  GPCameraViewToolbar.h
//  Goopic
//
//  Created by andrei.marincas on 30/08/14.
//  Copyright (c) 2014 JUPITER. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GPButton.h"


#pragma mark - Toolbar Delegate

@protocol GPCameraViewToolbarDelegate <NSObject>

- (void)toolbar:(id)toolbar didSelectButton:(UIButton *)button;

@end


#pragma mark - Top Toolbar

@interface GPCameraViewTopToolbar : UIView

@property (nonatomic, weak) id <GPCameraViewToolbarDelegate> delegate;

@property (nonatomic, strong) UIImageView * flashImageView;
@property (nonatomic, strong) GPButton    * flashAutoButton;
@property (nonatomic, strong) GPButton    * flashOnButton;
@property (nonatomic, strong) GPButton    * flashOffButton;

- (instancetype)init;

- (void)updateUI;

- (void)selectFlashButtonForValue:(NSString *)value;

- (void)setButtonsRotation:(CGFloat)angle animated:(BOOL)animated;

@end


#pragma mark - Bottom Toolbar

@interface GPCameraViewBottomToolbar : UIView

@property (nonatomic, weak) id <GPCameraViewToolbarDelegate> delegate;

@property (nonatomic, strong) GPButton *cancelButton;
@property (nonatomic, strong) GPButton *takeButton;
@property (nonatomic, strong) GPButton *retakeButton;
@property (nonatomic, strong) GPButton *useButton;

- (instancetype)init;

- (void)updateUI;

// angle: radians
- (void)setButtonsRotation:(CGFloat)angle animated:(BOOL)animated;

@end
