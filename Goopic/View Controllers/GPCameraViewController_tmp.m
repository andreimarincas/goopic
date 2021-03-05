//
//  GPCameraViewController.m
//  Goopic
//
//  Created by andrei.marincas on 29/08/14.
//  Copyright (c) 2014 JUPITER. All rights reserved.
//

#import <MobileCoreServices/MobileCoreServices.h>
#import <ImageIO/ImageIO.h>
#import "GPCameraViewController_tmp.h"
#import "GPButton.h"


// Constants

static const CGFloat kCameraPreset = 640.0f / 480.0f;

static const CGFloat kGaussianBlur = 30.0f;
static const CGFloat kLanczosScale = 1.6f;

// Context
static void * CapturingStillImageContext = &CapturingStillImageContext;
static void * SessionRunningAndDeviceAuthorizedContext = &SessionRunningAndDeviceAuthorizedContext;


#pragma mark -
#pragma mark - Camera View

@implementation GPCameraLayerTmp

- (void)renderInContext:(CGContextRef)ctx
{
    GPLogIN();
    
    GPLogOUT();
}

- (void)drawInContext:(CGContextRef)ctx
{
    GPLogIN();
    
    GPLogOUT();
}

@end

@implementation GPCameraViewTmp

+ (Class)layerClass
{
	return [GPCameraLayerTmp class];
}

- (instancetype)init
{
    self = [super init];
    
    if (self)
    {
        CALayer *blurLayer = [CALayer layer];
        blurLayer.backgroundColor = [[UIColor clearColor] CGColor];
        blurLayer.opacity = 0;
        [self.layer addSublayer:blurLayer];
        self.blurLayer = blurLayer;
    }
    
    return self;
}

- (AVCaptureVideoPreviewLayer *)previewLayer
{
    return (AVCaptureVideoPreviewLayer *)self.layer;
}

- (void)setSession:(AVCaptureSession *)session
{
    self.previewLayer.session = session;
}

- (AVCaptureSession *)session
{
    return self.previewLayer.session;
}

- (void)updateUI
{
    [CATransaction begin];
    [CATransaction setValue:(id)kCFBooleanTrue forKey:kCATransactionDisableActions];
    
    self.blurLayer.position = CGPointMake(self.bounds.size.width / 2, self.bounds.size.height / 2);
    
    [CATransaction commit];
    
    [self setNeedsDisplay];
}

#pragma mark - Camera Blur

- (void)addCameraBlurWithSnapshot:(UIImage *)snapshotImage
{
    GPLogIN();
    
    GPLog(@"%@ %@", snapshotImage, NSStringFromCGSize(snapshotImage.size));
    
    CIContext *context = [CIContext contextWithOptions:nil];
    CIImage *inputImage = [[CIImage alloc] initWithImage:snapshotImage];
    
    // Apply Lanczos filter to scale the image by preserving aspect ratio
    CIFilter *lanczosFilter = [CIFilter filterWithName:@"CILanczosScaleTransform"];
    [lanczosFilter setValue:inputImage forKey:kCIInputImageKey];
    [lanczosFilter setValue:@(kLanczosScale) forKey:kCIInputScaleKey];
    CIImage *result = [lanczosFilter valueForKey:kCIOutputImageKey];
    
    // Apply Gausian filter to blur the image
    CIFilter *gaussianFilter = [CIFilter filterWithName:@"CIGaussianBlur"];
    [gaussianFilter setValue:result forKey:kCIInputImageKey];
    [gaussianFilter setValue:@(kGaussianBlur) forKey:kCIInputRadiusKey];
    result = [gaussianFilter valueForKey:kCIOutputImageKey];
    
    // Apply Bloom that makes soft edges and adds glow to image
    CIFilter *bloomFilter = [CIFilter filterWithName:@"CIBloom"];
    [bloomFilter setValue:result forKey:kCIInputImageKey];
    [bloomFilter setValue:[NSNumber numberWithDouble:6.0] forKey:@"inputRadius"];
    result = [bloomFilter valueForKey:kCIOutputImageKey];
    
    CGImageRef cgImage = [context createCGImage:result fromRect:[result extent]];
    
    [CATransaction begin];
    [CATransaction setValue:(id)kCFBooleanTrue forKey:kCATransactionDisableActions];
    
    self.blurLayer.frame = CGRectMake(0, 0, snapshotImage.size.width, snapshotImage.size.height);
    self.blurLayer.contents = (__bridge id)cgImage;
    
    [CATransaction commit];
    
    self.blurLayer.opacity = 1; // TODO: Animated
    
    [self updateUI];
    
    GPLogOUT();
}

