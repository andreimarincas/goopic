//
//  GPPhotosTableViewController.m
//  Goopic
//
//  Created by andrei.marincas on 25/08/14.
//  Copyright (c) 2014 JUPITER. All rights reserved.
//

#import <AssetsLibrary/AssetsLibrary.h>
#import "GPPhotosTableViewController.h"
#import "GPAssetsManager.h"
#import "GPPhotoViewController.h"
#import "GPCameraViewController.h"
#import "GPSearchEngine.h"
#import "GPFadeTransition.h"
#import "GPTableToPhotoTransition.h"

static NSString * const kPhotoCellID                    = @"PhotoCell";
static NSString * const kPhotosHeaderID                 = @"PhotosHeader";
static NSString * const kPhotosFooterID                 = @"PhotosFooter";

static CGFloat          sThumbnailDimension             = 60.0f;
static const CGFloat    kPhotosSpacing                  = 2.0f; // 0.0f;

static const NSInteger  kPhotosCountPerCell_Portrait    = 5;
static const NSInteger  kPhotosCountPerCell_Landscape   = 9;

static NSString * const kPhotoKey                       = @"photo";
static NSString * const kThumbnailViewKey               = @"thumbnailView";

static const CGFloat    kPhotosHeaderHeight             = 0.1; // 30.0f;
static const CGFloat    kPhotosFooterHeight             = 0.1;

static const NSTimeInterval kTitleVisibilityTimeout = 0.1f;


#pragma mark -
#pragma mark - Photo Cell

@implementation GPPhotoCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    
    if (self)
    {
        // Custom initialization
        
        self.contentView.backgroundColor = GPCOLOR_BLACK;
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        
        _photos = [NSMutableArray array];
    }
    
    return self;
}

- (void)setPhotos:(NSArray *)photos
{
    for (id photoData in _photos)
    {
        UIImageView *thumbnailView = photoData[kThumbnailViewKey];
        [thumbnailView removeFromSuperview];
    }
    
    _photos = [NSMutableArray arrayWithCapacity:[photos count]];
    
    for (GPPhoto *photo in photos)
    {
        UIImageView *thumbnailView = [[UIImageView alloc] init];
        thumbnailView.image = [photo thumbnailImage];
        thumbnailView.userInteractionEnabled = NO;
        [self.contentView addSubview:thumbnailView];
        
        id photoData = @{ kPhotoKey : photo, kThumbnailViewKey : thumbnailView };
        [_photos addObject:photoData];
    }
    
    [self updateUI];
}

- (NSArray *)photos
{
    NSMutableArray *gpPhotos = [NSMutableArray arrayWithCapacity:[_photos count]];
    
    for (id photoData in _photos)
    {
        [gpPhotos addObject:photoData[kPhotoKey]];
    }
    
    return gpPhotos;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    self.contentView.frame = self.bounds;
    [self updateUI];
}

- (void)updateUI
{
    for (NSInteger i = 0; i < [_photos count]; i++)
    {
        id photoData = _photos[i];
        UIImageView *thumbnailView = photoData[kThumbnailViewKey];
        
        thumbnailView.frame = CGRectMake(kPhotosSpacing + i * (sThumbnailDimension + kPhotosSpacing),
                                         kPhotosSpacing / 2,
                                         sThumbnailDimension,
                                         sThumbnailDimension);
        
        [thumbnailView setNeedsDisplay];
    }
    
    [self setNeedsDisplay];
}

- (CGRect)frameForPhotoAtIndex:(NSInteger)index
{
    CGRect photoFrame = CGRectZero;
    
    if ((index >= 0) && (index < [_photos count]))
    {
        id photoData = _photos[index];
        UIImageView *thumbnailView = photoData[kThumbnailViewKey];
        photoFrame = thumbnailView.frame;
    }
    
    return photoFrame;
}

@end


#pragma mark -
#pragma mark - Photos Header View

@implementation GPPhotosHeaderView

