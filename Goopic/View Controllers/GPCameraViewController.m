//
//  GPCameraViewController.m
//  Goopic
//
//  Created by andrei.marincas on 29/08/14.
//  Copyright (c) 2014 JUPITER. All rights reserved.
//

#import "GPCameraViewController.h"
#import <CoreImage/CoreImage.h>
#import <ImageIO/ImageIO.h>
#import <AssertMacros.h>
#import <AssetsLibrary/AssetsLibrary.h>

#import "GPAppDelegate.h"
#import "GPPhotoViewController.h"
#import "GPPhotosTableViewController.h"
#import "GPAssetsManager.h"
#import "GPPermissionsManager.h"


// Constants

static CGFloat kTopToolbarSize    = 41.33f;
static CGFloat kBottomToolbarSize = 100.0f;

#if (CAMERA_BLUR_ENABLED)

static const CGFloat kGaussianBlur      = 25.0f;
static const CGFloat kSmoothFactor      = 0.6f;
static const CGFloat kBlurScale         = 1.5f;

#endif

static const CGFloat kFlashBulbAnimationDuration = 0.25f;

// Contexts

// used for KVO observation of the @"capturingStillImage" property to perform flash bulb animation
static void * CapturingStillImageContext = &CapturingStillImageContext;

static void * SessionRunningAndDeviceAuthorizedContext = &SessionRunningAndDeviceAuthorizedContext;


#pragma mark - 
#pragma mark = Camera View

@implementation GPCameraView

+ (Class)layerClass
{
	return [AVCaptureVideoPreviewLayer class];
}

- (instancetype)init
{
    self = [super init];
    
    if (self)
    {
        self.backgroundColor = CAMERA_VIEW_BACKGROUND_COLOR;
        
        [self.videoLayer setBackgroundColor:[[UIColor blackColor] CGColor]];
        [self.videoLayer setVideoGravity:AVLayerVideoGravityResizeAspect];
    }
    
    return self;
}

- (AVCaptureVideoPreviewLayer *)videoLayer
{
    return (AVCaptureVideoPreviewLayer *)self.layer;
}

- (void)setSession:(AVCaptureSession *)session
{
    self.videoLayer.session = session;
}

- (AVCaptureSession *)session
{
    return self.videoLayer.session;
}

@end


#pragma mark - 
#pragma mark - Camera View Controller

@implementation GPCameraViewController

@synthesize cameraRunning = _cameraRunning;
@synthesize capturingStillImage = _capturingStillImage;

@synthesize capturedImage = _capturedImage;

#pragma mark - Utils

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

#if (CAMERA_BLUR_ENABLED)

+ (CGImageRef)blurredImage:(CGImageRef)image
{
    CIImage *ciImage = [[CIImage alloc] initWithCGImage:image];
    
    // Apply Gausian filter to blur the image
    CIFilter *gaussianFilter = [CIFilter filterWithName:@"CIGaussianBlur"];
    [gaussianFilter setValue:ciImage forKey:kCIInputImageKey];
    [gaussianFilter setValue:@( kGaussianBlur ) forKey:kCIInputRadiusKey];
    ciImage = [gaussianFilter valueForKey:kCIOutputImageKey];
    
    // Apply Bloom that makes soft edges and adds glow to image
    CIFilter *bloomFilter = [CIFilter filterWithName:@"CIBloom"];
    [bloomFilter setValue:ciImage forKey:kCIInputImageKey];
    [bloomFilter setValue:[NSNumber numberWithDouble: kSmoothFactor] forKey:@"inputRadius"];
    ciImage = [bloomFilter valueForKey:kCIOutputImageKey];
    
    static CIContext *context;
    
    if (!context)
    {
        context = [CIContext contextWithOptions:nil];
    }
    
    CGImageRef blurredImage = [context createCGImage:ciImage fromRect:[ciImage extent]];
    return blurredImage;
}

#endif

+ (void)setFlashMode:(AVCaptureFlashMode)flashMode forDevice:(AVCaptureDevice *)device
{
	if ([device hasFlash] && [device isFlashModeSupported:flashMode])
	{
		NSError *error = nil;
        
		if ([device lockForConfiguration:&error])
		{
			[device setFlashMode:flashMode];
			[device unlockForConfiguration];
		}
		else
		{
			GPLogErr(@"%@ %@", error, [error userInfo]); // TODO: Handle error
		}
	}
}

