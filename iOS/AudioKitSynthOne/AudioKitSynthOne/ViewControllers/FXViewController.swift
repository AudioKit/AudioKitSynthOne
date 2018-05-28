//
//  FXViewController.swift
//  AudioKitSynthOne
//
//  Created by Matthew Fecher on 7/26/17.
//  Copyright © 2017 AudioKit. All rights reserved.
//

import UIKit

class FXViewController: SynthPanelController {

    @IBOutlet weak var lfoCutoffToggle: LfoButton!
    @IBOutlet weak var lfoRezToggle: LfoButton!
    @IBOutlet weak var lfoOscMixToggle: LfoButton!
    @IBOutlet weak var lfoReverbMixToggle: LfoButton!
    @IBOutlet weak var lfoDecayToggle: LfoButton!
    @IBOutlet weak var lfoNoiseToggle: LfoButton!
    @IBOutlet weak var lfoFMModToggle: LfoButton!
    @IBOutlet weak var lfoDetuneToggle: LfoButton!
    @IBOutlet weak var lfoFilterEnvToggle: LfoButton!
    @IBOutlet weak var lfoPitchToggle: LfoButton!
    @IBOutlet weak var lfoBitcrushToggle: LfoButton!
    @IBOutlet weak var lfoTremoloToggle: LfoButton!

    @IBOutlet weak var lfo1Amp: MIDIKnob!
    @IBOutlet weak var lfo1Rate: MIDIKnob!

    @IBOutlet weak var lfo2Amp: MIDIKnob!
    @IBOutlet weak var lfo2Rate: MIDIKnob!

    @IBOutlet weak var sampleRate: MIDIKnob!

    @IBOutlet weak var autoPanAmount: Knob!
    @IBOutlet weak var autoPanRate: MIDIKnob!

    @IBOutlet weak var reverbSize: MIDIKnob!
    @IBOutlet weak var reverbLowCut: MIDIKnob!
    @IBOutlet weak var reverbMix: MIDIKnob!
    @IBOutlet weak var reverbToggle: ToggleButton!

    @IBOutlet weak var delayTime: MIDIKnob!
    @IBOutlet weak var delayFeedback: MIDIKnob!
    @IBOutlet weak var delayMix: MIDIKnob!
    @IBOutlet weak var delayToggle: ToggleButton!

    @IBOutlet weak var phaserMix: MIDIKnob!
    @IBOutlet weak var phaserRate: MIDIKnob!
    @IBOutlet weak var phaserFeedback: MIDIKnob!
    @IBOutlet weak var phaserNotchWidth: MIDIKnob!

    @IBOutlet weak var lfo1WavePicker: LFOWavePicker!
    @IBOutlet weak var lfo2WavePicker: LFOWavePicker!

    @IBOutlet weak var tempoSyncToggle: ToggleButton!

