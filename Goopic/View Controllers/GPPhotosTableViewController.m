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
#import "GPCameraViewController.h"
#import "GPCameraToPhotoTransition.h"

static NSString * const kPhotoCellID                  = @"PhotoCell";
static NSString * const kPhotosHeaderID               = @"PhotosHeader";
static NSString * const kPhotosFooterID               = @"PhotosFooter";

static CGFloat          sThumbnailDimension           = 60.0f;
static const CGFloat    kPhotosSpacing                = 2.0f; // 0.0f;

static const NSInteger  kPhotosCountPerCell_Portrait  = 5;
static const NSInteger  kPhotosCountPerCell_Landscape = 9;

static const NSInteger  kEarlyReloadLimit             = 50;

static NSString * const kPhotoKey                     = @"photo";
static NSString * const kThumbnailViewKey             = @"thumbnailView";

static const CGFloat    kPhotosHeaderHeight           = 0.1; // 30.0f;
static const CGFloat    kPhotosFooterHeight           = 0.1;

static const NSInteger  kPhotosSection                = 1;

static const NSTimeInterval kTitleVisibilityTimeout   = 0.1f;


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
        
        UIView *bgView = [[UIView alloc] init];
        bgView.backgroundColor = GPCOLOR_LIGHT_BLACK;
        [self.contentView addSubview:bgView];
        self.backgroundView = bgView;
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
    
    self.backgroundView.frame = CGRectMake(0, 0,
                                           kPhotosSpacing + [_photos count] * (sThumbnailDimension + kPhotosSpacing) ,
                                           self.contentView.bounds.size.height);
    [self.backgroundView removeFromSuperview];
    [self.contentView insertSubview:self.backgroundView atIndex:0];
    [self.backgroundView setNeedsDisplay];
    
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

- (void)setThumbnailHidden:(BOOL)hidden atIndex:(NSInteger)index
{
    if ((index >= 0) && (index < [_photos count]))
    {
        id photoData = _photos[index];
        UIImageView *thumbnailView = photoData[kThumbnailViewKey];
        thumbnailView.hidden = hidden;
    }
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
        self.scrollsToTop = NO;
        
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
        self.canShowDate = NO;
        
        dispatch_queue_t libraryQueue = dispatch_queue_create("LibraryQueue", DISPATCH_QUEUE_SERIAL);
        self.libraryQueue = libraryQueue;
    }
    
    return self;
}

- (void)dealloc
{
    GPLogIN();
    
    // Dealloc code
    self.libraryQueue = nil;
    
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
    
    [self createPhotosSectionsWithPhotosFromLibrary:nil];
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
        if ([GPPhotosTableViewController photosCountPerCell] != _photosCountPerCellOnViewWillDisappear)
        {
            NSInteger oldSelectedPhotoIndexInSection = self.selectedIndexPath.row * _photosCountPerCellOnViewWillDisappear + self.selectedPhotoIndex;
            NSIndexPath *newIndexPath = [NSIndexPath indexPathForRow:oldSelectedPhotoIndexInSection / [GPPhotosTableViewController photosCountPerCell]
                                                           inSection:self.selectedIndexPath.section];
            self.selectedPhotoIndex = oldSelectedPhotoIndexInSection % [GPPhotosTableViewController photosCountPerCell];
            self.selectedIndexPath = newIndexPath;
            
            [self.photosTableView scrollToRowAtIndexPath:self.selectedIndexPath
                                        atScrollPosition:UITableViewScrollPositionMiddle animated:NO];
        }
    }
    
    [self updateSelection];
    
    GPLogOUT();
}

- (void)viewDidAppear:(BOOL)animated
{
    GPLogIN();
    [super viewDidAppear:animated];
    
    // Clear selection
//    self.selectedIndexPath = nil;
//    self.selectedPhotoIndex = 0;
    
    self.canShowDate = YES;
    
    GPLogOUT();
}

