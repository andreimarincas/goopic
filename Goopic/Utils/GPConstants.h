//
//  GPConstants.h
//  Goopic
//
//  Created by andrei.marincas on 24/08/14.
//  Copyright (c) 2014 JUPITER. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreMedia/CMSampleBuffer.h>


// Forward declarations

@protocol AFMultipartFormData;


// Time Intervals

static const NSTimeInterval kSecond = 1;
static const NSTimeInterval kMinute = 60 * kSecond;
static const NSTimeInterval kHour   = 60 * kMinute;
static const NSTimeInterval kDay    = 24 * kHour;

static const NSTimeInterval kPhotoLocalExpirationInterval = 1 * kDay;
static const NSTimeInterval kPhotoImgurExpirationInterval = 30 * kDay; // actually 6 months, but that's too much for this app's purpose anyway


// Colors

#define GPCOLOR_BLACK             [UIColor blackColor]
#define GPCOLOR_LIGHT_BLACK       [UIColor colorWithWhite:0.1f alpha:1.0f]
#define GPCOLOR_TRANSLUCENT_BLACK [GPCOLOR_LIGHT_BLACK colorWithAlphaComponent:0.75]
#define GPCOLOR_DARK_BLACK        [UIColor blackColor]
#define GPCOLOR_TRANSLUCENT_DARK  [GPCOLOR_DARK_BLACK colorWithAlphaComponent:0.75]
#define GPCOLOR_BLUE              [UIColor colorWithRed:75 / 255.0f green:142 / 255.0f blue:250 / 255.0f alpha:1.0f] // #4B8EFA
#define GPCOLOR_BLUE_HIGHLIGHT    [GPCOLOR_BLUE colorWithAlphaComponent:0.35f]
#define GPCOLOR_BLUE_TEXT         [UIColor colorWithRed:36 / 255.0f green:107 / 255.0f blue:209 / 255.0f alpha:1.0f] // #246BD1
#define GPCOLOR_ORANGE_SELECTED   [UIColor orangeColor] // #FF7F00
#define GPCOLOR_ORANGE_HIGHLIGHT  [GPCOLOR_ORANGE_SELECTED colorWithAlphaComponent:0.35f]
#define GPCOLOR_WHITE             [UIColor whiteColor]
#define GPCOLOR_TRANSLUCENT_WHITE [GPCOLOR_WHITE colorWithAlphaComponent:0.75]
#define GPCOLOR_LIGHT_GREY        [UIColor colorWithWhite:0.9f alpha:1.0f]
#define GPCOLOR_RED               [UIColor colorWithRed:221 / 255.0f green:75 / 255.0f blue:57 / 255.0f alpha:1.0f]


/* THEMES */

#define BLACK_THEME 0
#define WHITE_THEME 0
#define BLUE_THEME  1

#if (BLACK_THEME)
    #import "black_theme.h"

#elif (WHITE_THEME)
    #import "white_theme.h"

#elif (BLUE_THEME)
#import "blue_theme.h"

#endif


/* Use ToolbarHeight() instead these constants! */

static const CGFloat kToolbarHeight_Portrait  = 65.0f;
static const CGFloat kToolbarHeight_Landscape = 44.0f;

static const CGFloat kToolbarButtonFontSize   = 19.0f;
static const CGFloat kToolbarButtonsMargin    = 10.0f;


// Image Upload

static const CGFloat    kMaxImageUploadSize        = 20000; // 100000; // w * h
static NSString * const kPhotoDefaultNameForUpload = @"Photo";


// Persistent Store

static NSString * const kGoopicStore       = @"Goopic.sqlite";
static NSString * const kGoopicModel       = @"Goopic"; // momd

static NSString * const kStoreEntityPhotos = @"Photos";

static NSString * const kStoreEntityPhotosKeyAssetURL    = @"assetURL";
static NSString * const kStoreEntityPhotosKeyAssetName   = @"assetName";
static NSString * const kStoreEntityPhotosKeyAssetWidth  = @"assetWidth";
static NSString * const kStoreEntityPhotosKeyAssetHeight = @"assetHeight";
static NSString * const kStoreEntityPhotosKeyLink        = @"link";
static NSString * const kStoreEntityPhotosKeyUploadDate  = @"uploadDate";
static NSString * const kStoreEntityPhotosKeyDeleteHash  = @"deleteHash";


// Blocks

//struct CMSampleBufferRef;

