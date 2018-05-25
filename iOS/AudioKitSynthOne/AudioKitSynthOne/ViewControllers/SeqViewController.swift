//
//  SeqViewController.swift
//  AudioKitSynthOne
//
//  Created by Matthew Fecher on 8/1/17.
//  Copyright © 2017 AudioKit. All rights reserved.
//

import UIKit

class SeqViewController: SynthPanelController {

    @IBOutlet weak var seqStepsStepper: Stepper!
    @IBOutlet weak var octaveStepper: Stepper!
    @IBOutlet weak var arpDirectionButton: ArpDirectionButton!
    @IBOutlet weak var arpSeqToggle: ToggleSwitch!
    @IBOutlet weak var arpToggle: ToggleButton!
    @IBOutlet weak var arpInterval: MIDIKnob!

    var arpSeqOctBoostButtons = [SliderTransposeButton]()
    var arpSeqPatternSliders = [VerticalSlider]()
    var arpSeqNoteOnButtons = [ArpButton]()

    // *********************************************************
    // MARK: - Lifecycle
    // *********************************************************

    override func viewDidLoad() {
        super.viewDidLoad()

        viewType = .seqView

        let s = conductor.synth!
        seqStepsStepper.minValue = s.getParameterMin(.arpTotalSteps)
        seqStepsStepper.maxValue = s.getParameterMax(.arpTotalSteps)
        octaveStepper.minValue = s.getParameterMin(.arpOctave)
        octaveStepper.maxValue = s.getParameterMax(.arpOctave)
        arpInterval.range = s.getParameterRange(.arpInterval)

        // Bindings
        conductor.bind(arpToggle, to: .arpIsOn)
        conductor.bind(arpInterval, to: .arpInterval)
        conductor.bind(octaveStepper, to: .arpOctave)
        conductor.bind(arpDirectionButton, to: .arpDirection)
        conductor.bind(arpSeqToggle, to: .arpIsSequencer)
        conductor.bind(seqStepsStepper, to: .arpTotalSteps)

        // ARP/SEQ OCTAVE BOOST
        let arpSeqOctBoostArray: [AKSynthOneParameter] = [.arpSeqOctBoost00, .arpSeqOctBoost01, .arpSeqOctBoost02,
                                                          .arpSeqOctBoost03, .arpSeqOctBoost04, .arpSeqOctBoost05,
                                                          .arpSeqOctBoost06, .arpSeqOctBoost07, .arpSeqOctBoost08,
                                                          .arpSeqOctBoost09, .arpSeqOctBoost10, .arpSeqOctBoost11,
                                                          .arpSeqOctBoost12, .arpSeqOctBoost13, .arpSeqOctBoost14,
                                                          .arpSeqOctBoost15]

        arpSeqOctBoostButtons = self.view.subviews.filter { $0 is SliderTransposeButton }.sorted { $0.tag < $1.tag } as! [SliderTransposeButton]

        for (notePosition, octBoostButton) in arpSeqOctBoostButtons.enumerated() {
            let arpSeqOctBoostParam = arpSeqOctBoostArray[notePosition]
            conductor.bind(octBoostButton, to: arpSeqOctBoostParam) { _, _ in
                return { value in
                    s.setAK1SeqOctBoost(forIndex: notePosition, value)
                    for i in 0...15 {
                        self.updateOctBoostButton(notePosition: i)
                    }
                }
            }
        }

        // ARP/SEQ PATTERN
        let arpSeqPatternArray: [AKSynthOneParameter] = [.arpSeqPattern00, .arpSeqPattern01, .arpSeqPattern02,
                                                         .arpSeqPattern03, .arpSeqPattern04, .arpSeqPattern05,
                                                         .arpSeqPattern06, .arpSeqPattern07, .arpSeqPattern08,
                                                         .arpSeqPattern09, .arpSeqPattern10, .arpSeqPattern11,
                                                         .arpSeqPattern12, .arpSeqPattern13, .arpSeqPattern14,
                                                         .arpSeqPattern15]

        arpSeqPatternSliders = self.view.subviews.filter { $0 is VerticalSlider }.sorted { $0.tag < $1.tag } as! [VerticalSlider]

        for (notePosition, arpSeqPatternSlider) in arpSeqPatternSliders.enumerated() {
            let arpSeqPatternParam = arpSeqPatternArray[notePosition]
            conductor.bind(arpSeqPatternSlider, to: arpSeqPatternParam) { _, control in
                return { value in
                    let tval = Int( (-12 ... 12).clamp(value * 24 - 12) )
                    s.setAK1ArpSeqPattern(forIndex: notePosition, tval )
                    self.conductor.updateSingleUI(arpSeqPatternParam, control: arpSeqPatternSlider, value: Double(tval) )
                }
            }
        }

        // ARP/SEQ NOTE ON/OFF
        let arpSeqNoteOnArray: [AKSynthOneParameter] = [.arpSeqNoteOn00, .arpSeqNoteOn01, .arpSeqNoteOn02,
                                                        .arpSeqNoteOn03, .arpSeqNoteOn04, .arpSeqNoteOn05,
                                                        .arpSeqNoteOn06, .arpSeqNoteOn07, .arpSeqNoteOn08,
                                                        .arpSeqNoteOn09, .arpSeqNoteOn10, .arpSeqNoteOn11,
                                                        .arpSeqNoteOn12, .arpSeqNoteOn13, .arpSeqNoteOn14,
                                                        .arpSeqNoteOn15]

        arpSeqNoteOnButtons = self.view.subviews.filter { $0 is ArpButton }.sorted { $0.tag < $1.tag } as! [ArpButton]

        for (notePosition, arpSeqNoteOnButton) in arpSeqNoteOnButtons.enumerated() {
            let arpSeqPatternParam = arpSeqNoteOnArray[notePosition]
            conductor.bind(arpSeqNoteOnButton, to: arpSeqPatternParam) { _, control in
                return { value in
                    let v = Double(truncating: value > 0 ? true : false)
                    s.setAK1ArpSeqNoteOn(forIndex: notePosition, value >  0 ? true : false )
                    self.conductor.updateSingleUI(arpSeqPatternParam, control: arpSeqNoteOnButton, value: v)
                }
            }
        }
    }