- (instancetype)initWithReuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithReuseIdentifier:reuseIdentifier];
    
    if (self)
    {
        // Custom initialization
        
        self.contentView.backgroundColor = GPCOLOR_BLACK;
        
        UILabel *titleLabel = [[UILabel alloc] init];
        titleLabel.textAlignment = NSTextAlignmentRight;
        titleLabel.font = [UIFont fontWithName:@"TimesNewRomanPSMT" size:16.0f];
        titleLabel.textColor = [UIColor blackColor];
        titleLabel.backgroundColor = [UIColor clearColor];
        [self.contentView addSubview:titleLabel];
        self.titleLabel = titleLabel;
        
        GPLine *line = [[GPLine alloc] init];
        line.lineColor = [UIColor colorWithWhite:0.5 alpha:1];
        line.linePosition = LinePositionBottom;
        line.lineStyle = LineStyleContinuous;
        line.lineWidth = 0.25f;
        self.line = line;
    }
    
    return self;
}

- (void)dealloc
{
    // Dealloc code
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    self.contentView.frame = self.bounds;
    [self updateUI];
}

- (void)updateUI
{
    [self.titleLabel sizeToFit];
    
    const CGFloat marginRight = 10.0f;
    
    self.titleLabel.center = CGPointMake(self.contentView.bounds.size.width - self.titleLabel.bounds.size.width / 2 - marginRight,
                                         self.contentView.bounds.size.height / 2);
    
    CGFloat titleLabelBottom = self.titleLabel.frame.origin.y + self.titleLabel.frame.size.height;
    
    self.line.frame = CGRectMake(self.titleLabel.frame.origin.x,
                                 self.titleLabel.frame.origin.y,
                                 self.titleLabel.frame.size.width,
                                 self.titleLabel.frame.size.height + (self.bounds.size.height - titleLabelBottom) / 2);
    
    [self.titleLabel setNeedsDisplay];
    [self.line setNeedsDisplay];
    [self setNeedsDisplay];
}

- (NSString *)title
{
    return self.titleLabel.text;
}

- (void)setTitle:(NSString *)title
{
    self.titleLabel.text = title;
    [self updateUI];
}

@end


#pragma mark -
#pragma mark - Photos Footer View

@implementation GPPhotosFooterView

- (instancetype)initWithReuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithReuseIdentifier:reuseIdentifier];
    
    if (self)
    {
        // Custom initialization
        self.contentView.backgroundColor = GPCOLOR_BLACK;
    }
    
    return self;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    self.contentView.frame = self.bounds;
    [self updateUI];
}

- (void)updateUI
{
    [self setNeedsDisplay];
}

@end


#pragma mark -
#pragma mark - Photos Table View

@implementation GPPhotosTableView

- (instancetype)init
{
    self = [super initWithFrame:CGRectZero style:UITableViewStyleGrouped];
    
    if (self)
    {
        // Custom initialization
        
        self.backgroundColor = GPCOLOR_BLACK;
        self.showsHorizontalScrollIndicator = NO;
        self.showsVerticalScrollIndicator = YES;
        self.allowsSelection = NO; // YES;
        self.allowsMultipleSelection = NO;
        self.separatorStyle = UITableViewCellSeparatorStyleNone;
        self.decelerationRate = UIScrollViewDecelerationRateNormal;
        self.scrollEnabled = YES;
        
        [self registerClass:[GPPhotoCell class] forCellReuseIdentifier:kPhotoCellID];
        [self registerClass:[GPPhotosHeaderView class] forHeaderFooterViewReuseIdentifier:kPhotosHeaderID];
        [self registerClass:[GPPhotosFooterView class] forHeaderFooterViewReuseIdentifier:kPhotosFooterID];
    }
    
    return self;
}

- (void)dealloc
{
    GPLogIN();
    
    // Dealloc code
    
    GPLogOUT();
}

@end


#pragma mark -
#pragma mark - Photos Table View Controller

@interface GPPhotosTableViewController ()

@property (atomic) NSMutableArray *photosFromLibrary;
@property (atomic) NSTimer *hideTitleTimer;

@end

@implementation GPPhotosTableViewController

#pragma mark - Init / Dealloc

- (instancetype)init
{
    self = [super init];
    
    if (self)
    {
        // Custom initialization
        
        self.automaticallyAdjustsScrollViewInsets = NO;
    }
    
    return self;
}

- (void)dealloc
{
    GPLogIN();
    
    // Dealloc code
    
    GPLogOUT();
}

