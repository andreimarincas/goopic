//
//  GPPhotosTableViewController.m
//  Goopic
//
//  Created by andrei.marincas on 25/08/14.
//  Copyright (c) 2014 JUPITER. All rights reserved.
//

#import <AssetsLibrary/AssetsLibrary.h>
#import "GPPhotosTableViewController.h"
#import "GPToolbar.h"
#import "GPAssetsManager.h"
#import "GPRootViewController.h"

static NSString * const kPhotoCellID                    = @"PhotoCell";
static NSString * const kPhotosHeaderID                 = @"PhotosHeader";
static NSString * const kPhotosFooterID                 = @"PhotosFooter";

static CGFloat          sThumbnailDimension             = 60.0f;
static const CGFloat    kPhotosSpacing                  = 2.0f; // 0.0f;

static const NSInteger  kPhotosCountPerCell_Portrait    = 5;
static const NSInteger  kPhotosCountPerCell_Landscape   = 8;

static NSString * const kPhotoKey                       = @"photo";
static NSString * const kThumbnailViewKey               = @"thumbnailView";

static const CGFloat    kPhotosHeaderHeight             = 0.1; // 30.0f;
static const CGFloat    kPhotosFooterHeight             = 0.1;
//static const CGFloat    kPhotosFooterHeight             = 30.0f;

//static const CGFloat    kLineMargin                     = 10.0f;

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
        
        self.contentView.backgroundColor = COLOR_BLACK;
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
        
        self.contentView.backgroundColor = COLOR_BLUE;
        
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
//        [self.contentView insertSubview:line atIndex:0];
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
    // TODO: Align title based on text direction
    
    [self.titleLabel sizeToFit];
    
    const CGFloat marginRight = 10.0f;
//    const CGFloat marginBottom = 2.0f;
//    
//    self.titleLabel.center = CGPointMake(self.contentView.bounds.size.width - self.titleLabel.bounds.size.width / 2 - marginRight,
//                                         self.contentView.bounds.size.height - self.titleLabel.bounds.size.height / 2 - marginBottom - kPhotosSpacing / 2);
//    
//    self.line.frame = CGRectMake(kLineMargin,
//                                 0,
//                                 self.bounds.size.width - 2 * kLineMargin,
//                                 self.bounds.size.height - kPhotosSpacing / 2);
    
    self.titleLabel.center = CGPointMake(self.contentView.bounds.size.width - self.titleLabel.bounds.size.width / 2 - marginRight,
                                         self.contentView.bounds.size.height / 2);
    
    CGFloat titleLabelBottom = self.titleLabel.frame.origin.y + self.titleLabel.frame.size.height;
    
//    self.line.frame = CGRectMake(kLineMargin,
//                                 0,
//                                 self.bounds.size.width - 2 * kLineMargin,
//                                 titleLabelBottom + (self.bounds.size.height - titleLabelBottom) / 2);
    
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
        self.contentView.backgroundColor = COLOR_BLACK;
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
        
        self.backgroundColor = COLOR_BLACK;
        self.showsHorizontalScrollIndicator = NO;
        self.showsVerticalScrollIndicator = YES;
        self.allowsSelection = YES;
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

@property (atomic) BOOL reloadFromLibraryInProgress;

@property (atomic) NSMutableArray *photosFromLibrary;

//@property (atomic) NSDate *lastScrollTime;
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
        
        if ([self respondsToSelector:@selector(setAutomaticallyAdjustsScrollViewInsets:)]) {
            self.automaticallyAdjustsScrollViewInsets = NO;
        }
        
        self.reloadFromLibraryInProgress = NO;
//        self.lastScrollTime = [NSDate dateWithTimeIntervalSinceNow:kTitleVisibilityTimeout];
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
    
    self.view.backgroundColor = COLOR_BLACK;
    
    GPPhotosTableView *photosTableView = [[GPPhotosTableView alloc] init];
    photosTableView.dataSource = self;
    photosTableView.delegate = self;
    [self.view addSubview:photosTableView];
    self.photosTableView = photosTableView;
    
    UIActivityIndicatorView *activityIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
    activityIndicator.hidesWhenStopped = YES;
    activityIndicator.userInteractionEnabled = YES;
    activityIndicator.backgroundColor = [COLOR_BLACK colorWithAlphaComponent:0.5];
    [self.view addSubview:activityIndicator];
    self.activityIndicator = activityIndicator;
    
    [self createPhotosSections];
    [self reloadPhotosFromLibrary];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    if (self.indexPathOfSelectedCell)
    {
        [self.photosTableView deselectRowAtIndexPath:self.indexPathOfSelectedCell animated:NO];
        self.indexPathOfSelectedCell = nil;
    }
}

- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{
    [super willRotateToInterfaceOrientation:toInterfaceOrientation duration:duration];
    
    [UIView animateWithDuration:duration / 2
                          delay:0
                        options:UIViewAnimationOptionBeginFromCurrentState | UIViewAnimationOptionCurveEaseOut
                     animations:^{
                         
                         self.photosTableView.alpha = 0;
                         
                     } completion:^(BOOL finished) {
                         
                         [self reloadPhotosInTableView];
                         
                         [UIView animateWithDuration:duration / 2
                                               delay:0
                                             options:UIViewAnimationOptionBeginFromCurrentState | UIViewAnimationOptionCurveEaseIn
                                          animations:^{
                                              
                                              self.photosTableView.alpha = 1;
                                              
                                          } completion:nil];
                     }];
}

#pragma mark - Reload Photos

- (void)reloadPhotosFromLibrary
{
    GPLogIN();
    
    if (self.reloadFromLibraryInProgress)
    {
        GPLogErr(@"Cannot reload photos from library, already in progress...");
        
        GPLogOUT();
        return;
    }
    
    self.reloadFromLibraryInProgress = YES;
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [self updateUI];
        [self.activityIndicator startAnimating];
    });
    
    [self performSelectorInBackground:@selector(doReloadPhotosFromLibrary) withObject:nil];
    
    GPLogOUT();
}

- (void)doReloadPhotosFromLibrary
{
    GPLogIN();
    
    ALAssetsLibrary *library = [GPAssetsManager defaultAssetsLibrary];
    
    __block Completion updateTableViewCompletion = ^{
        
        [self createPhotosSections];
        self.reloadFromLibraryInProgress = NO;
        [self reloadPhotosInTableView];
    };
    
    [library enumerateGroupsWithTypes:ALAssetsGroupSavedPhotos usingBlock:^(ALAssetsGroup *group, BOOL *stop) {
        
        if (group)
        {
            if ([[group valueForProperty:ALAssetsGroupPropertyType] intValue] == ALAssetsGroupSavedPhotos)
            {
                GPLog(@"Enumerating photos in Camera Roll.");
                
                [group setAssetsFilter:[ALAssetsFilter allPhotos]];
                
                self.photosFromLibrary = [NSMutableArray array];
                
                [group enumerateAssetsUsingBlock:^(ALAsset *asset, NSUInteger index, BOOL *stop) {
                    
                    if (asset)
                    {
                        if ([[asset valueForProperty:@"ALAssetPropertyType"] isEqualToString:ALAssetTypePhoto])
                        {
                            NSString *UTI = [[asset defaultRepresentation] UTI];
                            GPLog(@"UTI: %@", UTI);
                            
                            if ([[UTI lowercaseString] isEqualToString:@"public.png"] || [[UTI lowercaseString] isEqualToString:@"public.jpeg"])
                            {
                                NSURL *URL = [[asset valueForProperty:ALAssetPropertyURLs] valueForKey:UTI];
                                GPLog(@"URL: %@", [URL absoluteString]);
                                
                                GPLog(@"file name: %@", [[asset defaultRepresentation] filename]);
                                GPLog(@"dimensions: %@", NSStringFromCGSize([[asset defaultRepresentation] dimensions]));
                                GPLog(@"size: %lld", [[asset defaultRepresentation] size]);
//                                GPLog(@"metadata: %@", [[asset defaultRepresentation] metadata]);
                                GPLog(@"date taken: %@", [asset valueForProperty:ALAssetPropertyDate]);
                                GPLog(@"");
                                
//                                NSURL *url = (NSURL *) [[asset valueForProperty:ALAssetPropertyURLs] valueForKey:[[[asset valueForProperty:ALAssetPropertyURLs] allKeys] objectAtIndex:0]];
                                
//                                id metadata = [asset defaultRepresentation] metadata];
//                                
//                                if (metadata)
//                                {
//                                    
//                                }
                                
                                GPPhoto *photo = [[GPPhoto alloc] init];
                                photo.asset = asset;
                                [self.photosFromLibrary addObject:photo];
                            }
                        }
                    }
                }];
            }
        }
        else // Last run
        {
            if (updateTableViewCompletion)
            {
                updateTableViewCompletion();
                updateTableViewCompletion = nil;
            }
        }
        
    } failureBlock:^(NSError *error) {
        
        GPLog(@"Library failed to enumerate photos group: %@", [error localizedDescription]);
        
        // TODO: Handle error
        
        if (updateTableViewCompletion)
        {
            updateTableViewCompletion();
            updateTableViewCompletion = nil;
        }
    }];
    
    GPLogOUT();
}

