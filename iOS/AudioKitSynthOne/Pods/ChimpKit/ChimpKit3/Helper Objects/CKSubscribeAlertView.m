//
//  CKSubscribeAlertView.m
//  ChimpKit3
//
//  Created by Drew Conner on 1/7/13.
//  Copyright (c) 2013 MailChimp. All rights reserved.
//

#import "CKSubscribeAlertView.h"
#import "ChimpKit.h"


@interface CKSubscribeAlertView()

@property (nonatomic, strong) NSString *listId;
@property (nonatomic) BOOL doubleOptIn;

@end


@implementation CKSubscribeAlertView


#pragma mark - Initialization

- (id)initWithTitle:(NSString *)title
            message:(NSString *)message
             listId:(NSString *)aListId
cancelButtonTitle:(NSString *)cancelButtonTitle
subscribeButtonTitle:(NSString *)subscribeButtonTitle
        doubleOptIn:(BOOL)doubleOptIn {

	self = [super initWithTitle:title
                        message:message
                       delegate:nil
              cancelButtonTitle:cancelButtonTitle
              otherButtonTitles:subscribeButtonTitle, nil];
	
    if (self) {
        //Set the delegate to self so we can handle button presses
        self.delegate = self;
        
        self.alertViewStyle = UIAlertViewStylePlainTextInput;
        
        UITextField *textField = [self textFieldAtIndex:0];
		
		// Common text field properties
		textField.placeholder = @"Email Address";
		textField.keyboardType = UIKeyboardTypeEmailAddress;
		textField.autocorrectionType = UITextAutocorrectionTypeNo;
		textField.autocapitalizationType = UITextAutocapitalizationTypeNone;
        
        self.listId = aListId;
        
        self.doubleOptIn = doubleOptIn;
    }
	
    return self;
}

- (id)initWithTitle:(NSString *)title
            message:(NSString *)message
            listId:(NSString *)aListId
  cancelButtonTitle:(NSString *)cancelButtonTitle
  subscribeButtonTitle:(NSString *)subscribeButtonTitle {
    
    return [self initWithTitle:title
                       message:message
                        listId:aListId
             cancelButtonTitle:cancelButtonTitle
          subscribeButtonTitle:subscribeButtonTitle
                   doubleOptIn:NO];
}


#pragma mark - Private Methods

- (void)showSubscribeError {
    UIAlertView *errorAlertView = [[UIAlertView alloc] initWithTitle:@"Subscription Failed"
                                                             message:@"We couldn't subscribe you to the list.  Please check your email address and try again."
                                                            delegate:nil
                                                   cancelButtonTitle:@"OK"
                                                   otherButtonTitles:nil];
    [errorAlertView show];
}


#pragma mark - <UIAlertViewDelegate> Methods

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (buttonIndex == 1) { // Subscribe pressed
		UITextField *textField = [self textFieldAtIndex:0];
		
        NSMutableDictionary *params = [NSMutableDictionary dictionary];
        params[@"id"] = self.listId;
        params[@"email"] = @{@"email": textField.text};
        params[@"double_optin"] = (self.doubleOptIn ? @"true" : @"false");
        params[@"update_existing"] = @"true";
		
		[[ChimpKit sharedKit] callApiMethod:@"lists/subscribe"
								 withParams:params
					   andCompletionHandler:^(NSURLResponse *response, NSData *data, NSError *error) {
						   NSString *responseString = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
						   if (kCKDebug) NSLog(@"Response String: %@", responseString);
						   
                           id parsedResponse = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
                           
                           if (![parsedResponse isKindOfClass:[NSDictionary class]] || ![parsedResponse[@"email"] isKindOfClass:[NSString class]] || error) {
							   [self showSubscribeError];
                           }
					   }];
    }
}


@end
