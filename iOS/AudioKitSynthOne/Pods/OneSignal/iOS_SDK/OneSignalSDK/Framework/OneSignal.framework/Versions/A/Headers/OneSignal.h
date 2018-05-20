/**
 * Modified MIT License
 *
 * Copyright 2017 OneSignal
 *
 * Permission is hereby granted, free of charge, to any person obtaining a copy
 * of this software and associated documentation files (the "Software"), to deal
 * in the Software without restriction, including without limitation the rights
 * to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 * copies of the Software, and to permit persons to whom the Software is
 * furnished to do so, subject to the following conditions:
 *
 * 1. The above copyright notice and this permission notice shall be included in
 * all copies or substantial portions of the Software.
 *
 * 2. All copies of substantial portions of the Software may only be used in connection
 * with services provided by OneSignal.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 * OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
 * THE SOFTWARE.
 */

/***
 
 ### Setting up the SDK ###
 Follow the documentation from https://documentation.onesignal.com/docs/ios-sdk-setupto setup OneSignal in your app.
 
 ### API Reference ###
 Follow the documentation from https://documentation.onesignal.com/docs/ios-sdk-api for a detailed explanation of the API.
 
 ### Troubleshoot ###
 Follow the documentation from https://documentation.onesignal.com/docs/troubleshooting-ios to fix common problems.
 
 For help on how to upgrade your code from 1.* SDK to 2.*: https://documentation.onesignal.com/docs/upgrading-to-ios-sdk-20
 
 ### More ###
 iOS Push Cert: https://documentation.onesignal.com/docs/generating-an-ios-push-certificate
 
***/

#import <Foundation/Foundation.h>

#if __IPHONE_OS_VERSION_MAX_ALLOWED >= 100000
#define XC8_AVAILABLE 1
#import <UserNotifications/UserNotifications.h>
#endif


#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wstrict-prototypes"
#pragma clang diagnostic ignored "-Wnullability-completeness"

/* The action type associated to an OSNotificationAction object */
typedef NS_ENUM(NSUInteger, OSNotificationActionType)  {
    OSNotificationActionTypeOpened,
    OSNotificationActionTypeActionTaken
};

/* The way a notification was displayed to the user */
typedef NS_ENUM(NSUInteger, OSNotificationDisplayType) {
    /*Notification is silent, or app is in focus but InAppAlertNotifications are disabled*/
    OSNotificationDisplayTypeNone,
    
    /*Default UIAlertView display*/
    OSNotificationDisplayTypeInAppAlert,
    
    /*iOS native notification display*/
    OSNotificationDisplayTypeNotification
};


@interface OSNotificationAction : NSObject

/* The type of the notification action */
@property(readonly)OSNotificationActionType type;

/* The ID associated with the button tapped. NULL when the actionType is NotificationTapped or InAppAlertClosed */
@property(readonly)NSString* actionID;

@end


// #### Notification Payload Received Object

@interface OSNotificationPayload : NSObject

/* Unique Message Identifier */
@property(readonly)NSString* notificationID;

/* Unique Template Identifier */
@property(readonly)NSString* templateID;

/* Name of Template */
@property(readonly)NSString* templateName;

/* True when the key content-available is set to 1 in the aps payload.
   content-available is used to wake your app when the payload is received.
   See Apple's documenation for more details.
  https://developer.apple.com/documentation/uikit/uiapplicationdelegate/1623013-application
*/
@property(readonly)BOOL contentAvailable;

/* True when the key mutable-content is set to 1 in the aps payload.
 mutable-content is used to wake your Notification Service Extension to modify a notification.
 See Apple's documenation for more details.
 https://developer.apple.com/documentation/usernotifications/unnotificationserviceextension
 */
@property(readonly)BOOL mutableContent;

/*
 Notification category key previously registered to display with.
 This overrides OneSignal's actionButtons.
 See Apple's documenation for more details.
 https://developer.apple.com/library/content/documentation/NetworkingInternet/Conceptual/RemoteNotificationsPG/SupportingNotificationsinYourApp.html#//apple_ref/doc/uid/TP40008194-CH4-SW26
*/
@property(readonly)NSString* category;

/* The badge assigned to the application icon */
@property(readonly)NSUInteger badge;
@property(readonly)NSInteger badgeIncrement;

/* The sound parameter passed to the notification
 By default set to UILocalNotificationDefaultSoundName */
@property(readonly)NSString* sound;

/* Main push content */
@property(readonly)NSString* title;
@property(readonly)NSString* subtitle;
@property(readonly)NSString* body;

/* Web address to launch within the app via a UIWebView */
@property(readonly)NSString* launchURL;

/* Additional key value properties set within the payload */
@property(readonly)NSDictionary* additionalData;

