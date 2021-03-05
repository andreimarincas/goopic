//
//  GPImgurManager.h
//  Goopic
//
//  Created by andrei.marincas on 24/08/14.
//  Copyright (c) 2014 JUPITER. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface GPImgurManager : NSObject
{
    NSURLSessionDataTask *_uploadImageBlock;
}

+ (GPImgurManager *)sharedManager;

- (void)uploadImage:(UIImage *)image withName:(NSString *)name completion:(UploadCompletionBlock)completion;
- (void)uploadImageWithName:(NSString *)name completion:(UploadCompletionBlock)completion;

- (void)deleteImageWithHash:(NSString *)deleteHash completion:(CompletionBlock)completion;

- (void)cancelImageUpload;

@end