- (void)reloadPhotosInTableView
{
    GPLogIN();
    
    if (![[NSThread currentThread] isMainThread])
    {
        [self performSelectorOnMainThread:@selector(doReloadPhotosInTableView) withObject:nil waitUntilDone:NO];
    }
    else
    {
        [self doReloadPhotosInTableView];
    }
    
    GPLogOUT();
}

- (void)doReloadPhotosInTableView
{
    GPLogIN();
    
    [self.activityIndicator startAnimating];
    
    self.photosTableView.scrollEnabled = NO;
    [self.photosTableView reloadData]; // See tableViewDidFinishLoading:
    
    [self updateUI];
    
//    GPLog(@"photos from library: %@", [self.photosFromLibrary description]);
//    GPLog(@"photos sections: %@", [self.photosSections description]);
    
    GPLogOUT();
}

- (void)createPhotosSections
{
    NSMutableArray *photosSections = [NSMutableArray array];
    
    GPPhoto *dummyPhoto = [[GPPhoto alloc] init];
    [photosSections addObject:@[ dummyPhoto ]]; // Table view header
    
//    NSDate *now = [NSDate date];
//    NSInteger photosCountPerCell = [GPPhotosTableViewController photosCountPerCell];
//
//    for (int j = 0; j < 4; j++)
//    {
//        NSMutableArray *photos = [NSMutableArray array];
//
//        for (int i = 0; i < photosCountPerCell * 10 + 1; i++)
//        {
//            GPPhoto *photo = [[GPPhoto alloc] init];
//            photo.name = @"ReflectionsOfAutumn.jpg";
//            photo.date = now;
//            [photos addObject:photo];
//        }
//
//        [photosSections addObject:photos];
//    }
    
    if (self.photosFromLibrary)
    {
        NSMutableArray *sortedPhotosFromLibrary = [NSMutableArray arrayWithArray:self.photosFromLibrary];
        [sortedPhotosFromLibrary sortUsingSelector:@selector(compare:)];
        
//        NSMutableArray *section = [NSMutableArray array];
//        GPPhoto *prevPhoto = nil;
//        
//        for (NSInteger i = 0; i < [sortedPhotosFromLibrary count]; i++)
//        {
//            GPPhoto *currPhoto = sortedPhotosFromLibrary[i];
//            
//            if (prevPhoto)
//            {
//                NSDate *currPhotoDate = [[currPhoto dateTaken] dateWithYearMonthAndDayOnly];
//                NSDate *prevPhotoDate = [[prevPhoto dateTaken] dateWithYearMonthAndDayOnly];
//                
//                if (![currPhotoDate isEqualToDate:prevPhotoDate])
//                {
//                    [photosSections addObject:section];
//                    section = [NSMutableArray array];
//                }
//            }
//            
//            [section addObject:currPhoto];
//            prevPhoto = currPhoto;
//        }
//        
//        if ([section count] > 0)
//        {
//            [photosSections addObject:section];
//        }
        
        [photosSections addObject:sortedPhotosFromLibrary];
    }
    
    [photosSections addObject:@[ dummyPhoto ]]; // Table view footer
    
    self.photosSections = photosSections;
}

- (void)updateDateTitle
{
    NSString *newDateTitle = @"";
    
    CGPoint topPointInRootView = CGPointMake(self.rootViewController.view.bounds.size.width / 2, [GPToolbar preferredHeight]);
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
            CGRect cellFrameInRootView = [self.rootViewController.view convertRect:photoCell.frame fromView:photoCell.superview];
            
            if (((topPointInRootView.y >= cellFrameInRootView.origin.y) &&
                 (topPointInRootView.y < cellFrameInRootView.origin.y + cellFrameInRootView.size.height)) ||
                [[visibleRowsIndexPaths firstObject] section] == 0)
            {
                GPPhoto *firstPhoto = (GPPhoto *)[photoCell.photos firstObject];
                
                if (firstPhoto)
                {
                    newDateTitle = [[firstPhoto.dateTaken dateWithYearMonthAndDayOnly] formattedDateForTitle];
                }
                
                break;
            }
        }
    }
    
    if ([newDateTitle length] > 0)
    {
        self.rootViewController.topToolbar.leftTitle = newDateTitle;
    }
}