/* iOS 10+ : Attachments sent as part of the rich notification */
@property(readonly)NSDictionary* attachments;

/* Action buttons passed */
@property(readonly)NSArray *actionButtons;

/* Holds the original payload received
 Keep the raw value for users that would like to root the push */
@property(readonly)NSDictionary *rawPayload;

@end

// ## OneSignal OSNotification
@interface OSNotification : NSObject

/* Notification Payload */
@property(readonly)OSNotificationPayload* payload;

/* Display method of the notification */
@property(readonly)OSNotificationDisplayType displayType;

/* Set to true when the user was able to see the notification and reacted to it
 Set to false when app is in focus and in-app alerts are disabled, or the remote notification is silent. */
@property(readonly, getter=wasShown)BOOL shown;

/* Set to true if the app was in focus when the notification  */
@property(readonly, getter=wasAppInFocus)BOOL isAppInFocus;

/* Set to true when the received notification is silent
 Silent means there is no alert, sound, or badge payload in the aps dictionary
 requires remote-notification within UIBackgroundModes array of the Info.plist */
@property(readonly, getter=isSilentNotification)BOOL silentNotification;

/* iOS 10+: Indicates whether or not the received notification has mutableContent : 1 assigned to its payload
 Used for UNNotificationServiceExtension to launch extension.
*/
#if XC8_AVAILABLE
@property(readonly, getter=hasMutableContent)BOOL mutableContent;
#endif

/* Convert object into an NSString that can be convertible into a custom Dictionary / JSON Object */
- (NSString*)stringify;

@end


@interface OSNotificationOpenedResult : NSObject

@property(readonly)OSNotification* notification;
@property(readonly)OSNotificationAction *action;

/* Convert object into an NSString that can be convertible into a custom Dictionary / JSON Object */
- (NSString*)stringify;

@end;


typedef NS_ENUM(NSInteger, OSNotificationPermission) {
    // The user has not yet made a choice regarding whether your app can show notifications.
    OSNotificationPermissionNotDetermined = 0,
    
    // The application is not authorized to post user notifications.
    OSNotificationPermissionDenied,
    
    // The application is authorized to post user notifications.
    OSNotificationPermissionAuthorized
};



// Permission Classes
@interface OSPermissionState : NSObject

@property (readonly, nonatomic) BOOL hasPrompted;
@property (readonly, nonatomic) OSNotificationPermission status;
- (NSDictionary*)toDictionary;

@end

@interface OSPermissionStateChanges : NSObject

@property (readonly) OSPermissionState* to;
@property (readonly) OSPermissionState* from;
- (NSDictionary*)toDictionary;

@end

@protocol OSPermissionObserver <NSObject>
- (void)onOSPermissionChanged:(OSPermissionStateChanges*)stateChanges;
@end


// Subscription Classes
@interface OSSubscriptionState : NSObject

@property (readonly, nonatomic) BOOL subscribed; // (yes only if userId, pushToken, and setSubscription exists / are true)
@property (readonly, nonatomic) BOOL userSubscriptionSetting; // returns setSubscription state.
@property (readonly, nonatomic) NSString* userId;    // AKA OneSignal PlayerId
@property (readonly, nonatomic) NSString* pushToken; // AKA Apple Device Token
- (NSDictionary*)toDictionary;

@end


@interface OSEmailSubscriptionState : NSObject
@property (readonly, nonatomic) NSString* emailUserId; // The new Email user ID
@property (readonly, nonatomic) NSString *emailAddress;
@property (readonly, nonatomic) BOOL subscribed;
- (NSDictionary*)toDictionary;
@end

@interface OSSubscriptionStateChanges : NSObject
@property (readonly) OSSubscriptionState* to;
@property (readonly) OSSubscriptionState* from;
- (NSDictionary*)toDictionary;
@end

@interface OSEmailSubscriptionStateChanges : NSObject
@property (readonly) OSEmailSubscriptionState* to;
@property (readonly) OSEmailSubscriptionState* from;
- (NSDictionary*)toDictionary;
@end

@protocol OSSubscriptionObserver <NSObject>
- (void)onOSSubscriptionChanged:(OSSubscriptionStateChanges*)stateChanges;
@end

@protocol OSEmailSubscriptionObserver <NSObject>
- (void)onOSEmailSubscriptionChanged:(OSEmailSubscriptionStateChanges*)stateChanges;
@end



// Permission+Subscription Classes
@interface OSPermissionSubscriptionState : NSObject

@property (readonly) OSPermissionState* permissionStatus;
@property (readonly) OSSubscriptionState* subscriptionStatus;
@property (readonly) OSEmailSubscriptionState *emailSubscriptionStatus;
- (NSDictionary*)toDictionary;

