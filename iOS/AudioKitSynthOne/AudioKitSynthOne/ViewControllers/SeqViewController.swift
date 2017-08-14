//
//  SeqViewController.swift
//  AudioKitSynthOne
//
//  Created by Matthew Fecher on 8/1/17.
//  Copyright © 2017 AudioKit. All rights reserved.
//


import UIKit

class SeqViewController: UpdatableViewController {
    
    @IBOutlet weak var seqStepsStepper: Stepper!
    @IBOutlet weak var octaveStepper: Stepper!
    @IBOutlet weak var arpDirectionButton: ArpDirectionButton!
    @IBOutlet weak var arpSeqToggle: ToggleSwitch!
    
    @IBOutlet weak var nav1Button: NavButton!
    @IBOutlet weak var nav2Button: NavButton!
    @IBOutlet weak var arpToggle: ToggleButton!
    
    let sliderTags = 400 ... 415
    let sliderToggleTags = 500 ... 515
    let sliderLabelTags = 550 ... 565
    
    var navDelegate: EmbeddedViewsDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Set Knob Delegates
        setDelegates()
        
        // Update Knob & Slider UI Values
        setupValues()
        
        updateCallbacks()
        
        navButtonsSetup()
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
        
        // Setup slider values & step labels
        for tag in sliderTags {
            if let slider = view.viewWithTag(tag) as? VerticalSlider {
                let notePosition = tag - sliderTags.lowerBound
                // let transposeAmt = arpeggiator!.seqPattern[notePosition]
                // set existing value = slider.currentValue = CGFloat(Double.scaleRangeZeroToOne(Double(transposeAmt), rangeMin: -12, rangeMax: 12))
                // updateStepDisplay(notePosition, transposeAmt: transposeAmt)
                slider.currentValue = 0.5
                slider.setNeedsDisplay()
            }
        }
        
    }
    
    func navButtonsSetup() {
        nav1Button.callback = { _ in
            self.navDelegate?.switchToChildView(.padView)
        }
        
        nav2Button.callback = { _ in
            self.navDelegate?.switchToChildView(.oscView)
        }
    }
    
    //*****************************************************************
    // MARK: - Callbacks
    //*****************************************************************
    
    override func updateCallbacks() {
        
        // Arp Direction Button
        arpDirectionButton.callback = { value in
            print("Arp Direction Update: \(value)")
        }
        
        // Seq Stepper
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
        
        
        // Slider
        for tag in sliderTags {
            if let slider = view.viewWithTag(tag) as? VerticalSlider {
                
                slider.callback = { value in
                    let notePosition = Int(tag) - self.sliderTags.lowerBound
                    
                    print("Slider changed, \(notePosition): \(value)")
                    self.updateTransposeBtn(notePosition: notePosition, transposeAmt: Int(value))
                    // setSequencerNote(notePosition, transposeAmt: transposeAmt)
                }
            }
        }
        
        // ArpButton Note on/off
        for tag in sliderToggleTags {
            if let toggle = view.viewWithTag(tag) as? ArpButton {
                
                toggle.callback = { value in
                    let notePosition = Int(tag) - self.sliderToggleTags.lowerBound
                    if value == 1.0 {
                        // arpeggiator!.seqNoteOn[notePosition] = true
                    } else {
                        // arpeggiator!.seqNoteOn[notePosition] = true
                    }
                    print("notePosition \(notePosition), value \(value)")
                }
            }
        }
        
        // Slider Transpose Label on/off
        for tag in sliderLabelTags {
            if let label = view.viewWithTag(tag) as? TransposeButton {
                
                label.callback = { value in
                    let notePosition = Int(tag) - self.sliderToggleTags.lowerBound
                    if value == 1.0 {
                        // add +12 to transposeAmt if positive, -12 if negative
                    } else {
                        // add -12 to transposeAmt if positive, +12 if negative
                    }
                }
            }
        }
        
    }
    //*****************************************************************
    // MARK: - Helpers
    //*****************************************************************
    
    func updateTransposeBtn(notePosition: Int, transposeAmt: Int) {
        
        let labelTag = notePosition + sliderLabelTags.lowerBound
        if let label = view.viewWithTag(labelTag) as? TransposeButton {
            label.text = "\(transposeAmt)"
        }
    }
    
    //*****************************************************************
    // MARK: - IBActions
    //*****************************************************************
    
    
}