#pragma mark - View Lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.view.backgroundColor = GPCOLOR_BLACK;
    
    GPPhotosTableView *photosTableView = [[GPPhotosTableView alloc] init];
    photosTableView.dataSource = self;
    photosTableView.delegate = self;
    [self.view addSubview:photosTableView];
    self.photosTableView = photosTableView;
    
    GPPhotosTableViewToolbar *toolbar = [[GPPhotosTableViewToolbar alloc] init];
    [toolbar hideDate:NO];
    toolbar.delegate = self;
    [self.view addSubview:toolbar];
    self.toolbar = toolbar;
    
    [self createPhotosSections];
    [self reloadPhotosFromLibrary];
    
    UITapGestureRecognizer *tapGr = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTap:)];
    [self.photosTableView addGestureRecognizer:tapGr];
    
    UILongPressGestureRecognizer *longPressGr = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(handleLongPress:)];
    [self.photosTableView addGestureRecognizer:longPressGr];
}

- (void)viewWillAppear:(BOOL)animated
{
    GPLogIN();
    [super viewWillAppear:animated];
    
    [self setNeedsStatusBarAppearanceUpdate];
    
    if (self.selectedIndexPath)
    {
        if ([GPPhotosTableViewController photosCountPerCell] != _lastPhotosCountPerCell)
        {
            NSInteger oldSelectedPhotoIndexInSection = self.selectedIndexPath.row * _lastPhotosCountPerCell + self.selectedPhotoIndex;
            NSIndexPath *newIndexPath = [NSIndexPath indexPathForRow:oldSelectedPhotoIndexInSection / [GPPhotosTableViewController photosCountPerCell]
                                                           inSection:self.selectedIndexPath.section];
            self.selectedPhotoIndex = oldSelectedPhotoIndexInSection % [GPPhotosTableViewController photosCountPerCell];
            self.selectedIndexPath = newIndexPath;
            
            [self.photosTableView scrollToRowAtIndexPath:self.selectedIndexPath
                                        atScrollPosition:UITableViewScrollPositionMiddle animated:NO];
        }
    }
    
    GPLogOUT();
}

- (void)viewDidAppear:(BOOL)animated
{
    GPLogIN();
    [super viewDidAppear:animated];
    
    // Clear selection
    self.selectedIndexPath = nil;
    self.selectedPhotoIndex = 0;
    
    GPLogOUT();
}

- (void)viewWillDisappear:(BOOL)animated
{
    GPLogIN();
    [super viewWillDisappear:animated];
    
    _lastPhotosCountPerCell = [GPPhotosTableViewController photosCountPerCell];
    
    GPLogOUT();
}

#pragma mark - Interface Orientation

- (NSUInteger)supportedInterfaceOrientations
{
    return UIInterfaceOrientationMaskAllButUpsideDown;
}

- (BOOL)shouldAutorotate
{
    return YES;
}

- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{
    GPLogIN();
    [super willRotateToInterfaceOrientation:toInterfaceOrientation duration:duration];
    
    NSArray *visibleIndexPaths = [self.photosTableView indexPathsForVisibleRows];
    NSIndexPath *middleIndexPath = [visibleIndexPaths middleObject];
    
    if (middleIndexPath)
    {
        NSInteger photoIndex = [GPPhotosTableViewController photosCountPerCell] / 2;
        NSInteger indexInSection = middleIndexPath.row * [GPPhotosTableViewController photosCountPerCell] + photoIndex;
        
        NSInteger photosCountPerCell = [GPPhotosTableViewController photosCountPerCellForOrientation:toInterfaceOrientation];
        NSIndexPath *newIndexPath = [NSIndexPath indexPathForRow:indexInSection / photosCountPerCell inSection:middleIndexPath.section];
        
        middleIndexPath = newIndexPath;
    }
    
    [UIView animateWithDuration:duration / 2
                          delay:0
                        options:UIViewAnimationOptionBeginFromCurrentState | UIViewAnimationOptionCurveEaseOut
                     animations:^{
                         
                         self.photosTableView.alpha = 0;
                         
                     } completion:^(BOOL finished) {
                         
                         [self.photosTableView reloadData];
                         
                         if (middleIndexPath)
                         {
                             [self.photosTableView scrollToRowAtIndexPath:middleIndexPath
                                                         atScrollPosition:UITableViewScrollPositionMiddle animated:NO];
                         }
                         
                         [UIView animateWithDuration:duration / 2
                                               delay:0
                                             options:UIViewAnimationOptionBeginFromCurrentState | UIViewAnimationOptionCurveEaseIn
                                          animations:^{
                                              
                                              self.photosTableView.alpha = 1;
                                              
                                          } completion:nil];
                     }];
    
    GPLogOUT();
}

