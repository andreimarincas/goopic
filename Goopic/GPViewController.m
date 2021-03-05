//
//  GPViewController.m
//  Goopic
//
//  Created by andrei.marincas on 24/08/14.
//  Copyright (c) 2014 JUPITER. All rights reserved.
//

#import "GPViewController.h"
#import "GPImgurManager.h"
#import "OpenInChromeController.h"

@implementation GPViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.view.backgroundColor = COLOR_BLACK;
    
    NSString *imageName = @"ReflectionsOfAutumn.jpg";
    
    GPImgurManager *imgurManager = [GPImgurManager sharedManager];
    
    [imgurManager uploadImageWithName:imageName
                           completion:^(NSString *link, NSString *deleteHash, NSError *error) {
                               
                               if (!error)
                               {
                                   GPLog(@"Link: %@", link);
                                   GPLog(@"Delete hash: %@", deleteHash);
                                   
                                   NSString *searchURL =  SEARCH_BY_IMAGE_URL(link);
                                   GPLog(@"Search URL: %@", searchURL);
                                   
                                   [self openURLInBrowser:[NSURL URLWithString:searchURL]];
                               }
                               else
                               {
                                   GPLogErr(@"%@ %@", error, [error userInfo]);
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
