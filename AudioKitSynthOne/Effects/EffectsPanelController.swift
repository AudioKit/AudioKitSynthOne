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

    @IBOutlet weak var lfo1AmpKnob: MIDIKnob!
    @IBOutlet weak var lfo1RateKnob: MIDIKnob!

    @IBOutlet weak var lfo2AmpKnob: MIDIKnob!
    @IBOutlet weak var lfo2RateKnob: MIDIKnob!

    @IBOutlet weak var sampleRateKnob: MIDIKnob!

    @IBOutlet weak var autoPanAmountKnob: MIDIKnob!
    @IBOutlet weak var autoPanRateKnob: MIDIKnob!

    @IBOutlet weak var reverbSizeKnob: MIDIKnob!
    @IBOutlet weak var reverbLowCutKnob: MIDIKnob!
    @IBOutlet weak var reverbMixKnob: MIDIKnob!
    @IBOutlet weak var reverbToggle: ToggleButton!

    @IBOutlet weak var delayTimeKnob: MIDIKnob!
    @IBOutlet weak var delayFeedbackKnob: MIDIKnob!
    @IBOutlet weak var delayMixKnob: MIDIKnob!
    @IBOutlet weak var delayToggle: ToggleButton!

    @IBOutlet weak var phaserMixKnob: MIDIKnob!
    @IBOutlet weak var phaserRateKnob: MIDIKnob!
    @IBOutlet weak var phaserFeedbackKnob: MIDIKnob!
    @IBOutlet weak var phaserNotchWidthKnob: MIDIKnob!

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

        sampleRateKnob.range = s.getRange(.bitCrushSampleRate)
        sampleRateKnob.taper = 4.6
        conductor.bind(sampleRateKnob, to: .bitCrushSampleRate)

        reverbLowCutKnob.range = s.getRange(.reverbHighPass)
        reverbLowCutKnob.taper = 1
        conductor.bind(reverbLowCutKnob, to: .reverbHighPass)

        delayFeedbackKnob.range = s.getRange(.delayFeedback)
        conductor.bind(delayFeedbackKnob, to: .delayFeedback)

        phaserMixKnob.range = s.getRange(.phaserMix)
        phaserRateKnob.range = s.getRange(.phaserRate)
        phaserRateKnob.taper = 2
        phaserFeedbackKnob.range = s.getRange(.phaserFeedback)
        phaserNotchWidthKnob.range = s.getRange(.phaserNotchWidth)

        conductor.bind(autoPanAmountKnob, to: .autoPanAmount)
        conductor.bind(reverbSizeKnob, to: .reverbFeedback)
        conductor.bind(reverbMixKnob, to: .reverbMix)
        conductor.bind(reverbToggle, to: .reverbOn)
        conductor.bind(delayMixKnob, to: .delayMix)
        conductor.bind(delayToggle, to: .delayOn)
        conductor.bind(lfo1AmpKnob, to: .lfo1Amplitude)
        conductor.bind(lfo2AmpKnob, to: .lfo2Amplitude)
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
        conductor.bind(phaserMixKnob, to: .phaserMix)
        conductor.bind(phaserRateKnob, to: .phaserRate)
        conductor.bind(phaserFeedbackKnob, to: .phaserFeedback)
        conductor.bind(phaserNotchWidthKnob, to: .phaserNotchWidth)
        conductor.bind(tempoSyncToggle, to: .tempoSyncToArpRate)

        // These 4 params are dependent on arpRate, and tempoSyncToArpRate, so can't use conductor binding scheme
        lfo1RateKnob.range = 0...1
        lfo1RateKnob.taper = 1
        lfo1RateKnob.value = s.getDependentParameter(.lfo1Rate)
        lfo1RateKnob.callback = { value in
            s.setDependentParameter(.lfo1Rate, value, self.conductor.lfo1RateEffectsPanelID)
            self.conductor.updateDisplayLabel(.lfo1Rate, value: s.getSynthParameter(.lfo1Rate))
        }

        lfo2RateKnob.range = 0...1
        lfo2RateKnob.taper = 1
        lfo2RateKnob.value = s.getDependentParameter(.lfo2Rate)
        lfo2RateKnob.callback = { value in
            s.setDependentParameter(.lfo2Rate, value, self.conductor.lfo2RateEffectsPanelID)
            self.conductor.updateDisplayLabel(.lfo2Rate, value: s.getSynthParameter(.lfo2Rate))
        }

        autoPanRateKnob.range = 0...1
        autoPanRateKnob.taper = 1
        autoPanRateKnob.value = s.getDependentParameter(.autoPanFrequency)
        autoPanRateKnob.callback = { value in
            s.setDependentParameter(.autoPanFrequency, value, self.conductor.autoPanEffectsPanelID)
            self.conductor.updateDisplayLabel(.autoPanFrequency, value: s.getSynthParameter(.autoPanFrequency))
        }

        delayTimeKnob.range = 0...1
        delayTimeKnob.taper = 1
        delayTimeKnob.value = s.getDependentParameter(.delayTime)
        delayTimeKnob.callback = { value in
            s.setDependentParameter(.delayTime, value, self.conductor.delayTimeEffectsPanelID)
            self.conductor.updateDisplayLabel(.delayTime, value: s.getSynthParameter(.delayTime))
        }


		view.accessibilityElements = [
			lfo1WavePicker!,
			lfo1RateKnob!,
			lfo1AmpKnob!,
			lfo2WavePicker!,
			lfo2RateKnob!,
			lfo2AmpKnob!,
			cutoffLFOToggle!,
			resonanceLFOToggle!,
			oscMixLFOToggle!,
			reverbMixLFOToggle!,
			decayLFOToggle!,
			noiseLFOToggle!,
			fmModLFOToggle!,
			detuneLFOToggle!,
			filterEnvLFOToggle!,
			pitchLFOToggle!,
			bitcrushLFOToggle!,
			tremoloLFOToggle!,
			tempoSyncToggle!,
			sampleRateKnob!,
			autoPanRateKnob!,
			autoPanAmountKnob!,
			reverbToggle!,
			reverbSizeKnob!,
			reverbLowCutKnob!,
			reverbMixKnob!,
			delayToggle!,
			delayTimeKnob!,
			delayFeedbackKnob!,
			delayMixKnob!,
			phaserRateKnob!,
			phaserNotchWidthKnob!,
			phaserFeedbackKnob!,
			phaserMixKnob!,
			leftNavButton!,
			rightNavButton!
		]
    }

    func dependentParameterDidChange(_ dependentParameter: DependentParameter) {
        switch dependentParameter.parameter {
        case .lfo1Rate:
            if dependentParameter.payload == conductor.lfo1RateEffectsPanelID {
                return
            }
            lfo1RateKnob.value = Double(dependentParameter.normalizedValue)
        case .lfo2Rate:
            if dependentParameter.payload == conductor.lfo2RateEffectsPanelID {
                return
            }
            lfo2RateKnob.value = Double(dependentParameter.normalizedValue)
        case .autoPanFrequency:
            if dependentParameter.payload == conductor.autoPanEffectsPanelID {
                return
            }
            autoPanRateKnob.value = Double(dependentParameter.normalizedValue)
        case .delayTime:
            if dependentParameter.payload == conductor.delayTimeEffectsPanelID {
                return
            }
            delayTimeKnob.value = Double(dependentParameter.normalizedValue)
        default:
            _ = 0
        }
    }
}