+ (ALAssetOrientation)assetOrientationForDeviceOrientation:(UIDeviceOrientation)orientation
{
    GPLog(@"device orientation when image was captured: %ld", (long)orientation);
    
    ALAssetOrientation assetOrientation = ALAssetOrientationUp;
    
    switch (orientation)
    {
        case UIDeviceOrientationPortrait:
        case UIDeviceOrientationFaceUp:
        case UIDeviceOrientationFaceDown:
        {
            assetOrientation = ALAssetOrientationRight;
        }
            break;
            
        case UIDeviceOrientationLandscapeRight:
        {
            assetOrientation = ALAssetOrientationDown;
        }
            break;
            
        case UIDeviceOrientationPortraitUpsideDown:
        {
            assetOrientation = ALAssetOrientationLeft;
        }
            break;
            
        case UIDeviceOrientationLandscapeLeft:
        case UIDeviceOrientationUnknown:
        default:
        {
            assetOrientation = ALAssetOrientationUp;
        }
            break;
    }
    
    UIDeviceOrientation currentOrientation = [[UIDevice currentDevice] orientation];
    GPLog(@"current device orientation: %ld", (long)currentOrientation);
    
    if (currentOrientation != orientation)
    {
        if (orientation == UIDeviceOrientationPortrait)
        {
            if (currentOrientation == UIDeviceOrientationLandscapeLeft)
            {
                assetOrientation = ALAssetOrientationUp;
            }
            else if (currentOrientation == UIDeviceOrientationLandscapeRight)
            {
                assetOrientation = ALAssetOrientationDown;
            }
        }
        else if (orientation == UIDeviceOrientationLandscapeLeft)
        {
            if (currentOrientation == UIDeviceOrientationPortrait)
            {
                assetOrientation = ALAssetOrientationRight;
            }
            else if (currentOrientation == UIDeviceOrientationLandscapeRight)
            {
                assetOrientation = ALAssetOrientationDown;
            }
        }
        else if (orientation == UIDeviceOrientationLandscapeRight)
        {
            if (currentOrientation == UIDeviceOrientationPortrait)
            {
                assetOrientation = ALAssetOrientationRight;
            }
            else if (currentOrientation == UIDeviceOrientationLandscapeLeft)
            {
                assetOrientation = ALAssetOrientationUp;
            }
        }
    }
    
    return assetOrientation;
}

#pragma mark - Init/Dealloc

- (instancetype)init
{
    GPLogIN();
    self = [super init];
    
    if (self)
    {
        // Custom initialization
        _deviceOrientation = (UIDeviceOrientation)GPInterfaceOrientation(); // will be portrait, the only allowed interface orientation here
        self.interfaceOrientationWhenPresented = UIInterfaceOrientationPortrait; // assumed
    }
    
    GPLogOUT();
    return self;
}

- (void)dealloc
{
    GPLogIN();
    
    self.stillImageOutput = nil;
    self.cameraDeviceInput = nil;
    self.sessionQueue = nil;
    self.session = nil;
    
#if (CAMERA_BLUR_ENABLED)
    
    self.videoDataOutput = nil;
    self.videoDataOutputQueue = nil;
    
#endif
    
    [self.capturedImageView setImage:nil];
    self.capturedImage = nil;
    
    GPLogOUT();
}

#pragma mark - View Lifecycle

- (void)viewDidLoad
{
    GPLogIN();
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    
    self.view.backgroundColor = CAMERA_VIEW_BACKGROUND_COLOR;
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
    
    [self rotateControlsToOrientation:_deviceOrientation animated:NO];
    
    // Flash
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    NSString *flashValue = [userDefaults stringForKey:kCameraFlashKey];
    [topToolbar selectFlashButtonForValue:flashValue];
    
    [self updateButtonsAnimated:YES];
    
	[self setupCamera];
    
    UIImageView *capturedImageView = [[UIImageView alloc] init];
    capturedImageView.backgroundColor = CAMERA_VIEW_BACKGROUND_COLOR;
    capturedImageView.userInteractionEnabled = NO;
    capturedImageView.hidden = YES;
    capturedImageView.contentMode = UIViewContentModeScaleAspectFit;
    [self.view addSubview:capturedImageView];
    self.capturedImageView = capturedImageView;
    
#if (CAMERA_BLUR_ENABLED)
    
    // Blur
    CALayer *blurLayer = [CALayer layer];
    blurLayer.masksToBounds = YES;
    blurLayer.backgroundColor = [CAMERA_VIEW_BACKGROUND_COLOR CGColor];
    blurLayer.opacity = 0;
    [self.view.layer addSublayer:blurLayer];
    self.blurLayer = blurLayer;
    
#endif
    
    // Overlay
    CALayer *cameraOverlay = [CALayer layer];
    cameraOverlay.backgroundColor = [UIColor blackColor].CGColor;
    [self.view.layer addSublayer:cameraOverlay];
    self.cameraOverlay = cameraOverlay;
    
    UIView *flashView = [[UIView alloc] init];
    flashView.userInteractionEnabled = NO;
    flashView.alpha = 0;
    flashView.backgroundColor = [UIColor colorWithWhite:0.8 alpha:1];
    [self.view addSubview:self.flashView];
    self.flashView = flashView;
    
    GPLogOUT();
}

