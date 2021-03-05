//
//  GPPhoto.h
//  Goopic
//
//  Created by andrei.marincas on 25/08/14.
//  Copyright (c) 2014 JUPITER. All rights reserved.
//

#import <Foundation/Foundation.h>

@class ALAsset;

@interface GPPhoto : NSObject

- (instancetype)init;

//@property (nonatomic, copy) NSString *name;

@property (nonatomic, strong) ALAsset *asset;

@property (nonatomic, readonly) UIImage *thumbnailImage;
@property (nonatomic, readonly) NSDate *dateTaken; // TODO: asset's timezone

- (NSComparisonResult)compare:(id)photo;

@end