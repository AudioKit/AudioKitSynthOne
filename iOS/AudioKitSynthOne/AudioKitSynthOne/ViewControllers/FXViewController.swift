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
    @IBOutlet weak var lfoSustainToggle: LfoButton!
    @IBOutlet weak var lfoMorph1Toggle: LfoButton!
    @IBOutlet weak var lfoMorph2Toggle: LfoButton!
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
    
    @IBOutlet weak var lfo1WavePicker: LFOWavePicker!
    @IBOutlet weak var lfo2WavePicker: LFOWavePicker!
    
    @IBOutlet weak var tempoSyncToggle: ToggleButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
     
        // Set Default LFO routing
/*
        bitCrush.value = 24
        bitCrush.range = 1 ... 24
        bitCrush.taper = 2
*/
        sampleRate.value = 44100
        sampleRate.range = 400 ... 44100
        sampleRate.taper = 5

        autoPanRate.range = 0 ... 10

        reverbLowCut.range = 10 ... 1000
        reverbLowCut.taper = 1

        delayFeedback.range = 0 ... 0.6
        delayTime.range = 0.01 ... 1.5

        lfo1Rate.range = 0 ... 10
        lfo1Rate.taper = 3
        lfo2Rate.range = 0 ... 10

      //  conductor.bind(bitCrush,           to: .bitCrushDepth)
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
        conductor.bind(lfoMorph1Toggle,    to: .index1LFO)
        conductor.bind(lfoMorph2Toggle,    to: .index2LFO)
        conductor.bind(lfoFMModToggle,     to: .fmLFO)
        conductor.bind(lfoDetuneToggle,    to: .detuneLFO)
        conductor.bind(lfoFilterEnvToggle, to: .filterEnvLFO)
        conductor.bind(lfoPitchToggle,     to: .pitchLFO)
        conductor.bind(lfoBitcrushToggle,  to: .bitcrushLFO)
        conductor.bind(lfoAutoPanToggle,   to: .autopanLFO)

        conductor.bind(lfo1WavePicker, to: .lfo1Index)
        conductor.bind(lfo2WavePicker, to: .lfo2Index)


        tempoSyncToggle.callback = { value in
            self.conductor.syncRatesToTempo = value == 1 ? true : false
            self.lfo1Rate.update()
            self.lfo2Rate.update()
            self.autoPanRate.update()

        }

        updateCallbacks()
    }

}
