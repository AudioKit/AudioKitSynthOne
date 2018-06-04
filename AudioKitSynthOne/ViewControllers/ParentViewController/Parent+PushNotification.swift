//
//  Parent+PushNotification.swift
//  FMPlayer
//
//  Created by AudioKit Contributors on 1/8/18.
//  Copyright © 2018 AudioKit Pro. All rights reserved.
//

import Foundation
import OneSignal

extension ParentViewController {

    func pushPopUp() {
        // Add pop up
        let alert = UIAlertController(title: "Stay Informed",
                                      message: "We'll send Free updates, sounds, and apps. Allow notifications!",
                                      preferredStyle: .alert)
        let submitAction = UIAlertAction(title: "Awesome! 👍🏼", style: .default) { (_) in
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
