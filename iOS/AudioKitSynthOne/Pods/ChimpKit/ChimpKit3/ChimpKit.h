//
//  ChimpKit.h
//  ChimpKit3
//
//  Created by Drew Conner on 1/7/13.
//  Copyright (c) 2013 MailChimp. All rights reserved.
//

#import <Foundation/Foundation.h>


#define kCKDebug					0
#define kDefaultTimeoutInterval		15.0f


typedef enum {
	kChimpKitErrorInvalidAPIKey = 0,
	kChimpKitErrorInvalidDelegate,
	kChimpKitErrorInvalidCompletionHandler
} ChimpKitError;


@protocol ChimpKitRequestDelegate <NSObject>

@optional
- (void)ckRequestIdentifier:(NSUInteger)requestIdentifier didUploadBytes:(int64_t)bytes outOfBytes:(int64_t)totalBytes;
- (void)ckRequestIdentifier:(NSUInteger)requestIdentifier didSucceedWithResponse:(NSURLResponse *)response andData:(NSData *)data;
- (void)ckRequestFailedWithIdentifier:(NSUInteger)requestIdentifier andError:(NSError *)anError;

@end


typedef void (^ChimpKitRequestCompletionBlock)(NSURLResponse *response, NSData *data, NSError *error);


@interface ChimpKit : NSObject

@property (nonatomic, strong) NSString *apiKey;
@property (nonatomic, strong) NSString *apiURL;
@property (nonatomic, assign) NSTimeInterval timeoutInterval;
@property (nonatomic, assign) BOOL shouldUseBackgroundThread;

+ (ChimpKit *)sharedKit;

// Returns unique identifier for each request
- (NSUInteger)callApiMethod:(NSString *)aMethod
				 withParams:(NSDictionary *)someParams
	   andCompletionHandler:(ChimpKitRequestCompletionBlock)aHandler;

- (NSUInteger)callApiMethod:(NSString *)aMethod
				 withParams:(NSDictionary *)someParams
				andDelegate:(id<ChimpKitRequestDelegate>)aDelegate;

// If these methods are called with a nil apikey, ChimpKit falls back to
// using the global apikey
- (NSUInteger)callApiMethod:(NSString *)aMethod
				 withApiKey:(NSString *)anApiKey
					 params:(NSDictionary *)someParams
	   andCompletionHandler:(ChimpKitRequestCompletionBlock)aHandler;

- (NSUInteger)callApiMethod:(NSString *)aMethod
				 withApiKey:(NSString *)anApiKey
					 params:(NSDictionary *)someParams
				andDelegate:(id<ChimpKitRequestDelegate>)aDelegate;

- (void)cancelRequestWithIdentifier:(NSUInteger)requestIdentifier;

@end