- (void)removeCameraBlur
{
    GPLogIN();
    
    self.blurLayer.opacity = 0; // TODO: Animated
    
    [CATransaction begin];
    [CATransaction setValue:(id)kCFBooleanTrue forKey:kCATransactionDisableActions];
    
    self.blurLayer.contents = nil; // TODO: Do this on completion
    
    [CATransaction commit];
    
    GPLogOUT();
}

- (BOOL)hasCameraBlur
{
    return (self.blurLayer.contents != nil);
}

- (void)drawLayer:(CALayer *)layer inContext:(CGContextRef)ctx
{
    GPLogIN();
    
    GPLogOUT();
}

- (void)drawRect:(CGRect)rect
{
    GPLogIN();
    
    GPLogOUT();
}

@end


#pragma mark -
#pragma mark - Camera View Controller

@implementation GPCameraViewControllerTmp

@synthesize rootViewController = _rootViewController;

+ (NSSet *)keyPathsForValuesAffectingSessionRunningAndDeviceAuthorized
{
	return [NSSet setWithObjects:@"session.running", @"deviceAuthorized", nil];
}

+ (AVCaptureDevice *)deviceWithMediaType:(NSString *)mediaType preferringPosition:(AVCaptureDevicePosition)position
{
	NSArray *devices = [AVCaptureDevice devicesWithMediaType:mediaType];
	AVCaptureDevice *captureDevice = [devices firstObject];
	
	for (AVCaptureDevice *device in devices)
	{
		if ([device position] == position)
		{
			captureDevice = device;
			break;
		}
	}
	
	return captureDevice;
}

#pragma mark - Init / Dealloc

- (instancetype)init
{
    GPLogIN();
    self = [super init];
    
    if (self)
    {
        // Photo Shutter sound
//        NSString *path = [[NSBundle mainBundle] pathForResource:@"photoShutter" ofType:@"caf"];
//        NSURL *filePath = [NSURL fileURLWithPath:path isDirectory:NO];
        
//        AudioServicesCreateSystemSoundID((__bridge CFURLRef)filePath, &_photoShutterSoundID);
        
        // Device orientation
        _gpDeviceOrientation = [UIDevice currentDevice].orientation;
        
        [[UIDevice currentDevice] beginGeneratingDeviceOrientationNotifications];
        [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(deviceOrientationChanged)
                                                    name:UIDeviceOrientationDidChangeNotification object:nil];
    }
    
    return self;
    GPLogOUT();
}

- (void)dealloc
{
    GPLogIN();
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIDeviceOrientationDidChangeNotification object:nil];
    [[UIDevice currentDevice] endGeneratingDeviceOrientationNotifications];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    
    GPLogOUT();
}

#pragma mark - View Lifecycle

