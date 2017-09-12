//
//  HeaderViewContoller.swift
//  AudioKitSynthOne
//
//  Created by Aurelius Prochazka on 7/23/17.
//  Copyright © 2017 AudioKit. All rights reserved.
//

import UIKit
import AudioKit

protocol HeaderDelegate {
    func displayLabelTapped()
    func prevPresetPressed()
    func nextPresetPressed()
    func savePresetPressed()
}

public class HeaderViewController: UpdatableViewController {

    @IBOutlet weak var mainBtn: HeaderNavButton!
    @IBOutlet weak var adsrBtn: HeaderNavButton!
    @IBOutlet weak var seqBtn: HeaderNavButton!
    @IBOutlet weak var padBtn: HeaderNavButton!
    @IBOutlet weak var fxBtn: HeaderNavButton!
    
    @IBOutlet weak var displayLabel: UILabel!
    var headerNavBtns = [HeaderNavButton]()
    
    var delegate: EmbeddedViewsDelegate?
    var headerDelegate: HeaderDelegate?
    
    func ADSRString(_ a: AKSynthOneParameter,
                    _ d: AKSynthOneParameter,
                    _ s: AKSynthOneParameter,
                    _ r: AKSynthOneParameter) -> String {
        return  "A: \(conductor.synth.parameters[a.rawValue].decimalString) " +
            "D: \(conductor.synth.parameters[d.rawValue].decimalString) " +
            "S: \(conductor.synth.parameters[s.rawValue].percentageString) " +
        "R: \(conductor.synth.parameters[r.rawValue].decimalString) "
    }
    
    public override func viewDidLoad() {
        headerNavBtns = [mainBtn, adsrBtn, padBtn, fxBtn, seqBtn]
        setupBtnCallbacks()
        
        // Add Gesture Recognizer to Display Label
        let tap = UITapGestureRecognizer(target: self, action: #selector(HeaderViewController.displayLabelTapped))
        tap.numberOfTapsRequired = 1
        displayLabel.addGestureRecognizer(tap)
        displayLabel.isUserInteractionEnabled = true

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
        case .cutoff, .resonance:
            displayLabel.text = "Cutoff: \(conductor.synth.parameters[AKSynthOneParameter.cutoff.rawValue].decimalString) Hz, Rez: \(conductor.synth.parameters[AKSynthOneParameter.resonance.rawValue].decimalString)"
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
            if conductor.syncRatesToTempo {
                displayLabel.text = "AutoPan Rate: \(Rate.fromFrequency(value))"
            } else {
                displayLabel.text = "AutoPan Rate: \(value.decimalString) Hz"
            }
        case .reverbOn:
            displayLabel.text = value == 1 ? "Reverb On" : "Reverb Off"
        case .reverbFeedback:
            displayLabel.text = "Reverb Size: \(value.percentageString)"
        case .reverbHighPass:
            displayLabel.text = "Reverb Cutoff: \(value.decimalString) Hz"
        case .reverbMix:
            displayLabel.text = "Reverb Mix: \(value.percentageString)"
        case .delayOn:
            displayLabel.text = value == 1 ? "Delay On" : "Delay Off"
        case .delayFeedback:
            displayLabel.text = "Delay Taps: \(value.percentageString)"
        case .delayTime:
            if conductor.syncRatesToTempo {
                displayLabel.text = "Delay Time: \(Rate.fromTime(value)), \(value.decimalString)s"
            } else {
               displayLabel.text = "Delay Time: \(value.decimalString) s"
            }
         
        case .delayMix:
            displayLabel.text = "Delay Mix: \(value.percentageString)"
        case .lfo1Rate:
            if conductor.syncRatesToTempo {
                displayLabel.text = "LFO 1 Rate: \(Rate.fromFrequency(value))"
            } else {
                displayLabel.text = "LFO 1 Rate: \(value.decimalString) Hz"
            }
        case .lfo2Rate:
            if conductor.syncRatesToTempo {
                displayLabel.text = "LFO 2 Rate: \(Rate.fromFrequency(value))"
            } else {
                displayLabel.text = "LFO 2 Rate: \(value.decimalString) Hz"
            }
        case .lfo1Amplitude:
            displayLabel.text = "LFO 1: \(value.percentageString)"
        case .lfo2Amplitude:
            displayLabel.text = "LFO 2: \(value.percentageString)"
        case .cutoffLFO:
            displayLabel.text = "Cutoff LFO: \(value.decimalString)"
        case .resonanceLFO:
            displayLabel.text = "Resonance LFO: \(value.decimalString)"
        case .oscMixLFO:
            displayLabel.text = "Osc Mix LFO: \(value.decimalString)"
        case .sustainLFO:
            displayLabel.text = "Sustain LFO: \(value.decimalString)"
        case .index1LFO:
            displayLabel.text = "Index1 LFO: \(value.decimalString)"
        case .index2LFO:
            displayLabel.text = "Index2 LFO: \(value.decimalString)"
        case .fmLFO:
            displayLabel.text = "FM LFO: \(value.decimalString)"
        case .detuneLFO:
            displayLabel.text = "Detune LFO: \(value.decimalString)"
        case .filterEnvLFO:
            displayLabel.text = "Filter Env LFO: \(value.decimalString)"
        case .pitchLFO:
            displayLabel.text = "Pitch LFO: \(value.decimalString)"
        case .bitcrushLFO:
            displayLabel.text = "Bitcrush LFO: \(value.decimalString)"
        case .autopanLFO:
            displayLabel.text = "AutoPan LFO: \(value.decimalString)"
            
        default:
            _ = 0
            // do nothing
        }
        displayLabel.setNeedsDisplay()
    }
   
    // ********************************************************
    // MARK: - IBActions
    // ********************************************************
    
    func setupBtnCallbacks() {
        
        mainBtn.callback = { _ in
            self.delegate?.switchToChildView(.oscView)
            self.updateHeaderNavButtons()
        }
        
        adsrBtn.callback = { _ in
            self.delegate?.switchToChildView(.adsrView)
            self.updateHeaderNavButtons()
        }
        
        seqBtn.callback = { _ in
            self.delegate?.switchToChildView(.seqView)
             self.updateHeaderNavButtons()
        }
        
        padBtn.callback = { _ in
            self.delegate?.switchToChildView(.padView)
            self.updateHeaderNavButtons()
        }
        
        fxBtn.callback = { _ in
            self.delegate?.switchToChildView(.fxView)
            self.updateHeaderNavButtons()
        }
    }
    
  
    func displayLabelTapped() {
        headerDelegate?.displayLabelTapped()
    }
    
    @IBAction func prevPresetPressed(_ sender: UIButton) {
         headerDelegate?.prevPresetPressed()
    }
    
   
    @IBAction func nextPresetPressed(_ sender: UIButton) {
         headerDelegate?.nextPresetPressed()
    }
    
    @IBAction func savePressed(_ sender: UIButton) {
         headerDelegate?.savePresetPressed()
    }
    
    // ********************************************************
    // MARK: - Helper
    // ********************************************************
    
    func updateHeaderNavButtons() {
        guard let parentController = self.parent as? SynthOneViewController else { return }
        guard let topView = parentController.topChildView else { return }
        guard let bottomView = parentController.bottomChildView else { return }
        
        headerNavBtns.forEach { $0.isSelected = false }
        headerNavBtns.forEach { $0.isEnabled = true }
        
        headerNavBtns[topView.rawValue].isSelected = true
        headerNavBtns[bottomView.rawValue].isEnabled = false
    }
    
    
}