typedef void (^Block)                       (void);
typedef void (^CompletionBlock)             (NSError *error);
typedef void (^UploadCompletionBlock)       (NSString *link, NSString *deleteHash, NSError *error);
typedef void (^BodyConstructionBlock)       (id <AFMultipartFormData>);
typedef void (^CaptureStillImageBlock)      (CMSampleBufferRef sampleBuffer, NSError *error);
typedef void (^CaptureImageCompletionBlock) (NSData *jpegData, id metadata);
typedef void (^PermissionBlock)             (BOOL granted);


// Enums

// Toolbar buttons
typedef NS_ENUM (NSInteger, GPToolbarButtonType)
{
    GPToolbarButtonCamera = 34589,
    GPToolbarButtonBackToPhotos,
    GPToolbarButtonSearchGoogleForThisImage,
};

// Position
typedef enum {
    GPPositionLeft,
    GPPositionRight,
    GPPositionTop,
    GPPositionBottom
} GPPosition;

// Error codes
typedef NS_ENUM (NSInteger, GPErrorCode)
{
    GPErrorInvalidLink = 1000,
    GPErrorBadImage,
    GPErrorCannotLaunchBrowser,
    
    /* Network Errors */
    
    // TODO: Use already defined error codes instead?
    
    // The Internet connection appears to be offline.
    GPErrorNoInternetConnection = -1009,
    GPErrorImageUploadCancelled = -999,
    
    /* Imgur Errors */
    
    // This error indicates that a required parameter is missing or a parameter has a value that is out of bounds or otherwise incorrect.
    // This status code is also returned when image uploads fail due to images that are corrupt or do not meet the format requirements.
    GPErrorIMGParameterMissingOrIncorrect = 400,
    
    // The request requires user authentication. Either you didn't send send OAuth credentials, or the ones you sent were invalid.
    GPErrorIMGInvalidCredentials          = 401,
    
    // Forbidden. You don't have access to this action.
    // If you're getting this error, check that you haven't run out of API credits or make sure you're sending the OAuth headers correctly and have valid tokens/secrets.
    GPErrorIMGForbidden                   = 403,
    
    // Resource does not exist. This indicates you have requested a resource that does not exist. For example, requesting an image that doesn't exist.
    GPErrorIMGImageNotFound               = 404,
    
    // Rate limiting. This indicates you have hit either the rate limiting on the application or on the user's IP address.
    GPErrorIMGRateLimit                   = 429,
    
    // Unexpected internal error. What it says. We'll strive NOT to return these but your app should be prepared to see it.
    // It basically means that something is broken with the Imgur service.
    GPErrorIMGInternal                    = 500,
};

// Activity types
typedef NS_ENUM (NSInteger, GPActivity)
{
    GPActivityProcessingImage = 100
};


// Search Google For This Image

static NSString * const kSearchByImageURL = @"http://images.google.com/searchbyimage?image_url=%@";


// User Defaults

static NSString * const kCameraFlashKey       = @"camera-flash";
static NSString * const kCameraFlashAutoValue = @"auto";
static NSString * const kCameraFlashOnValue   = @"on";
static NSString * const kCameraFlashOffValue  = @"off";

static NSString * const kBrowserForSearchingKey    = @"browser-for-searching";
static NSString * const kBrowserForSearchingChrome = @"Chrome";
static NSString * const kBrowserForSearchingSafari = @"Safari";

static NSString * const kOpenInNewTabKey = @"open-in-new-tab"; // bool value


// Macros

#define LOGS_ENABLED              1

#define CAMERA_BLUR_ENABLED       0

#define IMGUR_RATE_LIMITS_ENABLED 0 // TODO: Set to 1 and use it (? white-list)


#define IMGUR_CLIENT_ID           @"1a9340753c693df"
#define IMGUR_CLIENT_SECRET       @"64edfc2e9c114555ee65c7f894d7c379482c062a"

#define MULTIPART_FORM_IMAGE_DATA @"image"
#define MIME_TYPE_JPEG            @"image/jpeg"

#define GOOPIC_URL_SCHEME         @"goopic://"


#define SEARCH_BY_IMAGE_URL(aLink)    [NSString stringWithFormat:kSearchByImageURL, aLink]

#define IMGUR_UPLOAD_URL              [NSString stringWithFormat:@"/%@/upload", IMGAPIVersion];
#define IMGUR_DELETE_URL(aDeleteHash) [NSString stringWithFormat:@"/%@/image/%@", IMGAPIVersion, aDeleteHash]

