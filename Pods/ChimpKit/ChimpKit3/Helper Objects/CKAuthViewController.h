//
//  CKAuthViewController.h
//  ChimpKit2
//
//  Created by Amro Mousa on 8/16/11.
//  Copyright (c) 2011 MailChimp. All rights reserved.
//

#import <UIKit/UIKit.h>


#define kCKAuthDebug        1

#define kAuthorizeUrl           @"https://login.mailchimp.com/oauth2/authorize"
#define kAccessTokenUrl         @"https://login.mailchimp.com/oauth2/token"
#define kMetaDataUrl            @"https://login.mailchimp.com/oauth2/metadata"
#define kDefaultRedirectUrl     @"https://modev1.mailchimp.com/wait.html"


@protocol CKAuthViewControllerDelegate <NSObject>

// You must dismiss the Auth View in all of these methods
- (void)ckAuthUserCanceled;
- (void)ckAuthSucceededWithApiKey:(NSString *)apiKey andAccountData:(NSDictionary *)accountData;
- (void)ckAuthFailedWithError:(NSError *)error;

@end


@interface CKAuthViewController : UIViewController <UIWebViewDelegate>

@property (unsafe_unretained, readwrite) id<CKAuthViewControllerDelegate> delegate;

@property (nonatomic, assign) BOOL enableMultipleLogin;

@property (nonatomic, assign) BOOL disableCancelling;
@property (nonatomic, assign) BOOL disableAPIKeyScanning;
@property (nonatomic, assign) BOOL disableAccountDataFetching;

@property (strong, nonatomic) NSString *clientId;
@property (strong, nonatomic) NSString *clientSecret;
@property (strong, nonatomic) NSString *redirectUrl;

@property (strong, nonatomic) IBOutlet UIActivityIndicatorView *spinner;
@property (strong, nonatomic) IBOutlet UIWebView *webview;

- (id)initWithClientId:(NSString *)cId andClientSecret:(NSString *)cSecret;
- (id)initWithClientId:(NSString *)cId clientSecret:(NSString *)cSecret andRedirectUrl:(NSString *)redirectUrl;

@property (nonatomic, copy) void (^authSucceeded)(NSString *apiKey, NSDictionary *accountData);
@property (nonatomic, copy) void (^authFailed)(NSError *error);
@property (nonatomic, copy) void (^userCancelled)(void);

@end