- (void)viewWillDisappear:(BOOL)animated
{
    GPLogIN();
    [super viewWillDisappear:animated];
    
    _photosCountPerCellOnViewWillDisappear = [GPPhotosTableViewController photosCountPerCell];
    self.canShowDate = NO;
    
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
    
    self.canShowDate = NO;
    
    NSArray *visibleIndexPaths = [self.photosTableView indexPathsForVisibleRows];
    NSInteger photosCountPerCell = [GPPhotosTableViewController photosCountPerCell];
    
    _thumbnailViewsForInterfaceOrientation = [NSMutableArray array];
    
    for (NSIndexPath *indexPath in visibleIndexPaths)
    {
        if (indexPath.section == kPhotosSection)
        {
            GPPhotoCell *photoCell = (GPPhotoCell *)[self.photosTableView cellForRowAtIndexPath:indexPath];
            
            if (photoCell)
            {
                NSArray *photos = [photoCell photos];
                
                for (NSInteger i = 0; i < [photos count]; i++)
                {
                    GPPhoto *photo = photos[i];
                    NSInteger indexInSection = indexPath.row * photosCountPerCell + i;
                    
                    CGRect thumbnailFrame = [self frameForPhotoAtIndexPath:indexPath photoIndex:i];
                    
                    if ((thumbnailFrame.origin.y + thumbnailFrame.size.height > 0) && (thumbnailFrame.origin.y < self.view.bounds.size.height))
                    {
                        UIImageView *thumbnailView = [[UIImageView alloc] init];
                        thumbnailView.frame = thumbnailFrame;
                        thumbnailView.image = [photo thumbnailImage];
                        thumbnailView.userInteractionEnabled = NO;
                        thumbnailView.tag = indexInSection;
                        [self.view addSubview:thumbnailView];
                        [_thumbnailViewsForInterfaceOrientation addObject:thumbnailView];
                    }
                }
            }
        }
    }
    
    GPLogOUT();
}

- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation
{
    GPLogIN();
    [super didRotateFromInterfaceOrientation:fromInterfaceOrientation];
    
    if ([_thumbnailViewsForInterfaceOrientation count] > 0)
    {
        NSInteger photosCountPerCell = [GPPhotosTableViewController photosCountPerCell];
        
        for (UIImageView *thumbnailView in _thumbnailViewsForInterfaceOrientation)
        {
            NSInteger indexInSection = thumbnailView.tag;
            NSIndexPath *indexPath = [NSIndexPath indexPathForRow:indexInSection / photosCountPerCell inSection:kPhotosSection];
            NSInteger photoIndex = indexInSection % photosCountPerCell;
            
            GPPhotoCell *photoCell = (GPPhotoCell *)[self.photosTableView cellForRowAtIndexPath:indexPath];
            [photoCell setThumbnailHidden:NO atIndex:photoIndex];
            
            [thumbnailView removeFromSuperview];
        }
        
        [_thumbnailViewsForInterfaceOrientation removeAllObjects];
    }
    
    self.photosTableView.hidden = NO;
    self.canShowDate = YES;
    
    GPLogOUT();
}

#pragma mark - Status Bar

- (BOOL)prefersStatusBarHidden
{
    if ([super prefersStatusBarHidden])
    {
        return YES;
    }
    
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
    GPLog(@"photos count before reload: %lu", (unsigned long)[self.photos count]);
    
    dispatch_async(self.libraryQueue, ^{
        
        [self doReloadPhotosFromLibrary];
    });
    
    GPLogOUT();
}

