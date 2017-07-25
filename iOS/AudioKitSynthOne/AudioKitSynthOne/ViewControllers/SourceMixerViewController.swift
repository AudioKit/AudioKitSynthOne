//
//  MainViewController.swift
//  AudioKitSynthOne
//
//  Created by Aurelius Prochazka on 7/23/17.
//  Copyright © 2017 AudioKit. All rights reserved.
//

import UIKit
import AudioKit

public class SourceMixerViewController: UpdatableViewController {

    @IBOutlet weak var morph1Selector: MorphSelector!
    @IBOutlet weak var morph2Selector: MorphSelector!

    @IBOutlet weak var morph1SemitoneOffset: Knob!
    @IBOutlet weak var morph2SemitoneOffset: Knob!
    @IBOutlet weak var morph2Detuning: Knob!
    @IBOutlet weak var morphBalance: Knob!
    @IBOutlet weak var morph1Volume: Knob!
    @IBOutlet weak var morph2Volume: Knob!

    @IBOutlet weak var cutoff: Knob!
    @IBOutlet weak var resonance: Knob!

    @IBOutlet weak var subVolume: Knob!
    @IBOutlet weak var subOctaveDown: ToggleButton!
    @IBOutlet weak var subIsSquare: ToggleButton!

    @IBOutlet weak var fmVolume: Knob!
    @IBOutlet weak var fmAmount: Knob!

    @IBOutlet weak var noiseVolume: Knob!

    @IBOutlet weak var masterVolume: Knob!

    public override func viewDidLoad() {
        super.viewDidLoad()

        // Defaults, limits

        cutoff.minimum = 120
        cutoff.maximum = 28000
        cutoff.taper = 4.04

        morph1SemitoneOffset.onlyIntegers = true
        morph1SemitoneOffset.minimum = -12 // semitones
        morph1SemitoneOffset.maximum = 12  // semitones

        morph2SemitoneOffset.onlyIntegers = true
        morph2SemitoneOffset.minimum = -12 // semitones
        morph2SemitoneOffset.maximum = 12  // semitones

        morph2Detuning.minimum = -4 // Hz
        morph2Detuning.maximum = 4  // Hz

        morph1Volume.value = 0.5
        morph1Volume.value = 0.5

        morphBalance.value = 0.5

        noiseVolume.maximum = 0.3
        fmAmount.maximum = 15
        
        resonance.maximum = 0.99

        updateCallbacks()
    }

    override func updateCallbacks() {
        morph1Selector.callback       = conductor.changeParameter(.index1)
        morph2Selector.callback       = conductor.changeParameter(.index2)
        morph1SemitoneOffset.callback = conductor.changeParameter(.morph1SemitoneOffset)
        morph2SemitoneOffset.callback = conductor.changeParameter(.morph2SemitoneOffset)
        morph2Detuning.callback       = conductor.changeParameter(.morph2Detuning)
        morphBalance.callback         = conductor.changeParameter(.morphBalance)
        morph1Volume.callback         = conductor.changeParameter(.morph1Volume)
        morph2Volume.callback         = conductor.changeParameter(.morph2Volume)
        cutoff.callback               = conductor.changeParameter(.cutoff)
        resonance.callback            = conductor.changeParameter(.resonance)
        subVolume.callback            = conductor.changeParameter(.subVolume)
        subOctaveDown.callback        = conductor.changeParameter(.subOctaveDown)
        subIsSquare.callback          = conductor.changeParameter(.subIsSquare)
        fmVolume.callback             = conductor.changeParameter(.fmVolume)
        fmAmount.callback             = conductor.changeParameter(.fmAmount)
        noiseVolume.callback          = conductor.changeParameter(.noiseVolume)
        masterVolume.callback         = conductor.changeParameter(.masterVolume)
    }

    override func updateUI(_ param: AKSynthOneParameter, value: Double) {

        switch param {
        case .index1:
            morph1Selector.value = value
        case .index2:
            morph2Selector.value = value
        case .morph1SemitoneOffset:
            morph1SemitoneOffset.value = value
        case .morph2SemitoneOffset:
            morph2SemitoneOffset.value = value
        case .morph2Detuning:
            morph2Detuning.value = value
        case .morphBalance:
            morphBalance.value = value
        case .morph1Volume:
            morph1Volume.value = value
        case .morph2Volume:
            morph2Volume.value = value
        case .subVolume:
            subVolume.value = value
        case .subIsSquare:
            subIsSquare.value = value
        case .subOctaveDown:
            subOctaveDown.value = value
        case .cutoff:
            cutoff.value = value
        case .resonance:
            resonance.value = value
        case .fmVolume:
            fmVolume.value = value
        case .fmAmount:
            fmAmount.value = value
        case .noiseVolume:
            noiseVolume.value = value
        case .masterVolume:
            masterVolume.value = value
        default:
            _ = 0
            // do nothing
        }
    }
}

