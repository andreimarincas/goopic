//
//  GPPhotosTableViewController.h
//  Goopic
//
//  Created by andrei.marincas on 25/08/14.
//  Copyright (c) 2014 JUPITER. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GPPhoto.h"
#import "GPPhotosTableViewToolbar.h"
#import "GPBaseViewController.h"


#pragma mark - Photo Cell

@interface GPPhotoCell : UITableViewCell
{
    NSMutableArray *_photos; // @{ kPhotoKey : GPPhoto *, kThumbnailViewKey : UIImageView * }
}

@property (nonatomic, strong) NSArray *photos; // GPPhoto*

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier;

- (void)updateUI;

- (CGRect)frameForPhotoAtIndex:(NSInteger)index;

- (void)setThumbnailHidden:(BOOL)hidden atIndex:(NSInteger)index;

@end


#pragma mark - Photos Header View

@interface GPPhotosHeaderView : UITableViewHeaderFooterView

@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic, strong) GPLine *line;

@property (nonatomic) NSString *title;

- (instancetype)initWithReuseIdentifier:(NSString *)reuseIdentifier;

- (void)updateUI;

@end


#pragma mark - Photos Footer View

@interface GPPhotosFooterView : UITableViewHeaderFooterView

- (instancetype)initWithReuseIdentifier:(NSString *)reuseIdentifier;

- (void)updateUI;

@end


#pragma mark - Photos Table View

@interface GPPhotosTableView : UITableView

- (instancetype)init;

@end


#pragma mark - Photos Table View Controller

@interface GPPhotosTableViewController : GPBaseViewController <UITableViewDataSource,
                                                               UITableViewDelegate,
                                                               UIScrollViewDelegate,
                                                               UIViewControllerTransitioningDelegate,
                                                               GPPhotosTableViewToolbarDelegate>
{
    NSInteger _photosCountPerCellOnViewWillDisappear;
    NSMutableArray *_thumbnailViewsForInterfaceOrientation;
}

@property (nonatomic, strong) GPPhotosTableView *photosTableView;

@property (nonatomic, strong) GPPhotosTableViewToolbar *toolbar;

@property (nonatomic, strong) NSArray *photosSections; // NSArray*'s of GPPhoto*

@property (nonatomic) NSInteger selectedPhotoIndex;
@property (nonatomic) NSIndexPath *selectedIndexPath;
@property (nonatomic, readonly) UITableViewCell *selectedCell;

- (instancetype)init;

- (void)updateUI;

- (CGRect)frameForPhotoAtIndexPath:(NSIndexPath *)indexPath photoIndex:(NSInteger)photoIndex;

@end
