//
//  HeaderViewContoller.swift
//  AudioKitSynthOne
//
//  Created by Aurelius Prochazka on 7/23/17.
//  Copyright © 2017 AudioKit. All rights reserved.
//

import UIKit

protocol HeaderDelegate {
    func displayLabelTapped()
    func homePressed()
    func prevPresetPressed()
    func nextPresetPressed()
    func savePresetPressed()
    func randomPresetPressed()
    func devPressed()
}

public class HeaderViewController: UpdatableViewController {
    
    @IBOutlet weak var displayLabel: UILabel!
    @IBOutlet weak var panicButton: PresetUIButton!
    @IBOutlet weak var diceButton: UIButton!
    @IBOutlet weak var saveButton: PresetUIButton!
    @IBOutlet weak var devButton: PresetUIButton!
    
    var delegate: EmbeddedViewsDelegate?
    var headerDelegate: HeaderDelegate?
    var activePreset = Preset()
    
    func ADSRString(_ a: AKSynthOneParameter,
                    _ d: AKSynthOneParameter,
                    _ s: AKSynthOneParameter,
                    _ r: AKSynthOneParameter) -> String {
        return "A: \(conductor.synth.getAK1Parameter(a).decimalString) " +
            "D: \(conductor.synth.getAK1Parameter(d).decimalString) " +
            "S: \(conductor.synth.getAK1Parameter(s).percentageString) " +
            "R: \(conductor.synth.getAK1Parameter(r).decimalString) "
    }
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        
        // Add Gesture Recognizer to Display Label
        let tap = UITapGestureRecognizer(target: self, action: #selector(HeaderViewController.displayLabelTapped))
        tap.numberOfTapsRequired = 1
        displayLabel.addGestureRecognizer(tap)
        displayLabel.isUserInteractionEnabled = true
        
        setupCallbacks()
       
    }
    
    override func updateUI(_ param: AKSynthOneParameter, value: Double) {
        super.updateUI(param, value: value)
      
        switch param {
        case .index1:
            displayLabel.text = "OSC1 Morph: \(value.decimalString)"
        case .index2:
            displayLabel.text = "OSC2 Morph: \(value.decimalString)"
        case .morph1SemitoneOffset:
            displayLabel.text = "DCO1: \(value) semitones"
        case .morph2SemitoneOffset:
            displayLabel.text = "DCO2: \(value) semitones"
        case .morph2Detuning:
            displayLabel.text = "DCO2 Detune: \(value.decimalString) x Hz"
        case .morphBalance:
            displayLabel.text = "DCO Mix: \(value.decimalString)"
        case .morph1Volume:
            displayLabel.text = "DCO1 Vol: \(value.percentageString)"
        case .morph2Volume:
            displayLabel.text = "DCO2 Vol: \(value.percentageString)"
        case .glide:
            displayLabel.text = "Glide: \(value)"
        case .cutoff, .resonance:
            displayLabel.text = "Cutoff: \(conductor.synth.getAK1Parameter(.cutoff).decimalString) Hz, Rez: \(conductor.synth.getAK1Parameter(.resonance).decimalString)"
        case .subVolume:
            displayLabel.text = "Sub Mix: \(value.percentageString)"
        case .fmVolume:
            displayLabel.text = "FM Mix: \(value.percentageString)"
        case .fmAmount:
            displayLabel.text = "FM Mod: \(value.decimalString)" 
        case .noiseVolume:
            displayLabel.text = "Noise Mix: \((value*4).percentageString)"
        case .masterVolume:
            displayLabel.text = "Master Vol: \(value.percentageString)"
        case .attackDuration, .decayDuration, .sustainLevel, .releaseDuration:
            displayLabel.text = ADSRString(.attackDuration, .decayDuration, .sustainLevel, .releaseDuration)
        case .filterAttackDuration, .filterDecayDuration, .filterSustainLevel, .filterReleaseDuration:
            displayLabel.text = "" +
                ADSRString(.filterAttackDuration, .filterDecayDuration, .filterSustainLevel, .filterReleaseDuration)
        case .filterADSRMix:
            displayLabel.text = "Filter Envelope Amt: \(value.percentageString)"
        case .bitCrushDepth:
            displayLabel.text = "Bit Crush Depth: \(value.decimalString)"
        case .bitCrushSampleRate:
            displayLabel.text = "Downsample Rate: \(value.decimalString)"
        case .autoPanAmount:
            displayLabel.text = "Auto Pan Amount: \(value.decimalString)"
        case .autoPanFrequency:
            if conductor.syncRateToTempo {
                displayLabel.text = "AutoPan Rate: \(Rate.fromFrequency(value))"
            } else {
                displayLabel.text = "AutoPan Rate: \(value.decimalString) Hz"
            }
        case .reverbOn:
            displayLabel.text = value == 1 ? "Reverb On" : "Reverb Off"
        case .reverbFeedback:
            displayLabel.text = "Reverb Size: \(value.percentageString)"
        case .reverbHighPass:
            displayLabel.text = "Reverb Low-cut: \(value.decimalString) Hz"
        case .reverbMix:
            displayLabel.text = "Reverb Mix: \(value.percentageString)"
        case .delayOn:
            displayLabel.text = value == 1 ? "Delay On" : "Delay Off"
        case .delayFeedback:
            displayLabel.text = "Delay Taps: \(value.percentageString)"
        case .delayTime:
            if conductor.syncRateToTempo {
                displayLabel.text = "Delay Time: \(Rate.fromTime(value)), \(value.decimalString)s"
            } else {
               displayLabel.text = "Delay Time: \(value.decimalString) s"
            }
         
        case .delayMix:
            displayLabel.text = "Delay Mix: \(value.percentageString)"
        case .lfo1Rate:
            if conductor.syncRateToTempo {
                displayLabel.text = "LFO 1 Rate: \(Rate.fromFrequency(value))"
            } else {
                displayLabel.text = "LFO 1 Rate: \(value.decimalString) Hz"
            }
        case .lfo2Rate:
            if conductor.syncRateToTempo {
                displayLabel.text = "LFO 2 Rate: \(Rate.fromFrequency(value))"
            } else {
                displayLabel.text = "LFO 2 Rate: \(value.decimalString) Hz"
            }
        case .lfo1Amplitude:
            displayLabel.text = "LFO 1 Amp: \(value.percentageString)"
        case .lfo2Amplitude:
            displayLabel.text = "LFO 2 Amp: \(value.percentageString)"
        case .cutoffLFO:
            displayLabel.text = "Cutoff LFO: \(value.decimalString)"
        case .resonanceLFO:
            displayLabel.text = "Resonance LFO: \(value.decimalString)"
        case .oscMixLFO:
            displayLabel.text = "Osc Mix LFO: \(value.decimalString)"
        case .sustainLFO:
            displayLabel.text = "Sustain LFO: \(value.decimalString)"
        case .decayLFO:
            displayLabel.text = "Decay LFO: \(value.decimalString)"
        case .noiseLFO:
            displayLabel.text = "Noise LFO: \(value.decimalString)"
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
        case .filterType:
            displayLabel.text = "Filter Type: \(value.decimalString)"
        case .phaserMix:
            displayLabel.text = "Phaser Mix: \(value.decimalString)"
        case .phaserRate:
            displayLabel.text = "Phaser Rate: \(value.decimalString)"
        case .phaserFeedback:
            displayLabel.text = "Phaser Feedback: \(value.decimalString)"
        case .phaserNotchWidth:
            displayLabel.text = "Phaser Notch Width: \(value.decimalString)"

        default:
            _ = 0
            // do nothing
        }
        displayLabel.setNeedsDisplay()
        
    }
    
