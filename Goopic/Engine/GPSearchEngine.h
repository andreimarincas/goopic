//
//  GPSearchEngine.h
//  Goopic
//
//  Created by andrei.marincas on 30/08/14.
//  Copyright (c) 2014 JUPITER. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GPPhoto.h"

@interface GPSearchEngine : NSObject

+ (GPSearchEngine *)searchEngine;

- (void)searchGoogleForPhoto:(GPPhoto *)photo;

@end