#pragma mark - Update Interface

- (void)updateUI
{
    GPLogIN();
    
    GPLog(@"photos table controller bounds: %@", NSStringFromCGRect(self.view.bounds));
    GPLog(@"photos table controller frame: %@", NSStringFromCGRect(self.view.frame));
    
    self.activityIndicator.frame = self.view.bounds;
    [self.view bringSubviewToFront:self.activityIndicator];
    
    NSInteger photosCountPerCell = [GPPhotosTableViewController photosCountPerCell];
    sThumbnailDimension = (self.view.bounds.size.width - (photosCountPerCell + 1) * kPhotosSpacing) / photosCountPerCell;
    GPLog(@"thumbnail dimension: %f", sThumbnailDimension);
    
    self.photosTableView.frame = self.view.bounds;
    
    [self updateDateTitle];
    
    [self.photosTableView setNeedsLayout];
    [self.photosTableView setNeedsDisplay];
    [self.view setNeedsDisplay];
    
    GPLogOUT();
}

+ (NSInteger)photosCountPerCell
{
    return GPInterfaceOrientationIsPortrait() ? kPhotosCountPerCell_Portrait : kPhotosCountPerCell_Landscape;
}

- (UITableViewCell *)selectedCell
{
    if (self.indexPathOfSelectedCell)
    {
        return [self.photosTableView cellForRowAtIndexPath:self.indexPathOfSelectedCell];
    }
    
    return nil;
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
        return [GPToolbar preferredHeight];
    }
    
    if (indexPath.section == [self.photosSections count] - 1)
    {
        return (self.rootViewController.view.bounds.size.height - [GPToolbar preferredHeight] - sThumbnailDimension - kPhotosSpacing);
    }
    
    return sThumbnailDimension + kPhotosSpacing;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    GPLogIN();
    
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    
    if ([cell isKindOfClass:[GPPhotoCell class]])
    {
        if (indexPath.section > 0 && indexPath.section < [self.photosSections count] - 1) // Avoid table view header & footer
        {
            GPPhotoCell *photoCell = (GPPhotoCell *)cell;
            GPLog(@"Selected photo cell: %@ at index path: %@", [photoCell description], [indexPath description]);
            GPLog(@"cell photos: %@", [photoCell.photos description]);
            
            self.indexPathOfSelectedCell = indexPath;
        }
    }
    
    GPLogOUT();
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
//        NSArray *photos = self.photosSections[section];
//        GPPhoto *photo = [photos firstObject];
//        
//        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
//        [dateFormatter setDateStyle:NSDateFormatterFullStyle];
//        [dateFormatter setTimeStyle:NSDateFormatterNoStyle];
//        [dateFormatter setLocale:[NSLocale currentLocale]];
//        [dateFormatter setTimeZone:[NSTimeZone localTimeZone]];
        
        // TODO: Locale change notification handling
        
//        NSString *formattedDateString = [dateFormatter stringFromDate:photo.date];
        
//        GPLog(@"formattedDateString for locale %@: %@", [[dateFormatter locale] localeIdentifier], formattedDateString);
        
//        headerView.title = formattedDateString;
        
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

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ([indexPath row] == ((NSIndexPath *)[[tableView indexPathsForVisibleRows] lastObject]).row)
    {
        [self tableViewDidFinishLoading:tableView];
    }
}

- (void)tableViewDidFinishLoading:(UITableView *)tableView
{
    GPLogIN();
    GPLog(@"Reloading from library in progress: %@", NSStringFromBOOL(self.reloadFromLibraryInProgress));
    
    if (!self.reloadFromLibraryInProgress)
    {
        [self.activityIndicator stopAnimating];
        self.photosTableView.scrollEnabled = YES;
    }
    
    GPLogOUT();
}

#pragma mark - Scroll View Delegate

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    GPLogIN();
    
    [self updateDateTitle];
    
    if ([self.rootViewController.topToolbar.leftTitleLabel isHidden])
    {
        [self.rootViewController.topToolbar showLeftTitle:YES];
    }
    
    [self.hideTitleTimer invalidate];
    self.hideTitleTimer = [NSTimer scheduledTimerWithTimeInterval:kTitleVisibilityTimeout
                                                           target:self.rootViewController.topToolbar
                                                         selector:@selector(hideLeftTitleAnimated)
                                                         userInfo:nil
                                                          repeats:NO];
    
    GPLogOUT();
}

@end