- (void)doReloadPhotosFromLibrary
{
    GPLogIN();
    
    ALAssetsLibrary *library = [[GPAssetsManager sharedManager] assetsLibrary];
    NSMutableArray *libraryPhotos = [NSMutableArray array];
    
    [library enumerateGroupsWithTypes:ALAssetsGroupAll usingBlock:^(ALAssetsGroup *group, BOOL *stop) {
        
        if (group)
        {
            if ([[group valueForProperty:ALAssetsGroupPropertyType] intValue] == ALAssetsGroupSavedPhotos) // camera roll
            {
                GPLog(@"Enumerating photos in Camera Roll.");
                
                [group setAssetsFilter:[ALAssetsFilter allPhotos]];
                [group enumerateAssetsWithOptions:NSEnumerationReverse usingBlock:^(ALAsset *asset, NSUInteger index, BOOL *stop) {
                
                    if (asset)
                    {
                        if ([[asset valueForProperty:@"ALAssetPropertyType"] isEqualToString:ALAssetTypePhoto])
                        {
                            NSString *UTI = [[asset defaultRepresentation] UTI];
                            
                            if ([[UTI lowercaseString] isEqualToString:@"public.png"] || [[UTI lowercaseString] isEqualToString:@"public.jpeg"])
                            {
                                GPPhoto *photo = [[GPPhoto alloc] init];
                                photo.asset = asset;
                                [libraryPhotos addObject:photo];
                            }
                        }
                    }
                    
                    if ([libraryPhotos count] == kEarlyReloadLimit) // early reload
                    {
                        NSArray *libraryPhotosSoFar = [NSArray arrayWithArray:libraryPhotos];
                        dispatch_async(dispatch_get_main_queue(), ^{
                            
                            // load first photos immediately only at the beginning, so that the user doesn't have to wait for the entire camera roll
                            // to be enumerated before he can see something on the screen
                            if ([self.photos count] == 0)
                            {
                                dispatch_async(self.libraryQueue, ^{
                                    
                                    [self createPhotosSectionsWithPhotosFromLibrary:libraryPhotosSoFar];
                                });
                            }
                        });
                    }
                    
                    if (!asset && (index == NSNotFound)) // last run
                    {
                        [self createPhotosSectionsWithPhotosFromLibrary:libraryPhotos];
                    }
                }];
            }
        }
        
    } failureBlock:^(NSError *error) {
        
        GPLog(@"Library failed to enumerate library groups: %@", [error localizedDescription]);
    }];
    
    GPLogOUT();
}

// Call this on libraryQueue
// libraryPhotos: NSArray* or nil
- (void)createPhotosSectionsWithPhotosFromLibrary:(NSArray *)libraryPhotos
{
    GPLogIN();
    
    NSMutableArray *photosSections = [NSMutableArray array];
    
    GPPhoto *dummyPhoto = [[GPPhoto alloc] init];
    [photosSections addObject:@[ dummyPhoto ]]; // Table view header
    
    if (libraryPhotos)
    {
        NSMutableArray *sortedPhotosFromLibrary = [NSMutableArray arrayWithArray:libraryPhotos];
        [sortedPhotosFromLibrary sortUsingSelector:@selector(compare:)];
        [photosSections addObject:sortedPhotosFromLibrary];
    }
    else
    {
        [photosSections addObject:[NSMutableArray array]];
    }
    
    [photosSections addObject:@[ dummyPhoto ]]; // Table view footer
    
    dispatch_async(dispatch_get_main_queue(), ^{
        
        if (!self.photos || ![self.photos isEqualToArrayOfPhotos:photosSections[kPhotosSection]])
        {
            self.photosSections = photosSections;
            GPLog(@"photos count after reload: %lu", (unsigned long)[self.photos count]);
            
            [self updateUI]; // will also reload photos in table view
        }
        else
        {
            GPLog(@"photos are the same, no need to update.");
        }
    });
    
    GPLogOUT();
}

- (NSMutableArray *)photos
{
    if (self.photosSections && ([self.photosSections count] > kPhotosSection))
    {
        return self.photosSections[kPhotosSection];
    }
    
    return nil;
}

#pragma mark - Update Interface