- (void)viewWillAppear:(BOOL)animated
{
    GPLogIN();
    
    GPAppDelegate *appDelegate = (GPAppDelegate *)[[UIApplication sharedApplication] delegate];
    
    if ([appDelegate isPresentingPhotoViewControllerFromCameraViewController])
    {
        GPLog(@"Camera setup not allowed anymore.");
        GPLogOUT();
        return;
    }
    
    [super viewWillAppear:animated];
    
    [[GPPermissionsManager sharedManager] requestAccessToAssetsLibrary:^(BOOL granted) {
        [self updateButtonsAnimated:YES];
    }];
    
    [self requestAccessToCamera];
    
    self.cameraOverlay.opacity = 1; // fade to 0 on camera did start
    
    [[NSNotificationCenter defaultCenter] addObserver: self
                                             selector: @selector(deviceOrientationChanged:)
                                                 name: UIDeviceOrientationDidChangeNotification
                                               object: nil];
    
    [[UIDevice currentDevice] beginGeneratingDeviceOrientationNotifications];
    
    [[NSNotificationCenter defaultCenter] addObserver: self
                                             selector: @selector(captureSessionDidStartRunning:)
                                                 name: AVCaptureSessionDidStartRunningNotification
                                               object: nil];
    
    [[NSNotificationCenter defaultCenter] addObserver: self
                                             selector: @selector(captureSessionDidStopRunning:)
                                                 name: AVCaptureSessionDidStopRunningNotification
                                               object: nil];
    
    // Start the camera session
    dispatch_async(self.sessionQueue, ^{
        
        [self addObserver: self
               forKeyPath: @"sessionRunningAndDeviceAuthorized"
                  options: (NSKeyValueObservingOptionOld | NSKeyValueObservingOptionNew)
                  context: SessionRunningAndDeviceAuthorizedContext];
        
        [self addObserver: self
               forKeyPath: @"stillImageOutput.capturingStillImage"
                  options: (NSKeyValueObservingOptionOld | NSKeyValueObservingOptionNew)
                  context: CapturingStillImageContext];
        
        [[NSNotificationCenter defaultCenter] addObserver: self
                                                 selector: @selector(subjectAreaDidChange:)
                                                     name: AVCaptureDeviceSubjectAreaDidChangeNotification
                                                   object: [self.cameraDeviceInput device]];
        
        __weak GPCameraViewController *weakSelf = self;
        
        self.runtimeErrorHandlingObserver =
        [[NSNotificationCenter defaultCenter] addObserverForName: AVCaptureSessionRuntimeErrorNotification
                                                          object: self.session
                                                           queue: nil
                                                      usingBlock: ^(NSNotification *note) {
                                                          
                                                          GPCameraViewController *strongSelf = weakSelf;
                                                          
                                                          // Manually restarting the session since it must have been stopped due to an error.
                                                          [strongSelf.session startRunning];
                                                      }];
        [self.session startRunning];
    });
    
    if (!UIInterfaceOrientationIsLandscape(self.interfaceOrientationWhenPresented))
    {
        [self setNeedsStatusBarAppearanceUpdate];
    }
    
    GPLogOUT();
}

- (void)viewDidAppear:(BOOL)animated
{
    GPLogIN();
    [super viewDidAppear:animated];
    
    [[GPPermissionsManager sharedManager] requestAccessToAssetsLibrary:^(BOOL granted) {
        [self updateButtonsAnimated:YES];
    }];
    
    GPLogOUT();
}

- (void)viewDidDisappear:(BOOL)animated
{
    GPLogIN();
    
    if (!iOS_8_or_higher()) // iOS 7.1
    {
        GPAppDelegate *appDelegate = (GPAppDelegate *)[[UIApplication sharedApplication] delegate];
        
        if ([appDelegate isPresentingPhotoViewControllerFromCameraViewController])
        {
            GPLog(@"Camera setup not allowed anymore.");
            GPLogOUT();
            return;
        }
    }
    
    [super viewDidDisappear:animated];
    
    [[NSNotificationCenter defaultCenter] removeObserver: self
                                                    name: AVCaptureSessionDidStartRunningNotification
                                                  object: nil];
    
    [[NSNotificationCenter defaultCenter] removeObserver: self
                                                    name: AVCaptureSessionDidStopRunningNotification
                                                  object: nil];
    
    [[UIDevice currentDevice] endGeneratingDeviceOrientationNotifications];
    
    [[NSNotificationCenter defaultCenter] removeObserver: self
                                                    name: UIDeviceOrientationDidChangeNotification
                                                  object: nil];
    
    // Stop the camera session
    
    dispatch_async(self.sessionQueue, ^{
        
        [[NSNotificationCenter defaultCenter] removeObserver: self
                                                        name: AVCaptureDeviceSubjectAreaDidChangeNotification
                                                      object: [self.cameraDeviceInput device]];
        
        [[NSNotificationCenter defaultCenter] removeObserver:self.runtimeErrorHandlingObserver];
        
        [self removeObserver: self
                  forKeyPath: @"sessionRunningAndDeviceAuthorized"
                     context: SessionRunningAndDeviceAuthorizedContext];
        
        [self removeObserver: self
                  forKeyPath: @"stillImageOutput.capturingStillImage"
                     context: CapturingStillImageContext];
        
        [self.session stopRunning];
    });
    
    GPLogOUT();
}

#pragma mark - Camera Setup

