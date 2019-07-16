//
//  KeyboardSettingsViewController.swift
//  AudioKitSynthOne
//
//  Created by AudioKit Contributors on 11/27/16.
//  Copyright © 2016 AudioKit. All rights reserved.
//

import UIKit

protocol KeyboardPopOverDelegate: AnyObject {

    func didFinishSelecting(octaveRange: Int, labelMode: Int, darkMode: Bool, tuningMode: Bool)
}

class KeyboardSettingsViewController: UIViewController {

    @IBOutlet weak var octaveRangeSegment: UISegmentedControl!

    @IBOutlet weak var labelModeSegment: UISegmentedControl!

    @IBOutlet weak var keyboardModeSegment: UISegmentedControl!

    @IBOutlet weak var keyboardTuningModeSegment: UISegmentedControl!

    weak var delegate: KeyboardPopOverDelegate?

    var labelMode: Int = 1

    var octaveRange: Int = 2

    var darkMode: Bool = false

    var tuningMode: Bool = false

    override func viewDidLoad() {

        super.viewDidLoad()

        // set currently selected scale picks
        octaveRangeSegment.selectedSegmentIndex = octaveRange - 1
        labelModeSegment.selectedSegmentIndex = labelMode
        keyboardModeSegment.selectedSegmentIndex = darkMode ? 1 : 0
        keyboardTuningModeSegment.selectedSegmentIndex = tuningMode ? 1 : 0
    }

    // Set fonts for UISegmentedControls
    override func viewDidLayoutSubviews() {

        guard let font = UIFont(name: "Avenir Next Condensed", size: 15.0) else { return }
        let attr = [NSAttributedString.Key.font: font]
        labelModeSegment.setTitleTextAttributes(attr, for: .normal)
        keyboardModeSegment.setTitleTextAttributes(attr, for: .normal)
        octaveRangeSegment.setTitleTextAttributes(attr, for: .normal)
        keyboardTuningModeSegment.setTitleTextAttributes(attr, for: .normal)
    }

    @IBAction func octaveRangeDidChange(_ sender: UISegmentedControl) {

        octaveRange = sender.selectedSegmentIndex + 1
        delegate?.didFinishSelecting(octaveRange: octaveRange, labelMode: labelMode, darkMode: darkMode, tuningMode: tuningMode)
    }

    @IBAction func keyLabelDidChange(_ sender: UISegmentedControl) {

           labelMode = sender.selectedSegmentIndex
           delegate?.didFinishSelecting(octaveRange: octaveRange, labelMode: labelMode, darkMode: darkMode, tuningMode: tuningMode)
    }

    @IBAction func keyboardModeDidChange(_ sender: UISegmentedControl) {

        darkMode = (sender.selectedSegmentIndex == 1)
        delegate?.didFinishSelecting(octaveRange: octaveRange, labelMode: labelMode, darkMode: darkMode, tuningMode: tuningMode)
    }

    @IBAction func keyboardTuningModeDidChange(_ sender: UISegmentedControl) {

        tuningMode = (sender.selectedSegmentIndex == 1)

        delegate?.didFinishSelecting(octaveRange: octaveRange, labelMode: labelMode, darkMode: darkMode, tuningMode: tuningMode)
    }

    @IBAction func closeButton(_ sender: UIButton) {
        
        dismiss(animated: true, completion: nil)
    }
}

/**
Accessibility Functionality
*/
extension KeyboardSettingsViewController {
	func setUpAccessibility() {

		keyboardModeSegment.subviews[0].accessibilityLabel = NSLocalizedString("White", comment: "White")
		keyboardModeSegment.subviews[1].accessibilityLabel = NSLocalizedString("Dark", comment: "Dark")
		
		octaveRangeSegment.subviews[0].accessibilityLabel = NSLocalizedString("1", comment: "1")
		octaveRangeSegment.subviews[1].accessibilityLabel = NSLocalizedString("2", comment: "2")
		octaveRangeSegment.subviews[2].accessibilityLabel = NSLocalizedString("3", comment: "3")
		
		labelModeSegment.subviews[0].accessibilityLabel = NSLocalizedString("None", comment: "None")
		labelModeSegment.subviews[1].accessibilityLabel = NSLocalizedString("C", comment: "C")
		labelModeSegment.subviews[2].accessibilityLabel = NSLocalizedString("All", comment: "All")

        keyboardTuningModeSegment.subviews[0].accessibilityLabel = NSLocalizedString("12ET", comment: "12ET")
        keyboardTuningModeSegment.subviews[1].accessibilityLabel = NSLocalizedString("Microtonal", comment: "Microtonal")
	}
}
