//
//  Parent+HeaderDelegate.swift
//  AudioKitSynthOne
//
//  Created by AudioKit Contributors on 5/25/18.
//  Copyright © 2018 AudioKit. All rights reserved.
//

// Header Delegate

extension ParentViewController: HeaderDelegate {

    func displayLabelTapped() {
        if !isPresetsDisplayed {

            // Hide Keyboard
            keyboardView.isShown = keyboardToggle.isOn
            keyboardToggle.callback(0.0)
            keyboardToggle.value = 0.0

            // Save previous bottom panel
            prevBottomChildView = bottomChildView

            // Animate
            topPanelheight.constant = 0
            view.layoutIfNeeded()
            // Add Panel to Top
            displayPresetsController()
            guard let top = topChildView else { return }
            switchToChildView(top, isTopView: false)
            topChildView = nil

            // Animate panel
            UIView.animate(withDuration: Double(0.2), animations: {
                self.topPanelheight.constant = 299
                self.view.layoutIfNeeded()
            })

        } else {

            // Show Keyboard
            if keyboardView.isShown {
                keyboardToggle.value = 1.0
                keyboardBottomConstraint.constant = 0
                keyboardToggle.setTitle("Hide", for: .normal)
            }

            // Add Panel to Top
            guard let bottom = bottomChildView else { return }
            switchToChildView(bottom)

            // Add Panel to bottom
            isPresetsDisplayed = true
            if prevBottomChildView == topChildView {
                prevBottomChildView = prevBottomChildView?.rightView()
            }
            guard let previousBottom = prevBottomChildView else { return }
            switchToChildView(previousBottom, isTopView: false)
            isPresetsDisplayed = false
        }
    }

    func homePressed() {
        // Display Osc View when user clicks on AudioKit Synth One logo
        if bottomChildView == .oscView {
            switchToChildView(.adsrView, isTopView: false)
        }
        switchToChildView(.oscView, isTopView: true)
    }

    func devPressed() {
        isDevView = !isDevView

        if isDevView {
            topContainerView.subviews.forEach({ $0.removeFromSuperview() })
            add(asChildViewController: devViewController)
        } else {
            if let cv = topChildView {
                switchToChildView(cv)
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

    func morePressed() {
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

        displayAlertController("Midi Panic", message: "All notes have been turned off.")
    }

    func aboutPressed() {
        performSegue(withIdentifier: "SegueToAbout", sender: self)
    }
}
