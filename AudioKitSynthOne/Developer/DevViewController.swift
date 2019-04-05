//
//  DevViewController.swift
//  AudioKitSynthOne
//
//  Created by AudioKit Contributors on 12/2/17.
//  Copyright © 2017 AudioKit. All rights reserved.
//

import AudioKit
import UIKit

protocol DevViewDelegate: AnyObject {

    func freezeArpRateChanged(_ value: Bool)

    func freezeReverbChanged(_ value: Bool)

    func freezeDelayChanged(_ value: Bool)

    func freezeArpSeqChanged(_ value: Bool)

    func portamentoChanged(_ value: Double)

    func whiteKeysOnlyChanged(_ value: Bool)
}

class DevViewController: UpdatableViewController {

    @IBOutlet weak var backgroundImage: UIImageView!

    weak var delegate: DevViewDelegate?

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

    var freezeArpRateValue = false

    @IBOutlet weak var freezeReverb: ToggleButton!

    var freezeReverbValue = false

    @IBOutlet weak var freezeDelay: ToggleButton!

    var freezeDelayValue = false

    @IBOutlet weak var freezeArpSeq: ToggleButton!

    var freezeArpSeqValue = false

    @IBOutlet weak var whiteKeysOnly: ToggleButton!

    var whiteKeysOnlyValue = false

    @IBOutlet weak var portamento: Knob!

    var portamentoHalfTime = 0.1

    override func viewDidLoad() {
        super.viewDidLoad()

        // Defaults, limits
        guard let s = conductor.synth else {
            AKLog("DevViewController view state is invalid because synth is not instantiated")
            return
        }

        backgroundImage.isHidden = false
        backgroundImage.alpha = 0.15

        // masterVolume is the input gain to compressorMaster
        masterVolume.range = s.getRange(.masterVolume)
        conductor.bind(masterVolume, to: .masterVolume)

        // reverb/master dynamics
        compressorMasterRatio.range = s.getRange(.compressorMasterRatio)
        compressorReverbInputRatio.range = s.getRange(.compressorReverbInputRatio)
        compressorReverbWetRatio.range = s.getRange(.compressorReverbWetRatio)
        conductor.bind(compressorMasterRatio, to: .compressorMasterRatio)
        conductor.bind(compressorReverbInputRatio, to: .compressorReverbInputRatio)
        conductor.bind(compressorReverbWetRatio, to: .compressorReverbWetRatio)
        compressorMasterThreshold.range = s.getRange(.compressorMasterThreshold)
        compressorReverbInputThreshold.range = s.getRange(.compressorReverbInputThreshold)
        compressorReverbWetThreshold.range = s.getRange(.compressorReverbWetThreshold)
        conductor.bind(compressorMasterThreshold, to: .compressorMasterThreshold)
        conductor.bind(compressorReverbInputThreshold, to: .compressorReverbInputThreshold)
        conductor.bind(compressorReverbWetThreshold, to: .compressorReverbWetThreshold)
        compressorMasterAttack.range = s.getRange(.compressorMasterAttack)
        compressorReverbInputAttack.range = s.getRange(.compressorReverbInputAttack)
        compressorReverbWetAttack.range = s.getRange(.compressorReverbWetAttack)
        conductor.bind(compressorMasterAttack, to: .compressorMasterAttack)
        conductor.bind(compressorReverbInputAttack, to: .compressorReverbInputAttack)
        conductor.bind(compressorReverbWetAttack, to: .compressorReverbWetAttack)
        compressorMasterRelease.range = s.getRange(.compressorMasterRelease)
        compressorReverbInputRelease.range = s.getRange(.compressorReverbInputRelease)
        compressorReverbWetRelease.range = s.getRange(.compressorReverbWetRelease)
        conductor.bind(compressorMasterRelease, to: .compressorMasterRelease)
        conductor.bind(compressorReverbInputRelease, to: .compressorReverbInputRelease)
        conductor.bind(compressorReverbWetRelease, to: .compressorReverbWetRelease)
        compressorMasterMakeupGain.range = s.getRange(.compressorMasterMakeupGain)
        compressorReverbInputMakeupGain.range = s.getRange(.compressorReverbInputMakeupGain)
        compressorReverbWetMakeupGain.range = s.getRange(.compressorReverbWetMakeupGain)
        conductor.bind(compressorMasterMakeupGain, to: .compressorMasterMakeupGain)
        conductor.bind(compressorReverbInputMakeupGain, to: .compressorReverbInputMakeupGain)
        conductor.bind(compressorReverbWetMakeupGain, to: .compressorReverbWetMakeupGain)

        //delay input filter
        delayInputFilterCutoffFreqTrackingRatio.range = s.getRange(.delayInputCutoffTrackingRatio)
        delayInputFilterResonance.range = s.getRange(.delayInputResonance)
        conductor.bind(delayInputFilterCutoffFreqTrackingRatio, to: .delayInputCutoffTrackingRatio)
        conductor.bind(delayInputFilterResonance, to: .delayInputResonance)

        // This is musically useful when you have a tempo you like and want
        // to keep it as you browse presets
        // freeze arp rate, i.e., ignore Preset updates
        #if ABLETON_ENABLED_1
            let freezeIt = freezeArpRateValue || ABLLinkManager.shared.isConnected || ABLLinkManager.shared.isEnabled
        #else
            let freezeIt = freezeArpRateValue
        #endif

        // freeze tempo: ignore Preset updates
        freezeArpRate.value = freezeIt ? 1 : 0
        freezeArpRate.callback = { value in
            self.delegate?.freezeArpRateChanged(value == 1 ? true : false)
        }

        // freeze delay time: ignore Preset updates
        freezeDelay.value = freezeDelayValue ? 1 : 0
        freezeDelay.callback = { value in
            self.delegate?.freezeDelayChanged(value == 1 ? true : false)
        }

        // freeze reverb: ignore Preset updates
        freezeReverb.value = freezeReverbValue ? 1 : 0
        freezeReverb.callback = { value in
            self.delegate?.freezeReverbChanged(value == 1 ? true : false)
        }

        // This is musically useful when you have an arp that you like and want to hear it
        // when you browse presets:
        // freeze arp+sequencer: ignore Preset updates for the following parameters:
        // arpIsOn
        // arpIsSequencer
        // arpDirection
        // arpInterval
        // arpOctave
        // arpTotalSteps
        // sequencerPattern00, ..., sequencerPattern15
        // sequencerOctBoost00, ..., sequencerOctBoost15
        // sequencerNoteOn00, ..., sequencerNoteOn15
        freezeArpSeq.value = freezeArpSeqValue ? 1 : 0
        freezeArpSeq.callback = { value in
            self.delegate?.freezeArpSeqChanged(value == 1 ? true : false)
        }

        // portamentoHalfTime (dsp parameter stored in app settings not presets)
        portamento.range = s.getRange(.portamentoHalfTime)
        portamento.value = portamentoHalfTime
        portamento.callback = { value in
            self.delegate?.portamentoChanged(value)
        }

        whiteKeysOnly.callback = { value in
            self.delegate?.whiteKeysOnlyChanged(value == 1 ? true : false)
        }

        setupLinkStuff()
    }
}
