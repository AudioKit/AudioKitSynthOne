//
//  KeyboardSettingsViewController.swift
//  AudioKitSynthOne
//
//  Created by AudioKit Contributors on 11/27/16.
//  Copyright © 2016 AudioKit. All rights reserved.
//

import UIKit

protocol KeyboardPopOverDelegate: AnyObject {
    func didFinishSelecting(octaveRange: Int, labelMode: Int, darkMode: Bool)
}

class KeyboardSettingsViewController: UIViewController {

    @IBOutlet weak var octaveRangeSegment: UISegmentedControl!
    @IBOutlet weak var labelModeSegment: UISegmentedControl!
    @IBOutlet weak var keyboardModeSegment: UISegmentedControl!

    weak var delegate: KeyboardPopOverDelegate?

    var labelMode: Int = 1
    var octaveRange: Int = 2
    var darkMode: Bool = false

    override func viewDidLoad() {
        super.viewDidLoad()

        // set currently selected scale picks
        octaveRangeSegment.selectedSegmentIndex = octaveRange - 1
        labelModeSegment.selectedSegmentIndex = labelMode
        keyboardModeSegment.selectedSegmentIndex = darkMode ? 1 : 0

    }

    // Set fonts for UISegmentedControls
    override func viewDidLayoutSubviews() {
        guard let font = UIFont(name: "Avenir Next Condensed", size: 15.0) else { return }
        let attr = NSDictionary(object: font,
                                forKey: NSAttributedStringKey.font as NSCopying)
        labelModeSegment.setTitleTextAttributes(attr as [NSObject : AnyObject], for: .normal)
        keyboardModeSegment.setTitleTextAttributes(attr as [NSObject : AnyObject], for: .normal)
        octaveRangeSegment.setTitleTextAttributes(attr as [NSObject : AnyObject], for: .normal)
    }

    @IBAction func octaveRangeDidChange(_ sender: UISegmentedControl) {

        octaveRange = sender.selectedSegmentIndex + 1

        delegate?.didFinishSelecting(octaveRange: octaveRange, labelMode: labelMode, darkMode: darkMode)
    }

    @IBAction func keyLabelDidChange(_ sender: UISegmentedControl) {

           labelMode = sender.selectedSegmentIndex

           delegate?.didFinishSelecting(octaveRange: octaveRange, labelMode: labelMode, darkMode: darkMode)
    }

    @IBAction func keyboardModeDidChange(_ sender: UISegmentedControl) {

        if sender.selectedSegmentIndex == 1 {
            darkMode = true
        } else {
            darkMode = false
        }

        delegate?.didFinishSelecting(octaveRange: octaveRange, labelMode: labelMode, darkMode: darkMode)
    }

    @IBAction func closeButton(_ sender: UIButton) {
       // delegate?.didFinishSelecting(root: selectedRoot, scaleType: selectedScaleType)
        dismiss(animated: true, completion: nil)

    }
}

/**
Accessibility Functions
*/
extension KeyboardSettingsViewController {
	
	private func setOctaveRangeSegmentAccessibility() {
		octaveRangeSegment.subviews[0].accessibilityLabel = "1"
		octaveRangeSegment.subviews[1].accessibilityLabel = "2"
		octaveRangeSegment.subviews[1].accessibilityLabel = "3"
	}
	
	private func setLabelModeSegment() {
		labelModeSegment.subviews[0].accessibilityLabel = "None"
		labelModeSegment.subviews[1].accessibilityLabel = "C"
		labelModeSegment.subviews[2].accessibilityLabel = "All"
		
	}
	
	private func setKeyboardModeSegment() {
		keyboardModeSegment.subviews[0].accessibilityLabel = "White"
		keyboardModeSegment.subviews[1].accessibilityLabel = "Black"
	}
	
}
