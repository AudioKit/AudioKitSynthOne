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

    func application(_ app: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey : Any] = [:]) -> Bool {
        let urlStr = url.absoluteString
        let host = URLComponents(string: urlStr)?.host
        if host == "tune" {
            //TODO:need to handle Tuning panel UI
            let queryItems = URLComponents(string: urlStr)?.queryItems
            let tuningName = queryItems?.filter({$0.name == "tuningName"}).first?.value ?? ""
            if let fArray = queryItems?.filter({$0.name == "f"}).map({ Double($0.value ?? "1.0") ?? 1.0 }) {
                AKLog("tuningName:\(tuningName), fArray:\(fArray)")
                let tuningsPanel = conductor.viewControllers.first(where: { $0 is TuningsPanelController })
                    as? TuningsPanelController
                _ = tuningsPanel?.tuningModel.setTuning(name: tuningName, masterArray: fArray)
            }
            return true
        } else if host == "open" {
            // simply Open
            return true
        } else {
            // can't handle this command
            AKLog("can't handle url: \(String(describing: host))")
            return false
        }
    }

}