@end


typedef void (^OSWebOpenURLResultBlock)(BOOL shouldOpen);

typedef void (^OSResultSuccessBlock)(NSDictionary* result);
typedef void (^OSFailureBlock)(NSError* error);

/*Block for notifying availability of the User's ID and push token*/
typedef void (^OSIdsAvailableBlock)(NSString* userId, NSString* pushToken);

/*Block for handling the reception of a remote notification */
typedef void (^OSHandleNotificationReceivedBlock)(OSNotification* notification);

/*Block for handling a user reaction to a notification*/
typedef void (^OSHandleNotificationActionBlock)(OSNotificationOpenedResult * result);

/*Dictionary of keys to pass alongside the init settings*/
    
/*Let OneSignal directly prompt for push notifications on init*/
extern NSString * const kOSSettingsKeyAutoPrompt;
    
/*Enable the default in-app alerts*/
extern NSString * const kOSSettingsKeyInAppAlerts;

/*Enable In-App display of Launch URLs*/
extern NSString * const kOSSettingsKeyInAppLaunchURL;

/*Prompt user yes/no to open URL's from push notifications*/
extern NSString * const kOSSSettingsKeyPromptBeforeOpeningPushURL;

/* iOS10 +
 Set notification's in-focus display option.
 Value must be an OSNotificationDisplayType enum
*/
extern NSString * const kOSSettingsKeyInFocusDisplayOption;



// ======= OneSignal Class Interface =========
@interface OneSignal : NSObject

extern NSString* const ONESIGNAL_VERSION;

typedef NS_ENUM(NSUInteger, ONE_S_LOG_LEVEL) {
    ONE_S_LL_NONE, ONE_S_LL_FATAL, ONE_S_LL_ERROR, ONE_S_LL_WARN, ONE_S_LL_INFO, ONE_S_LL_DEBUG, ONE_S_LL_VERBOSE
};


/**
 Initialize OneSignal.
 Sends push token to OneSignal so you can later send notifications.
*/

// - Initialization
+ (id)initWithLaunchOptions:(NSDictionary*)launchOptions appId:(NSString*)appId;
+ (id)initWithLaunchOptions:(NSDictionary*)launchOptions appId:(NSString*)appId handleNotificationAction:(OSHandleNotificationActionBlock)actionCallback;
+ (id)initWithLaunchOptions:(NSDictionary*)launchOptions appId:(NSString*)appId handleNotificationAction:(OSHandleNotificationActionBlock)actionCallback settings:(NSDictionary*)settings;
+ (id)initWithLaunchOptions:(NSDictionary*)launchOptions appId:(NSString*)appId handleNotificationReceived:(OSHandleNotificationReceivedBlock)receivedCallback handleNotificationAction:(OSHandleNotificationActionBlock)actionCallback settings:(NSDictionary*)settings;

// - Privacy
+ (void)consentGranted:(BOOL)granted;
+ (BOOL)requiresUserPrivacyConsent; // tells your application if privacy consent is still needed from the current user
+ (void)setRequiresUserPrivacyConsent:(BOOL)required; //used by wrapper SDK's to require user privacy consent

@property (class) OSNotificationDisplayType inFocusDisplayType;

+ (NSString*)app_id;
+ (NSString*)sdk_version_raw;
+ (NSString*)sdk_semantic_version;

// Only use if you set kOSSettingsKeyAutoPrompt to false
+ (void)registerForPushNotifications __deprecated_msg("Please use promptForPushNotificationsWithUserResponse instead.");
+ (void)promptForPushNotificationsWithUserResponse:(void(^)(BOOL accepted))completionHandler;

// - Logging
+ (void)setLogLevel:(ONE_S_LOG_LEVEL)logLevel visualLevel:(ONE_S_LOG_LEVEL)visualLogLevel;
+ (void) onesignal_Log:(ONE_S_LOG_LEVEL)logLevel message:(NSString*)message;

