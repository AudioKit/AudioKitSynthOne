//
//  Parent+HeaderDelegate.swift
//  AudioKitSynthOne
//
//  Created by Aurelius Prochazka on 5/25/18.
//  Copyright © 2018 AudioKit. All rights reserved.
//

// Header Delegate

extension ParentViewController: HeaderDelegate {

    func displayLabelTapped() {
        if !isPresetsDisplayed {

            // Hide Keyboard
            keyboardView.isShown = keyboardToggle.isOn
            self.keyboardToggle.callback(0.0)
            self.keyboardToggle.value = 0.0

            // Save previous bottom panel
            prevBottomChildView = bottomChildView

            // Animate
            self.topPanelheight.constant = 0
            self.view.layoutIfNeeded()
            // Add Panel to Top
            self.displayPresetsController()
            self.switchToChildView(self.topChildView!, isTopView: false)
            self.topChildView = nil

            // Animate panel
            UIView.animate(withDuration: Double(0.2), animations: {
                self.topPanelheight.constant = 299
                self.view.layoutIfNeeded()
            })

        } else {

            // Show Keyboard
            if keyboardView.isShown {
                self.keyboardToggle.value = 1.0
                self.keyboardBottomConstraint.constant = 0
                self.keyboardToggle.setTitle("Hide", for: .normal)
            }

            // Add Panel to Top
            self.switchToChildView(self.bottomChildView!)

            // Add Panel to bottom
            self.isPresetsDisplayed = true
            if self.prevBottomChildView == self.topChildView {
                self.prevBottomChildView = self.prevBottomChildView?.rightView()
            }
            self.switchToChildView(self.prevBottomChildView!, isTopView: false)
            self.isPresetsDisplayed = false
        }
    }

    func homePressed() {
        displayLabelTapped()
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

    func prevPresetPressed() {
        presetsViewController.prevPreset()
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
        //self.conductor.synth.resetDSP() // nuclear panic option

        // Turn off held notes on keybaord
        keyboardView.allNotesOff()

        self.displayAlertController("Midi Panic", message: "All notes have been turned off.")
    }

    func aboutPressed() {
        self.performSegue(withIdentifier: "SegueToAbout", sender: self)
    }
}
