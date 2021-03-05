//
//  GPSearchEngine.h
//  Goopic
//
//  Created by andrei.marincas on 30/08/14.
//  Copyright (c) 2014 JUPITER. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GPPhoto.h"


@class GPSearchEngine;


@protocol GPSearchEngineDelegate <NSObject>

// will start uploading image
- (void)searchEngine:(GPSearchEngine *)searchEngine willBeginSearchingForPhoto:(GPPhoto *)photo;

// uploading image started
- (void)searchEngine:(GPSearchEngine *)searchEngine didBeginSearchingForPhoto:(GPPhoto *)photo;

// will launch browser
- (void)searchEngine:(GPSearchEngine *)searchEngine willBeginSearchingForImageAt:(NSURL *)link;

// error: uploading image failed or cannot open browser
- (void)searchEngine:(GPSearchEngine *)searchEngine searchingCompletedWithError:(NSError *)error;

- (void)searchEngineDidCancelSearching:(GPSearchEngine *)searchEngine;

@end


@interface GPSearchEngine : NSObject

@property (nonatomic, weak) id <GPSearchEngineDelegate> delegate;

+ (GPSearchEngine *)searchEngine;

- (void)searchGoogleForPhoto:(GPPhoto *)photo completion:(CompletionBlock)completion;

- (void)cancelPhotoSearching;

@end
