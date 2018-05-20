//
//  CKScanViewController.h
//  ChimpKitSampleApp
//
//  Created by Drew Conner on 10/29/13.
//  Copyright (c) 2013 MailChimp. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CKScanViewController : UIViewController

@property (nonatomic, copy) void (^apiKeyFound)(NSString *apiKey);
@property (nonatomic, copy) void (^userCancelled)(void);

- (void)restartScanning;

@end
