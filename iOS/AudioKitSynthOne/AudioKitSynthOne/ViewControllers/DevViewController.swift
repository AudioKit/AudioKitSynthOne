//
//  DevViewController.swift
//  AudioKitSynthOne
//
//  Created by Matthew Fecher on 12/2/17.
//  Copyright © 2017 AudioKit. All rights reserved.
//

import AudioKit
import UIKit

protocol DevPanelDelegate {
    func freezeArpChanged(_ value: Bool)
}

class DevViewController: UpdatableViewController {
    
    var delegate: DevPanelDelegate?
    
    @IBOutlet weak var masterVolume: Knob! // i.e., gain before compressorMaster
    @IBOutlet weak var compressorMasterRatio: Knob!
    @IBOutlet weak var compressorReverbInputRatio: Knob!
    @IBOutlet weak var compressorReverbWetRatio: Knob!
    
    @IBOutlet weak var compressorMasterThreshold: Knob!
    @IBOutlet weak var compressorReverbInputThreshold: Knob!
    @IBOutlet weak var compressorReverbWetThreshold: Knob!
    
    @IBOutlet weak var compressorMasterAttack: Knob!
    @IBOutlet weak var compressorReverbInputAttack: Knob!
    @IBOutlet weak var compressorReverbWetAttack: Knob!
    
    @IBOutlet weak var compressorMasterRelease: Knob!
    @IBOutlet weak var compressorReverbInputRelease: Knob!
    @IBOutlet weak var compressorReverbWetRelease: Knob!
    
    @IBOutlet weak var compressorMasterMakeupGain: Knob!
    @IBOutlet weak var compressorReverbInputMakeupGain: Knob!
    @IBOutlet weak var compressorReverbWetMakeupGain: Knob!

    @IBOutlet weak var delayInputFilterCutoffFreqTrackingRatio: Knob!
    @IBOutlet weak var delayInputFilterResonance: Knob!
    
    @IBOutlet weak var freezeArpRate: ToggleButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Defaults, limits
        let s = conductor.synth!
        
        // masterVolume is the input gain to compressorMaster
        masterVolume.range = s.getParameterRange(.masterVolume)
        conductor.bind(masterVolume, to:.masterVolume)
        
        // reverb/master dynamics
        compressorMasterRatio.range      = s.getParameterRange(.compressorMasterRatio)
        compressorReverbInputRatio.range = s.getParameterRange(.compressorReverbInputRatio)
        compressorReverbWetRatio.range   = s.getParameterRange(.compressorReverbWetRatio)
        conductor.bind(compressorMasterRatio,      to: .compressorMasterRatio)
        conductor.bind(compressorReverbInputRatio, to: .compressorReverbInputRatio)
        conductor.bind(compressorReverbWetRatio,   to: .compressorReverbWetRatio)

        compressorMasterThreshold.range      = s.getParameterRange(.compressorMasterThreshold)
        compressorReverbInputThreshold.range = s.getParameterRange(.compressorReverbInputThreshold)
        compressorReverbWetThreshold.range   = s.getParameterRange(.compressorReverbWetThreshold)
        conductor.bind(compressorMasterThreshold,      to: .compressorMasterThreshold)
        conductor.bind(compressorReverbInputThreshold, to: .compressorReverbInputThreshold)
        conductor.bind(compressorReverbWetThreshold,   to: .compressorReverbWetThreshold)
        
        compressorMasterAttack.range       = s.getParameterRange(.compressorMasterAttack)
        compressorReverbInputAttack.range  = s.getParameterRange(.compressorReverbInputAttack)
        compressorReverbWetAttack.range    = s.getParameterRange(.compressorReverbWetAttack)
        conductor.bind(compressorMasterAttack,      to: .compressorMasterAttack)
        conductor.bind(compressorReverbInputAttack, to: .compressorReverbInputAttack)
        conductor.bind(compressorReverbWetAttack,   to: .compressorReverbWetAttack)

        compressorMasterRelease.range      = s.getParameterRange(.compressorMasterRelease)
        compressorReverbInputRelease.range = s.getParameterRange(.compressorReverbInputRelease)
        compressorReverbWetRelease.range   = s.getParameterRange(.compressorReverbWetRelease)
        conductor.bind(compressorMasterRelease,      to: .compressorMasterRelease)
        conductor.bind(compressorReverbInputRelease, to: .compressorReverbInputRelease)
        conductor.bind(compressorReverbWetRelease,   to: .compressorReverbWetRelease)
        
        compressorMasterMakeupGain.range      = s.getParameterRange(.compressorMasterMakeupGain)
        compressorReverbInputMakeupGain.range = s.getParameterRange(.compressorReverbInputMakeupGain)
        compressorReverbWetMakeupGain.range   = s.getParameterRange(.compressorReverbWetMakeupGain)
        conductor.bind(compressorMasterMakeupGain,      to: .compressorMasterMakeupGain)
        conductor.bind(compressorReverbInputMakeupGain, to: .compressorReverbInputMakeupGain)
        conductor.bind(compressorReverbWetMakeupGain,   to: .compressorReverbWetMakeupGain)
        
        //delay input filter
        delayInputFilterCutoffFreqTrackingRatio.range = s.getParameterRange(.delayInputCutoffTrackingRatio)
        delayInputFilterResonance.range =               s.getParameterRange(.delayInputResonance)
        conductor.bind(delayInputFilterCutoffFreqTrackingRatio, to: .delayInputCutoffTrackingRatio)
        conductor.bind(delayInputFilterResonance,               to: .delayInputResonance)
        
        // freeze arp rate
        freezeArpRate.callback = { value in
            let v = (value == 1 ? true : false)
            self.delegate?.freezeArpChanged(v)
        }
    }
}