- (void)updateUI
{
    GPLogIN();
    [super updateUI];
    
    GPLog(@"self view: %@", self.view);
    
    self.toolbar.frame = CGRectMake(0, 0, self.view.bounds.size.width, ToolbarHeight(YES));
    [self.toolbar updateUI];
    
    static UIInterfaceOrientation _lastOrientation = (UIInterfaceOrientation)UIDeviceOrientationUnknown;
    BOOL animateThumbnails = NO;
    
    if ((_lastOrientation != (UIInterfaceOrientation)UIDeviceOrientationUnknown) && (GPInterfaceOrientation() != _lastOrientation) &&
        ([_thumbnailViewsForInterfaceOrientation count] > 0))
    {
        [UIView performWithoutAnimation:^{
            
            self.photosTableView.alpha = 0;
            self.photosTableView.hidden = YES;
        }];
        
        animateThumbnails = YES;
    }
    
    NSInteger photosCountPerCell = [GPPhotosTableViewController photosCountPerCell];
    
    sThumbnailDimension = (self.view.bounds.size.width - (photosCountPerCell + 1) * kPhotosSpacing) / photosCountPerCell;
    GPLog(@"thumbnail dimension: %f", sThumbnailDimension);
    
    self.photosTableView.frame = self.view.bounds;
    [self.photosTableView setNeedsLayout];
    [self.photosTableView setNeedsDisplay];
    GPLog(@"photos table view: %@", self.photosTableView);
    
    [self.photosTableView reloadData];
    
    _lastOrientation = GPInterfaceOrientation();
    
    if (animateThumbnails)
    {
        if ([_thumbnailViewsForInterfaceOrientation count] > 0)
        {
            UIImageView *middleThumbnail = [_thumbnailViewsForInterfaceOrientation middleObject];
            NSInteger indexInSection = middleThumbnail.tag;
            
            NSIndexPath *indexPath = [NSIndexPath indexPathForRow:indexInSection / photosCountPerCell inSection:kPhotosSection];
            
            [UIView performWithoutAnimation:^{
                
                [self.photosTableView scrollToRowAtIndexPath:indexPath
                                            atScrollPosition:UITableViewScrollPositionMiddle animated:NO];
            }];
            
            NSArray *visibleIndexPaths = [self.photosTableView indexPathsForVisibleRows];
            
            for (NSIndexPath *indexPath in visibleIndexPaths)
            {
                if (indexPath.section == kPhotosSection)
                {
                    GPPhotoCell *photoCell = (GPPhotoCell *)[self.photosTableView cellForRowAtIndexPath:indexPath];
                    
                    if (photoCell)
                    {
                        NSArray *photos = [photoCell photos];
                        
                        for (NSInteger i = 0; i < [photos count]; i++)
                        {
                            GPPhoto *photo = photos[i];
                            NSInteger indexInSection = indexPath.row * photosCountPerCell + i;
                            
                            if (![_thumbnailViewsForInterfaceOrientation containsViewWithTag:indexInSection])
                            {
                                CGRect thumbnailFrame = [self frameForPhotoAtIndexPath:indexPath photoIndex:i];
                                
                                if ((thumbnailFrame.origin.y + thumbnailFrame.size.height > 0) && (thumbnailFrame.origin.y < self.view.bounds.size.height))
                                {
                                    UIImageView *thumbnailView = [[UIImageView alloc] init];
                                    
                                    [UIView performWithoutAnimation:^{
                                        
                                        if (thumbnailFrame.origin.y + thumbnailFrame.size.height / 2 < self.view.bounds.size.height / 2)
                                        {
                                            thumbnailView.center = CGPointMake(thumbnailView.center.x, -thumbnailView.frame.size.height / 2);
                                        }
                                        else
                                        {
                                            thumbnailView.center = CGPointMake(thumbnailView.center.x, self.view.bounds.size.height + thumbnailView.frame.size.height / 2);
                                        }
                                    }];
                                    
                                    thumbnailView.frame = thumbnailFrame;
                                    thumbnailView.image = [photo thumbnailImage];
                                    thumbnailView.userInteractionEnabled = NO;
                                    thumbnailView.tag = indexInSection;
                                    [self.view addSubview:thumbnailView];
                                    [_thumbnailViewsForInterfaceOrientation addObject:thumbnailView];
                                }
                            }
                        }
                    }
                }
            }
            
            for (UIImageView *thumbnailView in _thumbnailViewsForInterfaceOrientation)
            {
                NSInteger indexInSection = thumbnailView.tag;
                NSIndexPath *indexPath = [NSIndexPath indexPathForRow:indexInSection / photosCountPerCell inSection:kPhotosSection];
                NSInteger photoIndex = indexInSection % photosCountPerCell;
                
                GPPhotoCell *photoCell = (GPPhotoCell *)[self.photosTableView cellForRowAtIndexPath:indexPath];
                [photoCell setThumbnailHidden:YES atIndex:photoIndex];
                
                thumbnailView.frame = [self frameForPhotoAtIndexPath:indexPath photoIndex:photoIndex];
            }
        }
        
        self.photosTableView.alpha = 1;
    }
    
    [self.view bringSubviewToFront:self.toolbar];
    [self updateDateTitle];
    
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

- (GPPhoto *)selectedPhoto
{
    UITableViewCell *selectedCell = [self selectedCell];
    
    if (selectedCell && [selectedCell isKindOfClass:[GPPhotoCell class]])
    {
        GPPhotoCell *photoCell = (GPPhotoCell *)selectedCell;
        NSArray *photos = [photoCell photos];
        
        if ((self.selectedPhotoIndex >= 0) && (self.selectedPhotoIndex < [photos count]))
        {
            return photos[self.selectedPhotoIndex];
        }
    }
    
    return nil;
}

- (CGRect)frameForPhotoAtIndexPath:(NSIndexPath *)indexPath photoIndex:(NSInteger)photoIndex
{
    CGRect photoFrame = CGRectZero;
    
    if (indexPath)
    {
         UITableViewCell *selectedCell = [self.photosTableView cellForRowAtIndexPath:indexPath];
        
        if ([selectedCell isKindOfClass:[GPPhotoCell class]])
        {
            GPPhotoCell *photoCell = (GPPhotoCell *)selectedCell;
            photoFrame = [photoCell frameForPhotoAtIndex:photoIndex];
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

- (void)updateSelection
{
    GPLogIN();
    
    if ([self.presentedViewController isKindOfClass:[GPPhotoViewController class]])
    {
        GPPhotoViewController *photoViewController = (GPPhotoViewController *)self.presentedViewController;
        
        if (photoViewController.photo && ![photoViewController.photo isEqualToPhoto:self.selectedPhoto])
        {
            NSArray *photos = [self photos];
            
            for (int i = 0; i < [photos count]; i++)
            {
                GPPhoto *photo = photos[i];
                
                if ([photo isEqualToPhoto:photoViewController.photo])
                {
                    self.selectedIndexPath = [NSIndexPath indexPathForRow:i / [GPPhotosTableViewController photosCountPerCell] inSection:kPhotosSection];
                    self.selectedPhotoIndex = i % [GPPhotosTableViewController photosCountPerCell];
                    
                    [self.photosTableView scrollToRowAtIndexPath:self.selectedIndexPath
                                                atScrollPosition:UITableViewScrollPositionMiddle animated:NO];
                }
            }
        }
    }
    
    GPLogOUT();
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
    
    photoCell.backgroundView.backgroundColor = (indexPath.section == kPhotosSection) ? GPCOLOR_LIGHT_BLACK : GPCOLOR_BLACK;
    
    return photoCell;
}

#pragma mark - Table View Delegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 0) // Table view header
    {
        return self.toolbar.frame.size.height;
    }
    
    if (indexPath.section == [self.photosSections count] - 1) // Table view footer
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
    
    CGPoint posInTableView = [tapGr locationInView:self.photosTableView];
    GPLog(@"tap: %@", NSStringFromCGPoint(posInTableView));
    
    self.canShowDate = NO;
    GPPhoto *selectedPhoto = [self selectPhotoAtPoint:posInTableView];
    
    if (selectedPhoto)
    {
        GPLog(@"Selected photo: %@", [selectedPhoto description]);
        
        GPPhotoViewController *photoViewController = [[GPPhotoViewController alloc] initWithPhoto:selectedPhoto];
        
        if (photoViewController)
        {
            photoViewController.transitioningDelegate = self;
            [GPSearchEngine searchEngine].delegate = photoViewController;
            
            [self presentViewController:photoViewController animated:YES completion:nil];
            
            GPLogOUT();
            return;
        }
        
        GPLogErr(@"Could not create GPPhotoViewController.");
        // TODO: Handle error
    }
    
    self.canShowDate = YES;
    
    GPLogOUT();
}

- (void)handleLongPress:(UILongPressGestureRecognizer *)longPressGr
{
    if (longPressGr.state == UIGestureRecognizerStateBegan)
    {
        GPLog(@"long press began");
        
        CGPoint posInTableView = [longPressGr locationInView:self.photosTableView];
        GPLog(@"long press loc: %@", NSStringFromCGPoint(posInTableView));
        
        self.canShowDate = NO;
        GPPhoto *selectedPhoto = [self selectPhotoAtPoint:posInTableView];
        
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
                
                GPLogOUT();
                return;
            }
            
            GPLogErr(@"Could not create GPPhotoViewController.");
            // TODO: Handle error
        }
        
        self.canShowDate = YES;
    }
}

- (GPPhoto *)selectPhotoAtPoint:(CGPoint)posInTableView
{
    NSIndexPath *indexPath = [self.photosTableView indexPathForRowAtPoint:posInTableView];
    
    if ((indexPath.section > 0) && (indexPath.section < [self.photosSections count] - 1)) // Ignore table view header & footer
    {
        GPPhotoCell *photoCell = (GPPhotoCell *)[self.photosTableView cellForRowAtIndexPath:indexPath];
        
        if (photoCell)
        {
            NSInteger index = (posInTableView.x / self.photosTableView.bounds.size.width) * [GPPhotosTableViewController photosCountPerCell];
            NSArray *photos = [photoCell photos];
            
            if ((index >= 0) && (index < [photos count]))
            {
                GPPhoto *photo = (GPPhoto *)photos[index];
                
                if (photo)
                {
                    self.selectedIndexPath = indexPath;
                    self.selectedPhotoIndex = index;
                    
                    CGRect photoFrame = [self frameForPhotoAtIndexPath:indexPath photoIndex:index];
                    
                    if (photoFrame.origin.y < self.toolbar.frame.size.height)
                    {
                        CGPoint pointToScrollAt = CGPointMake(photoFrame.origin.x, photoFrame.origin.y - self.toolbar.frame.size.height);
                        CGPoint pointToScrollAtInTableView = [self.view convertPoint:pointToScrollAt toView:self.photosTableView];
                        
                        CGRect rectToScrollAtInTableView = CGRectMake(pointToScrollAtInTableView.x, pointToScrollAtInTableView.y,
                                                                      photoFrame.size.width, photoFrame.size.height);
                        
                        [self.photosTableView scrollRectToVisible:rectToScrollAtInTableView animated:YES];
                    }
                    else if (photoFrame.origin.y + photoFrame.size.height > self.view.bounds.size.height)
                    {
                        CGPoint pointToScrollAt = CGPointMake(photoFrame.origin.x, self.view.bounds.size.height);
                        CGPoint pointToScrollAtInTableView = [self.view convertPoint:pointToScrollAt toView:self.photosTableView];
                        
                        CGRect rectToScrollAtInTableView = CGRectMake(pointToScrollAtInTableView.x, pointToScrollAtInTableView.y,
                                                                      photoFrame.size.width, photoFrame.origin.y + photoFrame.size.height - self.view.bounds.size.height);
                        
                        [self.photosTableView scrollRectToVisible:rectToScrollAtInTableView animated:YES];
                    }
                }
                
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
    
    if (self.canShowDate)
    {
        [self.toolbar showDate:YES];
        
        [self.hideTitleTimer invalidate];
        self.hideTitleTimer = [NSTimer scheduledTimerWithTimeInterval:kTitleVisibilityTimeout
                                                               target:self.toolbar
                                                             selector:@selector(hideDateAnimated)
                                                             userInfo:nil
                                                              repeats:NO];
    }
    
    if (scrollView.contentOffset.y == 0)
    {
        if ([scrollView.delegate respondsToSelector:@selector(scrollViewDidScrollToTop:)])
        {
            [scrollView.delegate performSelector:@selector(scrollViewDidScrollToTop:) withObject:scrollView];
        }
    }
}

- (void)scrollViewDidScrollToTop:(UIScrollView *)scrollView
{
    GPLogIN();
    
    self.canShowDate = YES;
    
    GPLogOUT();
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
        self.canShowDate = NO;
        
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
        if (self.selectedIndexPath)
        {
            // The presentedController is a GPPhotoViewController presented from this GPPhotosTableViewController by selecting a GPPhoto
            transition = [[GPTableToPhotoTransition alloc] init];
        }
        else
        {
            // The presentedViewController is a GPPhotoViewController presented from GPAppDelegate with a GPPhoto from GPCameraViewController
            transition = [[GPCameraToPhotoTransition alloc] init];
        }
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
        GPPhotoViewController *photoViewController = (GPPhotoViewController *)dismissedController;
        
        if ([photoViewController.photo exists])
        {
            transition = [[GPTableToPhotoTransition alloc] init];
        }
        else  // image deleted from camera roll from outside the app
        {
            transition = [[GPFadeTransition alloc] init];
        }
    }
    else if ([dismissedController isKindOfClass:[GPCameraViewController class]])
    {
        // GPCameraViewController dismissed by selecting 'Cancel'
        transition = [[GPFadeTransition alloc] init];
    }
    
    transition.reverse = YES;
    
    GPLogOUT();
    return transition;
}

@end
