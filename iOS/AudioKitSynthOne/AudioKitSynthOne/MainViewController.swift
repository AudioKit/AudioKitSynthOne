//
//  MainViewController.swift
//  AudioKitSynthOne
//
//  Created by Aurelius Prochazka on 7/23/17.
//  Copyright © 2017 AudioKit. All rights reserved.
//

import UIKit
import AudioKit

public class MainViewController: SynthOneViewController {

    @IBOutlet weak var sub24Toggle: ToggleButton!
    @IBOutlet weak var subSqrToggle: ToggleButton!

    @IBOutlet weak var osc1SemiKnob: Knob!
    @IBOutlet weak var osc2SemiKnob: Knob!
    @IBOutlet weak var osc2DetuneKnob: Knob!
    @IBOutlet weak var oscMixKnob: Knob!
    @IBOutlet weak var osc1VolKnob: Knob!
    @IBOutlet weak var osc2VolKnob: Knob!
    @IBOutlet weak var cutoffKnob: CutoffKnob!
    @IBOutlet weak var rezKnob: Knob!
    @IBOutlet weak var subMixKnob: Knob!
    @IBOutlet weak var fmMixKnob: Knob!
    @IBOutlet weak var fmModKnob: Knob!
    @IBOutlet weak var noiseMixKnob: Knob!
    @IBOutlet weak var masterVolKnob: Knob!

    public override func viewDidLoad() {
        super.viewDidLoad()

        // Callbacks
        sub24Toggle.callback    = changeParameter(.subOscOctavesDown)
        subSqrToggle.callback   = changeParameter(.subOscIsSquare)
        osc1SemiKnob.callback   = changeParameter(.morph1PitchOffset)
        osc2SemiKnob.callback   = changeParameter(.morph2PitchOffset)
        osc2DetuneKnob.callback = changeParameter(.detuningOffset)
        oscMixKnob.callback     = changeParameter(.morphBalance)
        osc1VolKnob.callback    = changeParameter(.morph1Mix)
        osc2VolKnob.callback    = changeParameter(.morph2Mix)
        rezKnob.callback        = changeParameter(.resonance)
        subMixKnob.callback     = changeParameter(.subOscMix)
        fmMixKnob.callback      = changeParameter(.fmMix)
        fmModKnob.callback      = changeParameter(.fmMod)
        noiseMixKnob.callback   = changeParameter(.noiseMix)

        // Defaults, limits
        osc1SemiKnob.onlyIntegers = true
        osc1SemiKnob.minimum = -12 // semitones
        osc1SemiKnob.maximum = 12  // semitones

        osc2SemiKnob.onlyIntegers = true
        osc2SemiKnob.minimum = -12 // semitones
        osc2SemiKnob.maximum = 12  // semitones

        osc2DetuneKnob.minimum = -3 // Hz
        osc2DetuneKnob.maximum = 3  // Hz

        osc1VolKnob.value = 0.5
        osc2VolKnob.value = 0.5

        oscMixKnob.value = 0.5

        rezKnob.maximum = 0.99

    }

    override func updateUI(_ param: AKSynthOneParameter, value: Double) {

        switch param {
        case .morph1PitchOffset:
            osc1SemiKnob.value = value
        case .morph2PitchOffset:
            osc2SemiKnob.value = value
        case .detuningMultiplier:
            osc2DetuneKnob.value = value
        case .morphBalance:
            oscMixKnob.value = value
        case .morph1Mix:
            osc1VolKnob.value = value
        case .morph2Mix:
            osc2VolKnob.value = value
        case .subOscIsSquare:
            subSqrToggle.value = value
        case .subOscOctavesDown:
            sub24Toggle.value = value
        case .resonance:
            rezKnob.value = value
        case .subOscMix:
            subMixKnob.value = value
        case .fmMix:
            fmMixKnob.value = value
        case .fmMod:
            fmModKnob.value = value
        case .noiseMix:
            noiseMixKnob.value = value
        default:
            _ = 0
            // do nothing
        }
    }
}