- (void)viewDidLoad
{
    GPLogIN();
    [super viewDidLoad];
    
    self.view.backgroundColor = GPCOLOR_DARK_BLACK;
    self.edgesForExtendedLayout = UIRectEdgeNone;
    
    // Toolbars
    GPCameraViewTopToolbar *topToolbar = [[GPCameraViewTopToolbar alloc] init];
    topToolbar.delegate = self;
    [self.view addSubview:topToolbar];
    self.topToolbar = topToolbar;
    
    GPCameraViewBottomToolbar *bottomToolbar = [[GPCameraViewBottomToolbar alloc] init];
    bottomToolbar.delegate = self;
    [self.view addSubview:bottomToolbar];
    self.bottomToolbar = bottomToolbar;
    
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    NSString *flashValue = [userDefaults stringForKey:kCameraFlashKey];
    [topToolbar selectFlashButtonForValue:flashValue];
    
    [self rotateControlsToOrientation:_gpDeviceOrientation animated:NO];
    
    // Create the capture session
	AVCaptureSession *session = [[AVCaptureSession alloc] init];
    session.sessionPreset = AVCaptureSessionPreset640x480;
	self.session = session;
	
	// Setup the preview view
    GPCameraViewTmp *cameraView = [[GPCameraViewTmp alloc] init];
    cameraView.backgroundColor = GPCOLOR_DARK_BLACK;
    cameraView.session = session;
    cameraView.previewLayer.videoGravity = AVLayerVideoGravityResizeAspect;
    
    UITapGestureRecognizer *tapGr = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(focusAndExposeTap:)];
    [cameraView addGestureRecognizer:tapGr];
    
    UIPanGestureRecognizer *panGr = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handlePanning:)];
    [cameraView addGestureRecognizer:panGr];
    
    [self.view addSubview:cameraView];
    self.cameraView = cameraView;
	
	// Check for device authorization
	[self checkDeviceAuthorizationStatus];
    
    // Dispatch session setup to the sessionQueue so that the main queue isn't blocked
    dispatch_queue_t sessionQueue = dispatch_queue_create("session queue", DISPATCH_QUEUE_SERIAL);
	self.sessionQueue = sessionQueue;
    
    dispatch_async(sessionQueue, ^{
		
        // Create the video device (back camera)
		AVCaptureDevice *videoDevice = [GPCameraViewControllerTmp deviceWithMediaType:AVMediaTypeVideo
                                                                preferringPosition:AVCaptureDevicePositionBack];
        
        // Set the video input
        NSError *error = nil;
		AVCaptureDeviceInput *videoDeviceInput = [AVCaptureDeviceInput deviceInputWithDevice:videoDevice error:&error];
        
        if (error)
		{
			GPLogErr(@"%@ %@", error, [error userInfo]); // TODO: handle error
		}
        
        if ([session canAddInput:videoDeviceInput])
		{
			[session addInput:videoDeviceInput];
			self.videoDeviceInput = videoDeviceInput;
            
			dispatch_async(dispatch_get_main_queue(), ^{
                // The backing layer for camera view and the view can only be manipulated on main thread.
                [[self.cameraView.previewLayer connection] setVideoOrientation:(AVCaptureVideoOrientation)[self interfaceOrientation]];
			});
		}
        
        // Set the image output
        AVCaptureStillImageOutput *stillImageOutput = [[AVCaptureStillImageOutput alloc] init];
        
		if ([session canAddOutput:stillImageOutput])
		{
			[stillImageOutput setOutputSettings:@{ AVVideoCodecKey : AVVideoCodecJPEG }];
			[session addOutput:stillImageOutput];
			self.stillImageOutput = stillImageOutput;
		}
    });
    
    GPLogOUT();
}

- (void)viewWillAppear:(BOOL)animated
{
    GPLogIN();
    [super viewWillAppear:animated];
    
	dispatch_async(self.sessionQueue, ^{
        
		[self addObserver:self forKeyPath:@"sessionRunningAndDeviceAuthorized"
                  options:(NSKeyValueObservingOptionOld | NSKeyValueObservingOptionNew)
                  context:SessionRunningAndDeviceAuthorizedContext];
        
		[self addObserver:self forKeyPath:@"stillImageOutput.capturingStillImage"
                  options:(NSKeyValueObservingOptionOld | NSKeyValueObservingOptionNew)
                  context:CapturingStillImageContext];
        
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(subjectAreaDidChange:)
                                                     name:AVCaptureDeviceSubjectAreaDidChangeNotification
                                                   object:[self.videoDeviceInput device]];
		
		__weak GPCameraViewControllerTmp *weakSelf = self;
        
		self.runtimeErrorHandlingObserver = [[NSNotificationCenter defaultCenter] addObserverForName: AVCaptureSessionRuntimeErrorNotification
                                                                                              object: self.session
                                                                                               queue: nil
                                                                                          usingBlock: ^(NSNotification *note)
        {
			GPCameraViewControllerTmp *strongSelf = weakSelf;
            
			dispatch_async([strongSelf sessionQueue], ^{
				// Manually restarting the session since it must have been stopped due to an error.
				[strongSelf.session startRunning];
			});
		}];
        
		[self.session startRunning];
	});
    
    if (![[UIApplication sharedApplication] isStatusBarHidden])
    {
        [self setNeedsStatusBarAppearanceUpdate];
    }
    
    GPLogOUT();
}

