//
//  EffectsPanelController.swift
//  AudioKitSynthOne
//
//  Created by AudioKit Contributors on 7/26/17.
//  Copyright © 2017 AudioKit. All rights reserved.
//

import UIKit

class EffectsPanelController: PanelController {

    @IBOutlet weak var cutoffLFOToggle: LFOToggle!
    @IBOutlet weak var resonanceLFOToggle: LFOToggle!
    @IBOutlet weak var oscMixLFOToggle: LFOToggle!
    @IBOutlet weak var reverbMixLFOToggle: LFOToggle!
    @IBOutlet weak var decayLFOToggle: LFOToggle!
    @IBOutlet weak var noiseLFOToggle: LFOToggle!
    @IBOutlet weak var fmModLFOToggle: LFOToggle!
    @IBOutlet weak var detuneLFOToggle: LFOToggle!
    @IBOutlet weak var filterEnvLFOToggle: LFOToggle!
    @IBOutlet weak var pitchLFOToggle: LFOToggle!
    @IBOutlet weak var bitcrushLFOToggle: LFOToggle!
    @IBOutlet weak var tremoloLFOToggle: LFOToggle!

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

        currentPanel = .effects
        guard let s = conductor.synth else {
            AKLog("EffectsPanel view state is invalid because synth is not instantiated")
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
        conductor.bind(cutoffLFOToggle, to: .cutoffLFO)
        conductor.bind(resonanceLFOToggle, to: .resonanceLFO)
        conductor.bind(oscMixLFOToggle, to: .oscMixLFO)
        conductor.bind(reverbMixLFOToggle, to: .reverbMixLFO)
        conductor.bind(decayLFOToggle, to: .decayLFO)
        conductor.bind(noiseLFOToggle, to: .noiseLFO)
        conductor.bind(fmModLFOToggle, to: .fmLFO)
        conductor.bind(detuneLFOToggle, to: .detuneLFO)
        conductor.bind(filterEnvLFOToggle, to: .filterEnvLFO)
        conductor.bind(pitchLFOToggle, to: .pitchLFO)
        conductor.bind(bitcrushLFOToggle, to: .bitcrushLFO)
        conductor.bind(tremoloLFOToggle, to: .tremoloLFO)
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
            s.setDependentParameter(.lfo1Rate, value, self.conductor.lfo1RateEffectsPanelID)
            self.conductor.updateDisplayLabel(.lfo1Rate, value: s.getSynthParameter(.lfo1Rate))
        }

        lfo2Rate.range = 0...1
        lfo2Rate.taper = 1
        lfo2Rate.value = s.getDependentParameter(.lfo2Rate)
        lfo2Rate.callback = { value in
            s.setDependentParameter(.lfo2Rate, value, self.conductor.lfo2RateEffectsPanelID)
            self.conductor.updateDisplayLabel(.lfo2Rate, value: s.getSynthParameter(.lfo2Rate))
        }

        autoPanRate.range = 0...1
        autoPanRate.taper = 1
        autoPanRate.value = s.getDependentParameter(.autoPanFrequency)
        autoPanRate.callback = { value in
            s.setDependentParameter(.autoPanFrequency, value, self.conductor.autoPanEffectsPanelID)
            self.conductor.updateDisplayLabel(.autoPanFrequency, value: s.getSynthParameter(.autoPanFrequency))
        }

        delayTime.range = 0...1
        delayTime.taper = 1
        delayTime.value = s.getDependentParameter(.delayTime)
        delayTime.callback = { value in
            s.setDependentParameter(.delayTime, value, self.conductor.delayTimeEffectsPanelID)
            self.conductor.updateDisplayLabel(.delayTime, value: s.getSynthParameter(.delayTime))
        }
    }

    func dependentParameterDidChange(_ dependentParameter: DependentParameter) {
        switch dependentParameter.parameter {
        case .lfo1Rate:
            if dependentParameter.payload == conductor.lfo1RateEffectsPanelID {
                return
            }
            lfo1Rate.value = Double(dependentParameter.normalizedValue)
        case .lfo2Rate:
            if dependentParameter.payload == conductor.lfo2RateEffectsPanelID {
                return
            }
            lfo2Rate.value = Double(dependentParameter.normalizedValue)
        case .autoPanFrequency:
            if dependentParameter.payload == conductor.autoPanEffectsPanelID {
                return
            }
            autoPanRate.value = Double(dependentParameter.normalizedValue)
        case .delayTime:
            if dependentParameter.payload == conductor.delayTimeEffectsPanelID {
                return
            }
            delayTime.value = Double(dependentParameter.normalizedValue)
        default:
            _ = 0
        }
    }
}