    @objc func displayLabelTapped() {
        headerDelegate?.displayLabelTapped()
    }
    
    @IBAction func homePressed(_ sender: UIButton) {
        headerDelegate?.homePressed()
    }
    
    @IBAction func prevPresetPressed(_ sender: UIButton) {
         headerDelegate?.prevPresetPressed()
    }
    
    @IBAction func nextPresetPressed(_ sender: UIButton) {
         headerDelegate?.nextPresetPressed()
    }
    
    
    @IBAction func randomPressed(_ sender: UIButton) {
        // Animate Dice
        UIView.animate(withDuration: 0.4, animations: {
            for _ in 0 ... 1 {
                self.diceButton.transform = self.diceButton.transform.rotated(by: CGFloat(Double.pi))
            }
        })
        
        headerDelegate?.randomPresetPressed()
    }
    
    func setupCallbacks() {
        
        panicButton.callback = { _ in
            //conductor.synth.reset() // kinder, gentler panic
            self.conductor.synth.resetDSP() // nuclear panic option
            
            // TODO: turn off held notes on keybaord
        }
        
        saveButton.callback = { _ in
            self.headerDelegate?.savePresetPressed()
        }
        
        devButton.callback = { _ in
            self.headerDelegate?.devPressed()
        }
    }
    
    // ********************************************************
    // MARK: - Helper
    // ********************************************************
    /*
    // Header nav buttons
    func updateHeaderNavButtons() {
     
        guard let parentController = self.parent as? SynthOneViewController else { return }
        guard let topView = parentController.topChildView else { return }
        guard let bottomView = parentController.bottomChildView else { return }
        
        headerNavBtns.forEach { $0.isSelected = false }
        headerNavBtns.forEach { $0.isEnabled = true }
        
        headerNavBtns[topView.rawValue].isSelected = true
        headerNavBtns[bottomView.rawValue].isEnabled = false
       
    }
    */
}
