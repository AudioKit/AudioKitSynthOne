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
    
    // app setting (not dsp param)
    func freezeArpRateChanged(_ value: Bool)
    func getFreezeArpRateChangedValue() -> Bool
    
    // app setting (not dsp param)
    func freezeReverbChanged(_ value: Bool)
    func getFreezeReverbChangedValue() -> Bool
    
    // app setting (not dsp param)
    func freezeDelayChanged(_ value: Bool)
    func getFreezeDelayChangedValue() -> Bool
    
    // app setting (not dsp param)
    func dspParamPortamentoHalfTimeChanged(_ value: Float)
    func getDspParamPortamentoHalfTimeValue() -> Float
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
    @IBOutlet weak var freezeReverb: ToggleButton!
    @IBOutlet weak var freezeDelay: ToggleButton!

    @IBOutlet weak var dspParamPortamentoHalfTime: Knob!
    
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
        
        // freeze arp rate, i.e., ignore Preset updates
        if let value = delegate?.getFreezeArpRateChangedValue() {
            freezeArpRate.value = value ? 1 : 0
        }
        freezeArpRate.callback = { value in
            self.delegate?.freezeArpRateChanged(value == 1 ? true : false)
        }
        
        // freeze delay time, i.e., ignore Preset updates
        if let value = delegate?.getFreezeDelayChangedValue() {
            freezeDelay.value = value ? 1 : 0
        }
        freezeDelay.callback = { value in
            self.delegate?.freezeDelayChanged(value == 1 ? true : false)
        }
        
        // freeze reverb, i.e., ignore Preset updates
        if let value = delegate?.getFreezeReverbChangedValue() {
            freezeReverb.value = value ? 1 : 0
        }
        freezeReverb.callback = { value in
            self.delegate?.freezeReverbChanged(value == 1 ? true : false)
        }
        
        //dspParamPortamentoHalfTime
        dspParamPortamentoHalfTime.range = conductor.synth!.getParameterRange(.dspParamPortamentoHalfTime)
        if let value = delegate?.getDspParamPortamentoHalfTimeValue() {
            dspParamPortamentoHalfTime.value = Double(value)
        }
        dspParamPortamentoHalfTime.callback = { value in
            self.delegate?.dspParamPortamentoHalfTimeChanged(Float(value))
            self.conductor.updateSingleUI(.dspParamPortamentoHalfTime, control: self.dspParamPortamentoHalfTime, value: value)
        }
    }
}