- (void)setupCamera
{
    GPLogIN();
    
    // Create the capture session
	AVCaptureSession *session = [[AVCaptureSession alloc] init];
    
    if (iPhone_5())
    {
        session.sessionPreset = AVCaptureSessionPreset640x480;
    }
    else
    {
        session.sessionPreset = AVCaptureSessionPreset352x288;
        kBottomToolbarSize = 80.0f;
    }
    
	self.session = session;
    
    // Setup the camera view
    GPCameraView *cameraView = [[GPCameraView alloc] init];
    [cameraView setSession:session];
    [self.view addSubview:cameraView];
    self.cameraView = cameraView;
    
    UITapGestureRecognizer *tapGr = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(focusAndExposeTap:)];
    [cameraView addGestureRecognizer:tapGr];
    
    // Dispatch session setup to the sessionQueue so that the main queue isn't blocked
    dispatch_queue_t sessionQueue = dispatch_queue_create("CameraSessionQueue", DISPATCH_QUEUE_SERIAL);
	self.sessionQueue = sessionQueue;
    
    // Check for device authorization
	[self checkDeviceAuthorizationStatus];
    
    dispatch_async(self.sessionQueue, ^{
        
        // Get the video device (back camera)
		AVCaptureDevice *videoDevice = [GPCameraViewController deviceWithMediaType:AVMediaTypeVideo
                                                                preferringPosition:AVCaptureDevicePositionBack];
        
        // TODO: Adjust activeVideoMinFrameDuration and activeVideoMaxFrameDuration on AVCaptureDevice
        
        // Set the video input
        NSError *error = nil;
		AVCaptureDeviceInput *videoDeviceInput = [AVCaptureDeviceInput deviceInputWithDevice:videoDevice error:&error];
        
        if (error)
		{
			GPLogErr(@"%@ %@", error, [error userInfo]);
            self.session = nil;
            
            GPLogOUT();
            return;
		}
        
        if ([self.session canAddInput:videoDeviceInput])
		{
			[self.session addInput:videoDeviceInput];
			self.cameraDeviceInput = videoDeviceInput;
            
			dispatch_async(dispatch_get_main_queue(), ^{
                
                // The backing layer for camera view and the view can only be manipulated on the main thread.
                [[self.cameraView.videoLayer connection] setVideoOrientation:(AVCaptureVideoOrientation)UIInterfaceOrientationPortrait];
                
                [self updateFlash];
			});
		}
        
        // Set the image output
        AVCaptureStillImageOutput *stillImageOutput = [[AVCaptureStillImageOutput alloc] init];
        [stillImageOutput setOutputSettings:@{ AVVideoCodecKey : AVVideoCodecJPEG }];
        
		if ([self.session canAddOutput:stillImageOutput])
		{
			[self.session addOutput:stillImageOutput];
			self.stillImageOutput = stillImageOutput;
		}
        
#if (CAMERA_BLUR_ENABLED)
        
        // Set the video data output
        AVCaptureVideoDataOutput *videoDataOutput = [[AVCaptureVideoDataOutput alloc] init];
        
        // we want BGRA, both CoreGraphics and OpenGL work well with 'BGRA'
        id rgbOutputSettings = @{ (id)kCVPixelBufferPixelFormatTypeKey : @(kCMPixelFormat_32BGRA) };
        
        [videoDataOutput setVideoSettings:rgbOutputSettings];
        [videoDataOutput setAlwaysDiscardsLateVideoFrames:YES]; // discard if the data output queue is blocked (as we process the still image)
        
        // create a serial dispatch queue used for the sample buffer delegate as well as when a still image is captured
        // a serial dispatch queue must be used to guarantee that video frames will be delivered in order
        // see the header doc for setSampleBufferDelegate:queue: for more information
        dispatch_queue_t videoDataOutputQueue = dispatch_queue_create("VideoDataOutputQueue", DISPATCH_QUEUE_SERIAL);
        [videoDataOutput setSampleBufferDelegate:self queue:videoDataOutputQueue];
        self.videoDataOutputQueue = videoDataOutputQueue;
        
        if ([self.session canAddOutput:videoDataOutput])
        {
            [self.session addOutput:videoDataOutput];
            self.videoDataOutput = videoDataOutput;
        }
        
        AVCaptureConnection *videoOutputConnection = [self.videoDataOutput connectionWithMediaType:AVMediaTypeVideo];
        [videoOutputConnection setEnabled:YES];
        
#endif
        
    });
    
    GPLogOUT();
}

#pragma mark - Interface Orientation

- (NSUInteger)supportedInterfaceOrientations
{
    return UIInterfaceOrientationMaskPortrait;
}

- (BOOL)shouldAutorotate
{
    return NO;
}

- (UIInterfaceOrientation)preferredInterfaceOrientationForPresentation
{
    return UIInterfaceOrientationPortrait;
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
    return UIStatusBarAnimationFade;
}

#pragma mark - Update UI

