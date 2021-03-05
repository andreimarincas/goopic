//
//  GPTableToPhotoTransition.h
//  Goopic
//
//  Created by Andrei Marincas on 01/09/14.
//  Copyright (c) 2014 JUPITER. All rights reserved.
//

#import "GPBaseTransition.h"

@class GPPhotoViewController;
@class GPPhotosTableViewController;
@class GPPhotosTableViewToolbar;
@class GPPhotoViewTopToolbar;
@class GPPhotoViewBottomToolbar;
@class GPButton;
@class GPPhotoCell;


#pragma mark - Table to Photo transition

@interface GPTableToPhotoTransition : GPBaseTransition

// Designated initializer
- (instancetype)init;

@end


#pragma mark - Interactive Table to Photo transition

@interface GPInteractiveTableToPhotoTransition : GPTableToPhotoTransition <UIViewControllerInteractiveTransitioning,
                                                                           UIGestureRecognizerDelegate>
{
    /* interactive transition */
    
    UIView *_viewForInteraction;
    
    UIPanGestureRecognizer *_panGestureRecognizer;
    
    CGPoint _initialPanningLocation;
    CGPoint _initialPanningLocationWithContext;
    
    CGPoint _currentPanningLocation;
    
    id <UIViewControllerContextTransitioning> _context;
    CGFloat _percentCompleted; // [0,1]
    CGFloat _highestPercent;
    
    BOOL _shouldDismissPhotoViewControllerWithoutInteraction;
    
    
    /* ui elements */
    
    GPPhotoViewTopToolbar    *_photoViewTopToolbar;
    GPPhotoViewBottomToolbar *_photoViewBottomToolbar;
    
    GPPhotosTableViewToolbar *_photosTableViewToolbar;
    
    BOOL         _photoToolbarsAreHidden;
    UIColor     *_photoViewTopToolbarInitialColor;
    UIColor     *_photoViewControllerInitialColor;
    UIView      *_transportedView;
    CGRect       _transportedViewInitialFrame;
    CGRect       _transportedViewToFrame;
    UIImageView *_photoView;
    CGRect       _photoViewInitialFrame;
    CGRect       _photoViewToFrame;
    UIView      *_blackOverlay;
    GPButton    *_photosButton;
    CGPoint      _photosButtonInitialCenter;
    UILabel     *_titleLabel;
    CGPoint      _titleLabelInitialCenter;
    GPPhotoCell *_selectedCell;
    NSInteger    _selectedPhotoIndex;
}

@property (nonatomic, strong) UIView *viewForInteraction;

@property (nonatomic, getter = isInteractive) BOOL interactive; // gesture has began/ended
@property (nonatomic, readonly) CGFloat percentCompleted;

@property (nonatomic, weak) GPPhotosTableViewController *photosTableViewController;
@property (nonatomic, weak) GPPhotoViewController *photoViewController;

// Designated initializer
- (instancetype)init;

@end
