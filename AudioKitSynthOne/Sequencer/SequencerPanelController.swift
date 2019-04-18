//
//  SequencerPanelController.swift
//  AudioKitSynthOne
//
//  Created by AudioKit Contributors on 8/1/17.
//  Copyright © 2017 AudioKit. All rights reserved.
//

import UIKit
import CoreGraphics


class SequencerPanelController: PanelController {

    @IBOutlet weak var arpToggle: MIDIToggleButton!

    @IBOutlet weak var arpInterval: MIDIKnob!

    @IBOutlet weak var octaveStepper: MIDIStepper!

    @IBOutlet weak var arpDirectionButton: MIDIArpDirectionButton!

    @IBOutlet weak var sequencerToggle: MIDIToggleSwitch!

    @IBOutlet weak var seqStepsStepper: MIDIStepper!
    
    @IBOutlet weak var arpSeqTempoMultiplier: MIDIKnob!

    var octBoostButtons = [SliderTransposeButton]()

    var sliders = [VerticalSlider]()

    var noteOnButtons = [ArpButton]()

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        currentPanel = .sequencer
        guard let s = conductor.synth else {
            AKLog("SequencerPanel view state is invalid because synth is not instantiated")
            return
        }
        conductor.bind(arpToggle, to: .arpIsOn)
        arpInterval.range = s.getRange(.arpInterval)
        arpInterval.value = s.getSynthParameter(.arpInterval)
        conductor.bind(arpInterval, to: .arpInterval)
        octaveStepper.minValue = s.getMinimum(.arpOctave)
        octaveStepper.maxValue = s.getMaximum(.arpOctave)
        conductor.bind(octaveStepper, to: .arpOctave)
        conductor.bind(arpDirectionButton, to: .arpDirection)
        conductor.bind(sequencerToggle, to: .arpIsSequencer)
        seqStepsStepper.minValue = s.getMinimum(.arpTotalSteps)
        seqStepsStepper.maxValue = s.getMaximum(.arpTotalSteps)
        conductor.bind(seqStepsStepper, to: .arpTotalSteps)

        // dependent param needs custom callback
        arpSeqTempoMultiplier.range = 0...1
        arpSeqTempoMultiplier.taper = 1
        arpSeqTempoMultiplier.value = s.getDependentParameter(.arpSeqTempoMultiplier)
        arpSeqTempoMultiplier.callback = { value in
            s.setDependentParameter(.arpSeqTempoMultiplier, value, self.conductor.arpSeqTempoMultiplierID)
            self.conductor.updateDisplayLabel(.arpSeqTempoMultiplier, value: s.getSynthParameter(.arpSeqTempoMultiplier))
        }

        // ARP/SEQ OCTAVE BOOST
        let sequencerOctBoostArray: [S1Parameter] = [.sequencerOctBoost00, .sequencerOctBoost01, .sequencerOctBoost02,
                                                     .sequencerOctBoost03, .sequencerOctBoost04, .sequencerOctBoost05,
                                                     .sequencerOctBoost06, .sequencerOctBoost07, .sequencerOctBoost08,
                                                     .sequencerOctBoost09, .sequencerOctBoost10, .sequencerOctBoost11,
                                                     .sequencerOctBoost12, .sequencerOctBoost13, .sequencerOctBoost14,
                                                     .sequencerOctBoost15]
        octBoostButtons.removeAll() // just in case we run this more than once
        for view in view.subviews.sorted(by: { $0.tag < $1.tag }) {
            guard let sliderTransposeButton = view as? SliderTransposeButton else { continue }
            octBoostButtons.append(sliderTransposeButton)
        }
        for (notePosition, octBoostButton) in octBoostButtons.enumerated() {
            let sequencerOctBoostParameter = sequencerOctBoostArray[notePosition]
            conductor.bind(octBoostButton, to: sequencerOctBoostParameter) { _, _ in
                return { value in
                    s.setOctaveBoost(forIndex: notePosition, value)
                    self.updateOctBoostButton(notePosition: notePosition)
                }
            }
        }

