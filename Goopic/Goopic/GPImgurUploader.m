//
//  GPImgurUploader.m
//  Goopic
//
//  Created by andrei.marincas on 24/08/14.
//  Copyright (c) 2014 JUPITER. All rights reserved.
//

#import "GPImgurUploader.h"
#import "GPAppDelegate.h"

static const CGFloat kCompressionQuality = 0.3f;

@implementation GPImgurUploader

+ (void)uploadImage:(NSString *)jpgImageName completion:(UploadCompletion)completion
{
    NSLog(@"Uploading image to Imgur: %@", jpgImageName);
    
    GPAppDelegate *appDelegate = (GPAppDelegate *)[[UIApplication sharedApplication] delegate];
    IMGSession *imgurSession = [appDelegate imgurSession];
    
    NSString *uploadURL = IMGUR_UPLOAD_URL;
    NSLog(@"Imgur Upload URL: %@", uploadURL);
    
    id params = nil;
    
    BodyConstruct appendImageBlock = ^(id <AFMultipartFormData> formData)
    {
        UIImage *jpgImage = [UIImage imageNamed:jpgImageName];
        NSData *imageDataToUpload = UIImageJPEGRepresentation(jpgImage, kCompressionQuality);
        
        if (imageDataToUpload)
        {
            [formData appendPartWithFileData:imageDataToUpload
                                        name:MULTIPART_FORM_IMAGE_DATA
                                    fileName:jpgImageName
                                    mimeType:MIME_TYPE_JPEG];
        }
        else
        {
            NSLog(@"Error: No image data to upload.");
        }
    };
    
    [imgurSession POST:uploadURL parameters:params constructingBodyWithBlock:appendImageBlock
     
             success:^(NSURLSessionDataTask *task, id responseObject) {
                 
                 NSLog(@"Imgur Response: %@", [responseObject description]);
                 
                 NSString *link = responseObject[@"link"];
                 
                 if (completion)
                 {
                     completion(link, nil);
                 }
                 
             } failure:^(NSURLSessionDataTask *task, NSError *error) {
                 
                 if (completion)
                 {
                     completion(@"", error);
                 }
             }];
}

@end
