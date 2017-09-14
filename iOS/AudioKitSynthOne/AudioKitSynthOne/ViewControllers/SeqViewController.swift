//
//  SeqViewController.swift
//  AudioKitSynthOne
//
//  Created by Matthew Fecher on 8/1/17.
//  Copyright © 2017 AudioKit. All rights reserved.
//


import UIKit

protocol SeqControllerDelegate {
    func arpValueDidChange(_ arpeggiator: Arpeggiator)
}

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
    
    var arpDelegate: SeqControllerDelegate?
    var arpeggiator = Arpeggiator()
    var prevLedTag: Int = 0
    
    // *********************************************************
    // MARK: - Lifecycle
    // *********************************************************
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
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
                let transposeAmt = arpeggiator.seqPattern[notePosition]
            
                slider.actualValue = Double(transposeAmt)
                updateTransposeBtn(notePosition: notePosition)
                slider.setNeedsDisplay()
            }
        }
        
        // ArpButton Note on/off
        for tag in sliderToggleTags {
            if let toggle = view.viewWithTag(tag) as? ArpButton {
                let notePosition = Int(tag) - sliderToggleTags.lowerBound
                toggle.isOn = arpeggiator.seqNoteOn[notePosition]
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
        
        seqStepsStepper.value = arpeggiator.totalSteps
        octaveStepper.value = arpeggiator.octave
        arpDirectionButton.arpDirectionSelected = arpeggiator.direction
        arpSeqToggle.isOn = arpeggiator.isSequencer
        arpToggle.value = arpeggiator.isOn
        arpInterval.value = arpeggiator.interval
    }
    
    
    //*****************************************************************
    // MARK: - Callbacks
    //*****************************************************************
    
    override func updateCallbacks() {
        
        // Arp Direction Button
        arpDirectionButton.callback = { value in
            print("Arp Direction Update: \(value)")
        }
        
        // Total Seq Steps
        seqStepsStepper.callback = { value in
            print("Seq Stepper Update: \(value)")
        }
        
        // Octave Stepper
        octaveStepper.callback = { value in
            print("Oct Stepper Update: \(value)")
        }
        
        // Arp/Seq Toggle
        arpSeqToggle.callback = { value in
            print("Arp/Seq Toggle: \(value)")
        }
        
        // Arp Interval
        arpInterval.callback = { value in
            print("Arp Interval: \(value)")
        }
        
        // Slider
        for tag in sliderTags {
            if let slider = view.viewWithTag(tag) as? VerticalSlider {
                
                slider.callback = { value in
                    let notePosition = Int(tag) - self.sliderTags.lowerBound
                    
                    // print("Slider changed, \(notePosition): \(value)")
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
                    self.arpeggiator.seqNoteOn[notePosition] = value == 1.0 ? true : false
                    print("notePosition \(notePosition), value \(value)")
                }
            }
        }
        
        // Slider Transpose Label on/off
        for tag in sliderLabelTags {
            if let label = view.viewWithTag(tag) as? TransposeButton {
                
                label.callback = { value in
                    let notePosition = Int(tag) - self.sliderLabelTags.lowerBound
                    self.arpeggiator.seqOctBoost[notePosition] = !self.arpeggiator.seqOctBoost[notePosition]
                    
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
        
            var transposeAmt = arpeggiator.seqPattern[notePosition]
            
            if arpeggiator.seqOctBoost[notePosition] {
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
        arpeggiator.seqPattern[notePosition] = transposeAmt
        arpDelegate?.arpValueDidChange(arpeggiator)
    }
}


