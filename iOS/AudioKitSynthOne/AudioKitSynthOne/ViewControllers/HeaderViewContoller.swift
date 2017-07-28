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
    var delegate: EmbeddedViewsDelegate?

    func ADSRString(_ a: AKSynthOneParameter, _ d: AKSynthOneParameter, _ s: AKSynthOneParameter, _ r : AKSynthOneParameter) -> String {
        return "A: \(conductor.synth.parameters[a.rawValue].decimalString) D: \(conductor.synth.parameters[d.rawValue].decimalString) S: \(conductor.synth.parameters[s.rawValue].percentageString) R: \(conductor.synth.parameters[r.rawValue].decimalString) "
    }

    override func updateUI(_ param: AKSynthOneParameter, value: Double) {
        
        switch param {
        case .morph1SemitoneOffset:
            displayLabel.text = "DCO1: \(value) semitones"
        case .morph2SemitoneOffset:
            displayLabel.text = "DCO2: \(value) semitones"
        case .morph2Detuning:
            displayLabel.text = "DCO2: \(value.decimalString) Hz"
        case .morphBalance:
            displayLabel.text = "DCO Mix: \(value.decimalString)"
        case .morph1Volume:
            displayLabel.text = "DCO1 Vol: \(value.percentageString)"
        case .morph2Volume:
            displayLabel.text = "DCO2 Vol: \(value.percentageString)"
        case .cutoff:
            displayLabel.text = "Cutoff: \(value.decimalString) Hz"
        case .resonance:
            displayLabel.text = "Resonance: \(value.decimalString)"
        case .subVolume:
            displayLabel.text = "Sub Mix: \(value.percentageString)"
        case .fmVolume:
            displayLabel.text = "FM Mix: \(value.percentageString)"
        case .fmAmount:
            displayLabel.text = "FM Mod \(value.percentageString)" // FIX ME
        case .noiseVolume:
            displayLabel.text = "Noise Mix: \(value.percentageString)"
        case .masterVolume:
            displayLabel.text = "Master Vol: \(value.percentageString)"
        case .attackDuration, .decayDuration, .sustainLevel, .releaseDuration:
            displayLabel.text = ADSRString(.attackDuration, .decayDuration, .sustainLevel, .releaseDuration)
        case .filterAttackDuration, .filterDecayDuration, .filterSustainLevel, .filterReleaseDuration:
            displayLabel.text = "F " +
                ADSRString(.filterAttackDuration, .filterDecayDuration, .filterSustainLevel, .filterReleaseDuration)
        case .filterADSRMix:
                displayLabel.text = "Filter Mix \(value.percentageString)"
        case .bitCrushDepth:
            displayLabel.text = "Bit Crush Depth: \(value.decimalString)"
        case .bitCrushSampleRate:
            displayLabel.text = "Downsample Rate: \(value.decimalString)"
        case .autoPanOn:
            displayLabel.text = value == 1 ? "Auto Pan On" : "Auto Pan Off"
        case .autoPanFrequency:
            displayLabel.text = "Auto Pan: \(value.decimalString) Hz"
        case .reverbOn:
            displayLabel.text = value == 1 ? "Reverb On" : "Reverb Off"
        case .reverbFeedback:
            displayLabel.text = "Reverb Size: \(value.percentageString)"
        case .reverbCutoff:
            displayLabel.text = "Reverb Cutoff: \(value.decimalString) Hz"
        case .reverbMix:
            displayLabel.text = "Reverb Mix: \(value.percentageString)"

        default:
            _ = 0
            // do nothing
        }
        displayLabel.setNeedsDisplay()
    }
    // ********************************************************
    // MARK: - IBActions
    // ********************************************************
    
    @IBAction func mainPressed(_ sender: UIButton) {
        delegate?.switchToChildView(.oscView)
    }
    
    @IBAction func adsrPressed(_ sender: UIButton) {
        delegate?.switchToChildView(.adsrView)
    }
    
    @IBAction func devPressed(_ sender: UIButton) {
        delegate?.switchToChildView(.devView)
    }
    
    @IBAction func padPressed(_ sender: UIButton) {
        delegate?.switchToChildView(.padView)
    }
    
    @IBAction func fxPressed(_ sender: UIButton) {
        delegate?.switchToChildView(.fxView)
    }
    
}
