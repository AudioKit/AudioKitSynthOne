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
    
    @IBOutlet weak var nav1Button: NavButton!
    @IBOutlet weak var nav2Button: NavButton!
    
    @IBOutlet weak var audioPlot: AKOutputWaveformPlot!
    
    var navDelegate: EmbeddedViewsDelegate?
    
    public override func viewDidLoad() {
        super.viewDidLoad()

        // Defaults, limits

        cutoff.range = 120 ... 28000
        cutoff.taper = 4.04

        morph1SemitoneOffset.onlyIntegers = true
        morph1SemitoneOffset.range = -12 ... 12 // semitones

        morph2SemitoneOffset.onlyIntegers = true
        morph2SemitoneOffset.range = -12 ... 12  // semitones

        morph2Detuning.range = -4 ... 4  // Hz

        morph1Volume.value = 0.5
        morph1Volume.value = 0.5

        morphBalance.value = 0.5

        noiseVolume.range = 0.0 ... 0.3
        fmAmount.range = 0.0 ... 15
        resonance.range = 0.0 ... 0.97

        conductor.bind(morph1Selector,       to: .index1)
        conductor.bind(morph2Selector,       to: .index2)
        conductor.bind(morph1SemitoneOffset, to: .morph1SemitoneOffset)
        conductor.bind(morph2SemitoneOffset, to: .morph2SemitoneOffset)
        conductor.bind(morph2Detuning,       to: .morph2Detuning)
        conductor.bind(morphBalance,         to: .morphBalance)
        conductor.bind(morph1Volume,         to: .morph1Volume)
        conductor.bind(morph2Volume,         to: .morph2Volume)
        conductor.bind(cutoff,               to: .cutoff)
        conductor.bind(resonance,            to: .resonance)
        conductor.bind(subVolume,            to: .subVolume)
        conductor.bind(subOctaveDown,        to: .subOctaveDown)
        conductor.bind(subIsSquare,          to: .subIsSquare)
        conductor.bind(fmVolume,             to: .fmVolume)
        conductor.bind(fmAmount,             to: .fmAmount)
        conductor.bind(noiseVolume,          to: .noiseVolume)
        conductor.bind(masterVolume,         to: .masterVolume)

        updateCallbacks()
        navButtonsSetup()
    }
    
    func navButtonsSetup() {
        nav1Button.callback = { _ in
            self.navDelegate?.switchToChildView(.seqView)
        }
        
        nav2Button.callback = { _ in
            self.navDelegate?.switchToChildView(.adsrView)
        }
    }
}

