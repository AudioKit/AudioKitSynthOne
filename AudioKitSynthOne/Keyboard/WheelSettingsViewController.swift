//
//  WheelSettingsViewControllerswift
//  AudioKitSynthOne
//
//  Created by AudioKit Contributors on 12/26/17.
//  Copyright © 2017 AudioKit. All rights reserved.
//

import UIKit

protocol ModWheelDelegate: AnyObject {
    func didSelectRouting(newDestination: Int)
}

class WheelSettingsViewController: UIViewController {

    @IBOutlet weak var modWheelSegment: UISegmentedControl!
    weak var delegate: ModWheelDelegate?
    var modWheelDestination = 0
    @IBOutlet weak var pitchUpperRange: Stepper!
    @IBOutlet weak var pitchLowerRange: Stepper!

    override func viewDidLoad() {
        super.viewDidLoad()

        modWheelSegment.selectedSegmentIndex = modWheelDestination

        let c = Conductor.sharedInstance
        guard let s = c.synth else {
            AKLog("PopUpMODController view state is invalid because synth is not instantiated")
            return
        }

        pitchUpperRange.maxValue = s.getMaximum(.pitchbendMaxSemitones)
        pitchUpperRange.minValue = s.getMinimum(.pitchbendMaxSemitones)
        pitchUpperRange.value = s.getSynthParameter(.pitchbendMaxSemitones)
        c.bind(pitchUpperRange, to: .pitchbendMaxSemitones)

        pitchLowerRange.maxValue = s.getMaximum(.pitchbendMinSemitones)
        pitchLowerRange.minValue = s.getMinimum(.pitchbendMinSemitones)
        pitchLowerRange.value = s.getSynthParameter(.pitchbendMinSemitones)
        c.bind(pitchLowerRange, to: .pitchbendMinSemitones)
		
		setModWheelSegmentAccessibiliyLabels()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        guard let s = Conductor.sharedInstance.synth else {
            AKLog("PopUpMODController view state is invalid because synth is not instantiated")
            return
        }
        pitchUpperRange.value = s.getSynthParameter(.pitchbendMaxSemitones)
        pitchLowerRange.value = s.getSynthParameter(.pitchbendMinSemitones)
    }

    @IBAction func routingValueDidChange(_ sender: UISegmentedControl) {
        delegate?.didSelectRouting(newDestination: sender.selectedSegmentIndex)
    }

    @IBAction func closeButton(_ sender: UIButton) {
        dismiss(animated: true, completion: nil)
    }

}


/**
Accessibility Functions
*/
extension WheelSettingsViewController {
	
	private func setModWheelSegmentAccessibiliyLabels() {
		modWheelSegment.subviews[0].accessibilityLabel = "Cutoff"
		modWheelSegment.subviews[1].accessibilityLabel = "L F O 1"
		modWheelSegment.subviews[1].accessibilityLabel = "L F O 2"
	}
	
	
}
