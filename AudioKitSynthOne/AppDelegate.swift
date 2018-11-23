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

    /// Handle opening scala files, or,
    /// Custom URL Scheme for octave-based tunings
    /// query host = "tune"
    /// args are Strings
    /// tuningName
    /// f frequency
    /// frequencyMiddleC
    ///
    /// query host = "open"
    /// no args
    func application(_ app: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey : Any] = [:]) -> Bool {
        // scala files
        if url.isFileURL {
            return openScala(atUrl: url)
        }

        // custom url
        let urlStr = url.absoluteString
        let host = URLComponents(string: urlStr)?.host
        if host == "tune" {
            // parse shared tuning
            let queryItems = URLComponents(string: urlStr)?.queryItems
            if let fArray = queryItems?.filter({$0.name == "f"}).map({ Double($0.value ?? "1.0") ?? 1.0 }) {
                // only valid if non-zero length frequency array
                if fArray.count > 0 {
                    let tuningName = queryItems?.filter({$0.name == "tuningName"}).first?.value ?? ""
                    let tuningsPanel = conductor.viewControllers.first(where: { $0 is TuningsPanelController })
                        as? TuningsPanelController
                    tuningsPanel?.setTuning(name: tuningName, masterArray: fArray)
                    if let frequencyMiddleCStr = queryItems?.filter({$0.name == "frequencyMiddleC"}).first?.value {
                        if let frequencyMiddleC = Double(frequencyMiddleCStr) {
                            if let s = conductor.synth {
                                let frequencyA4 = frequencyMiddleC * exp2((69-60)/12)
                                s.setSynthParameter(.frequencyA4, frequencyA4)
                            } else {
                                AKLog("ERROR:can't set frequencyA4 because synth is not initialized")
                            }
                        }
                    }
                } else {
                    // if you want to alert the user that the tuning is invalid this is the place
                    AKLog("tuning not set because input frequency array is empty")
                }
            }
            return true
        } else if host == "open" {
            // simply Open
            return true
        } else {
            // can't handle this url scheme
            AKLog("unsupported custom url scheme: \(url)")
            return false
        }
    }

    private func openScala(atUrl url: URL) -> Bool {
        AKLog("opening scala file at full path:\(url.path)")

        let tt = AKTuningTable()
        guard tt.scalaFile(url.path) != nil else {
            AKLog("Scala file is invalid")
            return true
        }

        let fArray = tt.masterSet
        if fArray.count > 0 {
            let tuningName = url.lastPathComponent
            let tuningsPanel = conductor.viewControllers.first(where: { $0 is TuningsPanelController })
                as? TuningsPanelController
            tuningsPanel?.setTuning(name: tuningName, masterArray: fArray)
            if let s = conductor.synth {
                let frequencyA4 = s.getDefault(.frequencyA4)
                s.setSynthParameter(.frequencyA4, frequencyA4)
            } else {
                AKLog("ERROR:can't set frequencyA4 because synth is not initialized")
            }
        } else {
            AKLog("Scala file is invalid: masterSet is zero-length")
        }

        return true
    }
}
