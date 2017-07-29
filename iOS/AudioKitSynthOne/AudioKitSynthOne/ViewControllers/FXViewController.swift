//
//  FXViewController.swift
//  AudioKitSynthOne
//
//  Created by Matthew Fecher on 7/26/17.
//  Copyright © 2017 AudioKit. All rights reserved.
//

import UIKit

class FXViewController: UpdatableViewController {
    

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
    @IBOutlet weak var lfo1Rate: Knob!
    
    @IBOutlet weak var lfo2Amp: Knob!
    @IBOutlet weak var lfo2Rate: Knob!
    
    @IBOutlet weak var bitCrush: Knob!
    @IBOutlet weak var sampleRate: Knob!
    
    @IBOutlet weak var autoPanToggle: ToggleButton!
    @IBOutlet weak var autoPanRate: Knob!
    
    @IBOutlet weak var reverbSize: Knob!
    @IBOutlet weak var reverbLowCut: Knob!
    @IBOutlet weak var reverbMix: Knob!
    @IBOutlet weak var reverbToggle: ToggleButton!
    
    @IBOutlet weak var delayTime: Knob!
    @IBOutlet weak var delayFeedback: Knob!
    @IBOutlet weak var delayMix: Knob!
    @IBOutlet weak var delayToggle: ToggleButton!
    

    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Set Default LFO routing
       
 
        bitCrush.value = 24
        bitCrush.range = 1 ... 24
        bitCrush.taper = 2

        sampleRate.value = 44100
        sampleRate.range = 400 ... 44100
        sampleRate.taper = 5

        autoPanRate.range = 0 ... 10

        reverbLowCut.range = 10 ... 1000
        reverbLowCut.taper = 1

        delayFeedback.range = 0 ... 0.6
        delayTime.range = 0.01 ... 1.5

        lfo1Rate.range = 0 ... 10
        lfo1Rate.taper = 4
        lfo2Rate.range = 0 ... 10

        updateCallbacks()
    }
    
    override func updateCallbacks() {

        bitCrush.callback = conductor.changeParameter(.bitCrushDepth)
        sampleRate.callback = conductor.changeParameter(.bitCrushSampleRate)
        autoPanToggle.callback = conductor.changeParameter(.autoPanOn)
        autoPanRate.callback = conductor.changeParameter(.autoPanFrequency)

        reverbSize.callback = conductor.changeParameter(.reverbFeedback)
        reverbLowCut.callback = conductor.changeParameter(.reverbHighPass)
        reverbMix.callback = conductor.changeParameter(.reverbMix)
        reverbToggle.callback = conductor.changeParameter(.reverbOn)

        delayTime.callback = conductor.changeParameter(.delayTime)
        delayFeedback.callback = conductor.changeParameter(.delayFeedback)
        delayMix.callback = conductor.changeParameter(.delayMix)
        delayToggle.callback = conductor.changeParameter(.delayOn)

        lfo1Amp.callback  = conductor.changeParameter(.lfo1Amplitude)
        lfo1Rate.callback = conductor.changeParameter(.lfo1Rate)
        lfo2Amp.callback = conductor.changeParameter(.lfo2Amplitude)
        lfo2Rate.callback = conductor.changeParameter(.lfo2Rate)

        lfoCutoffToggle.callback = conductor.changeParameter(.cutoffLFO)
        lfoRezToggle.callback = conductor.changeParameter(.resonanceLFO)
        lfoOscMixToggle.callback = conductor.changeParameter(.oscMixLFO)
        lfoSustainToggle.callback = conductor.changeParameter(.sustainLFO)
        lfoMorph1Toggle.callback = conductor.changeParameter(.index1LFO)
        lfoMorph2Toggle.callback = conductor.changeParameter(.index2LFO)
        lfoFMModToggle.callback = conductor.changeParameter(.fmLFO)
        lfoDetuneToggle.callback = conductor.changeParameter(.detuneLFO)
        lfoFilterEnvToggle.callback = conductor.changeParameter(.filterEnvLFO)
        lfoPitchToggle.callback = conductor.changeParameter(.pitchLFO)
        lfoBitcrushToggle.callback = conductor.changeParameter(.bitcrushLFO)
        lfoAutoPanToggle.callback = conductor.changeParameter(.autopanLFO)

    }
    
    override func updateUI(_ param: AKSynthOneParameter, value: Double) {

        switch param {
        case .bitCrushDepth:
            bitCrush.value = value
        case .bitCrushSampleRate:
            sampleRate.value = value
        case .autoPanOn:
            autoPanToggle.value = value
        case .autoPanFrequency:
            autoPanRate.value =  value
        case .reverbFeedback:
            reverbSize.value = value
        case .reverbHighPass:
            reverbLowCut.value = value
        case .reverbMix:
            reverbMix.value = value
        case .reverbOn:
            reverbToggle.value = value
        case .delayTime:
            delayTime.value = value
        case .delayFeedback:
            delayFeedback.value = value
        case .delayMix:
            delayMix.value = value
        case .delayOn:
            delayToggle.value = value
        case .cutoffLFO:
            lfoCutoffToggle.value = value
        case .lfo1Amplitude:
            lfo1Amp.value = value
        case .lfo1Rate:
            lfo1Rate.value = value
        case .lfo2Amplitude:
            lfo2Amp.value = value
        case .lfo2Rate:
            lfo2Rate.value = value

        default:
            _ = 0 // do nothing
        }

    }

}
