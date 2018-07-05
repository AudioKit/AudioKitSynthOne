//
//  UIViewController+DisplayAlert.swift
//  AudioKitSynthOne
//
//  Created by AudioKit Contributors on 5/1/16.
//  Copyright © 2016 AudioKit. All rights reserved.
//

import UIKit
import StoreKit

// Display AlertViewController (Pop-up message)
extension UIViewController {

    func displayAlertController(_ title: String, message: String) {
        // Create and display alert box
        let alert = UIAlertController(title: title, message: message, preferredStyle: UIAlertControllerStyle.alert)
        let action = UIAlertAction(title: "Ok", style: .default, handler: nil)
        alert.addAction(action)
        present(alert, animated: true, completion: nil)
    }

    func reviewPopUp() {
        // Add pop up
        let alert = UIAlertController(title: "Thank you",
                                      message: "This is a FREE effort. Please help with a Great rating so we can " +
                                               "make more apps! Thanks for being awesome.",
                                      preferredStyle: .alert)
        let submitAction = UIAlertAction(title: "Cool 👍🏼", style: .default) { (_) in
            self.requestReview()
        }

        let cancelAction = UIAlertAction(title: "No", style: .default) { (_) in
            AKLog("User canceled")
        }

        alert.addAction(cancelAction)
        alert.addAction(submitAction)

        self.present(alert, animated: true, completion: nil)
    }

    func requestReview() {
        if #available(iOS 10.3, *) {
            SKStoreReviewController.requestReview()
        } else {
            // Fallback on earlier versions
            if let url = URL(string: "https://itunes.apple.com/us/app/id1371050497?action=write-review") {
                UIApplication.shared.open(url)
            }
        }
    }
}
