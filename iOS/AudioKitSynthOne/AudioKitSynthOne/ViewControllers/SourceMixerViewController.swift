//
//  MainViewController.swift
//  AudioKitSynthOne
//
//  Created by Aurelius Prochazka on 7/23/17.
//  Copyright © 2017 AudioKit. All rights reserved.
//

import AudioKit
import AudioKitUI
import UIKit

class SourceMixerViewController: SynthPanelController {
    
    @IBOutlet weak var morph1Selector: MorphSelector!
    @IBOutlet weak var morph2Selector: MorphSelector!
    
    @IBOutlet weak var morph1SemitoneOffset: MIDIKnob!
    @IBOutlet weak var morph2SemitoneOffset: MIDIKnob!
    @IBOutlet weak var morph2Detuning: MIDIKnob!
    @IBOutlet weak var morphBalance: MIDIKnob!
    @IBOutlet weak var morph1Volume: MIDIKnob!
    @IBOutlet weak var morph2Volume: MIDIKnob!
    @IBOutlet weak var glideKnob: MIDIKnob!
    
    @IBOutlet weak var cutoff: MIDIKnob!
    @IBOutlet weak var resonance: MIDIKnob!
    
    @IBOutlet weak var subVolume: MIDIKnob!
    @IBOutlet weak var subOctaveDown: ToggleButton!
    @IBOutlet weak var subIsSquare: ToggleButton!
    @IBOutlet weak var isMonoToggle: ToggleButton!
  
    @IBOutlet weak var fmVolume: MIDIKnob!
    @IBOutlet weak var fmAmount: MIDIKnob!
    
    @IBOutlet weak var noiseVolume: MIDIKnob!
    
    @IBOutlet weak var masterVolume: MIDIKnob!
    
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
        let s = conductor.synth!
        
        morph1SemitoneOffset.onlyIntegers = true
        morph1SemitoneOffset.range = s.getParameterRange(.morph1SemitoneOffset)
        morph2SemitoneOffset.onlyIntegers = true
        morph2SemitoneOffset.range = s.getParameterRange(.morph2SemitoneOffset)
        morph2Detuning.range = s.getParameterRange(.morph2Detuning)
        morphBalance.range = s.getParameterRange(.morphBalance)
        morph1Volume.range = s.getParameterRange(.morph1Volume)
        morph2Volume.range = s.getParameterRange(.morph2Volume)
        glideKnob.range = s.getParameterRange(.glide)
        glideKnob.taper = 2
        cutoff.range = s.getParameterRange(.cutoff)
        cutoff.taper = 3
        resonance.range = s.getParameterRange(.resonance)
        subVolume.range = s.getParameterRange(.subVolume)
        fmVolume.range = s.getParameterRange(.fmVolume)
        fmAmount.range = s.getParameterRange(.fmAmount)
        noiseVolume.range = s.getParameterRange(.noiseVolume)
        masterVolume.range = s.getParameterRange(.masterVolume)
        tempoStepper.maxValue = s.getParameterMax(.arpRate)
        tempoStepper.minValue = s.getParameterMin(.arpRate)

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
        conductor.bind(isMonoToggle,         to: .isMono)
        conductor.bind(glideKnob,            to: .glide)
        conductor.bind(filterTypeToggle,     to: .filterType)
        conductor.bind(masterVolume,         to: .masterVolume)
        conductor.bind(legatoModeToggle,     to: .monoIsLegato)
        conductor.bind(widenToggle,          to: .widen)
        
        //TODO:Move this to DSP
        // update lfo1Rate, lfo2Rate, delayTime, and autoPanRate when arpIsOn changes
        conductor.bind(arpSeqToggle,         to: .arpIsOn) { param, control in
            return { value in
                s.setAK1Parameter(.arpIsOn, value)
                if self.conductor.syncRateToTempo {
                    self.conductor.updateSingleUI(.lfo1Rate, control: nil, value: s.getAK1Parameter(.lfo1Rate))
                    self.conductor.updateSingleUI(.lfo2Rate, control: nil, value: s.getAK1Parameter(.lfo2Rate))
                    self.conductor.updateSingleUI(.autoPanFrequency, control: nil, value: s.getAK1Parameter(.autoPanFrequency))
                    self.conductor.updateSingleUI(.delayTime, control: nil, value: s.getAK1Parameter(.delayTime))
                }
            }
        }
        
        //TODO:Move this to DSP
        // update lfo1Rate, lfo2Rate, delayTime, and autoPanRate when arpRate changes
        conductor.bind(tempoStepper,         to: .arpRate) { param, control in
            return { value in
                s.setAK1Parameter(.arpRate, value)
                if self.conductor.syncRateToTempo {
                    self.conductor.updateSingleUI(.lfo1Rate, control: nil, value: s.getAK1Parameter(.lfo1Rate))
                    self.conductor.updateSingleUI(.lfo2Rate, control: nil, value: s.getAK1Parameter(.lfo2Rate))
                    self.conductor.updateSingleUI(.autoPanFrequency, control: nil, value: s.getAK1Parameter(.autoPanFrequency))
                    self.conductor.updateSingleUI(.delayTime, control: nil, value: s.getAK1Parameter(.delayTime))
                }
            }
        }
        
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
