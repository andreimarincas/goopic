//
//  GPPhotoViewToolbar.h
//  Goopic
//
//  Created by andrei.marincas on 30/08/14.
//  Copyright (c) 2014 JUPITER. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GPButton.h"
#import "GPLine.h"


#pragma mark - Toolbar Delegate

@protocol GPPhotoViewToolbarDelegate <NSObject>

- (void)toolbar:(id)toolbar didSelectButton:(UIButton *)button;

@end


#pragma mark - Top Toolbar

@interface GPPhotoViewTopToolbar : UIView

@property (nonatomic, weak) id <GPPhotoViewToolbarDelegate> delegate;

@property (nonatomic, strong) GPLine *line;

@property (nonatomic, strong) GPButton *photosButton;
@property (nonatomic, strong) GPButton *disclosureButton;
@property (nonatomic, strong) GPButton *cameraButton;

- (instancetype)init;

- (void)updateUI;

@end


#pragma mark - Bottom Toolbar

@interface GPPhotoViewBottomToolbar : UIView

@property (nonatomic, weak) id <GPPhotoViewToolbarDelegate> delegate;

@property (nonatomic, strong) GPLine *line;

@property (nonatomic, strong) GPButton *searchButton;
@property (nonatomic, strong) GPButton *cancelButton;

- (instancetype)init;

- (void)updateUI;

@end
