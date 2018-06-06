//
//  ArpSeqPanel.swift
//  AudioKitSynthOne
//
//  Created by AudioKit Contributors on 8/1/17.
//  Copyright © 2017 AudioKit. All rights reserved.
//

import UIKit

class ArpSeqPanel: Panel {

    @IBOutlet weak var seqStepsStepper: Stepper!
    @IBOutlet weak var octaveStepper: Stepper!
    @IBOutlet weak var arpDirectionButton: ArpDirectionButton!
    @IBOutlet weak var arpSeqToggle: ToggleSwitch!
    @IBOutlet weak var arpToggle: ToggleButton!
    @IBOutlet weak var arpInterval: MIDIKnob!

    var octaveBoostButtons = [SliderTransposeButton]()
    var sliders = [VerticalSlider]()
    var noteOnButtons = [ArpButton]()

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()

        viewType = .arpSeq

        guard let s = conductor.synth else {
            AKLog("ArpSeqPanel view state is invalid because synth is not instantiated")
            return
        }

        seqStepsStepper.minValue = s.getMinimum(.arpTotalSteps)
        seqStepsStepper.maxValue = s.getMaximum(.arpTotalSteps)
        octaveStepper.minValue = s.getMinimum(.arpOctave)
        octaveStepper.maxValue = s.getMaximum(.arpOctave)
        arpInterval.range = s.getRange(.arpInterval)

        // Bindings
        conductor.bind(arpToggle, to: .arpIsOn)
        conductor.bind(arpInterval, to: .arpInterval)
        conductor.bind(octaveStepper, to: .arpOctave)
        conductor.bind(arpDirectionButton, to: .arpDirection)
        conductor.bind(arpSeqToggle, to: .arpIsSequencer)
        conductor.bind(seqStepsStepper, to: .arpTotalSteps)

        // ARP/SEQ OCTAVE BOOST
        let arpSeqOctBoostArray: [S1Parameter] = [.arpSeqOctBoost00, .arpSeqOctBoost01, .arpSeqOctBoost02,
                                                  .arpSeqOctBoost03, .arpSeqOctBoost04, .arpSeqOctBoost05,
                                                  .arpSeqOctBoost06, .arpSeqOctBoost07, .arpSeqOctBoost08,
                                                  .arpSeqOctBoost09, .arpSeqOctBoost10, .arpSeqOctBoost11,
                                                  .arpSeqOctBoost12, .arpSeqOctBoost13, .arpSeqOctBoost14,
                                                  .arpSeqOctBoost15]

        octaveBoostButtons.removeAll() // just in case we run this more than once
        for view in view.subviews.sorted(by: { $0.tag < $1.tag }) {
            guard let sliderTransposeButton = view as? SliderTransposeButton else { continue }
            octaveBoostButtons.append(sliderTransposeButton)
        }

        for (notePosition, octBoostButton) in octaveBoostButtons.enumerated() {
            let arpSeqOctBoostParameter = arpSeqOctBoostArray[notePosition]
            conductor.bind(octBoostButton, to: arpSeqOctBoostParameter) { _, _ in
                return { value in
                    s.setOctaveBoost(forIndex: notePosition, value)
                    for i in 0...15 {
                        self.updateOctBoostButton(notePosition: i)
                    }
                }
            }
        }

        // ARP/SEQ PATTERN
        let arpSeqPatternArray: [S1Parameter] = [.arpSeqPattern00, .arpSeqPattern01, .arpSeqPattern02,
                                                 .arpSeqPattern03, .arpSeqPattern04, .arpSeqPattern05,
                                                 .arpSeqPattern06, .arpSeqPattern07, .arpSeqPattern08,
                                                 .arpSeqPattern09, .arpSeqPattern10, .arpSeqPattern11,
                                                 .arpSeqPattern12, .arpSeqPattern13, .arpSeqPattern14,
                                                 .arpSeqPattern15]

