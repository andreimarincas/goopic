//
//  GPImgurManager.m
//  Goopic
//
//  Created by andrei.marincas on 24/08/14.
//  Copyright (c) 2014 JUPITER. All rights reserved.
//

#import "GPImgurManager.h"
#import "GPAppDelegate.h"

static const CGFloat kCompressionQuality = 0.3f;

@implementation GPImgurManager

+ (GPImgurManager *)sharedManager
{
    static dispatch_once_t once = 0;
    static GPImgurManager *manager = nil;
    
    dispatch_once(&once, ^{
        manager = [[GPImgurManager alloc] init];
    });
    
    return manager;
}

- (void)uploadImage:(UIImage *)image withName:(NSString *)name completion:(UploadCompletionBlock)completion
{
    GPLogIN();
    GPLog(@"Uploading image to Imgur: %@ - %@", name, image);
    
    GPAppDelegate *appDelegate = (GPAppDelegate *)[[UIApplication sharedApplication] delegate];
    IMGSession *imgurSession = [appDelegate imgurSession];
    
    NSString *uploadURL = IMGUR_UPLOAD_URL;
    GPLog(@"Imgur Upload URL: %@", uploadURL);
    
    BodyConstructionBlock appendImageBlock = ^(id <AFMultipartFormData> formData)
    {
        NSData *imageDataToUpload = UIImageJPEGRepresentation(image, kCompressionQuality);
        
        if (imageDataToUpload)
        {
            [formData appendPartWithFileData:imageDataToUpload
                                        name:MULTIPART_FORM_IMAGE_DATA
                                    fileName:[name copy]
                                    mimeType:MIME_TYPE_JPEG];
        }
        else
        {
            GPLogErr(@"No image data to upload.");
        }
    };
    
    _uploadImageBlock = [imgurSession POST:uploadURL
                                parameters:nil
                 constructingBodyWithBlock:appendImageBlock
                         
                                   success:^(NSURLSessionDataTask *task, id responseObject) {
                                       
                                       GPLog(@"Imgur Response: %@", [responseObject description]);
                                     
                                       NSString *link = responseObject[@"link"];
                                       NSString *deleteHash = responseObject[@"deletehash"];
                                     
                                       if (completion)
                                       {
                                           if ([link length] > 0)
                                           {
                                               completion(link, deleteHash, nil);
                                           }
                                           else
                                           {
                                               NSError *error = [NSError errorWithDomain:NSStringFromClass([self class]) code:GPErrorInvalidLink
                                                                                userInfo:@{ NSLocalizedDescriptionKey : @"Imgur returned empty link after upload." }];
                                               completion(@"", @"", error);
                                           }
                                       }
                                   
                                   } failure:^(NSURLSessionDataTask *task, NSError *error) {
                                       
                                       GPLogErr(@"%@ %@", error, [error userInfo]);
                                       
                                       if (completion)
                                       {
                                           completion(@"", @"", error);
                                       }
                                   }];
}

- (void)uploadImageWithName:(NSString *)name completion:(UploadCompletionBlock)completion
{
    GPLogIN();
    
    [self uploadImage:[UIImage imageNamed:name] withName:name completion:completion];
    
    GPLogOUT();
}

- (void)deleteImageWithHash:(NSString *)deleteHash completion:(CompletionBlock)completion
{
    GPLogIN();
    GPLog(@"Deleting image with hash: %@", deleteHash);
    
    if ([deleteHash length] == 0)
    {
        GPLogErr(@"Cannot delete image with hash: %@. Invalid delete hash.", deleteHash);
        
        GPLogOUT();
        return;
    }
    
    GPAppDelegate *appDelegate = (GPAppDelegate *)[[UIApplication sharedApplication] delegate];
    IMGSession *imgurSession = [appDelegate imgurSession];
    
    NSString *deleteURL = IMGUR_DELETE_URL(deleteHash);
    GPLog(@"Imgur Delete URL: %@", deleteURL);
    
    [imgurSession DELETE:deleteURL parameters:nil success:^(NSURLSessionDataTask *task, id responseObject) {
        
        GPLog(@"Successfully deleted image with hash: %@", deleteHash);
        
        if (completion)
        {
            completion(nil);
        }
        
    } failure:^(NSError *error) {
        
        GPLogErr(@"Error deleting image with hash: %@", deleteHash);
        GPLogErr(@"%@ %@", error, [error userInfo]);
        
        if (completion)
        {
            completion(error);
        }
        
    }];
    
    GPLogOUT();
}

- (void)cancelImageUpload
{
    GPLogIN();
    
    if (_uploadImageBlock)
    {
        [_uploadImageBlock cancel];
    }
    
    GPLogOUT();
}

@end