        // ARP/SEQ PATTERN
        let sequencerPatternArray: [S1Parameter] = [.sequencerPattern00, .sequencerPattern01, .sequencerPattern02,
                                                    .sequencerPattern03, .sequencerPattern04, .sequencerPattern05,
                                                    .sequencerPattern06, .sequencerPattern07, .sequencerPattern08,
                                                    .sequencerPattern09, .sequencerPattern10, .sequencerPattern11,
                                                    .sequencerPattern12, .sequencerPattern13, .sequencerPattern14,
                                                    .sequencerPattern15]
        sliders.removeAll()
        for view in view.subviews.sorted(by: { $0.tag < $1.tag }) {
            guard let verticalSlider = view as? VerticalSlider else { continue }
            sliders.append(verticalSlider)
        }
        for (notePosition, sequencerPatternSlider) in sliders.enumerated() {
            let sequencerPatternParameter = sequencerPatternArray[notePosition]
            conductor.bind(sequencerPatternSlider, to: sequencerPatternParameter) { _, control in
                return { value in
                    let r = self.conductor.synth.getRange(sequencerPatternParameter)
                    let transpose = Int(Double(value).denormalized(to: r))
                    s.setPattern(forIndex: notePosition, transpose)
                    self.conductor.updateSingleUI(sequencerPatternParameter,
                                                  control: sequencerPatternSlider,
                                                  value: Double(transpose))
                }
            }
        }

        // ARP/SEQ NOTE ON/OFF
        let sequencerNoteOnArray: [S1Parameter] = [.sequencerNoteOn00, .sequencerNoteOn01, .sequencerNoteOn02,
                                                   .sequencerNoteOn03, .sequencerNoteOn04, .sequencerNoteOn05,
                                                   .sequencerNoteOn06, .sequencerNoteOn07, .sequencerNoteOn08,
                                                   .sequencerNoteOn09, .sequencerNoteOn10, .sequencerNoteOn11,
                                                   .sequencerNoteOn12, .sequencerNoteOn13, .sequencerNoteOn14,
                                                   .sequencerNoteOn15]
        noteOnButtons.removeAll()
        for view in view.subviews.sorted(by: { $0.tag < $1.tag }) {
            guard let arpButton = view as? ArpButton else { continue }
            noteOnButtons.append(arpButton)
        }
        for (notePosition, sequencerNoteOnButton) in noteOnButtons.enumerated() {
            let sequencerPatternParameter = sequencerNoteOnArray[notePosition]
            conductor.bind(sequencerNoteOnButton, to: sequencerPatternParameter) { _, control in
                return { value in
                    let v = Double(truncating: value > 0 ? true : false)
                    s.setNoteOn(forIndex: notePosition, value > 0 ? true : false )
                    self.conductor.updateSingleUI(sequencerPatternParameter, control: sequencerNoteOnButton, value: v)
                }
            }
        }
		setAccessibilityReadOrder()
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

    func dependentParameterDidChange(_ dependentParameter: DependentParameter) {
        if (dependentParameter.parameter == .arpSeqTempoMultiplier) {
            if dependentParameter.payload == conductor.arpSeqTempoMultiplierID {
                return
            }
            arpSeqTempoMultiplier.value = Double(dependentParameter.normalizedValue)
        }
    }


    // MARK: - Helpers

    @objc public func updateLED(beatCounter: Int, heldNotes: Int = 128) {
        let arpIsOn = conductor.synth.getSynthParameter(.arpIsOn) > 0 ? true : false
        let arpIsSequencer = conductor.synth.getSynthParameter(.arpIsSequencer) > 0 ? true : false
        let seqTotalSteps = Int(conductor.synth.getSynthParameter(.arpTotalSteps))

        // clear out all indicators
        for button in octBoostButtons { button.isActive = false }

        // if a non-trivial sequence is playing
        if arpIsOn && arpIsSequencer && seqTotalSteps > 0 {
            let notePosition = (beatCounter + seqTotalSteps) % seqTotalSteps
            if heldNotes != 0 {
                // change the outline current notePosition
                octBoostButtons[notePosition].isActive = true
            } else {
                // on
                octBoostButtons[0].isActive = true
            }
        }
    }

    internal func updateOctBoostButton(notePosition: Int) {
        let octBoostButton = octBoostButtons[notePosition]
        octBoostButton.transposeAmt = conductor.synth.getPattern(forIndex: notePosition)
        octBoostButton.value = conductor.synth.getOctaveBoost(forIndex: notePosition) == true ? 1 : 0
    }

	/**
	Lot of controls in this view. This is to make it easier.
	*/
	private func setAccessibilityReadOrder() {

		// Sets the read order for VoiceOver
		view.accessibilityElements = [
			arpToggle as Any,
			arpInterval as Any,
			octaveStepper as Any,
			arpDirectionButton as Any,
			sequencerToggle as Any,
			seqStepsStepper as Any,
            arpSeqTempoMultiplier as Any
		]
		for index in 0...15 {
            view.accessibilityElements?.append(octBoostButtons[index])
            view.accessibilityElements?.append(sliders[index])
            view.accessibilityElements?.append(noteOnButtons[index])

		}
		view.accessibilityElements?.append(leftNavButton as Any)
		view.accessibilityElements?.append(rightNavButton as Any)
	}
    
}
