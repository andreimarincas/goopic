//
//  GPConstants.h
//  Goopic
//
//  Created by andrei.marincas on 24/08/14.
//  Copyright (c) 2014 JUPITER. All rights reserved.
//

#import <Foundation/Foundation.h>


@protocol AFMultipartFormData;


#define IMGUR_CLIENT_ID             @"1a9340753c693df"
#define IMGUR_CLIENT_SECRET         @"64edfc2e9c114555ee65c7f894d7c379482c062a"

#define MULTIPART_FORM_IMAGE_DATA   @"image"
#define MIME_TYPE_JPEG              @"image/jpeg"

#define GOOPIC_URL_SCHEME           @"goopic://"


static NSString * const kSearchByImageURL = @"http://images.google.com/searchbyimage?image_url=%@";

#define SEARCH_BY_IMAGE_URL(aLink)  [NSString stringWithFormat:kSearchByImageURL, aLink]

#define IMGUR_UPLOAD_URL            [NSString stringWithFormat:@"/%@/upload", IMGAPIVersion];


typedef void (^Completion)(void);
typedef void (^UploadCompletion)(NSString *link, NSError *error);

typedef void (^BodyConstruct)(id <AFMultipartFormData>);
