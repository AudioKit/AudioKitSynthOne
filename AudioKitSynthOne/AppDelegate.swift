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
                     didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.

        // Never Sleep mode is false
        UIApplication.shared.isIdleTimerDisabled = false

        let onesignalInitSettings = [kOSSettingsKeyAutoPrompt: false]

        // Set your OneSignal App ID in the Private.swift file.
        OneSignal.initWithLaunchOptions(launchOptions,
                                        appId: Private.OneSignalAppID,
                                        handleNotificationAction: nil,
                                        settings: onesignalInitSettings)

        OneSignal.inFocusDisplayType = OSNotificationDisplayType.notification
        
        // Determine iPhone or iPad
        let mainStoryboard = UIStoryboard(name: "Main", bundle: Bundle.main)
        if conductor.device == .pad {
             window?.rootViewController = mainStoryboard.instantiateInitialViewController()
        } else {
             window?.rootViewController = mainStoryboard.instantiateViewController(withIdentifier: "iPhoneParentVC")
        }
        window?.makeKeyAndVisible()

        AKLog("launchOptions:\(String(describing: launchOptions))")

        return true
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        conductor.checkIAAConnectionsEnterBackground()
    }

    
    func applicationWillEnterForeground(_ application: UIApplication) {
        conductor.checkIAAConnectionsEnterForeground()
    }

    func applicationWillResignActive(_ application: UIApplication) {
        // Prevent app from sleeping if never sleep is toggled on
        // Toggle back to sleep mode after 1 minutes
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 60) {
            UIApplication.shared.isIdleTimerDisabled = false
        }
        
        UIApplication.shared.isIdleTimerDisabled = conductor.neverSleep
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate.
        // Save data if appropriate. See also applicationDidEnterBackground:.
        conductor.stopEngine()
    }

    /// Handle opening scala files, or,
    /// Custom URL Scheme for octave-based tunings
    /// query host = "tune"
    /// args are Strings
    /// tuningName
    /// f frequency
    /// frequencyMiddleC
    ///
    /// query host = "tune", "tuneup", "open", "redirect"
    /// no args
    func application(_ app: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey : Any] = [:]) -> Bool {

        let tuningsPanel = conductor.viewControllers.first(where: { $0 is TuningsPanelController })
            as? TuningsPanelController
        return tuningsPanel?.openUrl(url: url) ?? true
    }

    /// redirect to redirectURL provided by last TuneUp ( "back button" )
    func tuneUpBackButton() {
        let tuningsPanel = conductor.viewControllers.first(where: { $0 is TuningsPanelController })
            as? TuningsPanelController
        tuningsPanel?.tuneUpBackButton()
    }
}