- (void)updateUI
{
    GPLogIN();
    [super updateUI];
    
    self.cameraView.frame = CGRectMake(0, kTopToolbarSize,
                                       self.view.bounds.size.width,
                                       self.view.bounds.size.height - kTopToolbarSize - kBottomToolbarSize);
    [self.cameraView setNeedsDisplay];
    
    GPLog(@"camera view :%@", self.cameraView);
    
    self.topToolbar.frame = CGRectMake(0, 0, self.view.bounds.size.width, kTopToolbarSize);
    [self.topToolbar updateUI];
    [self.view bringSubviewToFront:self.topToolbar];
    
    GPLog(@"top toolbar: %@", self.topToolbar);
    
    self.bottomToolbar.frame = CGRectMake(0, self.view.bounds.size.height - kBottomToolbarSize,
                                          self.view.bounds.size.width, kBottomToolbarSize);
    [self.bottomToolbar updateUI];
    [self.view bringSubviewToFront:self.bottomToolbar];
    
    GPLog(@"bottom toolbar: %@", self.bottomToolbar);
    
#if (CAMERA_BLUR_ENABLED)
    
    [CALayer performWithoutAnimation:^{
        
        self.blurLayer.bounds = CGRectMake(0, 0, self.cameraView.bounds.size.height, self.cameraView.bounds.size.width);
        self.blurLayer.position = self.cameraView.center;
        
        CATransform3D t = CATransform3DMakeRotation(M_PI_2, 0, 0, 1);
        t = CATransform3DScale(t, kBlurScale, kBlurScale, 0);
        self.blurLayer.transform = t;
        
        GPLog(@"camera view frame: %@", NSStringFromCGRect(self.cameraView.frame));
        GPLog(@"blur layer: %@", NSStringFromCGRect(self.blurLayer.frame));
        
        [self.blurLayer removeFromSuperlayer];
        [self.view.layer insertSublayer:self.blurLayer above:self.cameraView.layer];
    }];
    
#endif
    
    [CALayer performWithoutAnimation:^{
        
        self.cameraOverlay.bounds = self.cameraView.bounds;
        self.cameraOverlay.position = self.cameraView.center;
        [self.view.layer bringSublayerToFront:self.cameraOverlay];
        
        [self.view.layer bringSublayerToFront:self.topToolbar.layer];
        [self.view.layer bringSublayerToFront:self.bottomToolbar.layer];
        
        [self.view.layer bringSublayerToFront:self.flashView.layer];
    }];
    
    [self.view bringSubviewToFront:self.topToolbar];
    [self.view bringSubviewToFront:self.bottomToolbar];
    
    // Captured image view
    self.capturedImageView.frame = self.cameraView.frame;
    [self.capturedImageView removeFromSuperview];
    [self.view addSubview:self.capturedImageView];
    [self.view bringSubviewToFront:self.capturedImageView];
    
    [CALayer performWithoutAnimation:^{
        [self.view.layer bringSublayerToFront:self.capturedImageView.layer];
    }];
    
    [self.capturedImageView setNeedsDisplay];
    
    // Flash view
    self.flashView.frame = self.cameraView.frame;
    [self.flashView removeFromSuperview];
    [self.view addSubview:self.flashView];
    [self.view bringSubviewToFront:self.flashView];
    
    [CALayer performWithoutAnimation:^{
        [self.view.layer bringSublayerToFront:self.flashView.layer];
    }];
    
    [self.flashView setNeedsDisplay];
    
    GPLogOUT();
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

// Note: Calling updateButtonsAnimated:NO will cancel all other animations including view controller transitions!
- (void)updateButtonsAnimated:(BOOL)animated
{
    GPLogIN();
    
    Block updateButtons = ^{
        
        if (self.capturedImage)
        {
            [self.bottomToolbar.cancelButton setAlpha:0];
            
            [self.bottomToolbar.retakeButton setAlpha:1];
            [self.bottomToolbar.retakeButton setEnabled:YES];
            
            [self.bottomToolbar.useButton setAlpha:1];
            [self.bottomToolbar.useButton setEnabled:YES];
            
            [self.bottomToolbar.takeButton setEnabled:NO];
        }
        else
        {
            [self.bottomToolbar.cancelButton setAlpha:1];
            [self.bottomToolbar.retakeButton setAlpha:0];
            [self.bottomToolbar.useButton setAlpha:0];
            
            [self.bottomToolbar.takeButton setEnabled:YES];
            [self.bottomToolbar.takeButton setUserInteractionEnabled:self.cameraRunning];
        }
        
        if (![[GPPermissionsManager sharedManager] canAccessAssetsLibrary])
        {
            [self.bottomToolbar.useButton setEnabled:NO];
        }
        
        if (![[GPPermissionsManager sharedManager] canAccessCamera])
        {
            [self.bottomToolbar.takeButton setEnabled:NO];
        }
    };
    
    if (animated)
    {
        UIViewAnimationOptions options = UIViewAnimationOptionBeginFromCurrentState | UIViewAnimationOptionCurveLinear;
        
        [UIView animateWithDuration:0.2
                              delay:0
                            options:options
                         animations:updateButtons
                         completion:nil];
    }
    else
    {
        [UIView performWithoutAnimation:updateButtons];
    }
    
    GPLogOUT();
}

#pragma mark - Flash

- (void)updateFlash
{
    GPLogIN();
    
    AVCaptureFlashMode flashMode = [self flashModeForButton:[self.topToolbar selectedFlashButton]];
    [GPCameraViewController setFlashMode:flashMode forDevice:[self.cameraDeviceInput device]];
    
    GPLogOUT();
}

- (AVCaptureFlashMode)flashModeForButton:(GPButton *)button
{
    if (button == self.topToolbar.flashAutoButton)
    {
        return AVCaptureFlashModeAuto;
    }
    
    if (button == self.topToolbar.flashOnButton)
    {
        return AVCaptureFlashModeOn;
    }
    
    if (button == self.topToolbar.flashOffButton)
    {
        return AVCaptureFlashModeOff;
    }
    
    return AVCaptureFlashModeAuto;
}

#pragma mark - Key-Value Observer

// perform a flash bulb animation using KVO to monitor the value of the capturingStillImage property of the AVCaptureStillImageOutput class
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
	if (context == CapturingStillImageContext)
    {
		self.capturingStillImage = [change[NSKeyValueChangeNewKey] boolValue];
	}
    else if (context == SessionRunningAndDeviceAuthorizedContext)
	{
//        BOOL isRunning = [change[NSKeyValueChangeNewKey] boolValue];
//
//        dispatch_async(dispatch_get_main_queue(), ^{
//
//            if (isRunning)
//            {
//                [[self cameraButton] setEnabled:YES];
//                [[self recordButton] setEnabled:YES];
//                [[self stillButton] setEnabled:YES];
//            }
//            else
//            {
//                [[self cameraButton] setEnabled:NO];
//                [[self recordButton] setEnabled:NO];
//                [[self stillButton] setEnabled:NO];
//            }
//        });
	}
	else
	{
		[super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
	}
}

#pragma mark - Take Picture

// main action method to take a still image
- (void)takePicture:(CaptureImageCompletionBlock)completion
{
	// Find out the current orientation and tell the still image output.
	AVCaptureConnection *stillImageConnection = [self.stillImageOutput connectionWithMediaType:AVMediaTypeVideo];
	
    // Set the appropriate pixel format / image type output setting
    [self.stillImageOutput setOutputSettings:@{ AVVideoCodecKey : AVVideoCodecJPEG }];
	
	[self.stillImageOutput captureStillImageAsynchronouslyFromConnection:stillImageConnection
		completionHandler:^(CMSampleBufferRef imageDataSampleBuffer, NSError *error) {
            
            if (!error)
            {
                CFDictionaryRef attachments = CMCopyDictionaryOfAttachments(kCFAllocatorDefault,
                                                                            imageDataSampleBuffer,
                                                                            kCMAttachmentMode_ShouldPropagate);
                NSData *jpegData = nil;
                id metadata = nil;
                
                if (attachments)
                {
                    metadata = [NSMutableDictionary dictionaryWithDictionary:(__bridge id)(attachments)];
                    CFRelease(attachments);
                }
                
                jpegData = [AVCaptureStillImageOutput jpegStillImageNSDataRepresentation:imageDataSampleBuffer];
                
                dispatch_async(dispatch_get_main_queue(), ^{
                    
                    if (completion)
                    {
                        completion(jpegData, metadata);
                    }
                });
            }
            else
            {
                GPLogErr(@"%@ %@", error, [error userInfo]);
            }
		}
	 ];
}

- (void)useTakenPicture
{
    GPLogIN();
    
    UIDeviceOrientation orientation = [_imageMetadata[@"deviceOrientation"] integerValue];
    ALAssetOrientation assetOrientation = [GPCameraViewController assetOrientationForDeviceOrientation:orientation];
    GPLog(@"asset orientation: %ld", (long)assetOrientation);
    
    ALAssetsLibrary *assetsLibrary = [[GPAssetsManager sharedManager] assetsLibrary];
    
    [assetsLibrary writeImageToSavedPhotosAlbum:[self.capturedImage CGImage]
                                    orientation:assetOrientation
                                completionBlock:^(NSURL *assetURL, NSError *error) {
                                    
                                    if (!error)
                                    {
                                        GPLog(@"Image saved to camera roll.");
                                        GPLog(@"assetURL: %@", assetURL);
                                        
                                        [assetsLibrary assetForURL:assetURL resultBlock:^(ALAsset *asset) {
                                            
                                            GPPhoto *photo = [[GPPhoto alloc] init];
                                            photo.asset = asset;
                                            
                                            GPAppDelegate *appDelegate = (GPAppDelegate *)[[UIApplication sharedApplication] delegate];
                                            [appDelegate dismissCameraViewController:self withPhoto:photo];
                                            
                                        } failureBlock:^(NSError *error) {
                                            
                                            GPLogErr(@"%@ %@", error, [error userInfo]);
                                            // TODO: Handle error
                                            
                                            [self.bottomToolbar.useButton setEnabled:YES];
                                        }];
                                    }
                                    else
                                    {
                                        GPLogErr(@"%@ %@", error, [error userInfo]);
                                        // TODO: Handle error
                                        
                                        [self.bottomToolbar.useButton setEnabled:YES];
                                    }
                                }];
    
    GPLogOUT();
}

- (void)setCapturedImage:(UIImage *)capturedImage
{
    GPLogIN();
    
    if (_capturedImage != capturedImage)
    {
        _capturedImage = capturedImage;
        
        if (capturedImage)
        {
            [self.capturedImageView setImage:capturedImage];
            self.capturedImageView.hidden = NO;
        }
        else
        {
            [self.capturedImageView setImage:nil];
            self.capturedImageView.hidden = YES;
        }
        
        [self updateUI];
    }
    
    GPLogOUT();
}

#if (CAMERA_BLUR_ENABLED)

- (void)captureOutput:(AVCaptureOutput *)captureOutput didOutputSampleBuffer:(CMSampleBufferRef)sampleBuffer
       fromConnection:(AVCaptureConnection *)connection
{
//    GPLogIN();
    
    @autoreleasepool {
        
        CVImageBufferRef imageBuffer = CMSampleBufferGetImageBuffer(sampleBuffer);
        
        /* Lock the image buffer */
        CVPixelBufferLockBaseAddress(imageBuffer, 0);
        
        /* Get information about the image */
        uint8_t *baseAddress = (uint8_t *)CVPixelBufferGetBaseAddress(imageBuffer);
        size_t bytesPerRow   = CVPixelBufferGetBytesPerRow(imageBuffer);
        size_t width         = CVPixelBufferGetWidth(imageBuffer);
        size_t height        = CVPixelBufferGetHeight(imageBuffer);
        
        /* Create a CGImageRef from the CVImageBufferRef */
        CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
        CGContextRef newContext = CGBitmapContextCreate(baseAddress,
                                                        width,
                                                        height,
                                                        8,
                                                        bytesPerRow,
                                                        colorSpace,
                                                        kCGBitmapByteOrder32Little | kCGImageAlphaPremultipliedFirst);
        CGImageRef cgImage = CGBitmapContextCreateImage(newContext);
        
//        GPLog(@"image size: h %zu, w %zu", height, width);
        
        // unlock the  image buffer
        CVPixelBufferUnlockBaseAddress(imageBuffer, 0);
        
        // release some components
        CGContextRelease(newContext);
        CGColorSpaceRelease(colorSpace);
        
        CGImageRef cgBlurredImage = [GPCameraViewController blurredImage:cgImage];
        CGImageRelease(cgImage);
        
        UIImage *result = [UIImage imageWithCGImage:cgBlurredImage];
        CGImageRelease(cgBlurredImage);
        
        __weak typeof(self) weakSelf = self;
        
        dispatch_async(dispatch_get_main_queue(), ^{
            
            weakSelf.blurImage = result;
            
            static UIApplicationState lastAppState = UIApplicationStateActive;
            static NSDate *lastAppStateChangeTime = nil;
            
            NSDate *now = [NSDate now];
            
            if (!lastAppStateChangeTime) {
                lastAppStateChangeTime = now;
            }
            
            UIApplicationState appState = [[UIApplication sharedApplication] applicationState];
            
            if (appState != lastAppState)
            {
                lastAppState = appState;
                lastAppStateChangeTime = now;
            }
            
            if ([now timeIntervalSinceDate:lastAppStateChangeTime] >= 0.3)
            {
                if (appState == UIApplicationStateInactive)
                {
                    GPLog(@"Application inactive, setting the blur image.");
                    
                    [weakSelf.blurLayer setContents:(__bridge id)([weakSelf.blurImage CGImage])];
                    [weakSelf.blurLayer setOpacity:1.0f];
                    [weakSelf updateUI];
                }
                else if (appState == UIApplicationStateActive)
                {
                    if ([weakSelf.blurLayer contents] != nil)
                    {
                        [weakSelf.blurLayer setContents:nil];
                        [weakSelf.blurLayer setOpacity:0.0f];
                        [weakSelf updateUI];
                    }
                }
            }
        });
    }
    
//    GPLogOUT();
}

#endif // CAMERA_BLUR_ENABLED

#pragma mark - App Notifications

- (void)appWillResignActive
{
    GPLogIN();
    [super appWillResignActive];
    
#if (CAMERA_BLUR_ENABLED)
    
    [self.session removeOutput:self.videoDataOutput];
    
    [CALayer performWithoutAnimation:^{
        
        [self.blurLayer setContents:(__bridge id)([self.blurImage CGImage])];
        
        CABasicAnimation *anim = [CABasicAnimation animationWithKeyPath:@"opacity"];
        anim.duration = 0.3;
        anim.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseOut];
        anim.fillMode = kCAFillModeForwards;
        anim.removedOnCompletion = YES;
        anim.fromValue = @(0.0f);
        anim.toValue = @(1.0f);
        [self.blurLayer addAnimation:anim forKey:@"blur-anim-show"];
        [self.blurLayer setOpacity:1.0f];
        [self updateUI];
    }];
    
    [self.session addOutput:self.videoDataOutput];
    
#endif
    
    GPLogOUT();
}

