//
//  CKScanViewController.m
//  ChimpKitSampleApp
//
//  Created by Drew Conner on 10/29/13.
//  Copyright (c) 2013 MailChimp. All rights reserved.
//

#import <AVFoundation/AVFoundation.h>
#import "CKScanViewController.h"


@interface CKScanViewController () <AVCaptureMetadataOutputObjectsDelegate>

@property (nonatomic, strong) AVCaptureSession *captureSession;
@property (nonatomic, strong) AVCaptureMetadataOutput *metadataOutput;
@property (nonatomic, strong) AVCaptureVideoPreviewLayer *previewLayer;

@end


@implementation CKScanViewController


#pragma mark - View Lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];
	
	self.title = @"Scan API Key";
	
	if ([[[UIDevice currentDevice] systemVersion] floatValue] < 7.0) {
		// TODO: Show iOS7 Required Message
	} else {
		self.captureSession = [[AVCaptureSession alloc] init];
		
		AVCaptureDevice *videoCaptureDevice = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
		NSError *error = nil;
		AVCaptureDeviceInput *videoInput = [AVCaptureDeviceInput deviceInputWithDevice:videoCaptureDevice error:&error];
		
		if (videoInput) {
			[self.captureSession addInput:videoInput];
		} else {
			NSLog(@"Video Capture Error: %@", error);
		}
		
		self.metadataOutput = [[AVCaptureMetadataOutput alloc] init];
		[self.captureSession addOutput:self.metadataOutput];
		[self.metadataOutput setMetadataObjectsDelegate:self queue:dispatch_get_main_queue()];
		[self.metadataOutput setMetadataObjectTypes:@[AVMetadataObjectTypeQRCode]];
		
		self.previewLayer = [[AVCaptureVideoPreviewLayer alloc] initWithSession:self.captureSession];
		self.previewLayer.frame = self.view.layer.bounds;
		[self.view.layer addSublayer:self.previewLayer];
		
		[self.captureSession startRunning];
	}
	
	if ([self.navigationController.viewControllers objectAtIndex:0] == self) {
		self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel
																							  target:self
																							  action:@selector(cancelButtonTapped:)];
	}
}

- (void)willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration {
	[CATransaction begin];
    [CATransaction setValue:[NSNumber numberWithFloat:duration] forKey:kCATransactionAnimationDuration];
	
    if (self.previewLayer) {
        if (toInterfaceOrientation == UIInterfaceOrientationPortrait) {
            self.previewLayer.affineTransform = CGAffineTransformMakeRotation(0);
        } else if (toInterfaceOrientation == UIInterfaceOrientationLandscapeLeft) {
            self.previewLayer.affineTransform = CGAffineTransformMakeRotation(M_PI/2);
		} else if (toInterfaceOrientation == UIInterfaceOrientationPortraitUpsideDown) {
			self.previewLayer.affineTransform = CGAffineTransformMakeRotation(M_PI);
        } else if (toInterfaceOrientation == UIInterfaceOrientationLandscapeRight) {
            self.previewLayer.affineTransform = CGAffineTransformMakeRotation(-M_PI/2);
        }
		
        self.previewLayer.frame = self.view.bounds;
    }
	
	[CATransaction commit];
}

- (void)dealloc {
	[self.previewLayer removeFromSuperlayer];
	self.previewLayer = nil;
	
	[self.captureSession stopRunning];
	self.captureSession = nil;
}


#pragma mark - Public Methods

- (void)restartScanning {
	if (self.metadataOutput == nil) {
		self.metadataOutput = [[AVCaptureMetadataOutput alloc] init];
		[self.captureSession addOutput:self.metadataOutput];
		[self.metadataOutput setMetadataObjectsDelegate:self queue:dispatch_get_main_queue()];
		[self.metadataOutput setMetadataObjectTypes:@[AVMetadataObjectTypeQRCode]];
	}
}


#pragma mark - UI Actions

- (void)cancelButtonTapped:(id)sender {
	if (self.userCancelled) {
		self.userCancelled();
	}
}


#pragma mark <AVCaptureMetadataOutputObjectsDelegate> Methods

- (void)captureOutput:(AVCaptureOutput *)captureOutput didOutputMetadataObjects:(NSArray *)metadataObjects fromConnection:(AVCaptureConnection *)connection {
    for(AVMetadataObject *metadataObject in metadataObjects) {
        AVMetadataMachineReadableCodeObject *readableObject = (AVMetadataMachineReadableCodeObject *)metadataObject;
        if ([metadataObject.type isEqualToString:AVMetadataObjectTypeQRCode]) {
			if (self.apiKeyFound) {
				self.apiKeyFound(readableObject.stringValue);
				
				[self.captureSession removeOutput:self.metadataOutput];
				self.metadataOutput = nil;
			}
        }
    }
}


@end
