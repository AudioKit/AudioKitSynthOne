//
//  HeaderViewContoller.swift
//  AudioKitSynthOne
//
//  Created by Aurelius Prochazka on 7/23/17.
//  Copyright © 2017 AudioKit. All rights reserved.
//

import UIKit
import AudioKit

public class HeaderViewController: SynthOneViewController {

    @IBOutlet weak var displayLabel: UILabel!

    public override func viewDidLoad() {
        super.viewDidLoad()
    }

    override func updateUI(_ param: AKSynthOneParameter, value: Double) {
        switch param {
        case .morph1PitchOffset:
            displayLabel.text = "DCO1: \(value) semitones"
        case .morph2PitchOffset:
            displayLabel.text = "DCO2: \(value) semitones"
        case .detuningMultiplier:
            displayLabel.text = "DCO2: \(value)X"
        case .morphBalance:
            displayLabel.text = "OSC MIX: \(value)"
        case .morph1Mix:
            displayLabel.text = "OSC1: \(value)"
        case .morph2Mix:
            displayLabel.text = "OSC2: \(value)"
        case .resonance:
            displayLabel.text = "Resonance: \(value)"
        case .subOscMix:
            displayLabel.text = "Sub Mix: \(value)"
        case .fmMix:
            displayLabel.text = "FM Mix: \(value)"
        case .fmMod:
            displayLabel.text = "FM Mod \(value)"
        case .noiseMix:
            displayLabel.text = "Noise Mix: \(value)"
        default:
            _ = 0
            // do nothing
        }
        displayLabel.setNeedsDisplay()
        super.updateUI(param, value: value)
    }


}
