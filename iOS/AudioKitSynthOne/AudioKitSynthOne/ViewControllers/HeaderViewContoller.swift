//
//  HeaderViewContoller.swift
//  AudioKitSynthOne
//
//  Created by Aurelius Prochazka on 7/23/17.
//  Copyright © 2017 AudioKit. All rights reserved.
//

import UIKit
import AudioKit

public class HeaderViewController: UpdatableViewController {

    @IBOutlet weak var displayLabel: UILabel!

    override func updateUI(_ param: AKSynthOneParameter, value: Double) {
        switch param {
        case .morph1SemitoneOffset:
            displayLabel.text = "DCO1: \(value) semitones"
        case .morph2SemitoneOffset:
            displayLabel.text = "DCO2: \(value) semitones"
        case .morph2Detuning:
            displayLabel.text = "DCO2: \(value.decimalString) Hz"
        case .morphBalance:
            displayLabel.text = "OSC Mix: \(value.decimalString)"
        case .morph1Volume:
            displayLabel.text = "OSC1 Vol: \(value.percentageString)"
        case .morph2Volume:
            displayLabel.text = "OSC2 Vol: \(value.percentageString)"
        case .resonance:
            displayLabel.text = "Resonance: \(value.decimalString)"
        case .subVolume:
            displayLabel.text = "Sub Mix: \(value.percentageString)"
        case .fmVolume:
            displayLabel.text = "FM Mix: \(value.percentageString)"
        case .fmAmount:
            //displayLabel.text = "FM Mod \(fmAmount.knobValue.percentageString)"
            print(value)
        case .noiseVolume:
            displayLabel.text = "Noise Mix: \(value.percentageString)"
        case .masterVolume:
            displayLabel.text = "Master Vol: \(value.percentageString)"
        default:
            _ = 0
            // do nothing
        }
        displayLabel.setNeedsDisplay()
    }


}