- (void)willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{
    GPLogIN();
    [super willAnimateRotationToInterfaceOrientation:toInterfaceOrientation duration:duration];
    
    [self updateUI];
    [self setNeedsStatusBarAppearanceUpdate];
    
    GPLogOUT();
}

#pragma mark - Status Bar

- (BOOL)prefersStatusBarHidden
{
    return GPInterfaceOrientationIsLandscape();
}

- (UIStatusBarStyle)preferredStatusBarStyle
{
    return UIStatusBarStyleLightContent;
}

- (UIStatusBarAnimation)preferredStatusBarUpdateAnimation
{
    return UIStatusBarAnimationFade;
}

#pragma mark - Reload Photos

- (void)reloadPhotosFromLibrary
{
    GPLogIN();
    
    [self performSelectorInBackground:@selector(doReloadPhotosFromLibrary) withObject:nil];
    
    GPLogOUT();
}

- (void)doReloadPhotosFromLibrary
{
    GPLogIN();
    
    ALAssetsLibrary *library = [GPAssetsManager defaultAssetsLibrary];
    
    [library enumerateGroupsWithTypes:ALAssetsGroupSavedPhotos usingBlock:^(ALAssetsGroup *group, BOOL *stop) {
        
        if (!group) // last run
        {
            [self createPhotosSections];
            
            dispatch_async(dispatch_get_main_queue(), ^{
                
//                [self.photosTableView reloadData];
                [self updateUI];
            });
        }
        else if ([[group valueForProperty:ALAssetsGroupPropertyType] intValue] == ALAssetsGroupSavedPhotos)
        {
            GPLog(@"Enumerating photos in Camera Roll.");
            
            [group setAssetsFilter:[ALAssetsFilter allPhotos]];
            self.photosFromLibrary = [NSMutableArray array];
            
            [group enumerateAssetsUsingBlock:^(ALAsset *asset, NSUInteger index, BOOL *stop) {
                
                if ([[asset valueForProperty:@"ALAssetPropertyType"] isEqualToString:ALAssetTypePhoto])
                {
                    NSString *UTI = [[asset defaultRepresentation] UTI];
                    
                    if ([[UTI lowercaseString] isEqualToString:@"public.png"] || [[UTI lowercaseString] isEqualToString:@"public.jpeg"])
                    {
                        GPPhoto *photo = [[GPPhoto alloc] init];
                        photo.asset = asset;
                        [self.photosFromLibrary addObject:photo];
                    }
                }
            }];
        }
        
    } failureBlock:^(NSError *error) {
        
        GPLog(@"Library failed to enumerate photos group: %@", [error localizedDescription]);
        // TODO: Handle error
    }];
    
    GPLogOUT();
}

- (void)createPhotosSections
{
    NSMutableArray *photosSections = [NSMutableArray array];
    
    GPPhoto *dummyPhoto = [[GPPhoto alloc] init];
    [photosSections addObject:@[ dummyPhoto ]]; // Table view header
    
    if (self.photosFromLibrary)
    {
        NSMutableArray *sortedPhotosFromLibrary = [NSMutableArray arrayWithArray:self.photosFromLibrary];
        [sortedPhotosFromLibrary sortUsingSelector:@selector(compare:)];
        [photosSections addObject:sortedPhotosFromLibrary];
    }
    
    [photosSections addObject:@[ dummyPhoto ]]; // Table view footer
    
    self.photosSections = photosSections;
}

#pragma mark - Update Interface

