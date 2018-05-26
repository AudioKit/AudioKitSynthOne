//
//  Parent+MIDIListener.swift
//  AudioKitSynthOne
//
//  Created by Aurelius Prochazka on 5/25/18.
//  Copyright © 2018 AudioKit. All rights reserved.
//

// AKMIDIListener protocol functions

extension ParentViewController: AKMIDIListener {

    public func receivedMIDINoteOn(noteNumber: MIDINoteNumber, velocity: MIDIVelocity, channel: MIDIChannel) {
        guard channel == midiChannelIn || omniMode else { return }
        var newVelocity = velocity
        if !appSettings.velocitySensitive { newVelocity = 127 }

        DispatchQueue.main.async {
            self.keyboardView.pressAdded(noteNumber, velocity: newVelocity)
            self.notesFromMIDI.insert(noteNumber)
        }
    }

    public func receivedMIDINoteOff(noteNumber: MIDINoteNumber, velocity: MIDIVelocity, channel: MIDIChannel) {
        guard (channel == midiChannelIn || omniMode) && !keyboardView.holdMode else { return }

        DispatchQueue.main.async {
            self.keyboardView.pressRemoved(noteNumber)
            self.notesFromMIDI.remove(noteNumber)

            // Mono Mode
            if !self.keyboardView.polyphonicMode {
                let remainingNotes = self.notesFromMIDI.filter { $0 != noteNumber }
                if let highest = remainingNotes.max() {
                    self.keyboardView.pressAdded(highest, velocity: velocity)
                }
            }
        }
    }

    // Assign MIDI CC to active MIDI Learn knobs
    func assignMIDIControlToKnobs(cc: MIDIByte) {
        let activeMIDILearnKnobs = midiKnobs.filter { $0.isActive }
        activeMIDILearnKnobs.forEach {
            $0.midiCC = cc
            $0.isActive = false
        }
    }

    // MIDI Controller input
    public func receivedMIDIController(_ controller: MIDIByte, value: MIDIByte, channel: MIDIChannel) {
        guard channel == midiChannelIn || omniMode else { return }
        /// AKLog("Channel: \(channel+1) controller: \(controller) value: \(value)")

        // If any MIDI Learn knobs are active, assign the CC
        DispatchQueue.main.async {
            if self.midiLearnToggle.isSelected { self.assignMIDIControlToKnobs(cc: controller) }
        }

        // Handle MIDI Control Messages
        switch controller {

        // Mod Wheel
        case AKMIDIControl.modulationWheel.rawValue:
            DispatchQueue.main.async {
                self.modWheelPad.setVerticalValueFrom(midiValue: value)
            }

        // Sustain Pedal
        case AKMIDIControl.damperOnOff.rawValue:
            if value > 0 && !sustainMode {
                sustainer.sustain(down: true)
                sustainMode = true
            } else if sustainMode {
                sustainer.sustain(down: false)
                sustainMode = false
            }

        default:
            break
        }

        // Bank Change msb/cc0
        if controller == 0 {
            guard channel == midiChannelIn || omniMode else { return }

            if Int(value) != self.presetsViewController.bankIndex {
                AKLog ("DIFFERENT MSB")
                DispatchQueue.main.async {
                    self.presetsViewController.didSelectBank(index: Int(value))
                }
            }

        }

        // Check for MIDI learn knobs that match controller
        let matchingKnobs = midiKnobs.filter { $0.midiCC == controller }

        // Set new knob values from MIDI for matching knobs
        matchingKnobs.forEach { midiKnob in
            DispatchQueue.main.async {
                midiKnob.setKnobValueFrom(midiValue: value)
            }
        }
    }

    // MIDI Program/Patch Change
    public func receivedMIDIProgramChange(_ program: MIDIByte, channel: MIDIChannel) {
        guard channel == midiChannelIn || omniMode else { return }
        guard !pcJustTriggered else { return }

        DispatchQueue.main.async {
            self.presetsViewController.didSelectPreset(index: Int(program))
        }

        // Prevent multiple triggers from multiple MIDI inputs
        pcJustTriggered = true
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            self.pcJustTriggered = false
        }
    }

    // MIDI Pitch Wheel
    public func receivedMIDIPitchWheel(_ pitchWheelValue: MIDIWord, channel: MIDIChannel) {
        guard channel == midiChannelIn || omniMode else { return }
        guard let s = Conductor.sharedInstance.synth else { return }
        let val01 = Double(pitchWheelValue).normalized(from: 0...16_383)
        s.setDependentParameter(.pitchbend, val01, 0)
        // UI will be updated by dependentParameterDidChange()
    }

    // After touch
    public func receivedMIDIAfterTouch(_ pressure: MIDIByte, channel: MIDIChannel) {
        guard channel == midiChannelIn || omniMode else { return }
        //         self.conductor.tremolo.frequency = Double(pressure)/20.0
        // self.auMainController.tremoloKnob.setKnobValueFrom(midiValue: pressure)
    }

    // MIDI Setup Change
    public func receivedMIDISetupChange() {
        // AKLog("midi setup change, midi.inputNames: \(midi.inputNames)")

        let midiInputNames = midi.inputNames
        midiInputNames.forEach { inputName in

            // check to see if input exists
            if let index = midiInputs.index(where: { $0.name == inputName }) {
                midiInputs.remove(at: index)
            }

            let newMIDI = MIDIInput(name: inputName, isOpen: true)
            midiInputs.append(newMIDI)
            midi.openInput(inputName)
        }
    }

}
