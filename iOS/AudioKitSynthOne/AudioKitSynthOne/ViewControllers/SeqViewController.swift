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
    
    let sliderTags = 400 ... 415
    let sliderToggleTags = 500 ... 515
    let sliderLabelTags = 550 ... 565
    
    var prevLedTag: Int = 0
    
    // *********************************************************
    // MARK: - Lifecycle
    // *********************************************************
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        viewType = .seqView
        
        // Set Knob Delegates
        setDelegates()
        
        // Update Knob & Slider UI Values
        setupValues()
        
        updateCallbacks()
        
        // Replace with Binding
        setupControlValues()
    }
    
    // *********************************************************
    // MARK: - Set Delegates
    // *********************************************************
    
    func setDelegates() {
    }
    
    func setupValues() {
        
        seqStepsStepper.minValue = 1
        seqStepsStepper.maxValue = 16
        seqStepsStepper.value = 8
        
        arpInterval.range = 0 ... 12
    }
    
    // This function replaced by callbacks
    func setupControlValues() {
        
        // Slider values
        for tag in sliderTags {
            if let slider = view.viewWithTag(tag) as? VerticalSlider {
                let notePosition = tag - sliderTags.lowerBound
                let ii = AKSynthOneParameter.arpSeqPattern00.rawValue + notePosition
                let aksp = AKSynthOneParameter(rawValue: ii) ?? AKSynthOneParameter.arpSeqPattern00
                let transposeAmt = conductor.synth.getAK1Parameter(aksp)
                slider.actualValue = Double(transposeAmt)
                updateTransposeBtn(notePosition: notePosition)
                slider.setNeedsDisplay()
                //AKLog("Slider: \(notePosition): \(transposeAmt)")
            }
        }
        
        // ArpButton Note on/off
        for tag in sliderToggleTags {
            if let toggle = view.viewWithTag(tag) as? ArpButton {
                let notePosition = Int(tag) - sliderToggleTags.lowerBound
                let ii = AKSynthOneParameter.arpSeqNoteOn00.rawValue + notePosition
                let aksp = AKSynthOneParameter(rawValue: ii) ?? AKSynthOneParameter.arpSeqNoteOn00
                let isOn = conductor.synth.getAK1Parameter(aksp)
                toggle.isOn = (isOn > 0) ? true : false
            }
        }
        
        /*
        // Slider Transpose Label / +12/-12
        for tag in sliderLabelTags {
            if let label = view.viewWithTag(tag) as? TransposeButton {
                let notePosition = Int(tag) - sliderLabelTags.lowerBound
                //label.text = String(arpeggiator.seqPattern[notePosition])
            }
        }
        */
        
        seqStepsStepper.value = conductor.synth.getAK1Parameter(.arpTotalSteps)
        octaveStepper.value = conductor.synth.getAK1Parameter(.arpOctave)
        arpDirectionButton.arpDirectionSelected = conductor.synth.getAK1Parameter(.arpDirection)
        arpSeqToggle.isOn = ( conductor.synth.getAK1Parameter(.arpIsSequencer) > 0 ) ? true : false
        arpToggle.value = conductor.synth.getAK1Parameter(.arpIsOn)
        arpInterval.value = conductor.synth.getAK1Parameter(.arpInterval)
    }
    
    
    //*****************************************************************
    // MARK: - Callbacks
    //*****************************************************************
    
    override func updateCallbacks() {
        
        // Arp Direction Button
        arpDirectionButton.callback = { value in
            AKLog("Arp Direction Update: \(value)")
        }
        
        // Total Seq Steps
        seqStepsStepper.callback = { value in
            AKLog("Seq Stepper Update: \(value)")
        }
        
        // Octave Stepper
        octaveStepper.callback = { value in
            AKLog("Oct Stepper Update: \(value)")
        }
        
        // Arp/Seq Toggle
        arpSeqToggle.callback = { value in
            AKLog("Arp/Seq Toggle: \(value)")
        }
        
        // Arp Interval
        arpInterval.callback = { value in
            AKLog("Arp Interval: \(value)")
        }
        
        // Slider
        for tag in sliderTags {
            if let slider = view.viewWithTag(tag) as? VerticalSlider {
                
                slider.callback = { value in
                    let notePosition = Int(tag) - self.sliderTags.lowerBound
                    self.setSequencerNote(notePosition, transposeAmt: Int(value))
                    self.updateTransposeBtn(notePosition: notePosition)
                }
            }
        }
        
        // ArpButton Note on/off
        for tag in sliderToggleTags {
            if let toggle = view.viewWithTag(tag) as? ArpButton {
                
                toggle.callback = { value in
                    let notePosition = Int(tag) - self.sliderToggleTags.lowerBound
                    let ii = AKSynthOneParameter.arpSeqNoteOn00.rawValue + notePosition
                    let aksp = AKSynthOneParameter(rawValue: ii) ?? AKSynthOneParameter.arpSeqNoteOn00
                    self.conductor.synth.setAK1Parameter(aksp, value)
                    AKLog("notePosition \(notePosition), value \(value)")
                }
            }
        }
        
        // Slider Transpose Label on/off
        for tag in sliderLabelTags {
            if let label = view.viewWithTag(tag) as? TransposeButton {
                
                label.callback = { value in
                    let notePosition = Int(tag) - self.sliderLabelTags.lowerBound
                    let ii = AKSynthOneParameter.arpSeqOctBoost00.rawValue + notePosition
                    let aksp = AKSynthOneParameter(rawValue: ii) ?? AKSynthOneParameter.arpSeqOctBoost00
                    self.conductor.synth.setAK1Parameter(aksp, 1-value)
                    self.updateTransposeBtn(notePosition: notePosition)
                }
            }
        }
    }
    
    //*****************************************************************
    // MARK: - Helpers
    //*****************************************************************
    
    func updateTransposeBtn(notePosition: Int) {
        
        let labelTag = notePosition + sliderLabelTags.lowerBound
        if let label = view.viewWithTag(labelTag) as? TransposeButton {
        
            let ii = AKSynthOneParameter.arpSeqPattern00.rawValue + notePosition
            let aksp = AKSynthOneParameter(rawValue: ii) ?? AKSynthOneParameter.arpSeqPattern00
            var transposeAmt = self.conductor.synth.getAK1Parameter(aksp)
            
            let iib = AKSynthOneParameter.arpSeqOctBoost00.rawValue + notePosition
            let akspb = AKSynthOneParameter(rawValue: iib) ?? AKSynthOneParameter.arpSeqOctBoost00
            let akspbb = self.conductor.synth.getAK1Parameter(akspb)
            let octBoost = akspbb > 0 ? true : false
            
            if octBoost {
                label.isOn = true
                if transposeAmt >= 0 {
                    transposeAmt = transposeAmt + 12
                } else {
                    transposeAmt = transposeAmt - 12
                }
            } else {
                label.isOn = false
            }
            
            label.text = "\(transposeAmt)"
        }
    }
    
    func setSequencerNote(_ notePosition: Int, transposeAmt: Int) {
        
        let ii = AKSynthOneParameter.arpSeqPattern00.rawValue + notePosition
        let ssn = AKSynthOneParameter(rawValue: ii) ?? AKSynthOneParameter.arpSeqPattern00
        conductor.synth.setAK1Parameter(ssn, Double(transposeAmt))
    }
}