- (void)viewDidDisappear:(BOOL)animated
{
    GPLogIN();
    [super viewDidDisappear:animated];
    
	dispatch_async([self sessionQueue], ^{
        
		[self.session stopRunning];
		
		[[NSNotificationCenter defaultCenter] removeObserver:self
                                                        name:AVCaptureDeviceSubjectAreaDidChangeNotification
                                                      object:[self.videoDeviceInput device]];
        
		[[NSNotificationCenter defaultCenter] removeObserver:self.runtimeErrorHandlingObserver];
		
		[self removeObserver:self forKeyPath:@"sessionRunningAndDeviceAuthorized" context:SessionRunningAndDeviceAuthorizedContext];
		[self removeObserver:self forKeyPath:@"stillImageOutput.capturingStillImage" context:CapturingStillImageContext];
	});
    
    GPLogOUT();
}

#pragma mark - Capture Image

- (void)captureImageWithCompletion:(CaptureImageCompletionBlock)completion
{
    // Find the connection whose input port is collecting video:
    AVCaptureConnection *videoConnection = nil;
    
    for (AVCaptureConnection *connection in self.stillImageOutput.connections)
    {
        for (AVCaptureInputPort *port in [connection inputPorts])
        {
            if ([[port mediaType] isEqual:AVMediaTypeVideo] )
            {
                videoConnection = connection;
                break;
            }
        }
        
        if (videoConnection) { break; }
    }
    
    // Capture image
    CaptureStillImageBlock handler = ^(CMSampleBufferRef sampleBuffer, NSError *error) {
        
        if (!error)
        {
            CFDictionaryRef exifAttachments = CMGetAttachment(sampleBuffer, kCGImagePropertyExifDictionary, NULL);
            
            if (exifAttachments)
            {
                id data = (__bridge NSDictionary *)(exifAttachments);
                GPLog(@"data: %@", data);
                
                // Do something with the attachments.
            }
            
            // Continue as appropriate.
            
            NSData *imageData = [AVCaptureStillImageOutput jpegStillImageNSDataRepresentation:sampleBuffer];
            UIImage *image = [[UIImage alloc] initWithData:imageData];
            
            if (completion)
            {
                completion([image fixOrientation]);
            }
        }
        else
        {
            GPLogErr(@"%@ %@", error, [error userInfo]);
        }
    };
    
    [self.stillImageOutput captureStillImageAsynchronouslyFromConnection:videoConnection
                                                       completionHandler:handler];
}

- (UIImage *)screenshot
{
    // Create a graphics context with the target size
    // On iOS 4 and later, use UIGraphicsBeginImageContextWithOptions to take the scale into consideration
    // On iOS prior to 4, fall back to use UIGraphicsBeginImageContext
    CGSize imageSize = [[UIScreen mainScreen] bounds].size;
    if (NULL != UIGraphicsBeginImageContextWithOptions)
        UIGraphicsBeginImageContextWithOptions(imageSize, NO, 0);
    else
        UIGraphicsBeginImageContext(imageSize);
    
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    // Iterate over every window from back to front
    for (UIWindow *window in [[UIApplication sharedApplication] windows])
    {
        if (![window respondsToSelector:@selector(screen)] || [window screen] == [UIScreen mainScreen])
        {
            // -renderInContext: renders in the coordinate space of the layer,
            // so we must first apply the layer's geometry to the graphics context
            CGContextSaveGState(context);
            // Center the context around the window's anchor point
            CGContextTranslateCTM(context, [window center].x, [window center].y);
            // Apply the window's transform about the anchor point
            CGContextConcatCTM(context, [window transform]);
            // Offset by the portion of the bounds left of and above the anchor point
            CGContextTranslateCTM(context,
                                  -[window bounds].size.width * [[window layer] anchorPoint].x,
                                  -[window bounds].size.height * [[window layer] anchorPoint].y);
            
            // Render the layer hierarchy to the current context
            [[window layer] renderInContext:context];
            
            // Restore the context
            CGContextRestoreGState(context);
        }
    }
    
    // Retrieve the screenshot image
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    
    UIGraphicsEndImageContext();
    
    return image;
}

