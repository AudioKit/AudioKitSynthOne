//
//  FXViewController.swift
//  AudioKitSynthOne
//
//  Created by Matthew Fecher on 7/26/17.
//  Copyright © 2017 AudioKit. All rights reserved.
//

import UIKit
import AudioKit

class FXViewController: SynthPanelController {

    @IBOutlet weak var lfoCutoffToggle: LfoButton!
    @IBOutlet weak var lfoRezToggle: LfoButton!
    @IBOutlet weak var lfoOscMixToggle: LfoButton!
    @IBOutlet weak var lfoSustainToggle: LfoButton!
 
    @IBOutlet weak var lfoFMModToggle: LfoButton!
    @IBOutlet weak var lfoDetuneToggle: LfoButton!
    @IBOutlet weak var lfoFilterEnvToggle: LfoButton!
    @IBOutlet weak var lfoPitchToggle: LfoButton!
    @IBOutlet weak var lfoBitcrushToggle: LfoButton!
    @IBOutlet weak var lfoAutoPanToggle: LfoButton!
    
    @IBOutlet weak var lfo1Amp: Knob!
    @IBOutlet weak var lfo1Rate: RateKnob!
    
    @IBOutlet weak var lfo2Amp: Knob!
    @IBOutlet weak var lfo2Rate: RateKnob!
    
    @IBOutlet weak var sampleRate: Knob!
    
    @IBOutlet weak var autoPanToggle: ToggleButton!
    @IBOutlet weak var autoPanRate: RateKnob!
    
    @IBOutlet weak var reverbSize: Knob!
    @IBOutlet weak var reverbLowCut: Knob!
    @IBOutlet weak var reverbMix: Knob!
    @IBOutlet weak var reverbToggle: ToggleButton!
    
    @IBOutlet weak var delayTime: Knob!
    @IBOutlet weak var delayFeedback: Knob!
    @IBOutlet weak var delayMix: Knob!
    @IBOutlet weak var delayToggle: ToggleButton!
    
    @IBOutlet weak var phaserMix: Knob!
    @IBOutlet weak var phaserRate: Knob!
    @IBOutlet weak var phaserFeedback: Knob!
    @IBOutlet weak var phaserNotchWidth: Knob!
    
    @IBOutlet weak var lfo1WavePicker: LFOWavePicker!
    @IBOutlet weak var lfo2WavePicker: LFOWavePicker!
    
    @IBOutlet weak var tempoSyncToggle: ToggleButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
     
        viewType = .fxView

        let s = conductor.synth!
        
        sampleRate.value = s.getParameterDefault(.bitCrushSampleRate)
        sampleRate.range = s.getParameterRange(.bitCrushSampleRate)
        sampleRate.taper = 5

        autoPanRate.range = s.getParameterRange(.autoPanFrequency)
        autoPanRate.taper = 2

        //reverbLowCut.range = 80 ... 900
        reverbLowCut.range = s.getParameterRange(.reverbHighPass)
        reverbLowCut.taper = 1

        delayFeedback.range = s.getParameterRange(.delayFeedback)
        delayTime.range = s.getParameterRange(.delayTime)

        lfo1Rate.range = s.getParameterRange(.lfo1Rate)
        lfo1Rate.taper = 3
        lfo2Rate.range = s.getParameterRange(.lfo2Rate)
        lfo2Rate.taper = 3
        
        phaserMix.range = s.getParameterRange(.phaserMix)
        phaserRate.range = s.getParameterRange(.phaserRate)
        phaserRate.taper = 2
        phaserFeedback.range = s.getParameterRange(.phaserFeedback)
        phaserNotchWidth.range = s.getParameterRange(.phaserNotchWidth)

        conductor.bind(sampleRate,         to: .bitCrushSampleRate)
        conductor.bind(autoPanToggle,      to: .autoPanOn)
        conductor.bind(autoPanRate,        to: .autoPanFrequency)
        conductor.bind(reverbSize,         to: .reverbFeedback)
        conductor.bind(reverbLowCut,       to: .reverbHighPass)
        conductor.bind(reverbMix,          to: .reverbMix)
        conductor.bind(reverbToggle,       to: .reverbOn)
        conductor.bind(delayTime,          to: .delayTime)
        conductor.bind(delayFeedback,      to: .delayFeedback)
        conductor.bind(delayMix,           to: .delayMix)
        conductor.bind(delayToggle,        to: .delayOn)
        conductor.bind(lfo1Amp,            to: .lfo1Amplitude)
        conductor.bind(lfo1Rate,           to: .lfo1Rate)
        conductor.bind(lfo2Amp,            to: .lfo2Amplitude)
        conductor.bind(lfo2Rate,           to: .lfo2Rate)
        conductor.bind(lfoCutoffToggle,    to: .cutoffLFO)
        conductor.bind(lfoRezToggle,       to: .resonanceLFO)
        conductor.bind(lfoOscMixToggle,    to: .oscMixLFO)
        conductor.bind(lfoSustainToggle,   to: .sustainLFO)
        conductor.bind(lfoFMModToggle,     to: .fmLFO)
        conductor.bind(lfoDetuneToggle,    to: .detuneLFO)
        conductor.bind(lfoFilterEnvToggle, to: .filterEnvLFO)
        conductor.bind(lfoPitchToggle,     to: .pitchLFO)
        conductor.bind(lfoBitcrushToggle,  to: .bitcrushLFO)
        conductor.bind(lfoAutoPanToggle,   to: .autopanLFO)
        conductor.bind(lfo1WavePicker,     to: .lfo1Index)
        conductor.bind(lfo2WavePicker,     to: .lfo2Index)
        conductor.bind(phaserMix,          to: .phaserMix)
        conductor.bind(phaserRate,         to: .phaserRate)
        conductor.bind(phaserFeedback,     to: .phaserFeedback)
        conductor.bind(phaserNotchWidth,   to: .phaserNotchWidth)

        tempoSyncToggle.callback = { value in
            self.conductor.syncRatesToTempo = (value == 1)
            self.lfo1Rate.update()
            self.lfo2Rate.update()
            self.autoPanRate.update()
        }
    }
}
