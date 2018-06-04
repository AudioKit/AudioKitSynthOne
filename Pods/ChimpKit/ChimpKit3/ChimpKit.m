//
//  ChimpKit.m
//  ChimpKit3
//
//  Created by Drew Conner on 1/7/13.
//  Copyright (c) 2013 MailChimp. All rights reserved.
//

#import "ChimpKit.h"


#define kAPI20Endpoint	@"https://%@.api.mailchimp.com/2.0/"
#define kErrorDomain	@"com.MailChimp.ChimpKit.ErrorDomain"


@interface ChimpKit () <NSURLSessionTaskDelegate>

@property (nonatomic, strong) NSURLSession *urlSession;
@property (nonatomic, strong) NSMutableDictionary *requests;

@end


@interface ChimpKitRequestWrapper : NSObject

@property (nonatomic, strong) NSURLSessionDataTask *dataTask;
@property (nonatomic, strong) NSMutableData *receivedData;

@property (nonatomic, copy) ChimpKitRequestCompletionBlock completionHandler;
@property (nonatomic, strong) id<ChimpKitRequestDelegate> delegate;

@end


@implementation ChimpKit

#pragma mark - Class Methods

+ (ChimpKit *)sharedKit {
	static dispatch_once_t pred = 0;
	__strong static ChimpKit *_sharedKit = nil;
	
	dispatch_once(&pred, ^{
		_sharedKit = [[self alloc] init];
	});
	
	return _sharedKit;
}

- (id)init {
	if (self = [super init]) {
		self.timeoutInterval = kDefaultTimeoutInterval;
		self.requests = [[NSMutableDictionary alloc] init];
	}
	
	return self;
}


#pragma mark - Properties

- (NSURLSession *)urlSession {
	if (_urlSession == nil) {
		_urlSession = [NSURLSession sessionWithConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration]
													delegate:self
											   delegateQueue:nil];
	}
	
	return _urlSession;
}

- (void)setApiKey:(NSString *)apiKey {
	_apiKey = apiKey;
	
	if (_apiKey) {
		// Parse out the datacenter and template it into the URL.
		NSArray *apiKeyParts = [_apiKey componentsSeparatedByString:@"-"];
		if ([apiKeyParts count] > 1) {
			self.apiURL = [NSString stringWithFormat:kAPI20Endpoint, [apiKeyParts objectAtIndex:1]];
		} else {
			NSAssert(FALSE, @"Please provide a valid API Key");
		}
	}
}


#pragma mark - API Methods

- (NSUInteger)callApiMethod:(NSString *)aMethod withParams:(NSDictionary *)someParams andCompletionHandler:(ChimpKitRequestCompletionBlock)aHandler {
    return [self callApiMethod:aMethod withApiKey:nil params:someParams andCompletionHandler:aHandler];
}

- (NSUInteger)callApiMethod:(NSString *)aMethod withApiKey:(NSString *)anApiKey params:(NSDictionary *)someParams andCompletionHandler:(ChimpKitRequestCompletionBlock)aHandler {
	if (aHandler == nil) {
		return 0;
	}
    
	return [self callApiMethod:aMethod withApiKey:anApiKey params:someParams andCompletionHandler:aHandler orDelegate:nil];
}

- (NSUInteger)callApiMethod:(NSString *)aMethod withParams:(NSDictionary *)someParams andDelegate:(id<ChimpKitRequestDelegate>)aDelegate {
    return [self callApiMethod:aMethod withApiKey:nil params:someParams andDelegate:aDelegate];
}

- (NSUInteger)callApiMethod:(NSString *)aMethod withApiKey:(NSString *)anApiKey params:(NSDictionary *)someParams andDelegate:(id<ChimpKitRequestDelegate>)aDelegate {
	if (aDelegate == nil) {
		return 0;
	}
    
	return [self callApiMethod:aMethod withApiKey:anApiKey params:someParams andCompletionHandler:nil orDelegate:aDelegate];
}