    override func updateUI(_ param: AKSynthOneParameter, control: AKSynthOneControl?, value: Double) {
        for i in 0...15 {
            updateOctBoostButton(notePosition: i)
        }

        // Update arpIsSequencer LED position
        switch param {

        case .arpIsSequencer, .arpIsOn:
             updateLED(beatCounter: 0, heldNotes: 0)
        default:
            _ = 0
        }

    }

    // *****************************************************************
    // MARK: - Helpers
    // *****************************************************************

    @objc public func updateLED(beatCounter: Int, heldNotes: Int = 128) {
        let arpIsOn = conductor.synth.getAK1Parameter(.arpIsOn) > 0 ? true : false
        let arpIsSequencer = conductor.synth.getAK1Parameter(.arpIsSequencer) > 0 ? true : false
        let seqTotalSteps = Int(conductor.synth.getAK1Parameter(.arpTotalSteps))

        // clear out all indicators
        arpSeqOctBoostButtons.forEach { $0.isActive = false }

        // if a non-trivial sequence is playing
        if arpIsOn && arpIsSequencer && seqTotalSteps > 0 {
            let notePosition = (beatCounter + seqTotalSteps - 1) % seqTotalSteps
            if heldNotes != 0 {
                // change the outline current notePosition
                arpSeqOctBoostButtons[notePosition].isActive = true
            } else {
                // on
                arpSeqOctBoostButtons[0].isActive = true
            }
        }
    }

    func updateOctBoostButton(notePosition: Int) {
        let octBoostButton = arpSeqOctBoostButtons[notePosition]
        octBoostButton.transposeAmt = conductor.synth.getAK1ArpSeqPattern(forIndex: notePosition)
        octBoostButton.value = conductor.synth.getAK1SeqOctBoost(forIndex: notePosition) == true ? 1 : 0
    }
}