- (void)appDidBecomeActive
{
    GPLogIN();
    [super appDidBecomeActive];
    
    [self updateButtonsAnimated:YES];
    
#if (CAMERA_BLUR_ENABLED)
    
    [CALayer performWithoutAnimation:^{
        
        CABasicAnimation *anim = [CABasicAnimation animationWithKeyPath:@"opacity"];
        anim.duration = 0.3;
        anim.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseIn];
        anim.fillMode = kCAFillModeForwards;
        anim.removedOnCompletion = YES;
        anim.fromValue = @(1.0f);
        anim.toValue = @(0.0f);
        [self.blurLayer addAnimation:anim forKey:@"blur-anim-hide"];
        [self.blurLayer setOpacity:0.0f];
        
        [self updateUI];
    }];
    
#endif
    
    GPLogOUT();
}

- (void)appDidEnterBackground
{
    GPLogIN();
    [super appDidEnterBackground];
    
#if (CAMERA_BLUR_ENABLED)
    
    [self.blurLayer removeAllAnimations];
    
#endif
    
    GPLogOUT();
}

- (void)appWillEnterForeground
{
    GPLogIN();
    [super appWillEnterForeground];
    
    [[GPPermissionsManager sharedManager] requestAccessToAssetsLibrary:^(BOOL granted) {
        [self updateButtonsAnimated:YES];
    }];
    
    [self requestAccessToCamera];
    
    GPLogOUT();
}

