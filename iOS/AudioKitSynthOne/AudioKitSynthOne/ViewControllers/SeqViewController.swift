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
        
        seqStepsStepper.minValue = 1
        seqStepsStepper.maxValue = 16
        octaveStepper.minValue = 1
        octaveStepper.maxValue = 4
        arpInterval.range = 0 ... 12

        // Bindings
        conductor.bind(arpToggle,          to: .arpIsOn)
        conductor.bind(arpInterval,        to: .arpInterval)
        conductor.bind(octaveStepper,      to: .arpOctave)
        conductor.bind(arpDirectionButton, to: .arpDirection)
        conductor.bind(arpSeqToggle,       to: .arpIsSequencer)
        conductor.bind(seqStepsStepper,    to: .arpTotalSteps)
        
        setupControlValues()

        updateCallbacks()
    }
    
    func setupControlValues() {

        // Slider
        for tag in sliderTags {
            if let slider = view.viewWithTag(tag) as? VerticalSlider {
                
                slider.callback = { value in
                    let notePosition = Int(tag) - self.sliderTags.lowerBound
                    self.setSequencerNote(notePosition, transposeAmt: Int(value))
                    self.updateTransposeBtn(notePosition: notePosition)
                }
                let notePosition = Int(tag) - self.sliderTags.lowerBound
                let asp = AKSynthOneParameter.arpSeqPattern00.rawValue + notePosition
                if let aspe = AKSynthOneParameter(rawValue: asp) {
                    conductor.bind(slider, to:aspe)
                } else {
                    AKLog("error binding slider to conductor:\(slider), notePosition:\(notePosition)")
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
                slider.value = Double(transposeAmt)
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
        
        ///TODO:Matthew: Do you want to implement seqOctBoost?
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
    
    @objc public func updateLED(beatCounter: Int) {
        let arpIsOn = conductor.synth.getAK1Parameter(.arpIsOn) > 0 ? true : false
        let arpIsSequencer = conductor.synth.getAK1Parameter(.arpIsSequencer) > 0 ? true : false
        let seqNum = Int(conductor.synth.getAK1Parameter(.arpTotalSteps))
        if arpIsOn && arpIsSequencer && seqNum > 0 {
            let notePosition = beatCounter % seqNum
            AKLog("notePosition:\(notePosition)")
            for sliderLabelTag in sliderLabelTags {
                if let label = view.viewWithTag(sliderLabelTag) as? TransposeButton {
                    let labelTag = notePosition + sliderLabelTags.lowerBound
                    if labelTag == sliderLabelTag {
                        label.layer.borderColor = #colorLiteral(red: 0.8812435269, green: 0.4256765842, blue: 0, alpha: 1)
                        label.layer.borderWidth = 2
                    } else {
                        label.layer.borderColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1)
                        label.layer.borderWidth = 1
                    }
                }
            }
        }
    }
    
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

