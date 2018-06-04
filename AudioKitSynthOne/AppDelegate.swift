//
//  AppDelegate.swift
//  AudioKitSynthOne
//
//  Created by AudioKit Contributors on 7/8/17.
//  Copyright © 2017 AudioKit. All rights reserved.
//

import UIKit
import OneSignal

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    let conductor = Conductor.sharedInstance
    var window: UIWindow?

    func application(_ application: UIApplication,
                     didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.

        // Never Sleep mode is false
        UIApplication.shared.isIdleTimerDisabled = false

        let onesignalInitSettings = [kOSSettingsKeyAutoPrompt: false]

        // Replace 'YOUR_APP_ID' with your OneSignal App ID.
        OneSignal.initWithLaunchOptions(launchOptions,
                                        appId: "***REMOVED***",
                                        handleNotificationAction: nil,
                                        settings: onesignalInitSettings)

        OneSignal.inFocusDisplayType = OSNotificationDisplayType.notification

        // Recommend moving the below line to prompt for push after informing the user about
        //   how your app will use them.
//        OneSignal.promptForPushNotifications(userResponse: { accepted in
//            print("User accepted notifications: \(accepted)")
//        })

        return true
    }

    func applicationWillResignActive(_ application: UIApplication) {
        // Prevent app from sleeping if never sleep is toggled on
        // Toggle back to sleep mode after 1 minutes
        DispatchQueue.main.asyncAfter(deadline: .now() + 60) {
            UIApplication.shared.isIdleTimerDisabled = false
        }

        UIApplication.shared.isIdleTimerDisabled = conductor.neverSleep

    }

    func applicationDidEnterBackground(_ application: UIApplication) {
//        if !conductor.backgroundAudioOn {
//            conductor.stopEngine()
//        }
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
    }

    func applicationDidBecomeActive(_ application: UIApplication) {

//        if !conductor.backgroundAudioOn {
//            conductor.startEngine(completionHandler: {
//                // Audiobus.start()
//            })
//        }

    }

    func toggleDontSleepOn() {
        UIApplication.shared.isIdleTimerDisabled = true
    }

    func toggleDontSleepOff() {
        UIApplication.shared.isIdleTimerDisabled = false
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate.
        // Save data if appropriate. See also applicationDidEnterBackground:.
        conductor.stopEngine()
    }

}
