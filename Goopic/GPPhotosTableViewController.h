//
//  GPPhotosTableViewController.h
//  Goopic
//
//  Created by andrei.marincas on 25/08/14.
//  Copyright (c) 2014 JUPITER. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GPPhoto.h"
#import "GPLine.h"


@class GPRootViewController;


#pragma mark - Photo Cell

@interface GPPhotoCell : UITableViewCell
{
    NSMutableArray *_photos; // @{ kPhotoKey : GPPhoto *, kThumbnailViewKey : UIImageView* }
}

@property (nonatomic, strong) NSArray *photos; // GPPhoto*

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier;

- (void)updateUI;

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

@interface GPPhotosTableViewController : UIViewController <UITableViewDataSource,
                                                           UITableViewDelegate,
                                                           UIScrollViewDelegate>

@property (nonatomic, strong) GPPhotosTableView *photosTableView;

@property (nonatomic, strong) NSArray *photosSections; // NSArray*'s of GPPhoto*

@property (nonatomic, weak) GPRootViewController *rootViewController;

@property (nonatomic) NSIndexPath *indexPathOfSelectedCell;
@property (nonatomic, readonly) UITableViewCell *selectedCell;

@property (nonatomic, strong) UIActivityIndicatorView *activityIndicator;

- (instancetype)init;

- (void)updateUI;

@end