- (void)updateUI
{
    GPLogIN();
    [super updateUI];
    
    GPLog(@"self view: %@", self.view);
    
    NSInteger photosCountPerCell = [GPPhotosTableViewController photosCountPerCell];
    sThumbnailDimension = (self.view.bounds.size.width - (photosCountPerCell + 1) * kPhotosSpacing) / photosCountPerCell;
    GPLog(@"thumbnail dimension: %f", sThumbnailDimension);
    
    self.photosTableView.frame = self.view.bounds;
    [self.photosTableView setNeedsLayout];
    [self.photosTableView setNeedsDisplay];
    GPLog(@"photos table view: %@", self.photosTableView);
    
    if (!self.isRotatingInterfaceOrientation)
    {
        [self.photosTableView reloadData]; // TODO: Optimize this?
    }
    
    self.toolbar.frame = CGRectMake(0, 0, self.view.bounds.size.width, ToolbarHeight());
    [self.view bringSubviewToFront:self.toolbar];
    [self.toolbar updateUI];
    
    [self updateDateTitle];
    
    [self.view setNeedsDisplay];
    
    GPLogOUT();
}

+ (NSInteger)photosCountPerCell
{
    return [self photosCountPerCellForOrientation:GPInterfaceOrientation()];
}

+ (NSInteger)photosCountPerCellForOrientation:(UIInterfaceOrientation)orientation
{
    return UIInterfaceOrientationIsPortrait(orientation) ? kPhotosCountPerCell_Portrait : kPhotosCountPerCell_Landscape;
}

- (UITableViewCell *)selectedCell
{
    if (self.selectedIndexPath)
    {
        return [self.photosTableView cellForRowAtIndexPath:self.selectedIndexPath];
    }
    
    return nil;
}

- (CGRect)frameForPhotoAtIndexPath:(NSIndexPath *)indexPath
{
    CGRect photoFrame = CGRectZero;
    
    if (indexPath)
    {
         UITableViewCell *selectedCell = [self.photosTableView cellForRowAtIndexPath:indexPath];
        
        if ([selectedCell isKindOfClass:[GPPhotoCell class]])
        {
            GPPhotoCell *photoCell = (GPPhotoCell *)selectedCell;
            photoFrame = [photoCell frameForPhotoAtIndex:self.selectedPhotoIndex];
            photoFrame = [self.view convertRect:photoFrame fromView:photoCell.contentView];
        }
    }
    
    return photoFrame;
}

- (void)updateDateTitle
{
    NSString *newDateTitle = @"";
    
    CGPoint topPoint = CGPointMake(self.view.bounds.size.width / 2, self.toolbar.frame.size.height);
    NSArray *visibleRowsIndexPaths = [self.photosTableView indexPathsForVisibleRows];
    
    for (NSInteger i = 0; i < [visibleRowsIndexPaths count]; i++)
    {
        NSIndexPath *indexPath = visibleRowsIndexPaths[i];
        
        if (indexPath.section == 0 || indexPath.section == [self.photosSections count] - 1)
        {
            continue; // Skip table view header and footer
        }
        
        GPPhotoCell *photoCell = (GPPhotoCell *)[self.photosTableView cellForRowAtIndexPath:indexPath];
        
        if (photoCell)
        {
            CGRect cellFrameInRootView = [self.view convertRect:photoCell.frame fromView:photoCell.superview];
            
            if (((topPoint.y >= cellFrameInRootView.origin.y) &&
                 (topPoint.y < cellFrameInRootView.origin.y + cellFrameInRootView.size.height)) ||
                [[visibleRowsIndexPaths firstObject] section] == 0)
            {
                GPPhoto *firstPhoto = (GPPhoto *)[photoCell.photos firstObject];
                
                if (firstPhoto)
                {
                    newDateTitle = [[firstPhoto.dateTaken dateWithYearMonthAndDayOnly] dateStringForTitleFormat];
                }
                
                break;
            }
        }
    }
    
    if ([newDateTitle length] > 0)
    {
        self.toolbar.date = newDateTitle;
    }
}

