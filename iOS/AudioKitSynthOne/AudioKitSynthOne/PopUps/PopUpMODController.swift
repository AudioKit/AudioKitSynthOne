//
//  PopUpMODController.swift
//  AudioKitSynthOne
//
//  Created by Matthew Fecher on 12/26/17.
//  Copyright © 2017 AudioKit. All rights reserved.
//

import UIKit

protocol ModWheelDelegate {
    func didSelectRouting(newDestination: Int)
}

class PopUpMODController: UIViewController {

    @IBOutlet weak var modWheelSegment: UISegmentedControl!
    var delegate: ModWheelDelegate?
    var modWheelDestination = 0
    @IBOutlet weak var pitchUpperRange: Stepper!
    @IBOutlet weak var pitchLowerRange: Stepper!

    override func viewDidLoad() {
        super.viewDidLoad()

        modWheelSegment.selectedSegmentIndex = modWheelDestination

        let c = Conductor.sharedInstance
        guard let s = c.synth else { return }

        pitchUpperRange.maxValue = s.getMaximum(.pitchbendMaxSemitones)
        pitchUpperRange.minValue = s.getMinimum(.pitchbendMaxSemitones)
        pitchUpperRange.value = s.getAK1Parameter(.pitchbendMaxSemitones)
        c.bind(pitchUpperRange, to: .pitchbendMaxSemitones)

        pitchLowerRange.maxValue = s.getMaximum(.pitchbendMinSemitones)
        pitchLowerRange.minValue = s.getMinimum(.pitchbendMinSemitones)
        pitchLowerRange.value = s.getAK1Parameter(.pitchbendMinSemitones)
        c.bind(pitchLowerRange, to: .pitchbendMinSemitones)
    }

    override func viewDidAppear(_ animated: Bool) {
        guard let s = Conductor.sharedInstance.synth else { return }
        pitchUpperRange.value = s.getAK1Parameter(.pitchbendMaxSemitones)
        pitchLowerRange.value = s.getAK1Parameter(.pitchbendMinSemitones)
    }

    @IBAction func routingValueDidChange(_ sender: UISegmentedControl) {
        delegate?.didSelectRouting(newDestination: sender.selectedSegmentIndex)
    }

    @IBAction func closeButton(_ sender: UIButton) {
        dismiss(animated: true, completion: nil)
    }

}
