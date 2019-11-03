//
//  AppDelegate+PlatformServices.swift
//  AudioKitSynthOne
//
//  Created by Matthias Frick on 03/11/2019.
//  Copyright © 2019 AudioKit. All rights reserved.
//

import Foundation
#if !targetEnvironment(macCatalyst)
import OneSignal
import AppCenter
import AppCenterAnalytics
import AppCenterCrashes

extension AppDelegate {
    public func initializePlatformServices() {
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
    }
}
#endif

#if targetEnvironment(macCatalyst)
extension AppDelegate {
    public func initializePlatformServices() {}
}
#endif
