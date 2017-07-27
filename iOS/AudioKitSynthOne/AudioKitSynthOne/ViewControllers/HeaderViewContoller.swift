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
    
    public override func viewDidAppear(_ animated: Bool) {
        
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
            displayLabel.text = "OSC Mix: \(value.decimalString)"
        case .morph1Volume:
            displayLabel.text = "OSC1 Vol: \(value.percentageString)"
        case .morph2Volume:
            displayLabel.text = "OSC2 Vol: \(value.percentageString)"
        case .cutoff:
            displayLabel.text = "Cutoff: \(value.decimalString) Hz"
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
        case .attackDuration, .decayDuration, .sustainLevel, .releaseDuration:
            displayLabel.text = "A: \(conductor.synth.parameters[AKSynthOneParameter.attackDuration.rawValue].decimalString) D: \(conductor.synth.parameters[AKSynthOneParameter.decayDuration.rawValue].decimalString) S: \(conductor.synth.parameters[AKSynthOneParameter.sustainLevel.rawValue].percentageString) R: \(conductor.synth.parameters[AKSynthOneParameter.releaseDuration.rawValue].decimalString) "
        case .filterAttackDuration, .filterDecayDuration, .filterSustainLevel, .filterReleaseDuration:
            displayLabel.text = "F A: \(conductor.synth.parameters[AKSynthOneParameter.filterAttackDuration.rawValue].decimalString) D: \(conductor.synth.parameters[AKSynthOneParameter.filterDecayDuration.rawValue].decimalString) S: \(conductor.synth.parameters[AKSynthOneParameter.filterSustainLevel.rawValue].percentageString) R: \(conductor.synth.parameters[AKSynthOneParameter.filterReleaseDuration.rawValue].decimalString) "
            case .filterADSRMix:
                displayLabel.text = "Filter Mix \(value.percentageString)"

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