#pragma mark - Device Orientation

- (void)deviceOrientationChanged:(NSNotification *)notification
{
    GPLogIN();
    
    [self updateButtonsRotationAnimated:YES];
    
    GPLogOUT();
}

// updates buttons rotation based on current device orientation
- (void)updateButtonsRotationAnimated:(BOOL)animated
{
    GPLogIN();
    
    UIDeviceOrientation deviceOrientation = [UIDevice currentDevice].orientation;
    
    if ((deviceOrientation != _deviceOrientation) && [self isOrientationSupported:(UIInterfaceOrientation)deviceOrientation])
    {
        [self rotateControlsToOrientation:deviceOrientation animated:animated];
        
        // save the new device orientation only if used, otherwise the conditions
        // will prevent buttons from being rotated when they actually need to
        _deviceOrientation = deviceOrientation;
    }
    
    GPLogOUT();
}

#pragma mark - Camera Running

- (void)captureSessionDidStartRunning:(NSNotification *)notification
{
    GPLogIN();
    
    __weak typeof(self) weakSelf = self;
    
    dispatch_async(dispatch_get_main_queue(), ^{
        
        if ([weakSelf.cameraOverlay opacity] > 0)
        {
            [CALayer performWithoutAnimation:^{
                
                CABasicAnimation *anim = [CABasicAnimation animationWithKeyPath:@"opacity"];
                anim.duration = 0.3;
                anim.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseIn];
                anim.fillMode = kCAFillModeForwards;
                anim.removedOnCompletion = YES;
                anim.fromValue = @(1.0f);
                anim.toValue = @(0.0f);
                [weakSelf.cameraOverlay addAnimation:anim forKey:@"fade"];
                [weakSelf.cameraOverlay setOpacity:0.0f];
                [weakSelf updateUI];
            }];
        }
        
        self.cameraRunning = YES;
    });
    
    GPLogOUT();
}

