//
//  AppDelegate.swift
//  AudioKitSynthOne
//
//  Created by AudioKit Contributors on 7/8/17.
//  Copyright © 2017 AudioKit. All rights reserved.
//

import UIKit
import OneSignal
import AppCenter
import AppCenterAnalytics
import AppCenterCrashes

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    let conductor = Conductor.sharedInstance
    var window: UIWindow?
    private var launchOptions: [UIApplication.LaunchOptionsKey: Any]?

    func application(_ application: UIApplication,
                     didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.

        //print("launchOptions:\(String(describing: launchOptions))") // AKLog is not enabled at this point
        self.launchOptions = launchOptions

        // Never Sleep mode is false
        UIApplication.shared.isIdleTimerDisabled = false

        let onesignalInitSettings = [kOSSettingsKeyAutoPrompt: false]

        // Set your OneSignal App ID in the Private.swift file.
        OneSignal.initWithLaunchOptions(launchOptions,
                                        appId: Private.OneSignalAppID,
                                        handleNotificationAction: nil,
                                        settings: onesignalInitSettings)

        OneSignal.inFocusDisplayType = OSNotificationDisplayType.notification

        // Setup AppCenter for Crash Log Collection
        if (Private.AppCenterAPIKey != "***REMOVED***") {
            MSAppCenter.start(Private.AppCenterAPIKey, withServices:[
                MSAnalytics.self,
                MSCrashes.self
                ])
        }

        // Determine iPhone or iPad
        let mainStoryboard = UIStoryboard(name: "Main", bundle: Bundle.main)
        if conductor.device == .pad {
             window?.rootViewController = mainStoryboard.instantiateInitialViewController()
        } else {
             window?.rootViewController = mainStoryboard.instantiateViewController(withIdentifier: "iPhoneParentVC")
        }
        window?.makeKeyAndVisible()

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

    /// TuneUp
    func application(_ app: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey : Any] = [:]) -> Bool {

        // on launch tuningsPanel is not yet created -> fall back to tunings model initialization
        guard let tuningsPanel = conductor.viewControllers.first(where: { $0 is TuningsPanelController })
            as? TuningsPanelController else {
                return true
        }

        // open url
        _ = tuningsPanel.openUrl(url: url)

        // if url is a file in Inbox remove it (i.e., Scala file)
        if url.isFileURL {
            AKLog("removing temporary file at \(url)")
            do {
                try FileManager.default.removeItem(at: url)
            } catch let error as NSError {
                AKLog("error removing temporary file at \(url): \(error)")
            }
        }

        return true
    }

    func canOpenURL(_ url: URL) -> Bool {
        return true
    }
}


extension AppDelegate {

    public func applicationLaunchedWithURL() -> URL? {
        let launchUrl = self.launchOptions?[.url] as? URL
        self.launchOptions = nil
        return launchUrl
    }
    
}
