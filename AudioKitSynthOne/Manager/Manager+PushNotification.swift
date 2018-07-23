//
//  Manager+PushNotification.swift
//  AudioKitSynthOne
//
//  Created by AudioKit Contributors on 1/8/18.
//  Copyright © 2018 AudioKit Pro. All rights reserved.
//

import Foundation
import OneSignal

extension Manager {

    func pushPopUp() {
        // Add pop up
        let title = NSLocalizedString("Stay informed!", comment: "Alert Title: Allow notifications")
        let message = NSLocalizedString("We'll send Free updates, sounds, and apps. Allow notifications!",
                                        comment: "Alert Message: Allow notifications")
        let alert = UIAlertController(title: title,
                                      message: message,
                                      preferredStyle: .alert)
        let submitAction = UIAlertAction(title: "Yes! 👍🏼", style: .default) { (_) in
            self.appSettings.pushNotifications = true
            self.saveAppSettingValues()
            OneSignal.promptForPushNotifications(userResponse: { accepted in
                print("User accepted notifications: \(accepted)")
            })
        }

        let cancelAction = UIAlertAction(title: "Later", style: .default) { (_) in
            print("User canceled")
        }

        alert.addAction(cancelAction)
        alert.addAction(submitAction)

        self.present(alert, animated: true, completion: nil)
    }
}
