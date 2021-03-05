//
//  GPImgurUploader.h
//  Goopic
//
//  Created by andrei.marincas on 24/08/14.
//  Copyright (c) 2014 JUPITER. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface GPImgurUploader : NSObject

+ (void)uploadImage:(NSString *)jpgImageName completion:(UploadCompletion)completion;

@end