#pragma mark - Table View Data Source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return [self.photosSections count];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)sectionIndex
{
    NSArray *photos = self.photosSections[sectionIndex];
    NSInteger photosCountPerCell = [GPPhotosTableViewController photosCountPerCell];
    
    return [photos count] / photosCountPerCell + (([photos count] % photosCountPerCell > 0) ? 1 : 0);
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    GPPhotoCell *photoCell = [tableView dequeueReusableCellWithIdentifier:kPhotoCellID forIndexPath:indexPath];
    
    if (!photoCell)
    {
        photoCell = [[GPPhotoCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:kPhotoCellID];
    }
    
    NSInteger photosCountPerCell = [GPPhotosTableViewController photosCountPerCell];
    
    NSArray *photos = self.photosSections[indexPath.section];
    NSMutableArray *cellPhotos = [NSMutableArray arrayWithCapacity:photosCountPerCell];
    
    for (NSInteger i = 0; i < photosCountPerCell; i++)
    {
        if (indexPath.row * photosCountPerCell + i < [photos count])
        {
            [cellPhotos addObject:photos[indexPath.row * photosCountPerCell + i]];
        }
    }
    
    photoCell.photos = cellPhotos;
    
    return photoCell;
}

#pragma mark - Table View Delegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 0) // Table view header
    {
        return self.toolbar.frame.size.height;
    }
    
    if (indexPath.section == [self.photosSections count] - 1)
    {
        return (self.view.bounds.size.height - self.toolbar.frame.size.height - sThumbnailDimension - kPhotosSpacing);
    }
    
    return sThumbnailDimension + kPhotosSpacing;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    GPPhotosHeaderView *headerView = [tableView dequeueReusableHeaderFooterViewWithIdentifier:kPhotosHeaderID];
    
    if (!headerView)
    {
        headerView = [[GPPhotosHeaderView alloc] initWithReuseIdentifier:kPhotosHeaderID];
    }
    
    if (section == 0 || section == [self.photosSections count] - 1) // Table view header and footer
    {
        headerView.title = @"";
        headerView.alpha = 0;
    }
    else
    {
        headerView.alpha = 1;
    }
    
    headerView.hidden = YES;
    
    return headerView;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    if (section == 0 || section == [self.photosSections count] - 1) // Table view header & footer
    {
        return 0.1f; // hide
    }
    
    return kPhotosHeaderHeight;
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section
{
    GPPhotosFooterView *footerView = [tableView dequeueReusableHeaderFooterViewWithIdentifier:kPhotosFooterID];
    
    if (!footerView)
    {
        footerView = [[GPPhotosFooterView alloc] initWithReuseIdentifier:kPhotosFooterID];
    }
    
    if (section == 0 || section == [self.photosSections count] - 1) // Table view header & footer
    {
        footerView.alpha = 0;
    }
    else
    {
        footerView.alpha = 1;
    }
    
    [footerView updateUI];
    footerView.hidden = YES;
    
    return footerView;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    if (section == 0 || section == [self.photosSections count] - 1) // Table view header & footer
    {
        return 0.1f; // hide
    }
    
    return kPhotosFooterHeight;
}

#pragma mark - Gestures Handling

- (void)handleTap:(UITapGestureRecognizer *)tapGr
{
    GPLogIN();
    
//    CGPoint pos = [tapGr locationInView:self.view];
//    CGPoint posInTableView = [self.photosTableView convertPoint:pos fromView:self.view];
//    GPLog(@"tap: %@ %@", NSStringFromCGPoint(pos), NSStringFromCGPoint(posInTableView));
    
    CGPoint posInTableView = [tapGr locationInView:self.photosTableView];
    GPLog(@"tap: %@", NSStringFromCGPoint(posInTableView));
    
    GPPhoto *selectedPhoto = [self photoAtPoint:posInTableView];
    
    if (selectedPhoto)
    {
        GPLog(@"Selected photo: %@", [selectedPhoto description]);
        
        GPPhotoViewController *photoViewController = [[GPPhotoViewController alloc] initWithPhoto:selectedPhoto];
        
        if (photoViewController)
        {
            photoViewController.transitioningDelegate = self;
            [GPSearchEngine searchEngine].delegate = photoViewController;
            
            [self presentViewController:photoViewController animated:YES completion:nil];
        }
        else
        {
            GPLogErr(@"Could not create GPPhotoViewController.");
            // TODO: Handle error
        }
    }
    
    GPLogOUT();
}

- (void)handleLongPress:(UILongPressGestureRecognizer *)longPressGr
{
    if (longPressGr.state == UIGestureRecognizerStateBegan)
    {
        GPLog(@"long press began");
        
        CGPoint posInTableView = [longPressGr locationInView:self.photosTableView];
        GPLog(@"long press loc: %@", NSStringFromCGPoint(posInTableView));
        
        GPPhoto *selectedPhoto = [self photoAtPoint:posInTableView];
        
        if (selectedPhoto)
        {
            GPLog(@"Selected photo: %@", [selectedPhoto description]);
            
            GPPhotoViewController *photoViewController = [[GPPhotoViewController alloc] initWithPhoto:selectedPhoto];
            
            if (photoViewController)
            {
                photoViewController.transitioningDelegate = self;
                [GPSearchEngine searchEngine].delegate = photoViewController;
                
                [self presentViewController:photoViewController animated:YES completion:^{
                    
                    [[GPSearchEngine searchEngine] searchGoogleForPhoto:selectedPhoto completion:nil];
                }];
            }
            else
            {
                GPLogErr(@"Could not create GPPhotoViewController.");
                // TODO: Handle error
            }
        }
    }
}

- (GPPhoto *)photoAtPoint:(CGPoint)posInTableView
{
    NSIndexPath *indexPath = [self.photosTableView indexPathForRowAtPoint:posInTableView];
    self.selectedIndexPath = indexPath;
    
    if ((indexPath.section > 0) && (indexPath.section < [self.photosSections count] - 1)) // Ignore table view header & footer
    {
        GPPhotoCell *photoCell = (GPPhotoCell *)[self.photosTableView cellForRowAtIndexPath:indexPath];
        
        if (photoCell)
        {
            NSInteger index = (posInTableView.x / self.photosTableView.bounds.size.width) * [GPPhotosTableViewController photosCountPerCell];
            self.selectedPhotoIndex = index;
            
            NSArray *photos = [photoCell photos];
            
            if ((index >= 0) && (index < [photos count]))
            {
                GPPhoto *photo = (GPPhoto *)photos[index];
                return photo;
            }
        }
    }
    
    return nil;
}

#pragma mark - Scroll View Delegate

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    [self updateDateTitle];
    
    if ([self.toolbar.dateLabel isHidden])
    {
        [self.toolbar showDate:YES];
    }
    
    [self.hideTitleTimer invalidate];
    self.hideTitleTimer = [NSTimer scheduledTimerWithTimeInterval:kTitleVisibilityTimeout
                                                           target:self.toolbar
                                                         selector:@selector(hideDateAnimated)
                                                         userInfo:nil
                                                          repeats:NO];
}

