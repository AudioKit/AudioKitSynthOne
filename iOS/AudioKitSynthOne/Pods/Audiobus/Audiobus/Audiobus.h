//
//  Audiobus.h
//  Audiobus
//
//  Created by Michael Tyson on 10/12/2011.
//  Copyright (c) 2011-2017 Audiobus. All rights reserved.
//

#import "ABCommon.h"

#import "ABAudioSenderPort.h"
#import "ABAudioFilterPort.h"
#import "ABAudioReceiverPort.h"

#import "ABMIDISenderPort.h"
#import "ABMIDIFilterPort.h"
#import "ABMIDIReceiverPort.h"

#import "ABAudiobusController.h"
#import "ABPeer.h"
#import "ABPort.h"
#import "ABTrigger.h"
#import "ABButtonTrigger.h"
#import "ABMultiStreamBuffer.h"
#import "ABAudioUnitFader.h"

#import "ABAudioSenderPort.h"
#import "ABAudioFilterPort.h"
#import "ABAudioReceiverPort.h"

#import <AVFoundation/AVFoundation.h>
#import <Accelerate/Accelerate.h>

#define ABSDKVersionString @"3.0.4"

/*!
@mainpage

Introduction
============

 <blockquote>
 If you're already familiar with Audiobus and are integrating the 3.x version of the Audiobus SDK,
 then check out the [3.x Migration Guide](@ref Migration-Guide) to find out what's changed.
 </blockquote>
 
 Audiobus is an SDK and accompanying [controller app](https://audiob.us/download) that allows iOS 
 apps to stream audio and MIDI to one another. Just like audio and MIDI cables, Audiobus lets you connect apps
 together as modules, to  build sophisticated audio and MIDI production and processing configurations.

 The Audiobus SDK provides all you need to make your app Audiobus compatible.  It's designed to be
 extremely easy to use: depending on your app, you should be up and running with Audiobus well within 
 a couple of hours.

 The SDK contains:

- The Audiobus library and headers
- An Xcode project with a number of sample apps that you can build and run
- A README file with a link to this documentation

Don't Panic!
============

 We've worked hard to make Audiobus a piece of cake to integrate. Most developers will be able
 to have a functional integration within thirty minutes. Really.

 If your app's based around Remote IO audio units, then there's very little you'll need to
 do, particularly if it just produces audio and doesn't record it. This document will take you 
 through the process of integrating Audiobus.
 
 The process involves:
 - [Adding the Audiobus SDK files to your project](@ref Project-Setup), with or without CocoaPods,
 - [Enabling Inter-App Audio and Background Audio](@ref Audio-Setup),
 - Creating a [launch URL](@ref Launch-URL) and [registering your app with us](@ref Register-App),
 - Creating an instance of the [Audiobus Controller](@ref Create-Controller)
 - Adding [Audio Sender](@ref Create-Audio-Sender-Port), [Audio Filter](@ref Create-Audio-Filter-Port) and/or [Audio Receiver](@ref Create-Audio-Receiver-Port) ports.
 - Adding [MIDI Sender](@ref Create-MIDI-Sender-Port), [MIDI Filter](@ref Create-MIDI-Filter-Port) and/or [MIDI Receiver](@ref Create-MIDI-Receiver-Port) ports.
 - [Testing](@ref Test)
 - [Going live](@ref Go-Live)

 Easy-peasy.

 If you wanna do some more advanced stuff, like 
 [receiving individual audio streams separately](@ref Receiving-Separate-Streams),
 allowing your app to be [controlled remotely](@ref Triggers), or implementing 
 [state saving](@ref State-Saving) then this document will explain how that's done, too.

 Finally, if you need a little extra help, or just wanna meet and talk with us or other
 Audiobus-compatible app developers, come say hello on the [developer community forum](https://heroes.audiob.us).

Capabilities: Audio Sending, Filtering and Receiving
====================================================

 <img src="overviewAudio.png" width="570" height="422" title="Audiobus Audio Peers and Ports" />
 
 Audiobus defines three different audio capabilities that an Audiobus-compatible app can have: sending,
 filtering and receiving. Your app can perform several of these roles at once. You create audio sender,
 receiver and/or filter ports when your app starts, and/or as your app's state changes.

 **Audio senders** transmit audio to other apps (audio receivers or filters). A sender will typically send the
 audio that it's currently playing out of the device's audio output device. For
 example, a musical instrument app will send the sounds or the notes the user is currently playing.
 
 **Audio filters** accept audio input, process it, then send it onwards to another app over Audiobus. This
 allows applications to apply effects to the audio stream. Audio filters also behave as inputs or receivers,
 and can go in the "Input" and "Output" positions in Audiobus.


 **Audio receivers** accept audio from audio sender or filter apps. What is done with the received audio depends
 on the app. A simple recorder app might just save the recorded audio to disk. A multi-track recorder
 might save the audio from each sender app as a separate track. An audio analysis app might display
 information about the nature of the received audio, live.
 
 
 Audio receiver apps can receive from one or more sources, and audio filters can accept audio from multiple sources.
 
 Audio receivers can receive audio from connected source apps in two ways: mixed down to a single stereo stream,
 or with one stereo stream per connected source.
 
 By setting the [receiveMixedAudio](@ref ABAudioReceiverPort::receiveMixedAudio) property of the port to YES
 (the default), the port will automatically mix all the sources together, giving your application one
 stereo stream.
 
 If you set the property to NO, the port will offer you separate streams, one per connected app. This
 can be useful for providing users with per-app mixing controls, or multi-track recording.

 <div style="clear: both;"></div>
 
Capabilities: MIDI Sending, Filtering and Receiving
===================================================
 
 <img src="overviewMIDI.png" width="570" height="422" title="Audiobus MIDI Peers and Ports" />
 
 MIDI routing in Audiobus works in the same way audio routing does: There are 
 MIDI senders, MIDI filters and MIDI receivers.
 
 **MIDI Senders** transmit MIDI to other apps (MIDI receivers or filters).
 A Keyboard app for example is a typical MIDI sender. The notes played on the UI
 are transformed into MIDI message and sent out to other apps.
 
 **MIDI Filters** accept MIDI input, process it, then send it onwards to another 
 app over Audiobus. This allows applications apply effects to the MIDI stream. 
 Typical MIDI filter apps are arpeggiators, chord or time quantizers, etc.
 
 **MIDI Receivers** accept MIDI from MIDI sender or filter apps. What is done with
 the received MIDI depends on the app. A simple MIDI recorder might just save the
 MIDI to disk. A synthesizer could transform the MIDI into audible sounds. 
 An audio effect could use the MIDI to change its effects parameters. 
 

 
 
More Help
=========
 
 If you need any additional help integrating Audiobus into your application, or if you have
 any suggestions, then please join us on the [developer community forum](https://heroes.audiob.us).
 
@page Integration-Guide Integration Guide

 <blockquote>
 Please read this guide carefully, as there are some important things you need to
 know to effectively support Audiobus in your app. Particularly if you intend to receive
 audio from Audiobus, set aside ten minutes to read through to make sure you have a
 clear picture of how it all works.
 </blockquote>
 
 Many app developers will be able to implement Audiobus in just thirty minutes or so.

 This quick-start guide assumes your app uses the Core Audio C API or AVAudioEngine. If this is not the
 case, most of it will still be relevant, but you'll need to do some additional integration work which is beyond
 the scope of this documentation.
 
General Design Principles                                  {#General-Principles}
=========================
 
 We've worked hard to make Audiobus as close as possible to an "it just works" experience for 
 users. We think music on iOS should be easy and open to everyone, not just those technical 
 enough to understand convoluted settings.
 
 That means you should add **no switches to enable/disable Audiobus, no settings that users need 
 to configure to enable your app to run in the background while connected to Audiobus**.

 If you're a sender app or a filter app (i.e. you have an ABAudioSenderPort, ABAudioFilterPort, ABMIDISenderPort or ABMIDIFilterPort, and only send to other apps or filter audio/MIDI from other apps), you shouldn't
 need to ever add any Audiobus-specific UI. Audiobus takes care of all session management for
 you. If you're a receiver app (you have an ABAudioReceiverPort or an ABMIDIReceiverPort) then unless you're doing nifty things
 with multitrack recording, you shouldn't need to add Audiobus-specific UI either.
 
 Additionally, you should not offer Audiobus support as an in-app purchase, as this violates the
 "just works" principle.  We would be unable to list such apps in our Compatible Applications
 directory due to the customer frustration and support requests this would generate.
 
 <blockquote class="alert">
 We reserve the option to remove apps offering Audiobus support as an in-app purchase from the
 Audiobus Compatible Apps directory, or to ban them from Audiobus entirely.
 </blockquote>
 
 Audiobus' audio sender port is extremely lightweight when not connected: the send function ABAudioSenderPortSend
 will consume a negligible amount of CPU, so you can use it even while not connected to Audiobus, for
 convenience.
 
 If you find yourself implementing stuff that seems like it should've been in Audiobus, tell us. 
 It's probably already in there. If it's not, we'd be happy to consider putting it in ourselves 
 so you, and those who come after you, don't have to.
 
 In short: whenever possible, keep it simple. Your users will thank you, and you'll have more
 development time to devote to the things you care about.
 
1. Determine if your app will work with Audiobus                  {#Preparation}
================================================
 
 Audiobus relies heavily on multitasking, and one thing that is vital in apps that work together is
 that they are able to perform adequately alongside other apps, in a low-latency Audiobus environment.
 
 The primary factor affecting whether your app will work with Audiobus is whether your app can perform
 properly with a hardware IO buffer duration of 5ms (256 frames at 44.1kHz, 128 frames at 22kHz, etc)
 while other apps are running.
 
 **Your app *must* be prepared to handle a buffer length of 5ms (256 frames), when running alongside other apps,
 without glitching, on the iPad 3 and above, or iPhone 5 and above**.  You can test this prior to beginning 
 implementation of Audiobus support by opening the Audiobus app, with your app closed, then opening your app
 afterwards, which should force your app to a 5ms buffer duration. Push your app hard, and listen for glitches
 in the audio output. Ideally, you should also test while running additional audio apps in the background.
 
 <blockquote class="alert">
 If your app does not support a hardware buffer duration of 5ms without demonstrating performance problems
 on the iPad 3 and up, or the iPhone 5 and up, then we reserve the option to not list it in the Audiobus-compatible 
 app listing on our website and within the Audiobus app, or to ban it from Audiobus entirely.
 </blockquote>
 
 <blockquote class="alert" id="retronyms-audioio-bug">
 There is a sample project, [audioIO](http://blog.retronyms.com/2013/09/ios7-remoteio-inter-app-audiobus-and-you.html ),
 which can be used as starting point for audio apps. There's a problem in this code's
 `AudioUnitPropertyChangeDispatcher` function, where it calls `[audio addAudioUnitPropertyListener]`.
 This modifies the audio unit property change notification dispatch table mid-dispatch, which causes a
 data integrity error that causes other registered notify callbacks to not be called. This causes problems
 within the Audiobus library, which relies on these notifications - in particular, it causes silent audio
 in sender and filter ports, among other things.
 
 Removing this `[audio addAudioUnitPropertyListener]` line addresses the problem.
 </blockquote>
 
 <blockquote class="alert" id="audio-session-warning">
 If you're interacting with the audio session (via AVAudioSession or the old C API), you **must** set the
 audio session category and "mix with others" flag *before* setting the audio session active. If you do
 this the other way around, you'll get some weird behaviour, like silent output when used with IAA.
 </blockquote>
 
2. Add the Audiobus SDK to Your Project        {#Project-Setup}
===============================================================

 Audiobus is distributed as a static library, plus the associated header files.
 
 The easiest way to add Audiobus to your project is using [CocoaPods](https://cocoapods.org):
 
 1. If you don't have a Podfile at the top level of your project, create a file called "Podfile".
 2. Open your Podfile and add the following code, replacing `testTarget` with the name of your target:
 @code
 target 'testTarget' do
   pod 'Audiobus'
 end
 @endcode
 3. In the terminal and in the same folder, type:
   @code
    pod install
   @endcode
    In the future when you're updating your app, use `pod outdated` to check for available updates,
    and `pod update` to apply those updates.
 
 Alternatively, if you aren't using CocoaPods:

 1. Copy libAudiobus.a and the associated header files into an appropriate place within
    your project directory. We recommend putting these within an "Audiobus" folder within a "Library"
    folder (`Library/Audiobus`).
 2. Drag both the header files and libAudiobus.a into your project. In the sheet that appears,  make
    sure your app target is selected. Note that this will modify your app's "Header Search Paths" and
    "Library Search Paths" build settings.
 3. Ensure the following frameworks are added to your build process (to add frameworks,
    select your app target's "Link Binary With Libraries" build phase, and click the "+"
    button):
    - AVFoundation
    - CoreGraphics
    - Accelerate
    - AudioToolbox
    - QuartzCore
    - Security
    - libz.tbd
 
 Note that for technical reasons the Audiobus SDK supports iOS 8.0 and up only.
 

3. Enable Background Audio and Inter-App Audio        {#Audio-Setup}
==============================================

 If you haven't already done so, you must enable background audio and Inter-App Audio in your app -- even if you plan to [create a MIDI-only app](@ref Working-With-MIDI).
 
 To enable these:

 1. Open your app target screen within Xcode by selecting your project entry at the top of Xcode's 
    Project Navigator, and selecting your app from under the "TARGETS" heading.
 2. Select the "Capabilities" tab.
 3. Underneath the "Background Modes" section, make sure you have "Audio and AirPlay" ticked.
 4. To the right of the "Inter-App Audio" title, turn the switch to the "ON" position -- this will
    cause Xcode to update your App ID with Apple's "Certificates, Identifiers & Profiles" portal,
    and create or update an Entitlements file.

 Managing Your App's Life-Cycle                                     {#Lifecycle}
 ------------------------------

 Your app will only continue to run in the background if you have an *active, running*
 audio system. This means that if you stop your audio system while your app is in the background
 or moving to the background, your app will cease to run and will become unresponsive to
 Audiobus.
 
 Consequently, care must be taken to ensure your app is running and available when it needs to be.
 
 Firstly, **you must ensure you have a running and active audio session** once your app is connected
 via Audiobus, regardless of the state of your app. You can do this two ways: 
 
 1. Make sure you only instantiate the Audiobus controller ([Step 7](@ref Create-Controller))
    once your audio system is running.
 2. Register to receive [ABConnectionsChangedNotification](@ref ABConnectionsChangedNotification)
    notifications (or observe ABAudiobusController's connected property), and start your audio engine
    if the Audiobus controller is [connected](@ref ABAudiobusController::connected).
 
 If do not do this correctly, your app may suspend in the background before an Audiobus connection 
 has been completed, rendering it unable to work with Audiobus.
 
 Secondly, you may choose to suspend your app (by stopping your audio system) when it moves to the
 background under certain conditions. For example, you might have a 'Run in Background' 
 setting that the user can disable, or you may choose to always suspend your app if the app 
 is idle.
 
 This is fine - in fact, we recommend doing this by default, in order to avoid the
 possibility of overloading a user's device without their understanding why.
 
 If you do this however, you **must not** under any circumstances suspend your app if the
 [connected](@ref ABAudiobusController::connected) property of the Audiobus controller is
 YES. If you do, then Audiobus will **cease to function properly** with your app.
 
 The following describes the background policy we strongly recommend for use with Audiobus.
 
 1. When your app moves to the background, you should only stop your audio engine if (a) you are
    not currently connected via either Audiobus or Inter-App Audio, which can be determined via
    the [connected](@ref ABAudiobusController::connected) property of ABAudiobusController and 
    (b) you are not part of an active Audiobus session (i.e. your app has been used with Audiobus,
    and Audiobus is still running), which can be determined via the
    [memberOfActiveAudiobusSession](@ref ABAudiobusController::memberOfActiveAudiobusSession) property. 
    For example:
   @code
         -(void)applicationDidEnterBackground:(NSNotification *)notification {
             if ( !_audiobusController.connected && !_audiobusController.memberOfActiveAudiobusSession ) {
                // Fade out and stop the audio engine, suspending the app, if we're not connected, and we're not part of an active Audiobus session
                [ABAudioUnitFader fadeOutAudioUnit:_audioEngine.audioUnit completionBlock:^{ [_audioEngine stop]; }];
             }
         }
   @endcode
 2. Your app should continue to remain active in the background while connected and while Audiobus is running.
    When you are disconnected and Audiobus quits, your app should suspend too. You can do this by observing
    the two above properties. Once both are NO, stop your audio engine as appropriate:
   @code
    static void * kAudiobusConnectedOrActiveMemberChanged = &kAudiobusConnectedOrActiveMemberChanged;
 
    ...
 
    // Watch the connected and memberOfActiveAudiobusSession properties
    [self.audiobusController addObserver:self 
                          forKeyPath:@"connected"
                             options:0 
                             context:kAudiobusConnectedOrActiveMemberChanged];
    [self.audiobusController addObserver:self 
                          forKeyPath:@"memberOfActiveAudiobusSession"
                             options:0 
                             context:kAudiobusConnectedOrActiveMemberChanged];
 
    
    ...
 
    -(void)observeValueForKeyPath:(NSString *)keyPath
                         ofObject:(id)object
                           change:(NSDictionary *)change
                          context:(void *)context {
 
        if ( context == kAudiobusConnectedOrActiveMemberChanged ) {
            if ( [UIApplication sharedApplication].applicationState == UIApplicationStateBackground
                   && !_audiobusController.connected
                   && !_audiobusController.memberOfActiveAudiobusSession ) {
 
                // Audiobus session is finished. Time to sleep.
                [_audioEngine stop];
            }
        } else {
            [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
        }
    }
   @endcode
 3. When your app moves to the foreground, start your audio engine:
   @code
    -(void)applicationWillEnterForeground:(NSNotification *)notification {
        if ( !_audioEngine.running ) {
            // Start the audio system if it wasn't running
            [_audioEngine start];
        }
    }
   @endcode
 
 Note that during development, if you have not yet registered your app with Audiobus
 ([Step 5](@ref Register-App)), the Audiobus app will only be able to see your app while
 it is running. Consequently we **strongly recommend** registering your app before you 
 begin testing.

4. Set up a Launch URL        {#Launch-URL}
======================

 Audiobus needs a URL (like `YourApp-1.0.audiobus://`) that can be used to launch and switch to
 your app, and used to determine if your app is installed.
 
 The URL scheme needs to end in ".audiobus", to ensure that Audiobus app URLs are unique. This URL 
 also needs to be unique to each version of your app, so Audiobus can tell each version apart, 
 which is important when you add new Audiobus features.
 
 Here's how to add the new URL scheme to your app.

 1. Open your app target screen within Xcode by selecting your project entry at the top of Xcode's 
    Project Navigator, and selecting your app from under the "TARGETS" heading.
 2. Select the "Info" tab.
 3. Open the "URL types" group at the bottom.
 4. If you don't already have a URL type created, click the "Add" button at the bottom 
    left. Then enter an identifier for the URL (a reverse DNS string that identifies your app, like 
    "com.yourcompany.yourapp", will suffice).
 5. If you already have existing URL schemes defined for your app, add a comma and space (", ") 
    after the last one in URL Schemes field (Note: the space after the comma is important).
 6. Now enter the new Audiobus URL scheme for your app, such as "YourApp-1.0.audiobus". Note
    that this is just the URL scheme component, not including the "://" characters).

<img src="url-scheme.jpg" title="Adding a URL Scheme" width="570" height="89" />

 Other apps will now be able to switch to your app by opening the `YourApp-1.0.audiobus://` URL.
 
5. Register Your App and Generate Your API Key        {#Register-App}
==============================================

 Audiobus contains an app registry which is used to enumerate Audiobus-compatible apps that
 are installed. This allows apps to be seen by Audiobus even if they are not actively running
 in the background. The registry also allows users to discover and purchase apps that support Audiobus.
 
 Register your app, and receive an Audiobus API key, at the 
 [Audiobus app registration page](https://developer.audiob.us/apps/register).

 You'll need to provide various details about your app, and you'll need to provide a copy of your
 **compiled** Info.plist from your compiled app bundle, which Audiobus will use to populate the required fields.
 You'll be able to edit all of these details up until the time you go live with your app.
 
 <blockquote>
 You must provide the **compiled** version of your Info.plist, not the one from your project folder.
 You can find this by building your app, right-clicking on the app in the "Products" group of the 
 Xcode project navigator, and clicking "Show in Finder", then right-clicking on the app bundle and 
 selecting "Show Package Contents"
 </blockquote>
 
 After you register, we will briefly review your application. Upon approval, you will be notified via
 email, which will include your Audiobus API key, and the app will be added to the Audiobus registry.
 
 You can always look up your API key by visiting https://developer.audiob.us/apps and clicking on your
 app. The API key is at the top of the app details page.
 
 The API key is a string that you provide when you use the Audiobus SDK. It is unique to each version
 of your app, and tied to your bundle name and launch URL. It will be checked by the SDK upon 
 initialisation, to provide automatic error checking. No network connection is required to verify the key.
 
 > Note that while registering your app will *not* cause it to appear on our website or in the "Apps"
 > tab in the app, it *will* cause it to appear within the XML feed that Audiobus downloads
 > to keep track of which of the installed apps support Audiobus.
 > 
 > This will not cause your app to appear within Audiobus' app listings, because you chose a new, unique 
 > URL in [Step 4](@ref Launch-URL), but a dedicated user with a packet sniffer may see your app in the 
 > XML stream. Additionally, while we do not make the URL to this feed public, the feed itself is 
 > publicly-accessible.

 The Audiobus app downloads registry updates from our servers once every 30 minutes, so once we approve
 your submission, we recommend that you reinstall the Audiobus app to force it to update immediately,
 so you can begin working.
 
 > To make your app appear on the Audiobus website or in the in-app Compatible Apps directory, and therefore
 > give Audiobus users the ability to purchase your app, you need to you make your app live
 > ([Step 10](@ref Go-Live)). Do this only when the Audiobus-compatible
 > version of your app goes live on the App Store, so as not to confuse users.
 
 As you develop your app further, beyond this initial integration of Audiobus, we recommend you register
 new versions of your app with us when you add new Audiobus functionality, like adding new ports or
 implementing features like state saving. This will both allow Audiobus to correctly advertise the new
 features in your new version, and will boost your sales when your app appears at the top of our
 compatible apps directly again. You can register new versions of your app by clicking "Add Version" on
 your app page.
 
6. Enable mixing audio with other apps        {#Enable-Mixing}
======================================

 When you use audio on iOS, you typically select one of several audio session categories,
 usually either `AVAudioSessionCategoryPlayAndRecord` or `AVAudioSessionCategoryPlayback`.

 By default, both of these categories will cause iOS to interrupt the audio session of any other
 app running at the time your app is started, **forcing the other app to suspend**.

 If you are using either `PlayAndRecord` or `MediaPlayback`, then in order to use Audiobus you
 need to **override this default**, and tell iOS to allow other apps to run at the same time and
 mix the output of all running apps.

 To do this, you need to set the `AVAudioSessionCategoryOptionMixWithOthers` flag, like so:

 @code
 NSString *category = AVAudioSessionCategoryPlayAndRecord;
 AVAudioSessionCategoryOptions options = AVAudioSessionCategoryOptionMixWithOthers;

 NSError *error = nil;
 if ( ![[AVAudioSession sharedInstance] setCategory:category withOptions:options error:&error] ) {
     NSLog(@"Couldn't set audio session category: %@", error);
 }
 @endcode

 Note that with the old Audio Session C API, adjusting other session properties can interfere with
 this property setting, causing other apps to be interrupted despite the mix property being set.
 To avoid problems, we recommend only using the modern AVAudioSession API. If you do need to use
 the older C API though, be sure to reset the `kAudioSessionProperty_OverrideCategoryMixWithOthers`
 property value whenever you assign any audio session properties.
 
 <blockquote class="alert" id="audio-session-warning">
 If you're interacting with the audio session (via AVAudioSession or the old C API), you **must** set the
 audio session category and "mix with others" flag *before* setting the audio session active. If you do
 this the other way around, you'll get some weird behaviour, like silent output when used with IAA.
 </blockquote>

7. Instantiate the Audiobus Controller        {#Create-Controller}
======================================

 Next, you need to create a strong property for an instance of the Audiobus Controller. A convenient place
 to do this is in your app's delegate, or within your audio engine class.

 First, import the Audiobus header from your class's implementation file:

 @code
 #import "Audiobus.h"
 @endcode

 Next declare a strong (retaining) property for the instance from within a class extension:

 @code
     @interface MyAppDelegate ()
     @property (strong, nonatomic) ABAudiobusController *audiobusController;
     @end
 @endcode

 Now you'll need to create an instance of the Audiobus controller. A convenient place to do this
 is in your app delegate's `application:didFinishLaunchingWithOptions:` method, or perhaps within your
 audio engine's initialiser, but there are three very important caveats:
 
 First: you must either **start your audio system at the same time as you initialise Audiobus**, or you must watch for
 @link ABConnectionsChangedNotification @endlink and **start your audio system when the ABConnectionsChangedNotification
 is received**.  This is because as soon as your app is connected via Audiobus, your app **must have a running and active
 audio system**, or a race condition may occur wherein your app may suspend in the background
 before an Audiobus connection has been completed.
 
 Second: you must instantiate the Audiobus controller **on the main thread only**. If you do not, Audiobus
 will trigger an assertion.
 
 Third: you **must not hold up the main thread after initialising the Audiobus controller**. Due to
 an issue in Apple's service browser code, if the main thread is blocked for more than a couple of seconds,
 Audiobus peer discovery will fail, causing your app to refuse to respond to the Audiobus app. If you
 need to take more than a second or two to initialise your app, initialise the Audiobus controller afterwards,
 or do that processing in a background thread.
 
 > You must initialise ABAudiobusController as close to app launch as is possible, and you must keep the instance
 > around for the entire life of your app. If you release and create a new instance of ABAudiobusController, you
 > will see some odd behaviour, such as your app failing to connect to Audiobus.
 
 Create the ABAudiobusController instance, passing it the API key that you generated when you registered 
 your app in [Step 5](@ref Register-App):

 @code
 self.audiobusController = [[ABAudiobusController alloc] initWithApiKey:@"YOUR-API-KEY"];
 @endcode

 At certain times, Audiobus will display the Connection Panel within your app. This is a slim
 panel that appears at the side of the screen, that users can drag off the screen, and swipe
 from the edge of the screen to re-display, a bit like the iOS notification screen.

 By default, the Connection Panel appears at the right of the screen. If this does not work
 well with your app's UI, you can select [another location](@ref ABConnectionPanelPosition)
 for the panel:

 @code
 self.audiobusController.connectionPanelPosition = ABConnectionPanelPositionLeft;
 @endcode

 You can change this value at any time (such as after significant user interface orientation changes),
 and Audiobus will automatically animate the panel to the new location.
 
 > If the connection panel is on the bottom of the screen, it cannot be hidden by
 > the user. This is to avoid interference by the iOS Control Center panel.

8. Create Ports        {#Create-Ports}
===============

 Now you're ready to create your Audiobus ports.
 
 You can make as many ports as you like. For example, a multi-track recorder could provide per-track outputs, or
 an effect app with side-chain processing could create a main effect port, and a sidechain port. We recommend
 being generous with your port offering, to enable maximum flexibility, such as per-track routing. Take a look at
 Loopy or Loopy HD for an example of the use of multiple ports.
 
 If you plan to work with MIDI in your app, you may want to create some MIDI ports, as well; see [Working With MIDI](@ref Working-With-MIDI) for more information.
 
 Note that you should create all your ports when your app starts, regardless of whether you intend to use them
 straight away, or you'll get some weird behaviour. If you're not using them, just keep them silent (or inactive, 
 by not calling the receive/send functions).
 
 <blockquote class="alert">
 Due to some changes since iOS 9, we now **strongly discourage** you from creating apps that have only a receiver
 port (ABAudioReceiverPort). Such apps will not be able to be identified as installed by Audiobus on iOS 9 or later.
 
 To repeat: you should create a sender port or a filter port, in addition to any receiver ports you require.
 If this is simply not an option, **please contact us before proceeding**.
 
 This is a limitation enforced by security changes since iOS 9 that prohibit Audiobus from detecting installed apps
 unless they provide sender or filter ports.
 </blockquote>
 
 > If you are using the Audio Queue API in your app, unfortunately there is no convenient way to support sending
 > audio via Audiobus. You can, however, support [receiving from Audiobus](@ref Audio-Queue-Input).
 
 
 Audio Sender Port                                              {#Create-Audio-Sender-Port}
 -----------------
 
 If you intend to send audio, then you'll need to create an ABAudioSenderPort.

 The first sender port you define will be the one that Audiobus will connect to when the user taps your app
 in the port picker within Audiobus, so it's best to define the port with the most general, default behaviour
 first.

 Firstly, you'll need to create an AudioComponents entry within your app's Info.plist. This identifies your
 port to other apps. If you have integrated Inter-App Audio separately, and you already have an AudioComponents entry,
 you can use these values with your ABAudioSenderPort without issue. Otherwise:

 1. Open your app target screen within Xcode by selecting your project entry at the top of Xcode's 
    Project Navigator, and selecting your app from under the "TARGETS" heading.
 2. Select the "Info" tab.
 3. If you don't already have an "AudioComponents" group, then under the "Custom iOS Target Properties" 
    group, right-click and select "Add Row", then name it "AudioComponents". Set the type to "Array" in
    the second column.
 4. Open up the "AudioComponents" group by clicking on the disclosure triangle, then right-click on 
    "AudioComponents" and select "Add Row". Set the type of the row in the second column to "Dictionary". 
    Now make sure the new row is selected, and open up the new group using its disclosure triangle.
 5. Create five different new rows, by pressing Enter to create a new row and editing its properties:
    - "manufacturer" (of type String): set this to any four-letter code that identifies you (like "abus")
    - "type" (of type String): set this to "aurg", which means that we are identifying a "Remote Generator" audio unit,
      or "auri" for a "Remote Instrument" unit which can [receive MIDI](@ref Create-MIDI-Receiver-Port).
    - "subtype" (of type String): set this to any four-letter code that identifies the port.
    - "name" (of type String): Apple recommend that you set this to "Manufacturer: App name" (see [WWDC 2013 session 602,
      page 37](https://devstreaming.apple.com/videos/wwdc/2013/602xcx2xk6ipx0cusjryu1sx5eu/602/602.pdf?dl=1)). If you
      publish multiple ports, you will need to identify the particular port, too. We propose "Manufacturer: App name (Port name)".
      Note that this field does not need to match the name or title you pass to ABAudioSenderPort.
    - "version" (of type Number): set this to any integer (whole number) you like. "1" is a good place to start.

 Once you're done, it should look something like this:

 <img src="audio-component.jpg" title="Adding an Audio Component" width="466" height="126" />

 <blockquote class="alert">
 It's very important that you use a different AudioComponentDescription for each port (represented by the type, subtype
 and manufacturer fields). If you don't have a unique AudioComponentDescription per port, you'll get all sorts of
 Inter-App Audio errors (like error -66750 or -10879).
 
 The Audiobus Developer Center will check that your AudioComponentDescriptions are unique among the Audiobus community,
 but this is not a guarantee of uniqueness among non-Audiobus apps.
 </blockquote>
 
 If you intend to [work with MIDI](@ref Create-MIDI-Receiver-Port), you may wish to specify the Remote Instrument ('auri') type
 for your audio component.  See [Working With MIDI](@ref Working-With-MIDI) for more information. 
 
 <blockquote class="alert">
 If you create a port of Remote Instrument ('auri') you need to make sure that your port is not receiving twice, one time via Inter-App audio and a second time via Core MIDI. To ensure that you must assign a block to the [enableReceivingCoreMIDIBlock](@ref ABAudiobusController::enableReceivingCoreMIDIBlock) property. Audiobus calls this block to tell your app exactly when to enable or disable receiving via Core MIDI. See [here](@ref Disable-Core-MIDI) for more details.
 </blockquote>
 
 If you wish to use more than one AudioComponentDescription to publish the port, to provide both Remote Generator and
 Remote Instrument types for example, you may provide the additional AudioComponentDescription to the sender port via
 @link ABAudioSenderPort::registerAdditionalAudioComponentDescription: ABAudioSenderPort's registerAdditionalAudioComponentDescription: @endlink
 method (you will need to call AudioOutputUnitPublish for the additional types yourself).
 
 Now it's time to create an ABAudioSenderPort instance. You provide a port name, for internal use, and a port
 title which is displayed to the user. You can localise the port title.
 
 You may choose to provide your IO audio unit (of type kAudioUnitSubType_RemoteIO), which will cause the sender port 
 to automatically capture and send the audio output. This is the recommended, easiest, and most efficient approach. If you
 are using the C Core Audio API, this will be your main output unit. If you are using AVAudioEngine, you can access this
 via AVAudioOutputNode/AVAudioInputNode's "audioUnit" property.
 
 Alternatively, if you're creating secondary ports, or have another good reason for not using your IO audio unit with the
 sender port at all, then you send audio by calling @link ABAudioSenderPort::ABAudioSenderPortSend ABAudioSenderPortSend @endlink,
 then mute your audio output depending on the value of @link ABAudioSenderPort::ABAudioSenderPortIsMuted ABAudioSenderPortIsMuted @endlink.

 > ABAudioSenderPort when initialized without an audio unit will create and publish its own audio unit with the
 > AudioComponentDescription you pass into the initializer. If you are planning on using ABAudioSenderPort without an audio
 > unit (you're not passing an audio unit into the initializer), then you **must not** publish any other audio unit with
 > the same AudioComponentDescription. Otherwise, *two audio units will be published with the same AudioComponentDescription*, 
 > which would be bad, and would result in unexpected behaviour like silent output.
 > <br/>
 > If you're using ABAudioSenderPort without an audio unit for the purposes of offering a new, separate audio stream
 > with a different AudioComponentDescription, though, you're fine.
 
 > If you are using a sender port and *not* initialising it with your audio unit, you **must**
 > mute your app's corresponding audio output when needed, depending on the value of the
 > @link ABAudioSenderPort::ABAudioSenderPortIsMuted ABAudioSenderPortIsMuted @endlink function. This is very important and
 > both avoids doubling up the audio signal, and lets your app go silent when removed from Audiobus. See the 
 > [Sender Port recipe](@ref Sender-Port-Recipe) and the AB Receiver sample app for details.
 
 > If you work with floating-point audio in your app we strongly recommend you restrict values to the range
 >  -1.0 to 1.0, as a courtesy to developers of downstream apps.
 
 Finally, you need to pass in an AudioComponentDescription structure that contains the same details as the
 AudioComponents entry you added earlier.

 @code
 self.audioSenderPort = [[ABAudioSenderPort alloc] initWithName:@"Audio Output"
                                                         title:NSLocalizedString(@"Main App Output", @"")
                                     audioComponentDescription:(AudioComponentDescription) {
                                         .componentType = kAudioUnitType_RemoteGenerator,
                                         .componentSubType = 'subt', // Note single quotes
                                         .componentManufacturer = 'manu' }
                                                     audioUnit:_audioUnit];
 
 [self.audiobusController addAudioSenderPort:self.audioSenderPort];
 @endcode
 
 If your sender port's audio audio comes from the system audio input (such as a microphone),
 then you should set the port's @link ABAudioSenderPort::derivedFromLiveAudioSource derivedFromLiveAudioSource @endlink
 property to YES to allow Audiobus to be able to warn users if they are in danger of creating audio feedback.
 
 Please note that you should not split up stereo Audiobus streams into two separate channels,
 treated differently. You should always treat audio from Audiobus as one, 2-channel stream.
 
 You may also optionally provide an icon (a 32x32 mask, with transparency) via the [icon](@ref ABAudioSenderPort::icon) property, 
 which is also displayed to the user and can change dynamically. We strongly recommend providing icons if you
 publish more than one port, so these can be recognized from one another. If you provide an icon here, you should
 also add that icon to the port on your app's registry on our developer site, so it can be displayed to users
 prior to your app being launched.


 Audio Filter Port                                               {#Create-Audio-Filter-Port}
 -----------------
 
 If you intend to filter audio, to act as an audio effect, then create an ABAudioFilterPort.

 This process is very similar to [creating a sender port](@ref Create-Audio-Sender-Port). You need to create an
 Info.plist AudioComponents entry for your port, this time using 'aurx' as the type, which identifies the 
 port as a Remote Effect, or 'aurm' which identifies it as a Remote Music Effect capable of
 [receiving MIDI](@ref Create-MIDI-Receiver-Port).
 
 <blockquote class="alert">
 If you create a port of Remote Instrument ('aurm') you need to make sure that your port is not receiving twice, one time via Inter-App audio and a second time via Core MIDI. To ensure that you must assign a block to the [enableReceivingCoreMIDIBlock](@ref ABAudiobusController::enableReceivingCoreMIDIBlock) property. Audiobus calls this block to tell your app exactly when to enable or disable receiving via Core MIDI. See [here](@ref Disable-Core-MIDI) for more details.
 </blockquote>

 <blockquote class="alert">
 It's very important that you use a different AudioComponentDescription for each port (represented by the type, subtype
 and manufacturer fields). If you don't have a unique AudioComponentDescription per port, you'll get all sorts of
 Inter-App Audio errors (like error -66750 or -10879).
 
 The Audiobus Developer Center will check that your AudioComponentDescriptions are unique among the Audiobus community,
 but this is not a guarantee of uniqueness among non-Audiobus apps.
 </blockquote>
 
 Then you create an ABAudioFilterPort instance, passing in the port name, for internal use, and a title for
 display to the user.

 Again, you may provide your IO audio unit (of type kAudioUnitSubType_RemoteIO, with input enabled), which will cause 
 the filter to use your audio unit for processing. This is the easiest, most efficient and recommended approach. As mentioned
 above, if you are using the C Core Audio API, this will be your main output unit. If you are using AVAudioEngine, you can 
 access this via AVAudioOutputNode/AVAudioInputNode's "audioUnit" property.
 
 @code
 self.filter = [[ABAudioFilterPort alloc] initWithName:@"Main Effect"
                                            title:@"Main Effect"
                        audioComponentDescription:(AudioComponentDescription) {
                            .componentType = kAudioUnitType_RemoteEffect,
                            .componentSubType = 'myfx',
                            .componentManufacturer = 'you!' }
                                        audioUnit:_ioUnit];
 
 [self.audiobusController addFilterPort:_filter];
 @endcode
 
 Alternatively, if you have a good reason for not using your IO audio unit with the filter port, you can use ABAudioFilterPort's
 @link ABAudioFilterPort::initWithName:title:audioComponentDescription:processBlock:processBlockSize: process block initializer @endlink.
 This allows you to pass in a block to use for audio processing.

 @code
 self.filter = [[ABAudioFilterPort alloc] initWithName:@"Main Effect"
                                            title:@"Main Effect"
                        audioComponentDescription:(AudioComponentDescription) {
                            .componentType = kAudioUnitType_RemoteEffect,
                            .componentSubType = 'myfx',
                            .componentManufacturer = 'you!' }
                                     processBlock:^(AudioBufferList *audio, UInt32 frames, AudioTimeStamp *timestamp) {
                                         // Process audio here
                                     } processBlockSize:0];
 @endcode
 
 Note that if you intend to use a process block instead of an audio unit, you are responsible for muting
 your app's normal audio output when the filter port is connected. See the 
 [Filter Port recipe](@ref Filter-Port-Recipe) for details.
 
 > ABAudioFilterPort, when initialized with a filter block (instead of an audio unit) will create and publish its own audio unit with the
 > AudioComponentDescription you pass into the initializer. If you are planning on using ABAudioFilterPort with a process block,
 > instead of an audio unit, then you **must not** publish any other audio unit with
 > the same AudioComponentDescription. Otherwise, *two audio units will be published with the same AudioComponentDescription*,
 > which would be bad, and would result in unexpected behaviour like silent output.
 > <br/>
 > If you're using ABAudioFilterPort with a filter block for the purposes of offering a new, separate audio processing
 > facility, separate from your published audio unit, and with a different AudioComponentDescription, though, you're fine.

 You may also optionally provide an icon (a 32x32 mask, with transparency) via the [icon](@ref ABAudioFilterPort::icon) property, 
 which is also displayed to the user and can change dynamically. We strongly recommend providing icons if you
 publish more than one port, so these can be recognized from one another. If you provide an icon here, you should
 also add that icon to the port on your app's registry on our developer site, so it can be displayed to users
 prior to your app being launched.

 If, outside of Audiobus, your app processes audio from the system audio input, and provides monitoring via the system
 output (it probably does!), we strongly suggest muting your app briefly when it's launched from Audiobus. This will avoid the
 case where the user experiences feedback in the second or so after your app is initialized, but before your app is 
 connected within Audiobus. Take a look at the AB Filter sample app for a demonstration of how this can be achieved,
 by checking to see if your app was launched via its Audiobus launch URL, and silencing the audio engine for the duration:

 @code
 @implementation MyAudioEngine
 -(id)init {
     ...
     [[NSNotificationCenter defaultCenter] addObserver:self 
                                              selector:@selector(applicationDidFinishLaunching:) 
                                                  name:UIApplicationDidFinishLaunchingNotification 
                                                object:nil];
     ...
 }
 ...
 -(void)dealloc {
     ...
     [[NSNotificationCenter defaultCenter] removeObserver:self];
     ...
 }
 ...
 -(void)applicationDidFinishLaunching:(NSNotification*)notification {
     if ( [[notification.userInfo[UIApplicationLaunchOptionsURLKey] scheme] hasSuffix:@".audiobus"] ) {
         // If this effect app has been launched from within Audiobus, we need to silence our output for a little while
         // to avoid feedback issues while the connection is established.
         if ( !_audiobusController.connected ) {
             // Mute
             self.muted = YES;
 
             // Set a timeout for three seconds, after which we can assume there's actually no
             // Audiobus connection forthcoming (something went wrong), and we should unmute
             dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(3.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                 self.muted = NO;
             });
         }
     }
 }
 ...
 -(void)portConnectionsChanged:(NSNotification*)notification {
     if ( _muted ) {
         // Unmute now if we were launched from Audiobus
         self.muted = NO;
     }
 }
 ...
 @end
 @endcode
 
 Audio Receiver Port                           {#Create-Audio-Receiver-Port}
 -------------------
 
 If you intend to receive audio, then you create an ABAudioReceiverPort.

 ABAudioReceiverPort works slightly differently to ABAudioSenderPort and ABAudioFilterPort: it does not use an audio unit,
 nor does it require an AudioComponentDescription. Instead, you call 
 @link ABAudioReceiverPort::ABAudioReceiverPortReceive ABAudioReceiverPortReceive @endlink to receive audio.

 First, create the receiver, and store it so you can use it to receive audio:

 @code
 @property (nonatomic, strong) ABAudioReceiverPort *receiverPort;
 @endcode

 @code
 self.receiverPort = [[ABAudioReceiverPort alloc] initWithName:@"Audio Input"
                                                    title:NSLocalizedString(@"Main App Input", @"")];
 [self.audiobusController addReceiverPort:_receiverPort];
 @endcode

 Now set up the port's @link ABAudioReceiverPort::clientFormat clientFormat @endlink property to whatever
 PCM `AudioStreamBasicDescription` you are using (such as non-interleaved stereo floating-point PCM):

 @code
 AudioStreamBasicDescription audioDescription = {
    .mFormatID          = kAudioFormatLinearPCM,
    .mFormatFlags       = kAudioFormatFlagIsFloat | kAudioFormatFlagIsPacked | kAudioFormatFlagIsNonInterleaved,
    .mChannelsPerFrame  = 2,
    .mBytesPerPacket    = sizeof(float),
    .mFramesPerPacket   = 1,
    .mBytesPerFrame     = sizeof(float),
    .mBitsPerChannel    = 8 * sizeof(float),
    .mSampleRate        = 44100.0
 };
 _receiverPort.clientFormat = audioDescription;
 @endcode
 
 Now you may receive audio using @link ABAudioReceiverPort::ABAudioReceiverPortReceive ABAudioReceiverPortReceive @endlink, 
 in a similar fashion to calling  `AudioUnitRender` on an audio unit. For example, within a Remote iO input 
 callback, you might write:
 
 @code
 AudioTimeStamp timestamp = *inTimeStamp;
 if ( ABAudioReceiverPortIsConnected(self->_receiverPort) ) {
    // Receive audio from Audiobus, if connected. Note that we also fetch the timestamp here, which is
    // useful for latency compensation, where appropriate.
    ABAudioReceiverPortReceive(self->_receiverPort, nil, ioData, inNumberFrames, &timestamp);
 } else {
    // Receive audio from system input otherwise
    AudioUnitRender(self->_audioUnit, ioActionFlags, inTimeStamp, 1, inNumberFrames, ioData);
 }
 @endcode
 
 > Just as with `AudioUnitRender`, it's important to continually call
 > @link ABAudioReceiverPort::ABAudioReceiverPortReceive ABAudioReceiverPortReceive @endlink once
 > @link ABAudioReceiverPort::ABAudioReceiverPortIsConnected ABAudioReceiverPortIsConnected @endlink returns YES,
 > even if you're not currently using the returned audio. If you don't do this, your app will not work correctly.
 
 > The receiver port assumes you provide monitoring - where you pass the incoming audio to the system output
 > so the user can hear it. If you do not do so, the user won't be able to hear any apps that send audio to
 > your app. If that's the case, ABAudioReceiverPort provides an automatic monitoring facility for you: just set
 > @link ABAudioReceiverPort::automaticMonitoring automaticMonitoring @endlink to YES to use it.
 
 See [The Receiver Port](@ref Receiver-Port) or the [Receiver Port recipe](@ref Receiver-Port-Recipe) for 
 more info on receiving.
 
 You may also optionally provide an icon (a 32x32 mask, with transparency) via the [icon](@ref ABAudioReceiverPort::icon) property, 
 which is also displayed to the user and can change dynamically. We strongly recommend providing icons if you
 publish more than one port, so these can be recognized from one another. If you provide an icon here, you should
 also add that icon to the port on your app's registry on our developer site, so it can be displayed to users
 prior to your app being launched.
 
 If you wish to receive multi-channel audio, with one audio stream for each connected app, see the section on
 [receiving separate streams](@ref Receiving-Separate-Streams).
 
 
 MIDI Ports
 ----------
 
 If you intend to work with MIDI in your app, you may wish to create some MIDI sender, filter or receiver ports as well. See [Working With MIDI](@ref Working-With-MIDI) for more information.
 
 Note that if you only wish to respond to MIDI messages to generate audio, then you do not need to create a [MIDI receiver port](@ref Create-MIDI-Receiver-Port): you just need to specify a type of Remote Instrument ('auri') when creating an ABAudioSenderPort, and respond to MIDI messages via Inter-App Audio's [kAudioOutputUnitProperty_MIDICallbacks](https://developer.apple.com/library/content/samplecode/InterAppAudioSuite/Listings/InterAppAudioSampler_InterAppAudioSampler_Sampler_mm.html) mechanism. Audiobus will do the rest.
 
 
 Update the Audiobus Registry                                {#Update-Registry}
 ----------------------------
 
 Once you've set up your ports, open your [app page](https://developer.audiob.us/apps) on the Audiobus
 Developer Center and fill in any missing port details.
 
 We **strongly recommend** that you drop your compiled Info.plist into the indicated area in order to automatically
 populate the fields:
 
 1. This is much faster than putting them in yourself.
 2. This will ensure the details are free of errors, which could otherwise cause some "Port Unavailable" errors to be seen.
 3. This checks that you're not using AudioComponent fields that are already in use in another app, which would cause problems.
 
 Filling in the port details here allows all of your app's ports to be seen within Audiobus prior to your
 app being launched.
 
 > It's important that you fill in the "Ports" section correctly, matching the values you are using with your
 > instances of the ABSender, ABFilter and ABReceiver ports. If you don't do this correctly, you will see
 > "Port Unavailable" messages within Audiobus when trying to use your app.
 
 > Once you have updated and saved the port information you will get a new API key.
 > Copy this API key to your application. On the next launch the port configuration
 > in your app is compared to the port information encoded in the API key. If
 > mismatches are detected detailed error messages are printed to the console.
 > Check this to find out if anything is wrong with your port registration.
 
 
 
9. Show and hide Inter-App Audio Transport Panel {#Show-and-hide-Inter-App-Audio-Transport-Panel}
=======

 If your app shows an Inter-App Audio transport panel, you will need to hide it while
 participating in an Audiobus session. To do so, assign a block to the property 
 [showInterAppAudioTransportPanelBlock](@ref ABAudiobusController::showInterAppAudioTransportPanelBlock)
 of your ABAudiobusController instance. Within the block you need to show or hide your Inter-App Audio Transport
 panel accordingly:
 
 @code
    _audiobusController.showInterAppAudioTransportPanelBlock = ^(BOOL showIAAPanel) {
        if ( showIAAPanel ) {
           // TODO: Show Inter-App Audio Transport Panel
        } else {
           // TODO: Hide Inter-App Audio Transport Panel
        }
    };
 @endcode
 
 
 
10. If your app is an IAA host, do not show Audiobus' hidden sender ports  {#Dont-show-Audiobus-hidden-sender-ports}
=======
  Audiobus provides a number of intermediate sender ports. These ports are 
  only used internally by the Audiobus SDK. If your app is an IAA host (like a multitrack recorder or any sort of recording app) you should
  hide these ports in the list of available Inter-App audio nodes. To check 
  if an audio component description belongs to a hidden Audiobus sender port, 
  you can use the following function declared in ABCommon.h:
 @code
   BOOL ABIsHiddenAudiobusPort(AudioComponentDescription audioComponentDescription);
 @endcode
 
  Here is a code fragment showing how an Inter-App audio port list can be generated
  that does not contain the hidden Audiobus intermediate ports:
 
 @code
 - (void) refreshAUList {
    [_publishedInstruments removeAllObjects];
    
    AudioComponentDescription searchDesc = { 0, 0, 0, 0, 0 };
    AudioComponent comp = NULL;
    while (true) {
        comp = AudioComponentFindNext(comp, &searchDesc);
        if (comp == NULL) break;
        
        AudioComponentDescription desc;
        if (AudioComponentGetDescription(comp, &desc)) continue;
 
 
        //Ignore hidden Audiobus Inter-App Audio nodes
        if(ABIsHiddenAudiobusPort(desc)) continue;
        
        //Fill list of other Inter-App audio nodes
        if (desc.componentType == kAudioUnitType_RemoteInstrument ||
            desc.componentType == kAudioUnitType_RemoteGenerator ) {
            RemoteAU *rau = [[RemoteAU alloc] init];
            rau->_desc = desc;
            rau->_comp = comp;
            rau->_image = [AudioComponentGetIcon(comp, 32) retain];
            AudioComponentCopyName(comp, (CFStringRef *)&rau->_name);
            [_publishedInstruments addObject: rau];
        }
    }
  }
 
 @endcode
 
 
 
 
11. Test        {#Test}
=======
 
 To test your app with Audiobus, you'll need the Audiobus app (https://audiob.us/download).
 
 You'll find a number of fully-functional sample apps in the "Samples" folder of the Audiobus SDK
 distribution. Use these to test your app with, along with other Audiobus-compatible apps you may own.
  
 <blockquote class="alert">We reserve the right to **ban your app** from the Compatible Apps listing or even from
 Audiobus entirely, if it does not work correctly with Audiobus. It's critical that you test your app properly.</blockquote>
 
12. Go Live        {#Go-Live}
===========
 
 <blockquote class="alert">Before you submit your app to the App Store, please ensure the details of your registration at
 the [apps page](https://developer.audiob.us/apps) are correct. If not, users may experience unexpected behaviour. The 
 Audiobus app caches the local copy of the registration for 30 minutes, so if you make any fixes to your app registration 
 after going live, some users may not see the fix for up to 30 minutes.</blockquote>
 
 Once the Audiobus-compatible version of your app has been approved by Apple and hits the App
 Store, you should visit the [apps page](https://developer.audiob.us/apps) and click "Go Live".
 
 This will result in your app being added to the Compatible Applications listing
 within Audiobus, and shown on Audiobus's website in various locations. We will also include your app
 in our daily app mailing list, and if anyone has subscribed at our [compatible apps listing](https://audiob.us/apps) 
 to be notified specifically when your app gains Audiobus support, they will be notified by email.
 
 > If you forget this step, potential new users will never find your app through our app directories,
 > losing you sales!
 
You're Done!        {#Youre-Done}
============

 Unless you want to do more advanced stuff, that's it, you're done. Run your app, open the
 Audiobus app, and you should see your app appear in the appropriate port picker in the Audiobus app,
 depending on the ports you created.

 Congratulations! You are now Audiobus compatible.
 
 > When it's time to update your app with new Audiobus functionality (such as a new Audiobus SDK version,
 > or a new Audiobus-specific feature, like State Saving or the addition of more ports, be sure to
 > register your new version from your app registration on [developer.audiob.us](https://developer.audiob.us/apps).
 > Once you go live with the new version, this will move your app to the top of the Audiobus Compatible Apps
 > directory, resulting in increased exposure.
 >
 > Note that you should never register your app twice: if you update your app, register a new version for
 > your existing app registration.

 The next thing to do is read the important notes on [Being a Good Citizen](@ref Good-Citizen) to
 make sure your app behaves nicely with others. In particular, if your app records audio, it's
 important to make correct use of audio timestamps so Audiobus's latency compensation works
 properly in your app and those your app connects to.
 
 If you are interested in handling MIDI in your app, read [Working With MIDI](@ref Working-With-MIDI)
 for more information.

 If your app provides both an ABAudioSenderPort and an ABAudioReceiverPort, you may wish to allow users to 
 connect your app's output back to its input. If your app supports this kind of functionality, you can set the 
 @link ABAudiobusController::allowsConnectionsToSelf allowsConnectionsToSelf @endlink
 property to YES, and select the "Allows Connections To Self" checkbox on the app details
 page at [developer.audiob.us](https://developer.audiob.us/apps), once you've ensured that your app doesn't
 exhibit feedback issues in this configuration. See the documentation for
 @link ABAudioSenderPort::ABAudioSenderPortIsConnectedToSelf ABAudioSenderPortIsConnectedToSelf @endlink
 /@link ABAudioReceiverPort::ABAudioReceiverPortIsConnectedToSelf ABAudioReceiverPortIsConnectedToSelf @endlink for discussion,
 and the AB Receiver sample app for a demonstration.
 
 If you'd like to make your app more interactive, you can implement [triggers](@ref Triggers) that
 allow users to trigger actions in your app (like toggling recording, playback, etc) from other
 apps and devices.
 
 If your app has a clock, we'd recommend looking into [Ableton Link](http://ableton.com/link) for
 synchronization with other apps. The Audiobus SDK automatically supports Link, and will enable it within
 your app when it's connected to Audiobus. There's nothing you need to do but include the Link SDK within
 your app.
 
 The Audiobus app has a "Developer Mode" setting in its preferences screen. 
 Developer mode makes Audiobus print additional information to the console.
 This can be helpful in case you're encountering problems with Audiobus.

 Finally, tell your users that you support Audiobus! We provide a set of graphical resources
 you can use on your site and in other promotional material. Take a look at
 the [resources page](https://developer.audiob.us/resources) for the details.

 Read on if you want to know about more advanced uses of Audiobus, such as [MIDI](@ref Working-With-MIDI), multi-track
 [receiving](@ref Receiver-Port), [triggers](@ref Triggers), or [state saving](@ref State-Saving).
 
 
@page Working-With-MIDI Working with MIDI
 
 From version 3, Audiobus supports sending, filtering and receiving MIDI messages. This section explains how
 to get up and running with MIDI.
 
 If you have not done so yet, read the [Integration Guide](@ref Integration-Guide), which describes how to get started
 with the Audiobus SDK.
 
 1. Create a Regular Audio App   {#Working-With-MIDI-Create-an-ordinary-audio-app}
 ===============================
 
 Whether your MIDI app is a synthesizer, or a controller that produces no audio of
 its own, your app needs to have an audio engine. This is because:
 
 1. In order to receive MIDI in the background, your app needs to stay active
    in the background. This is only possible if your app has a running audio engine.
 2. Audiobus launches apps into the background via Inter-App Audio, which is only possible
    if your app provides an Inter-App Audio component.
 
 Consequently, the first step is to follow the @ref Integration-Guide "Integration Guide"
 and create a regular audio app, consisting of at least one [audio sender port](@ref Create-Audio-Sender-Port).
 
 2. Create MIDI Ports                            {#MIDI-Integration-Add-MIDI-Ports}
 ====================

 Now you're ready to create your Audiobus MIDI ports. You can create as many MIDI 
 ports as you like. For example, a multi timbral synth could offer one MIDI
 receiver port for each timbre: SoundPrism Link Edition offers three
 MIDI receiver ports, one for the bass synth, one for the chord synth and one 
 for the lead synth. A multi keyboard app could provide one MIDI 
 sender port for each keyboard.
 
 
 MIDI Sender Port                                              {#Create-MIDI-Sender-Port}
 ----------------
 Apps which offer MIDI Sender Ports appear in the "INPUTS" slots of the Audiobus MIDI page.
 If your app intends to send MIDI to other apps you need to create an instance
 of ABMIDISenderPort. The first MIDI sender port you define will be the one that 
 Audiobus will connect to when the user taps your app in the port picker on 
 the MIDI page in Audiobus, so it's best to define the port with the most
 general default behaviour first.
 
 The instantiation of a MIDI sender port is quite simple:
 
 @code
 self.MIDISenderPort =
    [[ABMIDISenderPort alloc] initWithName:@"MIDISend"
                                     title:@"MIDI Sender"];
 @endcode
 
 Like all other ports the new MIDI sender port needs to be added to the Audiobus
 controller:
 
 @code
 [self.audiobusController addMIDISenderPort:self.MIDISenderPort];
 @endcode
 
 
 MIDI can now be sent using [ABMIDIPortSendPacketList](@ref ABMIDIPort::ABMIDIPortSendPacketList), like this:
 
 @code
 ABMIDIPortSendPacketList(_MIDISenderPort, packetList);
 @endcode
 
 
 
 A working example of this code can be found within our AB Sender sample app.
 AB Sender is able to send MIDI notes you play on the local keyboard.
 
 
 MIDI Filter Port                                              {#Create-MIDI-Filter-Port}
 ----------------
 
 Apps that have MIDI Filter Ports appear in the "Effects" slots of the Audiobus 
 MIDI page. A MIDI filter port is instantiated with a name and a title, and with a block which is called
 when MIDI messages arrive. The task of the block is to modify and forward the processed MIDI data using
 [ABMIDIPortSendPacketList](@ref ABMIDIPort::ABMIDIPortSendPacketList):
 
 @code
    self.MIDIFilterPort
    = [[ABMIDIFilterPort alloc] initWithName:@"Transpose"
                                       title:@"Transpose"
                               receiverBlock:^(__unsafe_unretained ABPort * filterPort,
                                               const MIDIPacketList * packetList) {
       // TODO:
       // 1. Copy the packet list,
       // 2. Change events in the copied packet list
       // 3. Send the copied and changed packet list again using 
       //    ABMIDIPortSendPacketList
    }];
 @endcode
 
 Like all other ports the new MIDI filter port needs to be added to the Audiobus
 controller:
 
 @code
 [self.audiobusController addMIDIFilterPort:self.MIDIFilterPort];
 @endcode
 
 > Filter MIDI events by copying the original MIDI packet list. Change the 
 > MIDI events that are relevant to your filter. All other MIDI events should
 > remain unchanged in the processed list.
 
 > The receiverBlock is called from a realtime MIDI receive thread,
 > so be careful not to do anything that could cause priority inversion,
 > like calling Objective-C, allocating memory, or holding locks.
 
 
 
 MIDI Receiver Port                                            {#Create-MIDI-Receiver-Port}
 ------------------
 
 Apps that have MIDI receiver ports appear in the "Outputs" slots of the Audiobus
 MIDI page.
 
 > If your app is already an Inter-App Audio instrument (your sender port has type '`auri`') or an 
 > Inter-App Audio music effect (your filter port has type '`aurm`'), you don't need to implement 
 > a MIDI receiver port. Audiobus will show your app in the "Outputs" slot and provide your app with MIDI
 > via Inter-App Audio.
 
 > If you manually create at least one ABMIDIReceiverPort instance, then Audiobus will not send
 > any MIDI via Inter-App Audio to your app. All MIDI will be sent via the
 > receiver port instead.
 
 A MIDI receiver port is instantiated with a name and a title, and with a block which is called when
 MIDI messages arrive.
 
 @code
    self.MIDIReceiver
    = [[ABMIDIReceiverPort alloc] initWithName:@"MIDIReceive"
                                         title:@"MIDIReceive"
                                receiverBlock:^(__unsafe_unretained ABPort * receiverPort,
                                                const MIDIPacketList * packetList) {
        // TODO: Process the received MIDI here
    }];
 @endcode
 
 Like all other ports the new MIDI receiver port needs to be added to the Audiobus
 controller:
 
 @code
 [self.audiobusController addMIDIReceiverPort:self.MIDIReceiver];
 @endcode
 
 > The receiverBlock is called from a realtime MIDI receive thread,
 > so be careful not to do anything that could cause priority inversion,
 > like calling Objective-C, allocating memory, or holding locks.
 
 
 Multi-instance MIDI Ports {#Multi-instance-MIDI-Ports}
 ------------------------------------------------------
 
 Audiobus' Multi-instance MIDI ports feature allows you to create
 new MIDI ports on demand. Here are some examples where Multi-instance ports are 
 useful:
 
 - **Multitrack MIDI recorder apps**: Each time your MIDI recorder
   is added to an Audiobus MIDI connection pipeline a new instance of a MIDI
   receiver port is created automatically. MIDI events received on different 
   dynamically created MIDI receiver ports are stored on different tracks.
 
 - **Multi-Keyboard apps**: Each time the Multi-Keyboard app is added to a connection
   pipeline a new MIDI sender port instance is created. The multi keyboard app
   creates a new keyboard UI for each port instance.
 
 - **Multi-MIDI-Effect-Racks**: Add a MIDI effect to multiple connection pipelines at the
   same time. Receive and process and filter the MIDI streams of these pipelines
   separately. The AB MIDI Filter sample app does this: Each time it is added 
   to a connection pipeline a new channel strip is added allowing to transpose
   the connected stream.
 
 All three port types, ABMIDISenderPort, ABMIDIFilterPort as well ABMIDIReceiverPort
 can be configured as Multi-instance ports.
 The following example shows how this is done for a MIDI filter port. The code
 samples are taken from the AB MIDI Filter sample app.
 
 To prevent a retain cycle we create a weak reference to self first:
 
 @code
 __weak ABMIDIFilterAudioEngine * weakSelf = self;
 @endcode
 
 A multi-instance MIDI filter port is instantiated with four parameters:
 a `name`, a `title` an `instanceConnectedBlock` and an `instanceDisconnectedBlock`.
 The first block is called each time the filter port is added to an connection pipeline,
 the second each time the filter port is removed from an connection pipeline:
 
 @code
 self.MIDIFilterPort = [[ABMIDIFilterPort alloc]
    initWithName:@"Transpose" title:@"Transpose"

    // React to creation of a new port instance
    instanceConnectedBlock:^(ABMIDIPort * instance) {
       [weakSelf portInstanceAdded:(ABMIDIFilterPort *)instance];
    }

    // React to disposing of an additional instance
    instanceDisconnectedBlock:^(ABMIDIPort * instance) {
       [weakSelf portInstanceRemoved:(ABMIDIFilterPort *)instance];
    }];
 @endcode
 
 The `instanceConnectedBlock` calls the selector `portInstanceAdded:` which
 adds a MIDI receiver callback to the automatically created filter port 
 instance and informs the UI about the new port:
 
 @code
 - (void)portInstanceAdded:(ABMIDIFilterPort*)filterPort {
    
    // Assign a receiver block to the newly created filter port
    filterPort.MIDIReceiverBlock
        = ^(__unsafe_unretained ABPort * port, const MIDIPacketList * inMIDI) {
            // Perform MIDI processing here
        };
 
    // Update UI for added port, etc.
}
 @endcode
 
 The `instanceDisconnectedBlock` calls the selector `portInstanceRemoved:` which
 simply informs the UI about the change.
 
 @code
 - (void)portInstanceRemoved:(ABMIDIFilterPort*)filterPort  {
    // Update UI for removed port, etc.
 }
 @endcode
 
 To configure a port as a Multi-instance port, you need to flag it as such in the 
 [Audiobus registry](https://developer.audiob.us/apps) by ticking the "Multi-instance"
 checkbox beside the port entry.
 
 
 3. Avoid double notes by disabling Core MIDI when necessary  {#Disable-Core-MIDI}
 ===========================================================
 
 Audiobus 3's MIDI routing operates independently of Core MIDI, allowing users to set up
 particular MIDI routings. However, Core MIDI knows nothing about Audiobus, and consequently
 there are certain situations -- particularly when MIDI hardware is involved -- that can result
 in a double routing, causing incoming MIDI events to be doubled up.
 
 These double routings are very obscure and difficult for inexperienced users to understand
 and diagnose. Consequently, in order to avoid double notes and other problems, it's very important to disable
 receiving and sending MIDI via Core MIDI in your app when your app's part of an Audiobus session.
 
 The following figure shows examples for when receiving Core MIDI should be disabled.
 A MIDI source (such as a MIDI keyboard) is connected to your iOS device.
 Audiobus 3 will receive the MIDI events, route them through any connected MIDI effects
 and then forward them to your app. At the same time your app is also
 listening via Core MIDI to the connected keyboard: this causes the MIDI event to be
 received twice by your app – both from Audiobus and via Core MIDI.
 
 <img src="disableReceivingCoreMIDI.png" width="570" title="Core MIDI double routings" />
 
 <blockquote class="alert">
 If you don't stop sending to other destinations via Core MIDI
 these destinations will receive MIDI notes twice, from your app as well Audiobus.
 
 If you don't stop receiving from other sources via Core MIDI
 your app will receive MIDI notes twice, from your app and Audiobus.
 </blockquote>
 
 
 To prevent such double routings, ABAudiobusController provides two properties, [enableReceivingCoreMIDIBlock](@ref ABAudiobusController::enableReceivingCoreMIDIBlock)
 and [enableSendingCoreMIDIBlock](@ref ABAudiobusController::enableSendingCoreMIDIBlock).
 <ul>
 <li>If your app has at least one MIDI receiver port (Audiobus or Inter-App Audio)</li>
 you must assign a block to [enableReceivingCoreMIDIBlock](@ref ABAudiobusController::enableReceivingCoreMIDIBlock).
 <li>If your app has at least one MIDI sender port, you must assign a block to
 [enableSendingCoreMIDIBlock](@ref ABAudiobusController::enableSendingCoreMIDIBlock).</li>
 </ul>
 
 
 For example:
 
 @code
 _audiobusController.enableReceivingCoreMIDIBlock = ^(BOOL receivingEnabled) {
     if ( receivingEnabled ) {
         // TODO: Core MIDI RECEIVING needs to be enabled
     } else {
         // TODO: Core MIDI RECEIVING needs to be disabled
     }
 };
 
 _audiobusController.enableSendingCoreMIDIBlock = ^(BOOL sendingEnabled) {
     if ( sendingEnabled ) {
         // TODO: Core MIDI SENDING needs to be enabled
     } else {
         // TODO: Core MIDI SENDING needs to be disabled
     }
 };
 @endcode
 
 4. Update Audiobus Registry               {#MIDI-Update-Audiobus-Registry}
 ===========================
 
 Just like audio ports, MIDI ports need to be registered with the Audiobus registry.
 Once you've set up your MIDI ports, open your [app page](https://developer.audiob.us/apps) on the Audiobus
 Developer Center and fill in any missing port details.
 
 Filling in the port details here allows all for your app's ports to be seen
 within Audiobus prior to your app being launched.
 
 If your app is MIDI only (i.e. it does not produce audio on its own), then you should hide your audio sender port so that it does not appear within Audiobus. To do so, check the "Hidden" checkbox on the Audiobus registry beside your audio ports.
 
 > It's important that you fill in the "Ports" section correctly,
 > matching the values you are using with your instances of the ABMIDISender,
 > ABMIDIFilter and ABMIDIReceiver ports. If you don't do this correctly, you will see
 > "Port Unavailable" messages within Audiobus when trying to use your app.
 
 > Once you have updated and saved the port information you will receive a new API key.
 > Copy this API key to your application. On the next launch the port configuration
 > in your app is compared to the port information encoded in the API key. If
 > mismatches are detected detailed error messages are printed to the console.
 > Check it to find out if anything is wrong with your port registration.
 
 
 5. Be a Good MIDI Citizen          {#Be-A-Good-MIDI-Citizen}
 =========================
 
 There are a few extra steps you need to take in order to make sure your app functions 
 correctly:
 
 - Hide your audio sender ports if your app is a pure MIDI app
 - Avoid double notes by [disabling Core MIDI when necessary](@ref Disable-Core-MIDI).
 - Avoid note soup with a filtered MIDI stream by [respecting Local On/Off](@ref Local-On-Off).
 - [Mute your internal sound engine](@ref Mute-Internal-Sound-Engine) when acting as a MIDI controller.
 
 Here's how:
 
 
 Hide your audio sender ports if your app is a pure MIDI app  {#Hide-your-sender-ports}
 -----------------------------------------------------------
 
 If your app is a pure MIDI app you need to hide your Audio Sender port. Otherwise
 it will be shown in the Audio input port picker list. Here's how to do that:
 
 <ol>
 <li> Visit your app at http://developer.audiob.us/apps, scroll down to the port list, and
 check the "Hidden" checkbox right below your audio sender port.</li>
 <li> After instantiating your audio sender port set the isHidden property:
 @code
 ABPort *audioSenderPort = [[ABAudioSenderPort alloc] initWithName:...];
 audioSenderPort.isHidden = YES;
 @endcode
 </li>
 </ol>
 
 Sample code for a hidden port can be found in the file ABMIDIFilterAuidoEngine.m
 in the Audiobus 3 SDK.
 
 
 
 
 Avoid note soup by respecting Local On/Off         {#Local-On-Off}
 ------------------------------------------
 
 This section applies to you if your app sends MIDI (via ABMIDISenderPort), and also receives MIDI (either via
 ABMIDIReceiverPort or via Inter-App Audio via ABAudioSenderPort with a "Remote Instrument" 
 'auri' type).  A synth app that also behaves as a MIDI controller falls into this category, for example.
 
 Audiobus allows users to create connection pipelines where MIDI events generated
 by an app are routed through an effect and then back to the original app:
 
 <img src="localOff2.png" width="692" height="309" title="A typical Local Off scenario" />
 
 In this scenario, a synth app is expected to generate audio based on the modified MIDI
 events coming from the Audiobus chain, *and not local MIDI events originating from the app*.
 
 If your app incorrectly responds to both the local MIDI events *and* those coming from the Audiobus signal chain,
 then your users are likely to experience double notes and other unexpected behaviour, as your app
 receives MIDI events twice.
 
 To avoid this situation, ABMIDISenderPort provides a property called
 [localOn](@ref ABMIDISenderPort::localOn). When the value of this property is YES, your app
 should respond to local events as normal, as well as any events coming from Audiobus. However, 
 when the value of `localOn` is NO, it's important that your app *only respond to MIDI events coming
 from Audiobus*.
 
 To respond to changes in `localOn`, observe the property of your ABMIDISenderPort instance
 and respond appropriately when changes occur:
 
 @code
 void *kMIDIPortLocalOnChanged = &kMIDIPortLocalOnChanged;
 
 ...

 [self.MIDISenderPort addObserver:self
                       forKeyPath:@"localOn"
                          options:0
                          context:kMIDIPortLocalOnChanged];
 
 ...
 
 -(void)observeValueForKeyPath:(NSString *)keyPath
                         ofObject:(id)object
                           change:(NSDictionary *)change
                          context:(void *)context {
     if ( context == kMIDIPortLocalOnChanged ) {
         if ( self.MIDISenderPort.localOn ) {
             // Internal sound engine should respond to both internal MIDI events and
             // those coming from Audiobus
         } else {
             // Internal sound engine should only respond to MIDI events coming from Audiobus
         }
     } else {
         [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
     }
 }
 @endcode
 
 See the AB Sender sample app for a demonstration of this.

 > You should not access any Objective C code from a realtime thread like the
 > audio rendering callback. If you want to evaluate the localOn property from
 > there, you can use the realtime-safe C function [ABMIDISenderPortIsLocalOn](@ref ABMIDISenderPort::ABMIDISenderPortIsLocalOn).
 
 Mute your internal sound engine        {#Mute-Internal-Sound-Engine}
 -------------------------------
 
 If your app is both a MIDI controller or filter *and* a sound generator,
 the internal sound engine needs to be muted in some cases. Consider the following
 MIDI connection pipeline:
 
 <img src="muteSoundEngine0.png" width="580" height="234" title="A case where the internal sound engine needs to be muted." />
 
 In this example, AB Sender is used as MIDI controller in the MIDI Input slot. The generated notes are sent
 to AB MIDI Filter. From there the events are sent to Animoog. In this scenario, AB Sender is a 
 pure MIDI controller, and must not generate any of its own audio.
 
 To allow your app to mute when appropriate, ABAudioSenderPort provides a property called
 [muted](@ref ABAudioSenderPort::muted). When the value of this property is YES, your app should
 avoid producing any audio output. When NO, your app should behave as usual.
 
 To respond to changes to the `muted` property, observe the property of your
 ABAudioSenderPort instance and respond appropriately when changes occur:
 
 @code
 void *kSenderPortMutedChanged = &kSenderPortMutedChanged;

 ...
 
 [sender addObserver:self
         forKeyPath:@"muted"
             options:0
             context:kSenderPortMutedChanged];

  ...
 
  -(void)observeValueForKeyPath:(NSString *)keyPath
                         ofObject:(id)object
                           change:(NSDictionary *)change
                          context:(void *)context {
     if ( context == kSenderPortMutedChanged ) {
         if ( self.audioSenderPort.muted ) {
             // Mute the internal sound engine
         } else {
             // Unmute the internal sound engine
         }
     } else {
         [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
     }
 }
 @endcode
 
 See the AB Sender sample app for a demonstration of this.
 
 > You should not access any Objective C code from a realtime thread.
 > If you want to evaluate the muted property from
 > there, you can use the realtime-safe C function `ABAudioSenderPortIsMuted`.
 
 > If possible, Audiobus will mute your app's audio engine for you. But it can't
 > make your app stop processing audio. So in the case that no audio is audible
 > you should make sure that your sound engine does not process audio.
 > This will save CPU resources as well as battery power.
 
 
 
 Don't use MIDI channels                               {#Dont-use-MIDI-channels}
 -----------------------
 
 Audiobus-compatible apps should not use the MIDI Channel information contained
 within MIDI packets. As Audiobus uses ports (instances of `ABMIDIReceiverPort`, `ABMIDIFilterPort` and `ABMIDISenderPort`)
 for routing of MIDI, the MIDI Channel data is not required and using it can cause unexpected behaviour.
 
 - If possible, let your app only send on MIDI channel 0.
 - Do not evaluate MIDI channels. It should make no difference for your app if a message has MIDI channel 1, 2, etc.
 - If your app is a multitimbral synth and must therefore receive on multiple
   MIDI channels, create separate instances of `ABMIDIReceiverPort` for each timbre you want to use. The app SoundPrism
   creates one MIDI port for the bass sound, one for the chord sound and one for the melody sound, for example.
 - If your app is a complex MIDI controller, please create an instance
   of `ABMIDISenderPort` for each MIDI channel you want to use. The app Fugue Machine creates one instance of 
   `ABMIDISenderPort` for each playhead, for example.
 
 By using Audiobus MIDI ports instead of MIDI Channel information, your app allows Audiobus to correctly display
 MIDI sources and destinations to the user.
 
 
 Don't show private MIDI ports                     {#Dont-use-private-MIDI-ports}
 -----------------------------
 
 Audiobus uses private Virtual Core MIDI Sources and Destinations to route MIDI from app to app. Normally, private
 MIDI ports should never appear within other apps. Unfortunately there is currently a bug in iOS making these
 ports visible from time to time.
 
 To prevent your app's Core MIDI sources and destinations list from showing tons of Audiobus MIDI ports, please check
 if a port is private before displaying it to the user. Use this code to find out if a MIDI endpoint is private or not:
 
 @code
 BOOL isPrivateMIDIEndpoint(MIDIEndpointRef endpoint){
    OSStatus result;
    SInt32 isPrivate;
    
    result = MIDIObjectGetIntegerProperty (endpoint, kMIDIPropertyPrivate, &isPrivate);
    if (result == noErr)
        return isPrivate != 0;
    else
        return NO;
}
 @endcode
 
 Ideally, you should perform this check some milliseconds after a port has been appeared, to allow the owning app to
 set this flag on the other end.

 
 Developer Mode and Automatic App Termination  {#Dev-mode-and-automatic-app-termination}
 --------------------------------------------
 
 There is currently a bug in iOS which breaks receiving from Core MIDI when an app is relaunched
 into the background. To work around this bug we have added a mechanism within the Audiobus SDK that allows
 us to terminate and restart your app while it is in background. We only use this system if the aforementioned bug
 is observed. Currently only apps having one or more ports of type `ABMIDIReceiverPort` and `ABMIDIFilterPort` are 
 affected by this bug.
 
 If your app provides one of these ports you might want to observe [ABApplicationWillTerminateNotification](@ref ABApplicationWillTerminateNotification).
 This notification will be sent out shortly before Audiobus will terminate and relaunch your app.
 
 To disable this functionality during debugging, enable "Developer Mode" in the preferences of the Audiobus App.
 

@page Migration-Guide 2.x-3.x Migration Guide
 
 Along with a variety of workflow improvements including launching into the background,
 the main new addition in Audiobus 3 is MIDI routing. You can now send, filter and
 receive MIDI just like you can with audio, using the three new classes:
 
 - ABMIDISenderPort
 - ABMIDIFilterPort
 - ABMIDIReceiverPort
 
 Here's what you need to do to update your existing Audiobus 2 integration to Audiobus 3.
 
 
 1. Replace Audiobus 2 SDK                        {#Migration-Guide-Replace-SDK}
 ======================
 
 First you need to [download the Audiobus 3 SDK](@ref Project-Setup). Simply replace
 the previous Audiobus 2 SDK with the new one. 
 
 Additionally you need to link `libz.tbd` to your project, from your app target's
 "Link Binary With Libraries" build phase.
 
 
 2. Rename ABSenderPort, ABFilterPort and ABReceiverPort   {#Migration-Guide-Rename-Ports}
 ====================================================
 
 Audiobus 3 clearly distinguishes between audio and MIDI ports. Therefore
 you need to rename all occurrences of ABSenderPort, ABFilterPort and ABReceiverPort 
 to ABAudioSenderPort, ABAudioFilterPort and ABAudioReceiverPort, respectively.
 
 If you want to save time, the [migrateAudiobus3.py](migrateAudiobus3.py)
 script (also contained in the Audiobus SDK folder) will perform all required
 renaming for you. Here's how to use it:
 
 1. Make a backup of your current source folder
 2. Open the Terminal application
 3. Change into the folder containing `migrateAudiobus3.py` (e.g. the Audiobus 3 SDK folder)
 4. Enter `python migrateAudiobus3.py YOURSOURCEFOLDER`
 5. Compile and check for errors
 
 
 
 3. Create A New Version On The Audiobus Registry                {#Migration-Guide-Version}
 ==================================
 
 To ease the integration of the Audiobus SDK we have introduced a new API key format.
 With the help of the new API key we are now able to check if the ports declared
 in your app match the ports declared in the Audiobus registry. If this is not
 the case a detailed error message is printed to the console, helping you to identify and
 fix the issue as quickly as possible. To update the API key of your app please
 follow these steps:
 
 1. Increase the version number of the Audio Components in your app's Info.plist file.
 2. Open the [Audiobus Developer Center](https://developer.audiob.us/apps/), and open your
 app's registration there.
 3. Scroll down and click the green "Add Version" button.
 4. Access the compiled version of your app's Info.plist:
    1. Build your app, and find the built version in the "Products" area within Xcode.
    2. Right-click your app, and select "Show in Finder".
    3. Right-click your app in Finder, and select "Show Package Contents". Find Info.plist
       within this folder.
 5. Drag and drop your app's compiled Info.plist file in the field provided for it on the
    Audiobus Developer Center.
 6. Press "Submit".
 7. You will receive a new API key. Instantiate ABAudiobusController with that new key.
 8. Run your app and check the console output for any error messages.

 
 4. Disable Core MIDI when Necessary         {#Migration-Guide-Add-MIDI-Support}
 ===================================
 
 If your app interacts with Core MIDI directly, then it's important that you disable any Core MIDI
 functionality in your app when connected to Audiobus. This will prevent your app from receiving 
 Core MIDI events twice, once via Audiobus and once from the Core MIDI system itself.
 
 Please read and implement the chapter @ref Disable-Core-MIDI "Disable Core MIDI"
 in the MIDI guide. Audiobus will tell you when to enable and disable sending and receiving Core MIDI.
 
 5. Hide Inter-App Audio Transport Panel         {#Migration-Guide-Hide-Inter-App-Audio-Transport-Panel}
 =======================================
 
 If your app shows an Inter-App Audio transport panel, you will need to hide it while
 participating in an Audiobus session. See 
 @ref Show-and-hide-Inter-App-Audio-Transport-Panel "Show and hide Inter-App Audio Transport Panel" 
 in the audio integration guide for more info.
 
 6. Inter-App Audio Hosts: Do not show Audiobus' hidden sender ports  {#Migration-Guide-Dont-show-hidden-sender-ports}
 ==================================================

 Audiobus provides a number of hidden intermediate sender ports. These ports are
 only used internally by the Audiobus SDK. If your app is an Inter-App Audio host you should
 hide these ports in the list of available Inter-App Audio nodes. For more
 information read the section entitled
 @ref Dont-show-Audiobus-hidden-sender-ports "If your app is an IAA host, do not show Audiobus' hidden sender ports"
 in the audio integration guide.
 
 7. Hosts, Audiobus 2 and Audiobus 3 behave differently {#Migration-Guide-AB2-and-AB3-behave-differently}
 ======================================================
 
 There are some important differences between the way inputs and filters are 
 connected to outputs. If your app offers an ABAudioReceiverPort, please read
 the chapter @ref Differences-between-audiobus-2-and-audiobus-3 "Differences between Audiobus 2 and Audiobus 3".
 
@page Recipes Common Recipes

 This section contains code samples illustrating a variety of common Audiobus-related tasks.
 More sample code is available within the "Samples" folder of the SDK distribution.
 
 Create a sender port and send audio manually        {#Sender-Port-Recipe}
 ============================================

 This code snippet demonstrates how to create a sender port, and then send audio through it 
 manually, without using ABAudioSenderPort's audio unit initialiser. Note that the audio unit method is
 recommended as it's much simpler, but there may be circumstances under which more control is needed, 
 such as when you are publishing multiple sender ports.
 
 The code below also demonstrates how to use the result of 
 @link ABAudioSenderPort::ABAudioSenderPortIsMuted ABAudioSenderPortIsMuted @endlink to determine when to mute output.
 
 @code
 @interface MyAudioEngine ()
 @property (strong, nonatomic) ABAudiobusController *audiobusController;
 @property (strong, nonatomic) ABAudioSenderPort *sender;
 @end
 
 @implementation MyAudioEngine
 
 -(id)init {
    ...
 
    self.audiobusController = [[ABAudiobusController alloc] initWithApiKey:@"YOUR-API-KEY"];
 
    ABAudioSenderPort *sender = [[ABAudioSenderPort alloc] initWithName:@"Audio Output"
                                                        title:NSLocalizedString(@"Main App Output", @"")
                                    audioComponentDescription:(AudioComponentDescription) {
                                        .componentType = kAudioUnitType_RemoteGenerator,
                                        .componentSubType = 'subt',
                                        .componentManufacturer = 'manu' }];
    sender.clientFormat = [MyAudioEngine myAudioDescription];
    [self.audiobusController addAudioSenderPort:_sender];

    ...
 }
 
 ...
 
 static OSStatus audioUnitRenderCallback(void *inRefCon, 
                                         AudioUnitRenderActionFlags *ioActionFlags,
                                         const AudioTimeStamp *inTimeStamp, 
                                         UInt32 inBusNumber, 
                                         UInt32 inNumberFrames, 
                                         AudioBufferList *ioData) {

    __unsafe_unretained MyAudioEngine *self = (__bridge MyAudioEngine*)inRefCon;

    // Do rendering, resulting in audio in ioData
    ...
 
    // Now send audio through Audiobus
    ABAudioSenderPortSend(self->_sender, ioData, inNumberFrames, inTimeStamp);
 
    // Now mute, if appropriate
    if ( ABAudioSenderPortIsMuted(self->_sender) ) {
        // If we should be muted, then mute
        for ( int i=0; i<ioData->mNumberBuffers; i++ ) {
            memset(ioData->mBuffers[i].mData, 0, ioData->mBuffers[i].mDataByteSize);
        }
        *ioActionFlags |= kAudioUnitRenderAction_OutputIsSilence;
    }
 }
 @endcode

 Create a filter port with a process block        {#Filter-Port-Recipe}
 =========================================

 This demonstrates how to create and implement a filter port with a process block. Using
 a process block is more complex than using ABAudioFilterPort's audio unit initialiser, but
 may provide more flexibility under certain circumstances, such as when you are publishing
 multiple filter ports.
 
 The code creates a filter port, providing a processing implementation block which is
 invoked whenever audio arrives on the input side of the filter. After the block is called,
 during which your app processes the audio in place, Audiobus will automatically send the
 processed audio onwards.
 
 The code also demonstrates how to mute your audio system when the filter port is connected.
 
 @code
 @interface MyAudioEngine ()
 @property (strong, nonatomic) ABAudiobusController *audiobusController;
 @property (strong, nonatomic) ABAudioFilterPort *filter;
 @end
 
 @implementation MyAudioEngine
 
  -(id)init {
    ...
 
    self.audiobusController = [[ABAudiobusController alloc] initWithApiKey:@"YOUR-API-KEY"];
 
    self.filter = [[ABAudioFilterPort alloc] initWithName:@"Main Effect"
                                               title:@"Main Effect"
                           audioComponentDescription:(AudioComponentDescription) {
                               .componentType = kAudioUnitType_RemoteEffect,
                               .componentSubType = 'myfx',
                               .componentManufacturer = 'you!' }
                                        processBlock:^(AudioBufferList *audio, UInt32 frames, AudioTimeStamp *timestamp) {
                                            processAudio(audio);
                                        } processBlockSize:0];

    filter.clientFormat = [MyAudioEngine myAudioDescription];
    [self.audiobusController addFilterPort:_filter];
 
    ...
 }
 
 ...
 
 static OSStatus audioUnitRenderCallback(void *inRefCon, 
                                         AudioUnitRenderActionFlags *ioActionFlags,
                                         const AudioTimeStamp *inTimeStamp, 
                                         UInt32 inBusNumber, 
                                         UInt32 inNumberFrames, 
                                         AudioBufferList *ioData) {

    __unsafe_unretained MyAudioEngine *self = (__bridge MyAudioEngine*)inRefCon;
 
    // Mute and exit, if filter is connected
    if ( ABAudioFilterPortIsConnected(self->_filter) ) {
        for ( int i=0; i<ioData->mNumberBuffers; i++ ) {
            memset(ioData->mBuffers[i].mData, 0, ioData->mBuffers[i].mDataByteSize);
        }
        *ioActionFlags |= kAudioUnitRenderAction_OutputIsSilence;
        return noErr;
    }


    ...
 
 }
 @endcode
 
 Create a receiver port and receive audio        {#Receiver-Port-Recipe}
 ========================================

 This code illustrates the typical method of receiving audio from Audiobus.
 
 The code creates a single receiver port, assigns an AudioStreamBasicDescription describing the audio format to
 use, then uses the port to receive audio from within a Remote IO input callback.
 
 @code
 @interface MyAudioEngine ()
 @property (strong, nonatomic) ABAudiobusController *audiobusController;
 @property (strong, nonatomic) ABAudioReceiverPort *receiver;
 @end
 
 @implementation MyAudioEngine
 
 -(id)init {
    ...
 
    self.audiobusController = [[ABAudiobusController alloc] initWithApiKey:@"YOUR-API-KEY"];
 
    self.receiver = [[ABAudioReceiverPort alloc] initWithName:@"Main" title:NSLocalizedString(@"Main Input", @"")];
    _receiver.clientFormat = [MyAudioEngine myAudioDescription];
    [self.audiobusController addReceiverPort:_receiver];

    ...
 }
 
 ...
 
 static OSStatus audioUnitRenderCallback(void *inRefCon, 
                                         AudioUnitRenderActionFlags *ioActionFlags,
                                         const AudioTimeStamp *inTimeStamp, 
                                         UInt32 inBusNumber, 
                                         UInt32 inNumberFrames, 
                                         AudioBufferList *ioData) {

    __unsafe_unretained MyAudioEngine *self = (__bridge MyAudioEngine*)inRefCon;

    AudioTimeStamp timestamp = *inTimeStamp;
 
    if ( ABAudioReceiverPortIsConnected(self->_receiver) ) {
       // Receive audio from Audiobus, if connected.
       ABAudioReceiverPortReceive(self->_receiver, nil, ioData, inNumberFrames, &timestamp);
    } else {
       // Receive audio from system input otherwise
       AudioUnitRender(self->_audioUnit, ioActionFlags, inTimeStamp, 1, inNumberFrames, ioData);
    }
    
    // Do something with audio in 'ioData', and 'timestamp'
 }
 @endcode


 Create a trigger        {#Trigger-Recipe}
 ================

 This demonstrates how to create a trigger, which can be invoked remotely to perform some action within your app.
 
 The sample creates a trigger, passing in a block that toggles the recording state of a fictional transport controller.
 
 It also observes the recording state of the controller, and updates the trigger's state when the recording state
 changes, so that the appearance of the user interface element corresponding to the trigger on remote apps changes
 appropriately.
 
 @code
 static void * kTransportControllerRecordingStateChanged = &kTransportControllerRecordingStateChanged;

 ...

 self.recordTrigger = [ABTrigger triggerWithSystemType:ABTriggerTypeRecordToggle block:^(ABTrigger *trigger, NSSet *ports) {
    if ( self.transportController.recording ) {
        [self.transportController endRecording];
    } else {
        [self.transportController beginRecording];
    }
 }];
 [self.audiobusController addTrigger:self.recordTrigger];
 
 // Watch recording status of our controller class so we can update the trigger state
 [self.transportController addObserver:self forKeyPath:@"recording" options:0 context:kTransportControllerRecordingStateChanged];

 ...

 -(void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    // Update trigger state to reflect recording status
    if ( context == kTransportControllerRecordingStateChanged ) {
        self.recordTrigger.state = self.transportController.recording ? ABTriggerStateSelected : ABTriggerStateNormal;
    } else {
        [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
    }
 }
 @endcode

 Manage application life-cycle        {#Lifecycle-Recipe}
 =============================
 
 This example demonstrates the recommended way to manage your application's life-cycle.
 
 The example assumes the app in question has been registered at 
 [developer.audiob.us/register](https://developer.audiob.us/account/register), and is therefore able
 to be connected and launched from the Audiobus app.
 
 As soon as your app is connected via Audiobus, it must have a running and active audio system.
 This means you must either only instantiate the Audiobus controller at the same time you start 
 your audio system, or you must watch for @link ABConnectionsChangedNotification @endlink and start your
 audio system when the notification is observed.
 
 Once your app is connected via Audiobus, it should not under any circumstances suspend its 
 audio system when moving into the background. We also strongly recommend remaining active in the
 background while it's part of an active Audiobus session (i.e. the app's been used with Audiobus, and the
 Audiobus app is still active), to keep your app available for use without needing
 to be re-launched. When moving to the background, the app can check the 
 [connected](@ref ABAudiobusController::connected) and
 [memberOfActiveAudiobusSession](@ref ABAudiobusController::memberOfActiveAudiobusSession) properties of the Audiobus controller,
 and only stop the audio system if both are false:
 
 @code
 if ( !_audiobusController.connected && !_audiobusController.memberOfActiveAudiobusSession ) {
     // Fade out and stop the audio engine, suspending the app, if we're not connected, and we're not part of an active Audiobus session
     [ABAudioUnitFader fadeOutAudioUnit:_audioEngine.audioUnit completionBlock:^{ [_audioEngine stop]; }];
 }
 @endcode
 
 If your app is in the background when the [memberOfActiveAudiobusSession](@ref ABAudiobusController::memberOfActiveAudiobusSession) property becomes
 false, indicating that the session has ended, we recommend shutting down the audio engine, as appropriate.
 
 The below example uses ABAudioUnitFader to provide smooth fade-in and fade-out transitions, to avoid hard
 clicks when starting or stopping the audio system.
 
 @code
 static void * kAudiobusConnectedOrActiveMemberChanged = &kAudiobusConnectedOrActiveMemberChanged;
 
 -(BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // ...

    // Watch the connected and memberOfActiveAudiobusSession properties
    [self.audiobusController addObserver:self
                         forKeyPath:@"connected"
                            options:0
                            context:kAudiobusConnectedOrActiveMemberChanged];
    [self.audiobusController addObserver:self
                         forKeyPath:@"memberOfActiveAudiobusSession"
                            options:0
                            context:kAudiobusConnectedOrActiveMemberChanged];

    // ...
 }
 
 -(void)dealloc {
     [_audiobusController removeObserver:self forKeyPath:@"connected"];
     [_audiobusController removeObserver:self forKeyPath:@"memberOfActiveAudiobusSession"];
 }
 
 -(void)observeValueForKeyPath:(NSString *)keyPath
                     ofObject:(id)object
                       change:(NSDictionary *)change
                      context:(void *)context {

    if ( context == kAudiobusConnectedOrActiveMemberChanged ) {
        if ( [UIApplication sharedApplication].applicationState == UIApplicationStateBackground
               && !_audiobusController.connected
               && !_audiobusController.memberOfActiveAudiobusSession ) {

            // Audiobus session is finished. Time to sleep.
            [_audioEngine stop];
        }
    } else {
        [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
    }
 }
 
 -(void)applicationDidEnterBackground:(NSNotification *)notification {
     if ( !_audiobusController.connected && !_audiobusController.memberOfActiveAudiobusSession ) {
         // Fade out and stop the audio engine, suspending the app, if we're not connected, and we're not part of an active Audiobus session
         [ABAudioUnitFader fadeOutAudioUnit:_audioEngine.audioUnit completionBlock:^{ [_audioEngine stop]; }];
     }
 }
 
 -(void)applicationWillEnterForeground:(NSNotification *)notification {
     if ( !_audioEngine.running || [ABAudioUnitFader transitionsRunning] ) {
         // Start the audio system and fade in if it wasn't running
         [ABAudioUnitFader fadeInAudioUnit:_audioEngine.audioUnit beginBlock:^{ [_audioEngine start]; } completionBlock:nil];
     }
 }
 @endcode

 Determine if app is connected via Audiobus        {#Determine-Connected}
 ==========================================
 
 The following code demonstrates one way to monitor and determine whether any Audiobus ports are
 currently connected.

 You can also:

 - Observe (via KVO) the 'connected' property of ABAudiobusController or any of the port classes,
   or any of the 'sources'/'destinations' properties of the port classes
 - Watch for `ABAudioReceiverPortConnectionsChangedNotification`, `ABAudioReceiverPortPortAddedNotification`,
   `ABAudioReceiverPortPortRemovedNotification`, `ABAudioSenderPortConnectionsChangedNotification`, or
   `ABAudioFilterPortConnectionsChangedNotification`.
 - Use `ABAudioReceiverPortIsConnected`, `ABAudioSenderPortIsConnected`, and `ABAudioFilterPortIsConnected` from
   a Core Audio thread.
 
 @code
 // In app delegate/etc, watch for connection change notifications
 [[NSNotificationCenter defaultCenter] addObserver:self 
                                          selector:@selector(connectionsChanged:) 
                                              name:ABConnectionsChangedNotification 
                                            object:nil];
 
 // On cleanup...
 [[NSNotificationCenter defaultCenter] removeObserver:self 
                                                 name:ABConnectionsChangedNotification 
                                               object:nil];

 -(void)connectionsChanged:(NSNotification*)notification {
    if ( _audiobusController.connected ) {
        // We are connected
 
    } else {
        // Not connected
    }
 }
 @endcode
 
 Enumerate apps connected to a port        {#Enumerate-Connections}
 ==================================
 
 This illustrates how to inspect each individual source or destination of a port.
 Sender ports can have only destinations, receiver ports only sources. Filter ports
 can have both, sources and destinations.
 
 <blockquote>
 The way you obtain access to sources has changed in Audiobus 3. Audiobus 3
 inserts intermediate routings. Thus the sources obtained by ABPort::sources
 are not the source you are seeing in the Audiobus UI. Using ABPort::sources
 and ABPort::destinations you will get the physically connected sources and
 destinations. To represent sources and destinations in the user inteface of your app
 we recomment to use the new function ABPort::sourcesRecursive and
 ABPort::destinationsRecursive.
 </blockquote>
 
 To get the physically connected sources iterate the sources property of your
 port:
 
 @code
 for ( ABPort *connectedPort in _receiverPort.sources ) {
    NSLog(@"Source port '%@' of app '%@' is connected", connectedPort.displayName, connectedPort.peer.displayName);
 }
 @endcode
 
 To get the logically connected sources iterate the sourcesRecursive property of your
 port. This function will not only return direct sources but also indirect ones:
 
 @code
 for ( ABPort *connectedPort in _receiverPort.sourcesRecursive ) {
     NSLog(@"Source port '%@' of app '%@' is connected", connectedPort.displayName, connectedPort.peer.displayName);
 }
 @endcode
 
 The same is possible with destinations:
 
 @code
 for ( ABPort *connectedPort in _senderPort.destinations ) {
    NSLog(@"Destination port '%@' of app '%@' is connected", connectedPort.displayName, connectedPort.peer.displayName);
 }
 @endcode
 
 @code
 for ( ABPort *connectedPort in _senderPort.destinationsRecursive ) {
    NSLog(@"Destination port '%@' of app '%@' is connected", connectedPort.displayName, connectedPort.peer.displayName);
 }
 @endcode
 
 Show icons and titles for sources and destinations        {#Show-icons-and-titles}
 ==================================================
 
 To show the titles and icons of sources connected to a port use the 
 new properties sourcesIcon and sourcesTitle as well destinationsIcon and 
 destinationsTitle:
 
 @code
    UIImage *sourcesIcon = _filterPort.sourcesIcon;
    NSString *sourcesTitle = _filterPort.sourcesIcon;
 
    UIImage *destinationsIcon = _filterPort.destinationsIcon;
    NSString *destinationsTitle = _filterPort.destinationsIcon;
 @endcode
 
 These properties will return a summarized icon and title representing all
 sources and destinations connected to a port. 
 
 If you need access to the icons of the single sources you can iterate the
 sources and use the properties peer.icon and peer.name:
 
 @code
 for ( ABPort *sourcePort in _receiverPort.sourcesRecursive ) {
     NSString sourcePeerName =  *sourcePort.peer.name;
     UIImage *sourcePeerIcon = *sourcePort.peer.icon;
 }
 @endcode
 
The same can be done with destinations.

 
 
 
 Get all sources of the current Audiobus session        {#Get-All-Sources}
 ===============================================
 
 This example demonstrates how to obtain a list of all source ports of the current session; that is,
 all ports that correspond to the 'Inputs' position in the Audiobus app. Note that this is a different
 list of ports than the ones enumerated in the prior sample, as this is list of all inputs, not just the
 ones directly connected to a given port.
 
 @code
 NSArray *allSessionSources = [_audiobusController.connectedPorts filteredArrayUsingPredicate:
                                [NSPredicate predicateWithFormat:@"type = %d", ABPortTypeAudioSender]];
 @endcode
 
 Note: similarly, you can obtain a list of all filters by replacing the `ABPortTypeAudioSender` identifier with
 `ABPortTypeAudioFilter`, and a list of all receivers with the `ABPortTypeAudioReceiver`.
 
 Receive audio as separate streams        {#Receiver-Port-Separate-Streams}
 =================================
 
 This example demonstrates how to use ABAudioReceiverPort's separate-stream receive mode
 ([receiveMixedAudio](@ref ABAudioReceiverPort::receiveMixedAudio) = NO) to receive each audio stream from 
 each connected app separately, rather than as a single mixed-down audio stream.
 
 The code below maintains a C array of currently-connected sources, in order to be able to enumerate them
 within a Core Audio thread without calling any Objective-C methods (note that Objective-C methods should
 never be called on a Core Audio thread due to the risk of priority inversion, resulting in stuttering audio).

 The sample code monitors connection changes, then updates the C array accordingly.
 
 Then within the audio unit render callback, the code iterates through this array to receive each audio stream.
 
 @code
 static const int kMaxSources = 30; // Some reasonably high number
 static void * kReceiverSourcesChanged = &kReceiverSourcesChanged;
 
 // A structure used to make up our source table
 struct port_entry_t { void *port; BOOL pendingRemoval; };
 
 // Our class continuation, where we define a source port table
 @interface MyAudioEngine () {
    struct port_entry_t _portTable[kMaxSources];
 }
 @end
 
 @implementation MyAudioEngine

 -(id)init {
    ...
 
    self.audiobusController = [[ABAudiobusController alloc] initWithApiKey:@"YOUR-API-KEY"];
 
    self.receiver = [[ABAudioReceiverPort alloc] initWithName:@"Main" title:NSLocalizedString(@"Main Input", @"")];
    _receiver.clientFormat = [MyAudioEngine myAudioDescription];
    _receiver.receiveMixedAudio = NO;
    [self.audiobusController addReceiverPort:_receiver];

    // Watch the receiver's 'sources' property to be notified when the sources change
    [_receiver addObserver:self forKeyPath:@"sources" options:0 context:kReceiverSourcesChanged];
 }
 
 -(void)dealloc {
     [_receiver removeObserver:self forKeyPath:@"sources"];
 }

 // Table lookup facility, to make lookups easier
 -(struct port_entry_t*)entryForPort:(ABPort*)port {
     for ( int i=0; i<kMaxSources; i++ ) {
         if ( _portTable[i].port == (__bridge void*)port ) {
             return &_portTable[i];
         }
     }
     return NULL;
 }

 -(void)observeValueForKeyPath:(NSString *)keyPath
                      ofObject:(id)object
                        change:(NSDictionary *)change
                       context:(void *)context {
 
     if ( context == kReceiverSourcesChanged ) {
         
         // When the connections change, add any new sources to our C array
         for ( ABPort *source in _receiver.sources ) {
             if ( ![self entryForPort:source] ) {
                 struct port_entry_t *emptySlot = [self entryForPort:nil];
                 if ( emptySlot ) {
                     emptySlot->port = (__bridge void*)source;
                 }
             }
         }
     
         // Prepare to remove old sources (this will be done on the Core Audio thread, so removals are thread-safe)
         for ( int i=0; i<kMaxSources; i++ ) {
             if ( _portTable[i].port && ![_receiver.sources containsObject:(__bridge ABPort*)_portTable[i].port] ) {
                 _portTable[i].pendingRemoval = YES;
             }
         }
 
     } else {
         [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
     }
 }
 
 ...
 
 static OSStatus audioUnitRenderCallback(void *inRefCon, 
                                         AudioUnitRenderActionFlags *ioActionFlags,
                                         const AudioTimeStamp *inTimeStamp, 
                                         UInt32 inBusNumber, 
                                         UInt32 inNumberFrames, 
                                         AudioBufferList *ioData) {

     __unsafe_unretained MyAudioEngine *self = (__bridge MyAudioEngine*)inRefCon;

     // Remove sources pending removal (which we did in the change handler above)
     for ( int i=0; i<kMaxSources; i++ ) {
         if ( self->_portTable[i].port && self->_portTable[i].pendingRemoval ) {
             self->_portTable[i].pendingRemoval = NO;
             self->_portTable[i].port = NULL;
         }
     }
 
    if ( ABAudioReceiverPortIsConnected(self->_receiver) ) {

        // Now we can iterate through the source port table without using Objective-C:
        for ( int i=0; i<kMaxSources; i++ ) {
            if ( self->_portTable[i].port ) {
                AudioTimeStamp timestamp;
                ABAudioReceiverPortReceive(self->_receiver, (__bridge ABPort*)self->_portTable[i].port, ioData, inNumberFrames, &timestamp);
                
                // Do something with this audio
            }
        }

        // Mark the end of this time interval
        ABAudioReceiverPortEndReceiveTimeInterval(self->_receiver);

    } else {
       // Receive audio from system input otherwise
       AudioUnitRender(self->_audioUnit, ioActionFlags, inTimeStamp, 1, inNumberFrames, ioData);
       
       // Do something with this audio
    }
 }
 
 @endcode
 
 Use Audiobus input in an Audio Queue        {#Audio-Queue-Input}
 ====================================
 
 This example demonstrates the Audio Queue versions of the receiver port receive functions, which
 take an AudioQueueBufferRef argument instead of an AudioBufferList.
 
 Illustrated is an input callback which replaces the incoming microphone audio with audio from
 Audiobus, which represents a quick and easy way to implement receiver ports in an app that uses
 Audio Queues and microphone input.
 
 @code
 static void MyAQInputCallback(void *inUserData,
                               AudioQueueRef inQueue,
                               AudioQueueBufferRef inBuffer,
                               const AudioTimeStamp *inStartTime,
                               UInt32 inNumPackets,
                               const AudioStreamPacketDescription *inPacketDesc) {
 
    __unsafe_unretained MyController *self = (MyController*)inUserData;
 
    // Intercept audio, replacing it with Audiobus input
    AudioTimeStamp timestamp = *inStartTime;
    ABAudioReceiverPortReceiveAQ(self->_audiobusReceiverPort,
                         nil,
                         inBuffer,
                         &inNumPackets,
                         &timestamp,
                         NULL);
 
    // Now do something with audio in inBuffer...
 
 }
 @endcode
 
@page Receiver-Port Receiving: The Audiobus Receiver Port

 The Audiobus receiver port class ABAudioReceiverPort provides an interface for receiving audio,
 either as separate audio streams (one per connected sender), or as a single audio stream with all
 sources mixed together.

 Receiving audio tends to be a little more involved than sending or filtering audio, so this section aims
 to discuss some of the finer points of using ABAudioReceiverPort.

 See the [Receiver Port](@ref Create-Audio-Receiver-Port) section of the integration guide for an initial overview.

Dealing with Latency        {#Latency}
====================
 
 Audiobus receivers are given timestamps along with every piece of audio they receive. These
 timestamps are vital for compensating for latency when recording in a time-sensitive context.

 This works in exactly the same way that timestamps in Core Audio do.

 If your app records the audio it receives over Audiobus and the timing is important (for example,
 you record audio in time with some other track, such as a looper or a multi-track recorder), then
 use these timestamps when saving the received audio to negate the effects of latency.

 If your app already records from the microphone, then you are probably already using the
 `AudioTimeStamp` values given to you by Core Audio, in order to compensate for audio hardware
 latency. If this is the case, then there's probably nothing more you need to do, other than making
 sure this mechanism is using the timestamps generated by Audiobus.

 For example, a looper app might record audio while other loops are playing. The audio must be
 recorded in time so that the beats in the new recording match the beats in the already-playing
 loop tracks. If such an app has a time base (such as the time the app was started) which is used
 to determine the playback position of the loops, then this same time base can be used with the
 timestamps from the incoming audio in order to determine when the newly-recorded track should be
 played back. 
 
 Note that for system audio inputs, Audiobus already compensates for the reported hardware input
 latency, so you should not further modify the timestamp returned from ABAudioReceiverPortReceive.

Receiving Separate Streams        {#Receiving-Separate-Streams}
==========================

 You can receive audio as separate stereo streams - one per source - or as a single mixed stereo audio stream.
 By default, Audiobus will return the audio as a single, mixed stream.
 
 <blockquote>
 The behavior for receiving separate streams has been changed in Audiobus 3. 
 In Audiobus 2 a separate stream for each <em>source</em> connected to a pipeline was
 received. Audiobus 3 merges all sources in the input slot of a pipeline together into one stream.
 So if users want to record several sources in separate streams they need to add
 them to different pipelines in Audiobus 3.
 </blockquote>
 
 If you wish to receive separate streams for each <em>pipeline</em>, however, you can set
 [receiveMixedAudio](@ref ABAudioReceiverPort::receiveMixedAudio) to `NO`. Then, each pipeline will have
 its own audio stream, accessed by passing in a pointer to the source port in
 @link ABAudioReceiverPort::ABAudioReceiverPortReceive ABAudioReceiverPortReceive @endlink.
 
 After calling ABAudioReceiverPortReceive for each source, you must then call
 @link ABAudioReceiverPort::ABAudioReceiverPortEndReceiveTimeInterval ABAudioReceiverPortEndReceiveTimeInterval @endlink
 to mark the end of the current interval. 

 Please see the ['Receive Audio as Separate Streams'](@ref Receiver-Port-Separate-Streams) sample recipe,
 the documentation for [ABAudioReceiverPortReceive](@ref ABAudioReceiverPort::ABAudioReceiverPortReceive)
 and [ABAudioReceiverPortEndReceiveTimeInterval](@ref ABAudioReceiverPort::ABAudioReceiverPortEndReceiveTimeInterval),
 and the AB Multitrack sample app for more info.
 
 > Note you should not access the `sources` property, or any other Objective-C methods, from
 > a Core Audio thread, as this may cause the thread to block, resulting in audio glitches. You
 > should obtain a pointer to the ABPort objects in advance, and use these pointers directly, as
 > demonstrated in the ['Receive Audio as Separate Streams'](@ref Receiver-Port-Separate-Streams) sample recipe
 > and within the "AB Multitrack Receiver" sample.
 
@subsection Receiving-Separate-Streams-With-Core-Audio-Input Receiving Separate Streams Alongside Core Audio Input
 
 If you wish to simultaneously incorporate audio from other sources as well as Audiobus - namely, the device's audio
 input - then depending on your app, it may be very important that all sources are synchronised and delivered in a
 consistent fashion. This will be true if you provide live audio monitoring, or if you apply effects in a
 synchronised way across all audio streams.
 
 The Audiobus SDK provides the ABMultiStreamBuffer class for buffering and synchronising
 multiple audio streams, so that you can do this. You enqueue separate, un-synchronised audio streams on one side,
 and then dequeue synchronised streams from the other side, ready for further processing.

 Typical usage is as follows:
 
 1. You receive audio from the system audio input, typically via a Remote IO input callback and AudioUnitRender,
    then enqueue it on the ABMultiStreamBuffer.
 2. You receive audio from each connected Audiobus source, also enqueuing the audio on the ABMultiStreamBuffer 
    ([ABMultiStreamBufferEnqueue](@ref ABMultiStreamBuffer::ABMultiStreamBufferEnqueue)).
 3. You then dequeue each source from ABMultiStreamBuffer ([ABMultiStreamBufferDequeueSingleSource](@ref ABMultiStreamBuffer::ABMultiStreamBufferDequeueSingleSource)).
    Audio will be buffered and synchronised via the timestamps of the enqueued audio.
 
 
 Differences between Audiobus 2 and Audiobus 3        {#Differences-between-audiobus-2-and-audiobus-3}
 =============================================

 There are some important differences between Audiobus 2 and Audiobus 3 once 
 receiver ports come into play. The following table lists the most important 
 differences:
 
 
 &nbsp;                      | Audiobus 2               | Audiobus 3
 --------------------------- | ------------------------ | -------------
 Hosting inputs and filters  | The app in the output    | Audiobus itself.
 Receiving multiple streams  | One stream per source    | One stream per pipeline
 Assigning streams to tracks | Unique ID of the source  | Pipeline ID
 
 > All of the proposed changes below are backward compatible with Audiobus 2.
 > So don't worry about breaking Audiobus 2 compatibility by implementing it.
 
 
 Intermediate Routings
 ---------------------
 
 Audiobus 3 introduces so called intermediate routings. Imagine the following 
 input-filter-output connection chain:
 
 @code
   Animoog -> Bias -> Cubasis
 @endcode
 
 In Audiobus 2 Cubasis would host and connect Animoog and Bias. Because only
 hosts can launch other apps in background we needed to make Audiobus 3 hosting 
 Animoog and Bias. We did this by inserting a so called intermediate routing 
 just before the output. Thus the connection graph internally looks like this:
 

 @code
   Animoog -> Bias -> ABIRIn - ABIROut -> Cubasis
 @endcode
 
  - <code>ABIRIn</code> is an audio receiver port within Audiobus.
  - <code>ABIROut</code> is an audio sender port within Audiobus.
  - The chain <code>ABIRIn - ABIROut</code> is the intermediate routing.
  - Instead of being directly connected to Cubasis, Bias is now connected to ABIRIn
    and therefore hosted by Audiobus.
  - Cubasis is connected to ABIROut. Thus instead of hosting Animoog and Bias
    Cubasis only hosts Audiobus' sender port ABIROut.
 
 Internally Audiobus manages a set of sixteen intermediate routings which are
 dynamically assigned.
 
 
 Access sources connected to audio receiver ports
 ------------------------------------------------
 Due to the introduction of the intermediate routing between Cubasis and Bias
 Cubasis is not able access the name of connected sources by iterating
 the sources connected to an audio receiver port.
 
 Much more you need now to read the property ABPort::sourcesRecursive.
 Instead of returning the physically connected source which is Audiobus'
 intermediate sender port, this property will return the logically connected
 sources which are Animoog and Bias. Additionally ABPort provides the selectors
 ABPort::sourcesIcon and ABPort::sourcesTitle.
 

 Multitrack Audio Recorders: Assigning sources to tracks
 -------------------------------------------------------
 In Audiobus 2 multitrack records were able to record one track per source. 
 To reassign a source to the right track, the unique ID of the source could 
 be used. Because of the introduction of dynamic intermediate routings this is not
 possible anymore. 
 
 To solve this issue, Audiobus 3 introduces a new ABPort property called ABPort::pipelineIDs.
 This property returns an array containing the IDs of all pipelines the port
 is belonging too. Audio sender and audio filter ports can only be assigned to 
 one pipeline. So by reading the first pipeline ID of a source connected to 
 your audio receiver port you can estimate to which track this source belongs.
 
 The pipeline ID of a source is stored within Audiobus preset. So you can make
 sure that after loading a presets all assignements can be restored.
 
 
 

@page Triggers Triggers

 Audiobus provides a system where apps can define actions that can be triggered by users from other
 apps, via the Audiobus Connection Panel or from within [Audiobus Remote](@ref Remote-Triggers).

 You can use a set of built-in system triggers (see
 @link ABTrigger::triggerWithSystemType:block: triggerWithSystemType:block: @endlink and
 @link ABTriggerSystemType @endlink), or [create your own](@ref ABButtonTrigger).

 Use of Triggers        {#Use-of-Triggers}
 ===============
 
 Triggers are designed to provide limited remote-control functionality over Audiobus apps. If your
 app has functions that may be usefully activated from a connected app, then you should expose them
 using the Audiobus triggers mechanism.
 
 Triggers can appear within the Audiobus Connection Panel, or within [Audiobus Remote](@ref Remote-Triggers)
 running on another device, depending on how they are added. Use ABAudiobusController's 
 @link ABAudiobusController::addTrigger: addTrigger: @endlink method to add Connection Panel triggers,
 and @link ABAudiobusController::addRemoteTrigger: addRemoteTrigger: @endlink to add Audiobus Remote triggers.
 
 Apps should only provide a small number of Connection Panel triggers - no more than four - to avoid cluttering
 up the Audiobus Connection Panel interface. Remote Triggers may be more numerous, due to the extra available
 screen space within Audiobus Remote.
 
 Your app should only provide triggers that are *relevant to the current state*. Take, for
 example, an app that has the capability of behaving as an Audiobus input and an output. If the app
 presents a "Record" trigger, but is currently acting as an input to another Audiobus app, this
 may lead to confusion: the app is serving in an audio generation role, not an audio consumption role,
 and consequently a "Record" function is not relevant to the current state.
 
 You can add and remove triggers at any time, so you should make use of this functionality to only
 offer users relevant actions.
 
 Creating a Trigger        {#Creating-a-Trigger}
 ==================
 
 **Whenever possible, you should use a built-in trigger type, accessible via
 @link ABTrigger::triggerWithSystemType:block: triggerWithSystemType:block: @endlink.**
 
 If you *must* create a custom trigger, then you can create a button trigger with 
 @link ABButtonTrigger::buttonTriggerWithTitle:icon:block: ABButtonTrigger's buttonTriggerWithTitle:icon:block: @endlink.
 
 Note that icons should be an image of no greater than 80x80 pixels, and will be
 used as a mask to draw a styled button.  If you do not provide 'selected' or 'alternate' state icons or colours 
 for a toggle button, then the same icon will be drawn with a default style to indicate the state change.

 When you create a trigger, you provide a [block](@ref ABTriggerPerformBlock) to perform when the trigger is
 activated remotely. The block accepts two arguments: the trigger, and a set of your app's ports to which the app
 from which the trigger was activated is connected. This port set will typically be just one port,
 but may be multiple ports.

 You may wish to use the ports set to determine what elements within your app to apply the
 result of the trigger to. For example, if your trigger is @link ABTriggerTypeRecordToggle @endlink,
 and the connected port refers to one track of a multi-track recording app, then you may wish
 to begin recording this track.

 If you are implementing a two-state trigger, such as @link ABTriggerTypeRecordToggle @endlink,
 @link ABTriggerTypePlayToggle @endlink or a custom trigger with multiple states, you should update the
 [trigger state](@ref ABTrigger::state) as appropriate, when the state to which it refers changes.

 Note that you can also update the icon of custom triggers at any time. The user interface across
 all connected devices and apps will be updated accordingly.
 
 Have a look at the [Trigger recipe](@ref Trigger-Recipe) and the "AB Receiver" and "AB Filter" sample apps 
 for examples.
 
 System triggers are automatically ordered as follows: 
 ABTriggerTypeRewind, ABTriggerTypePlayToggle, ABTriggerTypeRecordToggle.

 Remote Triggers        {#Remote-Triggers}
 ===============
 
 [Audiobus Remote](http://audiob.us/remote) supports a new class of trigger which allows you to define
 extended functionality, without cluttering up the Audiobus Connection Panel.
 
 When you add a trigger via ABAudiobusController's @link ABAudiobusController::addRemoteTrigger: addRemoteTrigger: @endlink
 method, the trigger will appear only within Audiobus Remote.
 
 You may listen for particular control events (UIControlEventTouchDown and UIControlEventTouchUpInside) by registering
 a block using each trigger's @link ABButtonTrigger::addBlock:forRemoteControlEvents: addBlock:forRemoteControlEvents: @endlink
 method.
 
 Use these facilities for providing access to extra functions in your app, such as:
 
 - Individually toggling tracks or triggering samples,
 - Switching between patches,
 - Jumping to particular time offsets in a track,
 - Manipulating effect parameters,
 - Playing chords
 
 You may also define a matrix of triggers using
 @link ABAudiobusController::addRemoteTriggerMatrix:rows:cols: addRemoteTriggerMatrix:rows:cols: @endlink,
 which suits uses such as drum sample pads. Use these sparingly, however, as Audiobus Remote is able to make
 better use of available screen space with triggers added via @link ABAudiobusController::addRemoteTrigger: addRemoteTrigger: @endlink
 instead.
 
 See the "AB Sender" sample app for a demo implementation of Remote Triggers in a matrix.
 
@page State-Saving State Saving

 State saving allows your app to provide workspace configuration information that can be stored,  
 recalled and shared by users when saving or loading an Audiobus preset. This allows users to save and share
 their entire workspaces, across all the apps they are using.

 If you're not familiar with Audiobus presets and state saving, here're two videos explaining each:
 
 @htmlonly
 <iframe width="560" height="315" src="//www.youtube.com/embed/aDNesaca0do" frameborder="0" allowfullscreen
    style="display: block; margin: 0 auto;"></iframe>
 
 <iframe width="560" height="315" src="//www.youtube.com/embed/tE347uTXKms" frameborder="0" allowfullscreen
    style="display: block; margin: 0 auto;"></iframe>
 @endhtmlonly
 
 To support state saving, you need to implement the @link ABAudiobusControllerStateIODelegate @endlink
 protocol, and identify your State IO delegate to the Audiobus controller via its
 @link ABAudiobusController::stateIODelegate stateIODelegate @endlink property.

 The State IO delegate protocol consists of two methods: one which is invoked when a preset is being saved,
 @link ABAudiobusControllerStateIODelegate::audiobusStateDictionaryForCurrentState audiobusStateDictionaryForCurrentState @endlink,
 and one which is invoked when a preset is being loaded, 
 @link ABAudiobusControllerStateIODelegate::loadStateFromAudiobusStateDictionary:responseMessage: loadStateFromAudiobusStateDictionary:responseMessage: @endlink.

 You use the former to provide Audiobus with a dictionary of keys and values that represent your app's current
 state. The latter provides you with the same keys and values you provided when the preset was saved, which you
 use to restore that state. If there was a problem restoring the state (for example, the state relies on functionality
 accessible only via an In-App Purchase, or content that hasn't been downloaded yet), you may return a message
 that will be displayed to the user within Audiobus.

 What data you provide via this system is up to you: you can provide NSData blobs, NSStrings, and any other
 Property List types (see Apple's 
 [About Property Lists](https://developer.apple.com/library/mac/documentation/Cocoa/Conceptual/PropertyLists/AboutPropertyLists/AboutPropertyLists.html)
 documentation).
 
 For example: a synth app should save current patch settings. An effects app should save the parameters. A multi-track
 recorder app may choose to save the current project, including the audio tracks. A sampler should save the loaded
 audio samples.

 We currently require that you **do not return data larger than 20MB**. Any audio data in presets should preferably be
 in a compressed format. We previously asked developers working with the 2.0 SDK version not to save MIDI settings 
 information: we have since relaxed this requirement, and **we now allow MIDI settings to be saved**, such as a set 
 of active MIDI connections.

 State saving is a very new feature that will undergo further evolution as we see what users and developers
 are doing with it. Consequently, these guidelines may change over time. If you have feedback, let us know on 
 the [developer forums!](https://heroes.audiob.us).

@page Ableton-Link Synchronization with Ableton Link
 
 [Ableton Link](http://ableton.com/link) is a new technology that synchronises beat, phase and tempo. It 
 works between Ableton Live and Link-enabled iOS apps over a wireless network, or iOS apps on the same device.
 
 If your app has a clock, we'd recommend looking into Ableton Link for synchronization with other apps. The 
 Audiobus SDK automatically supports Link, and will enable it within your app when it's connected to Audiobus. 
 There's nothing you need to do but include the Link SDK within your app.
 
 Write to *link-devs at ableton.com* to enquire about gaining early access to the Ableton Link SDK.
 
@page Good-Citizen Being a Good Citizen

 Beyond being an audio transmission protocol or platform, Audiobus is a community of applications. The
 experience that users have is strongly dependent on how well these apps work together. So, these are
 a set of rules/guidelines that your app should follow, in order to be a good Audiobus citizen.

Receivers, Use Audio Timestamps        {#Receivers-Timestamps}
===============================

 When dealing with multiple effect pipelines, latency is an unavoidable factor that is very important to 
 address when timing is important.
 
 Audiobus deals with latency by providing you, the developer, with timestamps that correspond
 to the creation time of each block of audio.
 
 If you are recording audio, and are mixing it with other live signals or if timing is 
 otherwise important, then it is **vital** that you make full use of these timestamps in order 
 to compensate for system latency. How you use these timestamps depends on your app - you may
 already be using timestamps from Core Audio, which means there's nothing special that you need
 to do.

 See [Dealing with Latency](@ref Latency) for more info.

Use Low IO Buffer Durations, If You Can        {#Low-Buffer-Durations}
=======================================

 Core Audio allows apps to set a preferred IO buffer duration via the audio session (see
 AVAudioSession's `preferredIOBufferDuration` property in the Core Audio documentation). This
 setting configures the length of the buffers the audio system manages. Shorter buffers mean
 lower latency. By the time you receive a 5ms buffer from the system input, for example,
 roughly 5ms have elapsed since the audio reached the microphone.  Similarly, by the time a
 5ms buffer has been played by the system's speaker, 5ms or so have elapsed since the
 audio was generated.

 The tradeoff of small IO buffer durations is that your app has to work harder, per time unit,
 as it's processing smaller blocks of audio, more frequently. So, it's up to you to figure out
 how low your app's latency can go - but remember to save some CPU cycles for other apps as well!

In the Background Suspend When Possible, But Not While Audiobus Is Running        {#Background-Mode}
==========================================================================
 
 It's up to you whether it's appropriate to suspend your app in the background, but there are a few
 things to keep in mind.
 
 Most important: you should never, ever suspend your app if it's connected via Audiobus. You can tell
 whether your app's connected at any time via the [connected](@ref ABAudiobusController::connected)
 property of the Audiobus controller.  If the value is YES, then you mustn't suspend.
 
 Secondly, we strongly recommend that your app remain active in the background while the Audiobus app
 is running. This keeps your app available for being re-added to a connection graph (or reloaded from a
 preset) without needing to be manually launched again. Once the Audiobus app closes, then your app can
 suspend in the background. 

 See the [Lifecycle](@ref Lifecycle) section of the integration guide, or the [associated recipe](@ref Lifecycle-Recipe)
 for further details.
 
 Note that during development, if your app has not yet been [registered](https://developer.audiob.us/apps/register)
 with Audiobus, Audiobus will not be able to see the app if it is not actively running in the background.
 Consequently, we **strongly recommend** that you register your app at the beginning of development.
 
Be Efficient!        {#Efficient}
=============

 Audiobus leans heavily on iOS multitasking! You could be running three synth apps, two filter apps,
 and be recording into a live-looper or a DAW. That requires a lot of juice.

 So, be kind to your fellow developers. Profile your app and find places where you can back off
 the CPU a bit. Never, ever wait on locks, allocate memory, or call Objective-C functions from Core
 Audio. Use plain old C in time-critical places (or even drop to assembly). Take a look at the
 Accelerate framework if you're not familiar with it, and use its vector operations instead of
 scalar operations within loops - it makes a huge difference.

*/
