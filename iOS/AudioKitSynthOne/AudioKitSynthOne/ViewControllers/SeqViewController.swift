//
//  SeqViewController.swift
//  AudioKitSynthOne
//
//  Created by Matthew Fecher on 8/1/17.
//  Copyright © 2017 AudioKit. All rights reserved.
//


import UIKit

class SeqViewController: UpdatableViewController {
    
    @IBOutlet weak var displayLabel: UILabel!
    
    let sliderTags = 400 ... 415
    let sliderToggleTags = 500 ... 515
    let sliderLabelTags = 550 ... 565
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Set Knob Delegates
        setDelegates()
        
        // Update Knob & Slider UI Values
        setupSliderValues()
        
        updateCallbacks()
    }
    
    // *********************************************************
    // MARK: - Set Delegates
    // *********************************************************
    
    func setDelegates() {
        
    }
    
    func setupSliderValues() {
        
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
    
    //*****************************************************************
    // MARK: - Callbacks
    //*****************************************************************
    
    override func updateCallbacks() {
        
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


