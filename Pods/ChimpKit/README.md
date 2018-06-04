# ChimpKit 3.1.1

ChimpKit is an API wrapper for the [MailChimp API 2.0](http://www.mailchimp.com/api).

##Requirements

A MailChimp account and API key. You can see your API keys [here](http://admin.mailchimp.com/account/api).

ChimpKit includes uses ARC. If your project doesn't use ARC, you can enable it per file using the `-fobjc-arc` compiler flag under "Build Phases" and "Compile Sources" on your project's target in Xcode.

##Installation

There are two ways to add ChimpKit to your project:

Using [Cocoapods](cocoapods.org):

    pod "ChimpKit"

Or using Git submodules. Add ChimpKit as a submodule of your git repository by doing something like:

    cd myrepo
    git submodule add https://github.com/mailchimp/ChimpKit3.git Libs/ChimpKit

Now add ChimpKit to your project by dragging the everything in the `ChimpKit3` directory into your project.

##Usage

First, set an API key:

    [[ChimpKit sharedKit] setApiKey:apiKey];

You can now make requests. For example, here's how to subscribe an email address:

Using a block:

    NSDictionary *params = @{@"id": listId, @"email": @{@"email": @"foo@example.com"}, @"merge_vars": @{@"FNAME": @"Freddie", @"LName":@"von Chimpenheimer"}};
    [[ChimpKit sharedKit] callApiMethod:@"lists/subscribe" withParams:params andCompletionHandler:^(ChimpKitRequest *request, NSError *error) {
        NSLog(@"HTTP Status Code: %d", request.response.statusCode);
        NSLog(@"Response String: %@", request.responseString);
      
        if (error) {
           //Handle connection error
            NSLog(@"Error, %@", error);
            dispatch_async(dispatch_get_main_queue(), ^{
                //Update UI here
            });
        } else {
            NSError *parseError = nil;
            id response = [NSJSONSerialization JSONObjectWithData:request.responseData
                                                          options:0
                                                            error:&parseError];
            if ([response isKindOfClass:[NSDictionary class]]) {
                id email = [response objectForKey:@"email"];
                if ([email isKindOfClass:[NSString class]]) {
                    //Successfully subscribed email address
                    dispatch_async(dispatch_get_main_queue(), ^{
                        //Update UI here
                    });
                }
            }
        }
    }];

Using the delegate pattern:

    NSDictionary *params = @{@"id": listId, @"email": @{@"email": @"foo@example.com"}, @"merge_vars": @{@"FNAME": @"Freddie", @"LName":@"von Chimpenheimer"}};
    [[ChimpKit sharedKit] callApiMethod:@"lists/subscribe" withParams:params andDelegate:self];

And implement the `ChimpKitRequestDelegate` protocol:

    - (void)ckRequestSucceeded:(ChimpKitRequest *)aRequest {
        NSLog(@"HTTP Status Code: %d", aRequest.response.statusCode);
        NSLog(@"Response String: %@", aRequest.responseString);
    
        NSError *parseError = nil;
        id response = [NSJSONSerialization JSONObjectWithData:request.responseData
                                                      options:0
                                                        error:&parseError];
        if ([response isKindOfClass:[NSDictionary class]]) {
            id email = [response objectForKey:@"email"];
            if ([email isKindOfClass:[NSString class]]) {
                //Successfully subscribed email address
                dispatch_async(dispatch_get_main_queue(), ^{
                    //Update UI here
                });
            }
        }
    }

    - (void)ckRequestFailed:(ChimpKitRequest *)aRequest andError:(NSError *)anError {
        //Handle connection error
        NSLog(@"Error, %@", anError);
        dispatch_async(dispatch_get_main_queue(), ^{
            //Update UI here
        });
    }

Calling other API endpoints works similarly. Read the API [documentation](http://apidocs.mailchimp.com/api/2.0/) for details.

###Blocks and delegate methods can be called from a background queue

The examples above use dispatch_async to call back onto the main queue after parsing the response. If you've set `shouldUseBackgroundThread` to `YES` then ChimpKit will call your block from a background queue so you can parse the JSON response with low impact on interface responsiveness. You should dispatch_* back to the main queue before updating your UI as shown above. You can enable this behavior like so:

    [[ChimpKit sharedKit] setShouldUseBackgroundThread:YES];

### Controlling Timeout

ChimpKit defaults to a 10 second timeout. You can change that (globally) to 30 seconds like so:

    [[ChimpKit sharedKit] setTimeoutInterval:30.0f];

### MailChimp now supports [OAuth2](http://apidocs.mailchimp.com/oauth2/) and so does ChimpKit:

An example of logging in via OAuth is provided in the sample application. See `ViewController.m`.

##Copyrights

* Copyright (c) 2010-2014 The Rocket Science Group. Please see LICENSE.txt for details.
* MailChimp (c) 2001-2014 The Rocket Science Group.
