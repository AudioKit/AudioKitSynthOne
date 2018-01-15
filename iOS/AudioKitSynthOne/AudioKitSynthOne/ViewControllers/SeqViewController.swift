//
//  SeqViewController.swift
//  AudioKitSynthOne
//
//  Created by Matthew Fecher on 8/1/17.
//  Copyright © 2017 AudioKit. All rights reserved.
//


import UIKit
import AudioKit


class SeqViewController: SynthPanelController {
    
    @IBOutlet weak var seqStepsStepper: Stepper!
    @IBOutlet weak var octaveStepper: Stepper!
    @IBOutlet weak var arpDirectionButton: ArpDirectionButton!
    @IBOutlet weak var arpSeqToggle: ToggleSwitch!
    @IBOutlet weak var arpToggle: ToggleButton!
    @IBOutlet weak var arpInterval: Knob!
    
    let sliderLabelTags = 550 ... 565
    let sliderTags = 400 ... 415
    let sliderToggleTags = 500 ... 515
    
    var sliderTransposeButtons = [SliderTransposeButton]()
    
    // *********************************************************
    // MARK: - Lifecycle
    // *********************************************************
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        viewType = .seqView
        
        seqStepsStepper.minValue = 1
        seqStepsStepper.maxValue = 16
        octaveStepper.minValue = 1
        octaveStepper.maxValue = 4
        arpInterval.range = 0 ... 12
        
        // Get all Slider Transpose Buttons
        sliderTransposeButtons = self.view.subviews.filter { $0 is SliderTransposeButton } as! [SliderTransposeButton]
        
        // Bindings
        conductor.bind(arpToggle,          to: .arpIsOn)
        conductor.bind(arpInterval,        to: .arpInterval)
        conductor.bind(octaveStepper,      to: .arpOctave)
        conductor.bind(arpDirectionButton, to: .arpDirection)
        conductor.bind(arpSeqToggle,       to: .arpIsSequencer)
        conductor.bind(seqStepsStepper,    to: .arpTotalSteps)
        
        // SeqOctBoost/Slider Transpose Label bindings
        for tag in sliderLabelTags {
            if let label = view.viewWithTag(tag) as? SliderTransposeButton {
                let notePosition = Int(tag) - self.sliderLabelTags.lowerBound
                let asp = Int32(Int(AKSynthOneParameter.arpSeqOctBoost00.rawValue) + notePosition)
                if let aspe = AKSynthOneParameter(rawValue: asp) {
                    let labelCallback: AKSynthOneControlCallback = { param in
                        return { value in
                            self.conductor.synth.setAK1SeqOctBoost(forIndex: notePosition, value)
                            self.conductor.updateSingleUI(param)
                        }
                    }
                    conductor.bind(label, to: aspe, callback: labelCallback)
                } else {
                    AKLog("error binding label to conductor:\(label), notePosition:\(notePosition)")
                }
            }
        }

        // Slider bindings
        for tag in sliderTags {
            if let slider = view.viewWithTag(tag) as? VerticalSlider {
                let notePosition = Int(Int(tag) - self.sliderTags.lowerBound)
                let asp = Int32(Int(AKSynthOneParameter.arpSeqPattern00.rawValue) + notePosition)
                if let aspe = AKSynthOneParameter(rawValue: asp) {
                    let sliderCallback: AKSynthOneControlCallback = { param in
                        return { value in
                            let tval = Int( (-12 ... 12).clamp(value * 24 - 12) )
                            self.conductor.synth.setAK1ArpSeqPattern(forIndex: notePosition, tval )
                            self.conductor.updateSingleUI(param)
                        }
                    }
                    conductor.bind(slider, to: aspe, callback: sliderCallback)
                } else {
                    AKLog("error binding slider to conductor:\(slider), notePosition:\(notePosition)")
                }
            }
        }
        
        // ArpButton Note on/off bindings
        for tag in sliderToggleTags {
            if let toggle = view.viewWithTag(tag) as? ArpButton {
                let notePosition = Int(tag) - self.sliderToggleTags.lowerBound
                let asp = Int32(Int(AKSynthOneParameter.arpSeqNoteOn00.rawValue) + notePosition)
                if let aspe = AKSynthOneParameter(rawValue: asp) {
                    let toggleCallback: AKSynthOneControlCallback = { param in
                        return { value in
                            self.conductor.synth.setAK1ArpSeqNoteOn(forIndex: notePosition, value >  0 ? true : false )
                            self.conductor.updateSingleUI(param)
                        }
                    }
                    conductor.bind(toggle, to: aspe, callback: toggleCallback)
                } else {
                    AKLog("error binding toggle to conductor:\(toggle), notePosition:\(notePosition)")
                }
            }
        }
    }
    
    override func updateUI(_ param: AKSynthOneParameter, value: Double) {
        super.updateUI(param, value: value)
        for i in 0...15 {
            updateSliderLabel(notePosition: i)
        }
    }
    
    // *****************************************************************
    // MARK: - Helpers
    // *****************************************************************
    
    @objc public func updateLED(beatCounter: Int) {
        let arpIsOn = conductor.synth.getAK1Parameter(.arpIsOn) > 0 ? true : false
        let arpIsSequencer = conductor.synth.getAK1Parameter(.arpIsSequencer) > 0 ? true : false
        let seqNum = Int(conductor.synth.getAK1Parameter(.arpTotalSteps))
        if arpIsOn && arpIsSequencer && seqNum > 0 {
            let notePosition = (beatCounter % seqNum)
            
            // TODO: REMOVE - FOR DEBUGING
            conductor.updateDisplayLabel("notePosition: \(notePosition), beatCounter: \(beatCounter)")
            
            // clear out all indicators
            sliderTransposeButtons.forEach { $0.isActive = false }
            
            // change the outline current notePosition
            sliderTransposeButtons[notePosition].isActive = true
        }
    }
    
    func updateSliderLabel(notePosition: Int) {
        let sliderTransposeButton = sliderTransposeButtons[notePosition]

        sliderTransposeButton.transposeAmt = conductor.synth.getAK1ArpSeqPattern(forIndex: notePosition)
        sliderTransposeButton.octBoost = conductor.synth.getAK1SeqOctBoost(forIndex: notePosition) > 0 ? true : false
    }
    
}