#pragma mark - Toolbar Delegate

- (void)toolbar:(GPPhotosTableViewToolbar *)toolbar didSelectButton:(UIButton *)button
{
    if (button == toolbar.cameraButton)
    {
        GPCameraViewController *cameraViewController = [[GPCameraViewController alloc] init];
        cameraViewController.transitioningDelegate = self;
        
        button.enabled = NO;
        
        [self presentViewController:cameraViewController animated:YES completion:^{
            button.enabled = YES;
        }];
    }
}

- (void)toolbarDidTapTitle:(GPPhotosTableViewToolbar *)toolbar
{
    if (toolbar == self.toolbar)
    {
        [self.photosTableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]
                                    atScrollPosition:UITableViewScrollPositionTop animated:YES];
    }
}

#pragma mark - Transitioning Delegate

- (id <UIViewControllerAnimatedTransitioning>)animationControllerForPresentedController:(UIViewController *)presentedController
                                                                   presentingController:(UIViewController *)presentingController
                                                                       sourceController:(UIViewController *)source
{
    GPLogIN();
    
    GPBaseTransition *transition = nil;
    
    if ([presentedController isKindOfClass:[GPPhotoViewController class]])
    {
        transition = [[GPTableToPhotoTransition alloc] init];
    }
    else if ([presentedController isKindOfClass:[GPCameraViewController class]])
    {
        transition = [[GPFadeTransition alloc] init];
    }
    
    GPLogOUT();
    return transition;
}

- (id <UIViewControllerAnimatedTransitioning>)animationControllerForDismissedController:(UIViewController *)dismissedController
{
    GPLogIN();
    
    GPBaseTransition *transition = nil;
    
    if ([dismissedController isKindOfClass:[GPPhotoViewController class]])
    {
        transition = [[GPTableToPhotoTransition alloc] init];
    }
    else if ([dismissedController isKindOfClass:[GPCameraViewController class]])
    {
        transition = [[GPFadeTransition alloc] init];
    }
    
    transition.reverse = YES;
    
    GPLogOUT();
    return transition;
}

@end