    override func viewDidLoad() {
        super.viewDidLoad()

        viewType = .fxView
        guard let s = conductor.synth else {
            AKLog("FXViewController view state is invalid because synth is not instantiated")
            return
        }

        sampleRate.range = s.getRange(.bitCrushSampleRate)
        sampleRate.taper = 4.6
        conductor.bind(sampleRate, to: .bitCrushSampleRate)

        reverbLowCut.range = s.getRange(.reverbHighPass)
        reverbLowCut.taper = 1
        conductor.bind(reverbLowCut, to: .reverbHighPass)

        delayFeedback.range = s.getRange(.delayFeedback)
        conductor.bind(delayFeedback, to: .delayFeedback)

        phaserMix.range = s.getRange(.phaserMix)
        phaserRate.range = s.getRange(.phaserRate)
        phaserRate.taper = 2
        phaserFeedback.range = s.getRange(.phaserFeedback)
        phaserNotchWidth.range = s.getRange(.phaserNotchWidth)

        conductor.bind(autoPanAmount, to: .autoPanAmount)
        conductor.bind(reverbSize, to: .reverbFeedback)
        conductor.bind(reverbMix, to: .reverbMix)
        conductor.bind(reverbToggle, to: .reverbOn)
        conductor.bind(delayMix, to: .delayMix)
        conductor.bind(delayToggle, to: .delayOn)
        conductor.bind(lfo1Amp, to: .lfo1Amplitude)
        conductor.bind(lfo2Amp, to: .lfo2Amplitude)
        conductor.bind(lfoCutoffToggle, to: .cutoffLFO)
        conductor.bind(lfoRezToggle, to: .resonanceLFO)
        conductor.bind(lfoOscMixToggle, to: .oscMixLFO)
        conductor.bind(lfoReverbMixToggle, to: .reverbMixLFO)
        conductor.bind(lfoDecayToggle, to: .decayLFO)
        conductor.bind(lfoNoiseToggle, to: .noiseLFO)
        conductor.bind(lfoFMModToggle, to: .fmLFO)
        conductor.bind(lfoDetuneToggle, to: .detuneLFO)
        conductor.bind(lfoFilterEnvToggle, to: .filterEnvLFO)
        conductor.bind(lfoPitchToggle, to: .pitchLFO)
        conductor.bind(lfoBitcrushToggle, to: .bitcrushLFO)
        conductor.bind(lfoTremoloToggle, to: .tremoloLFO)
        conductor.bind(lfo1WavePicker, to: .lfo1Index)
        conductor.bind(lfo2WavePicker, to: .lfo2Index)
        conductor.bind(phaserMix, to: .phaserMix)
        conductor.bind(phaserRate, to: .phaserRate)
        conductor.bind(phaserFeedback, to: .phaserFeedback)
        conductor.bind(phaserNotchWidth, to: .phaserNotchWidth)
        conductor.bind(tempoSyncToggle, to: .tempoSyncToArpRate)

        // These 4 params are dependent on arpRate, and tempoSyncToArpRate, so can't use conductor binding scheme
        lfo1Rate.range = 0...1
        lfo1Rate.taper = 1
        lfo1Rate.value = s.getDependentParameter(.lfo1Rate)
        lfo1Rate.callback = { value in
            s.setDependentParameter(.lfo1Rate, value, self.conductor.lfo1RateFXPanelID)
            self.conductor.updateDisplayLabel(.lfo1Rate, value: s.getSynthParameter(.lfo1Rate))
        }

        lfo2Rate.range = 0...1
        lfo2Rate.taper = 1
        lfo2Rate.value = s.getDependentParameter(.lfo2Rate)
        lfo2Rate.callback = { value in
            s.setDependentParameter(.lfo2Rate, value, self.conductor.lfo2RateFXPanelID)
            self.conductor.updateDisplayLabel(.lfo2Rate, value: s.getSynthParameter(.lfo2Rate))
        }

        autoPanRate.range = 0...1
        autoPanRate.taper = 1
        autoPanRate.value = s.getDependentParameter(.autoPanFrequency)
        autoPanRate.callback = { value in
            s.setDependentParameter(.autoPanFrequency, value, self.conductor.autoPanFXPanelID)
            self.conductor.updateDisplayLabel(.autoPanFrequency, value: s.getSynthParameter(.autoPanFrequency))
        }

        delayTime.range = 0...1
        delayTime.taper = 1
        delayTime.value = s.getDependentParameter(.delayTime)
        delayTime.callback = { value in
            s.setDependentParameter(.delayTime, value, self.conductor.delayTimeFXPanelID)
            self.conductor.updateDisplayLabel(.delayTime, value: s.getSynthParameter(.delayTime))
        }
    }

    func dependentParamDidChange(_ param: DependentParam) {
        switch param.param {
        case .lfo1Rate:
            if param.payload == conductor.lfo1RateFXPanelID {
                return
            }
            lfo1Rate.value = Double(param.value01)
        case .lfo2Rate:
            if param.payload == conductor.lfo2RateFXPanelID {
                return
            }
            lfo2Rate.value = Double(param.value01)
        case .autoPanFrequency:
            if param.payload == conductor.autoPanFXPanelID {
                return
            }
            autoPanRate.value = Double(param.value01)
        case .delayTime:
            if param.payload == conductor.delayTimeFXPanelID {
                return
            }
            delayTime.value = Double(param.value01)
        default:
            _ = 0
        }
    }
}
