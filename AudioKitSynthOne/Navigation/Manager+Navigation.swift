//
//  Manager+Navigation.swift
//  AudioKitSynthOne
//
//  Created by Aurelius Prochazka on 6/8/18.
//  Copyright © 2018 AudioKit. All rights reserved.
//

/// View Navigation/Embed Helper Methods
extension Manager {
    
    override public func prepare(for segue: UIStoryboardSegue, sender: Any?) {

        if segue.identifier == "SegueToKeyboardSettings" {
            guard let popOverController = segue.destination as? KeyboardSettingsViewController else { return }
            popOverController.delegate = self
            popOverController.octaveRange = keyboardView.octaveCount
            popOverController.labelMode = keyboardView.labelMode
            popOverController.darkMode = keyboardView.darkMode

            popOverController.preferredContentSize = CGSize(width: 300, height: 240)
            if let presentation = popOverController.popoverPresentationController {
                presentation.backgroundColor = #colorLiteral(red: 0.1568627451, green: 0.1568627451, blue: 0.1568627451, alpha: 1)
                presentation.sourceRect = configKeyboardButton.bounds
            }
        }

        if segue.identifier == "SegueToMIDI" {
            guard let popOverController = segue.destination as? MIDISettingsViewController else { return }
            popOverController.delegate = self
            let userMIDIChannel = omniMode ? -1 : Int(midiChannelIn)
            popOverController.userChannelIn = userMIDIChannel
            popOverController.midiSources = midiInputs
            popOverController.saveTuningWithPreset = appSettings.saveTuningWithPreset
            popOverController.launchWithLastTuning = appSettings.launchWithLastTuning
            popOverController.velocitySensitive = appSettings.velocitySensitive

            popOverController.preferredContentSize = CGSize(width: 600, height: 378)
            if let presentation = popOverController.popoverPresentationController {
                presentation.backgroundColor = #colorLiteral(red: 0.1568627451, green: 0.1568627451, blue: 0.1568627451, alpha: 1)
                presentation.sourceRect = midiButton.bounds
            }
        }

        if segue.identifier == "SegueToMOD" {
            guard let popOverController = segue.destination as? WheelSettingsViewController else { return }
            popOverController.delegate = self
            popOverController.modWheelDestination = Int(activePreset.modWheelRouting)
            popOverController.preferredContentSize = CGSize(width: 300, height: 290)
            if let presentation = popOverController.popoverPresentationController {
                presentation.backgroundColor = #colorLiteral(red: 0.1568627451, green: 0.1568627451, blue: 0.1568627451, alpha: 1)
                presentation.sourceRect = midiButton.bounds
            }
        }

        if segue.identifier == "SegueToAbout" {
            guard let popOverController = segue.destination as? AboutViewController else { return }
            popOverController.delegate = self
        }

        if segue.identifier == "SegueToMailingList" {
            guard let popOverController = segue.destination as? MailingListViewController else { return }
            popOverController.delegate = self
        }
    }

    func add(asChildViewController viewController: UIViewController, isTopContainer: Bool = true) {

        // Add Child View Controller
        addChild(viewController)

        // Add Child View as Subview
        if isTopContainer {
            topContainerView.addSubview(viewController.view)
            viewController.view.frame = topContainerView.bounds
        } else {
            bottomContainerView.addSubview(viewController.view)
            viewController.view.frame = bottomContainerView.bounds
        }

        viewController.view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        viewController.didMove(toParent: self)
    }

    func displayPresetsController() {

        // Display Presets View
        topContainerView.subviews.forEach { $0.removeFromSuperview() }
        add(asChildViewController: presetsViewController)
        presetsViewController.presetsDelegate = self
        isPresetsDisplayed = true
    }
}
