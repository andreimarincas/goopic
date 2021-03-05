//
//  GPPhotosTableViewToolbar.h
//  Goopic
//
//  Created by andrei.marincas on 30/08/14.
//  Copyright (c) 2014 JUPITER. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GPButton.h"
#import "GPLine.h"

#pragma mark - Toolbar Delegate

@class GPPhotosTableViewToolbar;

@protocol GPPhotosTableViewToolbarDelegate <NSObject>

- (void)toolbar:(GPPhotosTableViewToolbar *)toolbar didSelectButton:(UIButton *)button;
- (void)toolbarDidTapTitle:(GPPhotosTableViewToolbar *)toolbar;

@end


#pragma mark - Toolbar

@interface GPPhotosTableViewToolbar : UIView

@property (nonatomic, weak) id <GPPhotosTableViewToolbarDelegate> delegate;

@property (nonatomic, strong) GPLine *line;

@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic) NSString *title;

@property (nonatomic, strong) UILabel *dateLabel;
@property (nonatomic) NSString *date;

@property (nonatomic, strong) GPButton *cameraButton;

- (instancetype)init;

- (void)updateUI;

- (void)hideDate:(BOOL)animated;
- (void)hideDateAnimated;

- (void)showDate:(BOOL)animated;

@end
