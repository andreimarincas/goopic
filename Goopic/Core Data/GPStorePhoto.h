//
//  GPStorePhoto.h
//  Goopic
//
//  Created by andrei.marincas on 28/08/14.
//  Copyright (c) 2014 JUPITER. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface GPStorePhoto : NSManagedObject

@property (nonatomic, strong) NSString * assetURL;
@property (nonatomic, strong) NSString * assetName;
@property (nonatomic, strong) NSNumber * assetWidth;
@property (nonatomic, strong) NSNumber * assetHeight;
@property (nonatomic, strong) NSString * link;
@property (nonatomic, strong) NSDate   * uploadDate;
@property (nonatomic, strong) NSString * deleteHash;

@end
