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
            displayLabel.text = "DCO2: \(value)X"
        case .morphBalance:
            displayLabel.text = "OSC MIX: \(value)"
        case .morph1Volume:
            displayLabel.text = "OSC1: \(value)"
        case .morph2Volume:
            displayLabel.text = "OSC2: \(value)"
        case .resonance:
            displayLabel.text = "Resonance: \(value)"
        case .subVolume:
            displayLabel.text = "Sub Mix: \(value)"
        case .fmVolume:
            displayLabel.text = "FM Mix: \(value)"
        case .fmAmount:
            displayLabel.text = "FM Mod \(value)"
        case .noiseVolume:
            displayLabel.text = "Noise Mix: \(value)"
        default:
            _ = 0
            // do nothing
        }
        displayLabel.setNeedsDisplay()
    }


}
