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

+ (void)uploadImage:(UIImage *)image withName:(NSString *)name completion:(UploadCompletion)completion
{
    GPLogIN();
    GPLog(@"Uploading image to Imgur: %@ - %@", name, image);
    
    GPAppDelegate *appDelegate = (GPAppDelegate *)[[UIApplication sharedApplication] delegate];
    IMGSession *imgurSession = [appDelegate imgurSession];
    
    NSString *uploadURL = IMGUR_UPLOAD_URL;
    GPLog(@"Imgur Upload URL: %@", uploadURL);
    
    id params = nil;
    
    BodyConstruct appendImageBlock = ^(id <AFMultipartFormData> formData)
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
            GPLog(@"Error: No image data to upload.");
        }
    };
    
    [imgurSession POST:uploadURL parameters:params constructingBodyWithBlock:appendImageBlock
     
             success:^(NSURLSessionDataTask *task, id responseObject) {
                 
                 GPLog(@"Imgur Response: %@", [responseObject description]);
                 
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

+ (void)uploadImageWithName:(NSString *)name completion:(UploadCompletion)completion
{
    GPLogIN();
    
    [self uploadImage:[UIImage imageNamed:name] withName:name completion:completion];
    
    GPLogOUT();
}

@end