- (void)captureSessionDidStopRunning:(NSNotification *)notification
{
    GPLogIN();
    
    self.cameraRunning = NO;
    
    GPLogOUT();
}

- (void)setCameraRunning:(BOOL)cameraRunning
{
    GPLogIN();
    
    if (_cameraRunning != cameraRunning)
    {
        _cameraRunning = cameraRunning;
        [self updateButtonsAnimated:YES];
    }
    
    GPLogOUT();
}

- (void)setCapturingStillImage:(BOOL)capturingStillImage
{
    GPLogIN();
    
    if (_capturingStillImage != capturingStillImage)
    {
        GPLog(@"is capturing still image: %@", NSStringFromBOOL(capturingStillImage));
        _capturingStillImage = capturingStillImage;
        
        [self runStillImageCaptureAnimation];
        [self updateButtonsAnimated:YES];
    }
    
    GPLogOUT();
}

- (void)runStillImageCaptureAnimation
{
    if ([self isCapturingStillImage])
    {
        // do flash bulb like animation
        
        UIViewAnimationOptions options = UIViewAnimationOptionBeginFromCurrentState | UIViewAnimationOptionCurveEaseOut;
        
        [UIView animateWithDuration:kFlashBulbAnimationDuration / 2
                              delay:0
                            options:options
                         animations:^{
                             
                             self.flashView.alpha = 1;
                             
                         } completion:^(BOOL finished) {
                             
                             UIViewAnimationOptions options = UIViewAnimationOptionBeginFromCurrentState | UIViewAnimationOptionCurveEaseIn;
                             
                             [UIView animateWithDuration:kFlashBulbAnimationDuration / 2
                                                   delay:0
                                                 options:options
                                              animations:^{
                                                  
                                                  self.flashView.alpha = 0;
                                                  
                                              } completion:nil];
                         }];
    }
}

#pragma mark - Focus and Exposure

- (void)focusWithMode:(AVCaptureFocusMode)focusMode exposeWithMode:(AVCaptureExposureMode)exposureMode
        atDevicePoint:(CGPoint)point monitorSubjectAreaChange:(BOOL)monitorSubjectAreaChange
{
    GPLogIN();
    GPLog(@"point: %@", NSStringFromCGPoint(point));
    
	dispatch_async(self.sessionQueue, ^{
        
		AVCaptureDevice *device = [self.cameraDeviceInput device];
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
    
	CGPoint devicePoint = [self.cameraView.videoLayer captureDevicePointOfInterestForPoint:[tapGr locationInView:tapGr.view]];
    
	[self focusWithMode:AVCaptureFocusModeContinuousAutoFocus exposeWithMode:AVCaptureExposureModeContinuousAutoExposure
          atDevicePoint:devicePoint monitorSubjectAreaChange:YES];
    
    GPLogOUT();
}

#pragma mark - Device Authorization

- (BOOL)isSessionRunningAndDeviceAuthorized
{
	return [self.session isRunning] && [self isDeviceAuthorized];
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
                 
                 GPLogErr(@"AVCam doesn't have permission to use Camera, please change privacy settings");
                 
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

- (void)requestAccessToCamera
{
    GPLogIN();
    
    [[GPPermissionsManager sharedManager] requestAccessToCamera:^(BOOL granted) {
        
        [self updateButtonsAnimated:YES];
        
        if (!granted)
        {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle: @"Privacy"
                                                            message: @"Goopic doesn't have permission to use the camera, please change this in privacy settings."
                                                           delegate: nil
                                                  cancelButtonTitle: @"OK"
                                                  otherButtonTitles: nil];
            [self showAlert:alert];
        }
    }];
    
    GPLogOUT();
}

#pragma mark - Toolbar Delegate

- (void)toolbar:(id)toolbar didSelectButton:(GPButton *)button
{
    GPLogIN();
    GPLog(@"button: %@", button);
    
    if (toolbar == self.topToolbar)
    {
        GPLog(@"flash selection changed");
        
        [self updateFlash];
    }
    else // bottom toolbar
    {
        button.enabled = NO;
        
        if (button == self.bottomToolbar.cancelButton)
        {
            [self dismissViewControllerAnimated:YES completion:^{
                button.enabled = YES;
            }];
        }
        else if (button == self.bottomToolbar.takeButton)
        {
            [self takePicture:^(NSData *jpegData, id metadata) {
                
                GPLog(@"metadata: %@", metadata);
                
                if (jpegData && metadata)
                {
                    self.capturedImage = [UIImage imageWithData:jpegData];
                    metadata[@"deviceOrientation"] = @(_deviceOrientation);
                    _imageMetadata = metadata;
                    
                    [self updateButtonsAnimated:YES];
                }
                else
                {
                    GPLogErr(@"Captured image is invalid.");
                    
                    // TODO: Handle error
                }
            }];
        }
        else if (button == self.bottomToolbar.retakeButton)
        {
            self.capturedImage = nil;
            [self updateButtonsAnimated:YES];
        }
        else if (button == self.bottomToolbar.useButton)
        {
            [self useTakenPicture];
        }
    }
    
    GPLogOUT();
}

@end
