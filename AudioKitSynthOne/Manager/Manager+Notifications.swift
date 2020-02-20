//
//  Manager+Notifications.swift
//  AudioKitSynthOne
//
//  Created by Marcus W. Hobbs on 2/19/20.
//  Copyright © 2020 AudioKit. All rights reserved.
//

import Foundation

extension Manager {

    func registerForNotifications() {
        let notificationCenter = NotificationCenter.default
        notificationCenter.addObserver(self, selector: #selector(appBackgroundedOrTerminated), name: UIApplication.willResignActiveNotification, object: nil)
        notificationCenter.addObserver(self, selector: #selector(appBackgroundedOrTerminated), name: UIApplication.willTerminateNotification, object: nil)
    }

    func unregisterForNotifications() {
        NotificationCenter.default.removeObserver(self)
    }

    @objc func appBackgroundedOrTerminated() {
        saveAppSettingValues()
    }
}