- (NSUInteger)callApiMethod:(NSString *)aMethod withApiKey:(NSString *)anApiKey params:(NSDictionary *)someParams andCompletionHandler:(ChimpKitRequestCompletionBlock)aHandler orDelegate:(id<ChimpKitRequestDelegate>)aDelegate {
	if ((anApiKey == nil) && (self.apiKey == nil)) {
		NSError *error = [NSError errorWithDomain:kErrorDomain code:kChimpKitErrorInvalidAPIKey userInfo:nil];
		
		if (aDelegate && [aDelegate respondsToSelector:@selector(ckRequestFailedWithIdentifier:andError:)]) {
			[aDelegate ckRequestFailedWithIdentifier:0 andError:error];
		}
		
		if (aHandler) {
			aHandler(nil, nil, error);
		}
		
		return 0;
	}
	
	NSString *urlString = nil;
	NSMutableDictionary *params = [NSMutableDictionary dictionaryWithDictionary:someParams];
	
	if (anApiKey) {
		NSArray *apiKeyParts = [anApiKey componentsSeparatedByString:@"-"];
		if ([apiKeyParts count] > 1) {
			NSString *apiURL = [NSString stringWithFormat:kAPI20Endpoint, [apiKeyParts objectAtIndex:1]];
			urlString = [NSString stringWithFormat:@"%@%@", apiURL, aMethod];
		} else {
            NSError *error = [NSError errorWithDomain:kErrorDomain code:kChimpKitErrorInvalidAPIKey userInfo:nil];

			if (aDelegate && [aDelegate respondsToSelector:@selector(ckRequestFailedWithIdentifier:andError:)]) {
				[aDelegate ckRequestFailedWithIdentifier:0 andError:error];
			}
            
            if (aHandler) {
                aHandler(nil, nil, error);
            }
			
			return 0;
		}
		
		[params setValue:anApiKey forKey:@"apikey"];
	} else if (self.apiKey) {
		urlString = [NSString stringWithFormat:@"%@%@", self.apiURL, aMethod];
		[params setValue:self.apiKey forKey:@"apikey"];
	}
	
	if (kCKDebug) NSLog(@"URL: %@", urlString);
	
	NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:[NSURL URLWithString:urlString]
																cachePolicy:NSURLRequestUseProtocolCachePolicy
															timeoutInterval:self.timeoutInterval];
	
	[request setHTTPMethod:@"POST"];
	[request setHTTPBody:[self encodeRequestParams:params]];
	
	NSURLSessionDataTask *dataTask = [self.urlSession dataTaskWithRequest:request];
	
	ChimpKitRequestWrapper *requestWrapper = [[ChimpKitRequestWrapper alloc] init];
	
	requestWrapper.dataTask = dataTask;
	requestWrapper.delegate = aDelegate;
	requestWrapper.completionHandler = aHandler;
	
	[dataTask resume];
	
	[self.requests setObject:requestWrapper forKey:[NSNumber numberWithUnsignedInteger:[dataTask taskIdentifier]]];
	
	return [dataTask taskIdentifier];
}

- (void)cancelRequestWithIdentifier:(NSUInteger)identifier {
	ChimpKitRequestWrapper *requestWrapper = [self.requests objectForKey:[NSNumber numberWithUnsignedInteger:identifier]];
	
	[requestWrapper.dataTask cancel];
	
	[self.requests removeObjectForKey:[NSNumber numberWithUnsignedInteger:identifier]];
}


#pragma mark - <NSURLSessionTaskDelegate> Methods

- (void)URLSession:(NSURLSession *)session task:(NSURLSessionTask *)task didSendBodyData:(int64_t)bytesSent totalBytesSent:(int64_t)totalBytesSent totalBytesExpectedToSend:(int64_t)totalBytesExpectedToSend {
	ChimpKitRequestWrapper *requestWrapper = [self.requests objectForKey:[NSNumber numberWithUnsignedInteger:[task taskIdentifier]]];
	
	if (requestWrapper.delegate && [requestWrapper.delegate respondsToSelector:@selector(ckRequestIdentifier:didUploadBytes:outOfBytes:)]) {
		[requestWrapper.delegate ckRequestIdentifier:[task  taskIdentifier]
									  didUploadBytes:totalBytesSent
										  outOfBytes:totalBytesExpectedToSend];
	}
}

- (void)URLSession:(NSURLSession *)session dataTask:(NSURLSessionDataTask *)dataTask didReceiveData:(NSData *)data {
	ChimpKitRequestWrapper *requestWrapper = [self.requests objectForKey:[NSNumber numberWithUnsignedInteger:[dataTask taskIdentifier]]];
	[requestWrapper.receivedData appendData:data];
}

- (void)URLSession:(NSURLSession *)session task:(NSURLSessionTask *)task didCompleteWithError:(NSError *)error {
	ChimpKitRequestWrapper *requestWrapper = [self.requests objectForKey:[NSNumber numberWithUnsignedInteger:[task taskIdentifier]]];
	
	if (requestWrapper.completionHandler) {
		requestWrapper.completionHandler(task.response, requestWrapper.receivedData, error);
	} else {
		if (error) {
			if (requestWrapper.delegate && [requestWrapper.delegate respondsToSelector:@selector(ckRequestFailedWithIdentifier:andError:)]) {
				[requestWrapper.delegate ckRequestFailedWithIdentifier:[task taskIdentifier]
															  andError:error];
			}
		} else {
			if (requestWrapper.delegate && [requestWrapper.delegate respondsToSelector:@selector(ckRequestIdentifier:didSucceedWithResponse:andData:)]) {
				[requestWrapper.delegate ckRequestIdentifier:[task taskIdentifier]
									  didSucceedWithResponse:task.response
													 andData:requestWrapper.receivedData];
			}
		}
	}
	
	[self.requests removeObjectForKey:[NSNumber numberWithUnsignedInteger:[task taskIdentifier]]];
}


#pragma mark - Private Methods

- (NSMutableData *)encodeRequestParams:(NSDictionary *)params {
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:params options:0 error:nil];
    NSString *jsonString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
    
    NSMutableData *postData = [NSMutableData dataWithData:[jsonString dataUsingEncoding:NSUTF8StringEncoding]];
	
    return postData;
}


@end


@implementation ChimpKitRequestWrapper

- (id)init {
	if (self = [super init]) {
		self.receivedData = [[NSMutableData alloc] init];
	}
	
	return self;
}

@end
