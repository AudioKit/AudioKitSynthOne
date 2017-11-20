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
    
    // these UI classes do NOT conform to AKSynthOneControl protocol
    @IBOutlet weak var seqStepsStepper: Stepper!
    @IBOutlet weak var octaveStepper: Stepper!
    @IBOutlet weak var arpDirectionButton: ArpDirectionButton!
    @IBOutlet weak var arpSeqToggle: ToggleSwitch!
    
    // these UI classes DO conform to the AKSynthOneControl protocol
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
        
        // Bindings
        conductor.bind(arpToggle,   to: .arpIsOn)
        conductor.bind(arpInterval, to: .arpInterval)
        
        ///TODO:Replace with Binding:
        // Stepper, ArpDirectionButton, and ToggleSwitch do not conform to AKSynthOneControl
        seqStepsStepper.minValue = 1
        seqStepsStepper.maxValue = 16
        seqStepsStepper.value = 8
        arpInterval.range = 0 ... 12
        
        seqStepsStepper.value = conductor.synth.getAK1Parameter(.arpTotalSteps)
        octaveStepper.value = conductor.synth.getAK1Parameter(.arpOctave)
        arpDirectionButton.arpDirectionSelected = conductor.synth.getAK1Parameter(.arpDirection)
        arpSeqToggle.isOn = ( conductor.synth.getAK1Parameter(.arpIsSequencer) > 0 ) ? true : false
        arpToggle.value = conductor.synth.getAK1Parameter(.arpIsOn)
        arpInterval.value = conductor.synth.getAK1Parameter(.arpInterval)
        
        updateCallbacks()

        setupControlValues()
    }
    
    ///TODO:Replace with Binding:
    ///But Stepper, ArpDirectionButton, and ToggleSwitch do not conform to AKSynthOneControl
    func setupControlValues() {

        // these UI classes do NOT conform to AKSynthOneControl protocol

        // Arp Direction Button
        arpDirectionButton.callback = { value in
            self.conductor.synth.setAK1Parameter(.arpDirection, value)
        }
        
        // Total Seq Steps
        seqStepsStepper.callback = { value in
            self.conductor.synth.setAK1Parameter(.arpTotalSteps, value)
        }
        
        // Octave Stepper
        octaveStepper.callback = { value in
            self.conductor.synth.setAK1Parameter(.arpOctave, value)
        }
        
        // Arp/Seq Toggle
        arpSeqToggle.callback = { value in
            self.conductor.synth.setAK1Parameter(.arpIsSequencer, value)
        }
        
        // Arp Interval
        arpInterval.callback = { value in
            self.conductor.synth.setAK1Parameter(.arpInterval, value)
        }
        
        // Slider
        for tag in sliderTags {
            if let slider = view.viewWithTag(tag) as? VerticalSlider {
                
                slider.callback = { value in
                    let notePosition = Int(tag) - self.sliderTags.lowerBound
                    self.setSequencerNote(notePosition, transposeAmt: Int(value))
                    self.conductor.synth.setAK1ArpSeqPattern(forIndex: notePosition, Int(value) )
                    self.updateTransposeBtn(notePosition: notePosition)
                }
            }
        }
        
        // ArpButton Note on/off
        for tag in sliderToggleTags {
            if let toggle = view.viewWithTag(tag) as? ArpButton {
                
                toggle.callback = { value in
                    let notePosition = Int(tag) - self.sliderToggleTags.lowerBound
                    self.conductor.synth.setAK1ArpSeqNoteOn(forIndex: notePosition, value>0 ?true :false )
                }
            }
        }
        
        // Slider Transpose Label on/off
        for tag in sliderLabelTags {
            if let label = view.viewWithTag(tag) as? TransposeButton {
                
                label.callback = { value in
                    let notePosition = Int(tag) - self.sliderLabelTags.lowerBound
                    self.conductor.synth.setAK1SeqOctBoost(forIndex: notePosition, (1-value)>0 ?true :false)
                    self.updateTransposeBtn(notePosition: notePosition)
                }
            }
        }

        // Slider values
        for tag in sliderTags {
            if let slider = view.viewWithTag(tag) as? VerticalSlider {
                let notePosition = tag - sliderTags.lowerBound
                let transposeAmt = conductor.synth.getAK1ArpSeqPattern(forIndex: notePosition)
                slider.actualValue = Double(transposeAmt)
                updateTransposeBtn(notePosition: notePosition)
                slider.setNeedsDisplay()
            }
        }
        
        // ArpButton Note on/off
        for tag in sliderToggleTags {
            if let toggle = view.viewWithTag(tag) as? ArpButton {
                let notePosition = Int(tag) - sliderToggleTags.lowerBound
                toggle.isOn = conductor.synth.getAK1ArpSeqNoteOn(forIndex: notePosition)
            }
        }
        
        ///TODO:Is arp octave boost implemented?
        
        /*
        // Slider Transpose Label / +12/-12
        for tag in sliderLabelTags {
            if let label = view.viewWithTag(tag) as? TransposeButton {
                let notePosition = Int(tag) - sliderLabelTags.lowerBound
                //label.text = String(arpeggiator.seqPattern[notePosition])
            }
        }
        */
    }
    
    
    //*****************************************************************
    // MARK: - Callbacks
    //*****************************************************************
    
    override func updateCallbacks() {
        
        
        // must call last
        super.updateCallbacks()
    }
    
    //*****************************************************************
    // MARK: - Helpers
    //*****************************************************************
    
    func updateTransposeBtn(notePosition: Int) {
        
        let labelTag = notePosition + sliderLabelTags.lowerBound
        if let label = view.viewWithTag(labelTag) as? TransposeButton {
            var transposeAmt = self.conductor.synth.getAK1ArpSeqPattern(forIndex: notePosition)
            let octBoost = self.conductor.synth.getAK1SeqOctBoost(forIndex: notePosition)
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
        conductor.synth.setAK1ArpSeqPattern(forIndex: notePosition, transposeAmt)
    }
}