        sliders.removeAll() // just in case we run this more than once
        for view in view.subviews.sorted(by: { $0.tag < $1.tag }) {
            guard let verticalSlider = view as? VerticalSlider else { continue }
            sliders.append(verticalSlider)
        }

        for (notePosition, arpSeqPatternSlider) in sliders.enumerated() {
            let arpSeqPatternParameter = arpSeqPatternArray[notePosition]
            conductor.bind(arpSeqPatternSlider, to: arpSeqPatternParameter) { _, control in
                return { value in
                    let tval = Int( (-12 ... 12).clamp(value * 24 - 12) )
                    s.setPattern(forIndex: notePosition, tval )
                    self.conductor.updateSingleUI(arpSeqPatternParameter,
                                                  control: arpSeqPatternSlider,
                                                  value: Double(tval))
                }
            }
        }

        // ARP/SEQ NOTE ON/OFF
        let arpSeqNoteOnArray: [S1Parameter] = [.arpSeqNoteOn00, .arpSeqNoteOn01, .arpSeqNoteOn02,
                                                .arpSeqNoteOn03, .arpSeqNoteOn04, .arpSeqNoteOn05,
                                                .arpSeqNoteOn06, .arpSeqNoteOn07, .arpSeqNoteOn08,
                                                .arpSeqNoteOn09, .arpSeqNoteOn10, .arpSeqNoteOn11,
                                                .arpSeqNoteOn12, .arpSeqNoteOn13, .arpSeqNoteOn14,
                                                .arpSeqNoteOn15]

        noteOnButtons.removeAll() // just in case we run this more than once
        for view in view.subviews.sorted(by: { $0.tag < $1.tag }) {
            guard let arpButton = view as? ArpButton else { continue }
            noteOnButtons.append(arpButton)
        }

        for (notePosition, arpSeqNoteOnButton) in noteOnButtons.enumerated() {
            let arpSeqPatternParameter = arpSeqNoteOnArray[notePosition]
            conductor.bind(arpSeqNoteOnButton, to: arpSeqPatternParameter) { _, control in
                return { value in
                    let v = Double(truncating: value > 0 ? true : false)
                    s.setNoteOn(forIndex: notePosition, value > 0 ? true : false )
                    self.conductor.updateSingleUI(arpSeqPatternParameter, control: arpSeqNoteOnButton, value: v)
                }
            }
        }
    }

    override func updateUI(_ parameter: S1Parameter, control: S1Control?, value: Double) {
        for i in 0...15 {
            updateOctBoostButton(notePosition: i)
        }

        // Update arpIsSequencer LED position
        switch parameter {

        case .arpIsSequencer, .arpIsOn:
             updateLED(beatCounter: 0, heldNotes: 0)
        default:
            _ = 0
        }

    }

    // MARK: - Helpers

    @objc public func updateLED(beatCounter: Int, heldNotes: Int = 128) {
        let arpIsOn = conductor.synth.getSynthParameter(.arpIsOn) > 0 ? true : false
        let arpIsSequencer = conductor.synth.getSynthParameter(.arpIsSequencer) > 0 ? true : false
        let seqTotalSteps = Int(conductor.synth.getSynthParameter(.arpTotalSteps))

        // clear out all indicators
        octaveBoostButtons.forEach { $0.isActive = false }

        // if a non-trivial sequence is playing
        if arpIsOn && arpIsSequencer && seqTotalSteps > 0 {
            let notePosition = (beatCounter + seqTotalSteps - 1) % seqTotalSteps
            if heldNotes != 0 {
                // change the outline current notePosition
                octaveBoostButtons[notePosition].isActive = true
            } else {
                // on
                octaveBoostButtons[0].isActive = true
            }
        }
    }

    func updateOctBoostButton(notePosition: Int) {
        let octBoostButton = octaveBoostButtons[notePosition]
        octBoostButton.transposeAmt = conductor.synth.getPattern(forIndex: notePosition)
        octBoostButton.value = conductor.synth.getOctaveBoost(forIndex: notePosition) == true ? 1 : 0
    }
}