// - Tagging
+ (void)sendTag:(NSString*)key value:(NSString*)value onSuccess:(OSResultSuccessBlock)successBlock onFailure:(OSFailureBlock)failureBlock;
+ (void)sendTag:(NSString*)key value:(NSString*)value;
+ (void)sendTags:(NSDictionary*)keyValuePair onSuccess:(OSResultSuccessBlock)successBlock onFailure:(OSFailureBlock)failureBlock;
+ (void)sendTags:(NSDictionary*)keyValuePair;
+ (void)sendTagsWithJsonString:(NSString*)jsonString;
+ (void)getTags:(OSResultSuccessBlock)successBlock onFailure:(OSFailureBlock)failureBlock;
+ (void)getTags:(OSResultSuccessBlock)successBlock;
+ (void)deleteTag:(NSString*)key onSuccess:(OSResultSuccessBlock)successBlock onFailure:(OSFailureBlock)failureBlock;
+ (void)deleteTag:(NSString*)key;
+ (void)deleteTags:(NSArray*)keys onSuccess:(OSResultSuccessBlock)successBlock onFailure:(OSFailureBlock)failureBlock;
+ (void)deleteTags:(NSArray*)keys;
+ (void)deleteTagsWithJsonString:(NSString*)jsonString;
// Optional method that sends us the user's email as an anonymized hash so that we can better target and personalize notifications sent to that user across their devices.
// Sends as MD5 and SHA1 of the provided email
+ (void)syncHashedEmail:(NSString*)email __deprecated_msg("Please refer to our new Email methods/functionality such as setEmail(). This method will be removed in a future version of the OneSignal SDK");

// - Subscription and Permissions
+ (void)IdsAvailable:(OSIdsAvailableBlock)idsAvailableBlock __deprecated_msg("Please use getPermissionSubscriptionState or addSubscriptionObserver and addPermissionObserver instead.");

+ (OSPermissionSubscriptionState*)getPermissionSubscriptionState;

+ (void)addPermissionObserver:(NSObject<OSPermissionObserver>*)observer;
+ (void)removePermissionObserver:(NSObject<OSPermissionObserver>*)observer;

+ (void)addSubscriptionObserver:(NSObject<OSSubscriptionObserver>*)observer;
+ (void)removeSubscriptionObserver:(NSObject<OSSubscriptionObserver>*)observer;

+ (void)addEmailSubscriptionObserver:(NSObject<OSEmailSubscriptionObserver>*)observer;
+ (void)removeEmailSubscriptionObserver:(NSObject<OSEmailSubscriptionObserver>*)observer;

+ (void)setSubscription:(BOOL)enable;

// - Posting Notification
+ (void)postNotification:(NSDictionary*)jsonData;
+ (void)postNotification:(NSDictionary*)jsonData onSuccess:(OSResultSuccessBlock)successBlock onFailure:(OSFailureBlock)failureBlock;
+ (void)postNotificationWithJsonString:(NSString*)jsonData onSuccess:(OSResultSuccessBlock)successBlock onFailure:(OSFailureBlock)failureBlock;
+ (NSString*)parseNSErrorAsJsonString:(NSError*)error;

// - Request and track user's location
+ (void)promptLocation;
+ (void)setLocationShared:(BOOL)enable;


// Only used for wrapping SDKs, such as Unity, Cordova, Xamarin, etc.
+ (void)setMSDKType:(NSString*)type;


// iOS 10 only
// Process from Notification Service Extension.
// Used for iOS Media Attachemtns and Action Buttons.
+ (UNMutableNotificationContent*)didReceiveNotificationExtensionRequest:(UNNotificationRequest*)request withMutableNotificationContent:(UNMutableNotificationContent*)replacementContent;
+ (UNMutableNotificationContent*)serviceExtensionTimeWillExpireRequest:(UNNotificationRequest*)request withMutableNotificationContent:(UNMutableNotificationContent*)replacementContent;

// Email methods

// Typedefs defining completion blocks for email & simultaneous HTTP requests
typedef void (^OSEmailFailureBlock)(NSError* error);
typedef void (^OSEmailSuccessBlock)();

// Allows you to set the email for this user.
// Email Auth Token is a (recommended) optional parameter that should *NOT* be generated on the client.
// For security purposes, the emailAuthToken should be generated by your backend server.
// If you do not have a backend server for your application, use the version of thge setEmail: method without an emailAuthToken parameter.
+ (void)setEmail:(NSString * _Nonnull)email withEmailAuthHashToken:(NSString * _Nullable)hashToken withSuccess:(OSEmailSuccessBlock _Nullable)successBlock withFailure:(OSEmailFailureBlock _Nullable)failureBlock;

// Sets email without an authentication token
+ (void)setEmail:(NSString * _Nonnull)email withSuccess:(OSEmailSuccessBlock _Nullable)successBlock withFailure:(OSEmailFailureBlock _Nullable)failureBlock;

// Logs the device out of the current email.
+ (void)logoutEmailWithSuccess:(OSEmailSuccessBlock _Nullable)successBlock withFailure:(OSEmailFailureBlock _Nullable)failureBlock;

//convenience - no completion blocks
+ (void)logoutEmail;
+ (void)setEmail:(NSString * _Nonnull)email;
+ (void)setEmail:(NSString * _Nonnull)email withEmailAuthHashToken:(NSString * _Nullable)hashToken;

@end

#pragma clang diagnostic pop
