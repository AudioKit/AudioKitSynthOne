//
//  Manager+MailingListDelegate.swift
//  AudioKitSynthOne
//
//  Created by AudioKit Contributors on 5/25/18.
//  Copyright © 2018 AudioKit. All rights reserved.
//

// Mailing List PopOver Delegate

extension Manager: MailingListDelegate {
  
    func didSignMailingList(email: String) {

        signedMailingList = true

        DispatchQueue.main.async {
            if let headerVC = self.children.first as? HeaderViewController {
                headerVC.updateMailingListButton(self.signedMailingList)
            }
        }
        userSignedMailingList(email: email)
    }

    func userSignedMailingList(email: String) {
        appSettings.signedMailingList = true
        appSettings.userEmail = email
        saveAppSettingValues()

        presetsViewController.addBonusPresets()
    }
    
}
