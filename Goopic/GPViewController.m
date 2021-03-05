//
//  GPViewController.m
//  Goopic
//
//  Created by andrei.marincas on 24/08/14.
//  Copyright (c) 2014 JUPITER. All rights reserved.
//

#import "GPViewController.h"
#import "GPImgurUploader.h"
#import "OpenInChromeController.h"

@implementation GPViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.view.backgroundColor = COLOR_BLACK;
    
    NSString *imageName = @"ReflectionsOfAutumn.jpg";
    
    [GPImgurUploader uploadImageWithName:imageName
                      completion:^(NSString *link, NSError *error) {
                          
                          if (!error)
                          {
                              GPLog(@"Link: %@", link);
                              
                              NSString *searchURL =  SEARCH_BY_IMAGE_URL(link);
                              GPLog(@"Search URL: %@", searchURL);
                              
                              [self openURLInBrowser:[NSURL URLWithString:searchURL]];
                          }
                          else
                          {
                              GPLog(@"Error: %@", [error localizedDescription]);
                          }
                      }];
}

- (void)openURLInBrowser:(NSURL *)url
{
    // Try to open in Chrome first
    
    OpenInChromeController *chromeCtrl = [OpenInChromeController sharedInstance];
    
    if ([chromeCtrl isChromeInstalled])
    {
        NSURL *callbackURL = [NSURL URLWithString:GOOPIC_URL_SCHEME];
        
        BOOL success = [[OpenInChromeController sharedInstance] openInChrome:url
                                                             withCallbackURL:callbackURL
                                                                createNewTab:YES];
        if (success)
        {
            GPLog(@"Opened URL in Chrome: %@", url);
            return;
        }
        
        GPLog(@"Failed to open URL in Chrome: %@", url);
    }
    
    // Open in Safari (default browser)
    
    if ([[UIApplication sharedApplication] canOpenURL:url])
    {
        [[UIApplication sharedApplication] openURL:url];
    }
    else
    {
        GPLog(@"Cannot open URL: %@", url);
    }
}

@end