- (void)captureSnapshotWithCompletion:(CaptureImageCompletionBlock)completion
{
    GPLogIN();
    
//    UIView *snapshot = [self.cameraView snapshotViewAfterScreenUpdates:YES];
    
    UIGraphicsBeginImageContext(self.cameraView.bounds.size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    [[self.cameraView.layer presentationLayer] renderInContext:context];
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    GPLog(@"%@ %@", image, NSStringFromCGSize(image.size));
    UIGraphicsEndImageContext();
    
//    UIGraphicsBeginImageContextWithOptions(self.cameraView.frame.size, NULL, 0);
//    [self.cameraView drawViewHierarchyInRect:self.cameraView.bounds afterScreenUpdates:NO];
//
//    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
//
//    UIGraphicsEndImageContext();
    
    if (completion)
    {
//        completion([image fixOrientation]);
        completion(image);
    }
    
//    UIImage *image = [self screenshot];
    
    GPLogOUT();
}

#pragma mark - User Interface

- (void)updateUI
{
    GPLogIN();
    [super updateUI];
    
    self.cameraView.frame = CGRectMake(0, [self topMargin], [self cameraVisibleSize].width, [self cameraVisibleSize].height);
    [self.cameraView updateUI];
    
    self.topToolbar.frame = CGRectMake(0, 0, self.view.bounds.size.width, [self topMargin]);
    [self.topToolbar updateUI];
    [self.view bringSubviewToFront:self.topToolbar];
    
    self.bottomToolbar.frame = CGRectMake(0, self.view.bounds.size.height - [self bottomMargin],
                                          self.view.bounds.size.width, [self bottomMargin]);
    [self.bottomToolbar updateUI];
    [self.view bringSubviewToFront:self.bottomToolbar];
    
    [self.view setNeedsDisplay];
    
    GPLogOUT();
}

- (CGSize)cameraVisibleSize
{
    return CGSizeMake(self.view.bounds.size.width, kCameraPreset * self.view.bounds.size.width);
}

- (CGFloat)topMargin
{
    return (self.view.bounds.size.height - [self cameraVisibleSize].height - [self bottomMargin]);
}

- (CGFloat)bottomMargin
{
    return 0.7f * (self.view.bounds.size.height - [self cameraVisibleSize].height);
}

#pragma mark - Interface Orientation

- (NSUInteger)supportedInterfaceOrientations
{
    return UIInterfaceOrientationMaskAllButUpsideDown;
}

- (BOOL)shouldAutorotate
{
    return NO;
}

- (UIInterfaceOrientation)preferredInterfaceOrientationForPresentation
{
    return UIInterfaceOrientationPortrait;
}

- (void)deviceOrientationChanged
{
    UIDeviceOrientation deviceOrientation = [UIDevice currentDevice].orientation;
    
    if (deviceOrientation != _gpDeviceOrientation)
    {
        [self rotateControlsToOrientation:deviceOrientation animated:YES];
        _gpDeviceOrientation = deviceOrientation;
    }
}

- (void)rotateControlsToOrientation:(UIDeviceOrientation)toDeviceOrientation animated:(BOOL)animated
{
    GPLogIN();
    
    CGFloat angle = 0;
    
    if (toDeviceOrientation == UIDeviceOrientationLandscapeLeft)
    {
        angle = M_PI_2;
    }
    else if (toDeviceOrientation == UIDeviceOrientationLandscapeRight)
    {
        angle = -M_PI_2;
    }
    
    [self.topToolbar setButtonsRotation:angle animated:animated];
    [self.bottomToolbar setButtonsRotation:angle animated:animated];
    
    GPLogOUT();
}

#pragma mark - Status Bar

- (BOOL)prefersStatusBarHidden
{
	return YES;
}

- (UIStatusBarStyle)preferredStatusBarStyle
{
    return UIStatusBarStyleDefault;
}

- (UIStatusBarAnimation)preferredStatusBarUpdateAnimation
{
    return UIStatusBarAnimationSlide;
}

#pragma mark - Key-Value Observer

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
	if (context == CapturingStillImageContext)
	{
		BOOL isCapturingStillImage = [change[NSKeyValueChangeNewKey] boolValue];

		if (isCapturingStillImage)
		{
            GPLog(@"is capturing still image...");
            
//            AudioServicesPlaySystemSound(_photoShutterSoundID);
            
//			[self runStillImageCaptureAnimation];
		}
	}
	else if (context == SessionRunningAndDeviceAuthorizedContext)
	{
//		BOOL isRunning = [change[NSKeyValueChangeNewKey] boolValue];
//		
//		dispatch_async(dispatch_get_main_queue(), ^{
//
//			if (isRunning)
//			{
//				[[self cameraButton] setEnabled:YES];
//				[[self recordButton] setEnabled:YES];
//				[[self stillButton] setEnabled:YES];
//			}
//			else
//			{
//				[[self cameraButton] setEnabled:NO];
//				[[self recordButton] setEnabled:NO];
//				[[self stillButton] setEnabled:NO];
//			}
//		});
	}
	else
	{
		[super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
	}
}

#pragma mark - Device Authorization

- (BOOL)isSessionRunningAndDeviceAuthorized
{
	return [[self session] isRunning] && [self isDeviceAuthorized];
}

- (void)checkDeviceAuthorizationStatus
{
	NSString *mediaType = AVMediaTypeVideo;
	
	[AVCaptureDevice requestAccessForMediaType:mediaType
                             completionHandler:^(BOOL granted)
    {
        if (granted)
        {
            // Granted access to mediaType
            [self setDeviceAuthorized:YES];
        }
        else
        {
            // Not granted access to mediaType
            dispatch_async(dispatch_get_main_queue(), ^{
                
//                [[[UIAlertView alloc] initWithTitle:@"AVCam!"
//                                            message:@"AVCam doesn't have permission to use Camera, please change privacy settings"
//                                           delegate:self
//                                  cancelButtonTitle:@"OK"
//                                  otherButtonTitles:nil] show];
                
                // TODO: Show appropriate error message & dismiss controller
                
                [self setDeviceAuthorized:NO];
            });
        }
    }];
}

#pragma mark - Focus and Exposure

- (void)focusWithMode:(AVCaptureFocusMode)focusMode exposeWithMode:(AVCaptureExposureMode)exposureMode
        atDevicePoint:(CGPoint)point monitorSubjectAreaChange:(BOOL)monitorSubjectAreaChange
{
    GPLogIN();
    GPLog(@"point: %@", NSStringFromCGPoint(point));
    
	dispatch_async(self.sessionQueue, ^{
        
		AVCaptureDevice *device = [self.videoDeviceInput device];
		NSError *error = nil;
        
		if ([device lockForConfiguration:&error])
		{
			if ([device isFocusPointOfInterestSupported] && [device isFocusModeSupported:focusMode])
			{
				[device setFocusMode:focusMode];
				[device setFocusPointOfInterest:point];
			}
            
			if ([device isExposurePointOfInterestSupported] && [device isExposureModeSupported:exposureMode])
			{
				[device setExposureMode:exposureMode];
				[device setExposurePointOfInterest:point];
			}
            
			[device setSubjectAreaChangeMonitoringEnabled:monitorSubjectAreaChange];
			[device unlockForConfiguration];
		}
		else
		{
			GPLog(@"%@ %@", error, [error userInfo]);
		}
	});
    
    GPLogOUT();
}

- (void)subjectAreaDidChange:(NSNotification *)notification
{
    GPLogIN();
    
	CGPoint devicePoint = CGPointMake(.5, .5);
    
	[self focusWithMode:AVCaptureFocusModeContinuousAutoFocus exposeWithMode:AVCaptureExposureModeContinuousAutoExposure
          atDevicePoint:devicePoint monitorSubjectAreaChange:NO];
    
    GPLogOUT();
}

- (void)focusAndExposeTap:(UITapGestureRecognizer *)tapGr
{
    GPLogIN();
    
	CGPoint devicePoint = [self.cameraView.previewLayer captureDevicePointOfInterestForPoint:[tapGr locationInView:tapGr.view]];
    
	[self focusWithMode:AVCaptureFocusModeContinuousAutoFocus exposeWithMode:AVCaptureExposureModeContinuousAutoExposure
          atDevicePoint:devicePoint monitorSubjectAreaChange:YES];
    
    ///
    if (![self.cameraView hasCameraBlur])
    {
        [self captureSnapshotWithCompletion:^(UIImage *image) {
            [self.cameraView addCameraBlurWithSnapshot:image];
        }];
    }
    else
    {
        [self.cameraView removeCameraBlur];
    }
    ///
    
    GPLogOUT();
}

#pragma mark - Zoom on panning

- (void)handlePanning:(UIPanGestureRecognizer *)panGr
{
    static CGPoint initialLocation;
    
    switch (panGr.state)
    {
        case UIGestureRecognizerStateBegan:
        {
            initialLocation = [panGr locationInView:self.cameraView];
        }
            break;
            
        case UIGestureRecognizerStateChanged:
        {
            CGPoint loc = [panGr locationInView:self.cameraView];
            CGFloat offset = initialLocation.y - loc.y;
            
            static const CGFloat totalDistance = 400.0f;
            CGFloat percent = offset / totalDistance;
            
            GPLog(@"offset: %f, percent: %f", offset, percent);
            
            percent = fmaxf(-1, fminf(percent, 1));
            
            CGFloat maxScale = [[self.cameraView.previewLayer connection] videoMaxScaleAndCropFactor];
            GPLog(@"max scale: %f", maxScale);
            percent = -1;
            
//            [[self.cameraView.previewLayer connection] setVideoScaleAndCropFactor:percent];
//            [self.cameraView setTransform:CGAffineTransformMakeScale(2.0, 2.0 )];
        }
            break;
            
        default:
            break;
    }
}

#pragma mark - Toolbar Delegate

- (void)toolbar:(id)toolbar didSelectButton:(UIButton *)button
{
    GPLogIN();
    GPLog(@"button: %@", button);
    
    if (toolbar == self.topToolbar)
    {
        GPLog(@"flash selection changed");
    }
    else // bottom toolbar
    {
        if (button == self.bottomToolbar.cancelButton)
        {
            button.enabled = NO;
            
            [self dismissViewControllerAnimated:YES completion:^{
                button.enabled = YES;
            }];
        }
        else if (button == self.bottomToolbar.takeButton)
        {
            button.enabled = NO;
        }
    }
    
    GPLogOUT();
}

#pragma mark - Notifications

- (void)appWillResignActive
{
    GPLogIN();
    [super appWillResignActive];
    
    if (![self.cameraView hasCameraBlur])
    {
//        [NSThread sleepForTimeInterval:.5];
        
//        [self.session stopRunning];
        
        [self captureSnapshotWithCompletion:^(UIImage *image) {
            [self.cameraView addCameraBlurWithSnapshot:image];
        }];
    }
    
    GPLogOUT();
}

- (void)appDidBecomeActive
{
    GPLogIN();
    [super appDidBecomeActive];
    
    if ([self.cameraView hasCameraBlur])
    {
        [self.cameraView removeCameraBlur];
    }
    
    GPLogOUT();
}

@end
