//
//  GPCameraViewController.h
//  Goopic
//
//  Created by andrei.marincas on 29/08/14.
//  Copyright (c) 2014 JUPITER. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>
#import "GPCameraViewToolbar.h"
#import "GPBaseViewController.h"

@class GPRootViewController;


#pragma mark - Camera View

@interface GPCameraLayerTmp : AVCaptureVideoPreviewLayer

@end


@interface GPCameraViewTmp : UIView

@property (nonatomic) AVCaptureSession *session;
@property (nonatomic, readonly) AVCaptureVideoPreviewLayer *previewLayer;

@property (nonatomic, strong) CALayer *blurLayer;
@property (nonatomic, readonly) BOOL hasCameraBlur;

// Designated initializer
- (instancetype)init;

- (void)updateUI;

- (void)addCameraBlurWithSnapshot:(UIImage *)snapshotImage;
- (void)removeCameraBlur;

@end


#pragma mark - Camera View Controller

@interface GPCameraViewControllerTmp : GPBaseViewController <GPCameraViewToolbarDelegate>
{
    UIDeviceOrientation _gpDeviceOrientation;
    
//    SystemSoundID _photoShutterSoundID;
}

@property (nonatomic, weak) GPRootViewController *rootViewController;

// Session management
@property (nonatomic, strong) dispatch_queue_t sessionQueue; // Communicate with the session and other session objects on this queue

@property (nonatomic, strong) AVCaptureSession          * session;
@property (nonatomic, strong) AVCaptureDeviceInput      * videoDeviceInput;
@property (nonatomic, strong) AVCaptureStillImageOutput * stillImageOutput;

// Utilities
@property (nonatomic, getter = isDeviceAuthorized) BOOL deviceAuthorized;
@property (nonatomic, readonly, getter = isSessionRunningAndDeviceAuthorized) BOOL sessionRunningAndDeviceAuthorized;
@property (nonatomic) id runtimeErrorHandlingObserver;

// Interface
@property (nonatomic, strong) GPCameraViewTmp *cameraView;

@property (nonatomic, strong) GPCameraViewTopToolbar *topToolbar;
@property (nonatomic, strong) GPCameraViewBottomToolbar *bottomToolbar;

- (instancetype)init;

@end
