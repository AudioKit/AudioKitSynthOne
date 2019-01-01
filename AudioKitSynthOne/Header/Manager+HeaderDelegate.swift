//
//  Manager+HeaderDelegate.swift
//  AudioKitSynthOne
//
//  Created by AudioKit Contributors on 5/25/18.
//  Copyright © 2018 AudioKit. All rights reserved.
//

// Header Delegate

extension Manager: HeaderDelegate {

    func displayLabelTapped() {
        if !isPresetsDisplayed {

            // Hide Keyboard
            keyboardView.isShown = keyboardToggle.isOn
            keyboardToggle.callback(0.0)
            keyboardToggle.value = 0.0

            // Save previous bottom panel
            prevBottomChildPanel = bottomChildPanel

            // Animate
            topPanelheight.constant = 0
            view.layoutIfNeeded()
            // Add Panel to Top
            displayPresetsController()
            guard let top = topChildPanel else { return }
            switchToChildPanel(top, isOnTop: false)
            topChildPanel = nil

            // Animate panel
            UIView.animate(withDuration: Double(0.2), animations: {
                self.topPanelheight.constant = 299
                self.view.layoutIfNeeded()
            })

        } else {

            // Show Keyboard
            if keyboardView.isShown {
                keyboardToggle.value = 1.0
                if self.conductor.device == .phone {
                    keyboardTopConstraint.constant = 257
                } else {
                    keyboardTopConstraint.constant = 337
                }
                keyboardToggle.setTitle("Hide", for: .normal)
            }

            // Add Panel to Top
            guard let bottom = bottomChildPanel else { return }
            switchToChildPanel(bottom)

            // Add Panel to bottom
            isPresetsDisplayed = true
            if prevBottomChildPanel == topChildPanel {
                prevBottomChildPanel = prevBottomChildPanel?.rightPanel()
            }
            guard let previousBottom = prevBottomChildPanel else { return }
            switchToChildPanel(previousBottom, isOnTop: false)
            isPresetsDisplayed = false
        }
    }

    func homePressed() {
        // Display Osc View when user clicks on AudioKit Synth One logo
        if bottomChildPanel == .generators {
            switchToChildPanel(.envelopes, isOnTop: false)
        }
        switchToChildPanel(.generators, isOnTop: true)
    }

    func devPressed() {
        isDevView = !isDevView

        if isDevView {
            for subview in topContainerView.subviews { subview.removeFromSuperview() }
            add(asChildViewController: devViewController)
        } else {
            if let cv = topChildPanel {
                switchToChildPanel(cv)
            }
        }
    }

    func randomPresetPressed() {
        presetsViewController.randomPreset()
    }

    func previousPresetPressed() {
        presetsViewController.previousPreset()
    }

    func nextPresetPressed() {
        presetsViewController.nextPreset()
    }

    func savePresetPressed() {
        presetsViewController.editPressed()
    }
    
    func appsPressed() {
         performSegue(withIdentifier: "SegueToApps", sender: self)
    }

    func morePressed() {
        guard Private.MailChimpAPIKey != "***REMOVED***" || appSettings.signedMailingList else {
           // Running source code with no mailchimp key
           self.displayAlertController("Congrats! 🎉", message: "Bonus presets have been added to BankA. " +
                "We are all volunteers who made this app for free. " +
                "We hope you enjoy it & tell other musicians! 😎")
           didSignMailingList(email: "test@audiokitpro.com")
           return
        }

        if signedMailingList {
            performSegue(withIdentifier: "SegueToMore", sender: self)
        } else {
            performSegue(withIdentifier: "SegueToMailingList", sender: self)
        }
    }

    func panicPressed() {
        conductor.synth.reset() // kinder, gentler panic
        // conductor.synth.resetDSP() // nuclear panic option

        // Turn off held notes on keybaord
        keyboardView.allNotesOff()

        let title = NSLocalizedString("Midi Panic", comment: "Alert Title: MIDI Panic")
        let message = NSLocalizedString("All notes have been turned off.", comment: "Alert Message: MIDI Panic")
        displayAlertController(title, message: message)
    }

    func aboutPressed() {
        performSegue(withIdentifier: "SegueToAbout", sender: self)
    }
}
