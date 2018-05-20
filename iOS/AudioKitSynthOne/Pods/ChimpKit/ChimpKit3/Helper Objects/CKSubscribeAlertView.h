//
//  CKSubscribeAlertView.h
//  ChimpKit3
//
//  Created by Drew Conner on 1/7/13.
//  Copyright (c) 2013 MailChimp. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CKSubscribeAlertView : UIAlertView <UITextFieldDelegate, UIAlertViewDelegate> 

- (id)initWithTitle:(NSString *)title
            message:(NSString *)message
             listId:(NSString *)aListId
  cancelButtonTitle:(NSString *)cancelButtonTitle
subscribeButtonTitle:(NSString *)subscribeButtonTitle;

- (id)initWithTitle:(NSString *)title
            message:(NSString *)message
             listId:(NSString *)aListId
  cancelButtonTitle:(NSString *)cancelButtonTitle
subscribeButtonTitle:(NSString *)subscribeButtonTitle
        doubleOptIn:(BOOL)doubleOptIn;

@end
