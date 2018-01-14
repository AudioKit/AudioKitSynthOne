//
//  MainViewController.swift
//  AudioKitSynthOne
//
//  Created by Aurelius Prochazka on 7/23/17.
//  Copyright © 2017 AudioKit. All rights reserved.
//

import UIKit
import AudioKit
import AudioKitUI

class SourceMixerViewController: SynthPanelController {
    
    @IBOutlet weak var morph1Selector: MorphSelector!
    @IBOutlet weak var morph2Selector: MorphSelector!
    
    @IBOutlet weak var morph1SemitoneOffset: Knob!
    @IBOutlet weak var morph2SemitoneOffset: Knob!
    @IBOutlet weak var morph2Detuning: Knob!
    @IBOutlet weak var morphBalance: Knob!
    @IBOutlet weak var morph1Volume: Knob!
    @IBOutlet weak var morph2Volume: Knob!
    @IBOutlet weak var glideKnob: Knob!
    
    @IBOutlet weak var cutoff: Knob!
    @IBOutlet weak var resonance: Knob!
    
    @IBOutlet weak var subVolume: Knob!
    @IBOutlet weak var subOctaveDown: ToggleButton!
    @IBOutlet weak var subIsSquare: ToggleButton!
    @IBOutlet weak var isMonoToggle: ToggleButton!
  
    @IBOutlet weak var fmVolume: Knob!
    @IBOutlet weak var fmAmount: Knob!
    
    @IBOutlet weak var noiseVolume: Knob!
    
    @IBOutlet weak var masterVolume: Knob!
    
    @IBOutlet weak var filterTypeToggle: FilterTypeButton!
    @IBOutlet weak var displayContainer: UIView!
    
    @IBOutlet weak var arpSeqToggle: FlatToggleButton!
    @IBOutlet weak var tempoStepper: TempoStepper!
    
    @IBOutlet weak var legatoModeToggle: ToggleButton!
    @IBOutlet weak var widenToggle: FlatToggleButton!
    
    var audioPlot: AKNodeOutputPlot!
    var isAudioPlotFilled: Bool = false
    var midiKnobs = [MIDIKnob]()
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        
        viewType = .oscView
        
        // Defaults, limits
        cutoff.range = conductor.synth.filterCutoffMin ... conductor.synth.filterCutoffMax
        cutoff.taper = 3
        morph1SemitoneOffset.onlyIntegers = true
        morph1SemitoneOffset.range = -12 ... 12 // semitones
        morph2SemitoneOffset.onlyIntegers = true
        morph2SemitoneOffset.range = -12 ... 12  // semitones
        morph2Detuning.range = -4 ... 4  // Hz
        glideKnob.range = 0.0 ... 0.2
        glideKnob.taper = 2
        noiseVolume.range = 0.0 ... 0.25
        fmAmount.range = 0.0 ... 15
        resonance.range = conductor.synth.filterResonanceMin ... conductor.synth.filterResonanceMax
        tempoStepper.maxValue = 280
        tempoStepper.minValue = 10
        masterVolume.range = 0.0...2.0

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
        conductor.bind(arpSeqToggle,         to: .arpIsOn)
        conductor.bind(isMonoToggle,         to: .isMono)
        conductor.bind(glideKnob,            to: .glide)
        conductor.bind(filterTypeToggle,     to: .filterType)
        conductor.bind(masterVolume,         to: .masterVolume)
        conductor.bind(tempoStepper,         to: .arpRate)
        conductor.bind(legatoModeToggle,     to: .monoIsLegato)
        
        // Setup Audio Plot Display
        setupAudioPlot()
    }
    
    func setupAudioPlot() {
        audioPlot = AKNodeOutputPlot(conductor.synth, frame: CGRect(x: 0, y: 0, width: 172, height: 93))
        audioPlot.backgroundColor = #colorLiteral(red: 0.2431372549, green: 0.2431372549, blue: 0.262745098, alpha: 0)
        audioPlot.color = #colorLiteral(red: 0.9611048102, green: 0.509832561, blue: 0, alpha: 1)
        audioPlot.gain = 1
        audioPlot.shouldFill = false
        displayContainer.addSubview(audioPlot)
       
        // Add Tap Gesture Recognizer to AudioPlot
        let audioPlotTap = UITapGestureRecognizer(target: self, action: #selector(SourceMixerViewController.audioPlotToggled))
        audioPlot.addGestureRecognizer(audioPlotTap)
    }
    
    @objc func audioPlotToggled() {
        isAudioPlotFilled = !isAudioPlotFilled
        audioPlot.shouldFill = isAudioPlotFilled
    }
    
}

