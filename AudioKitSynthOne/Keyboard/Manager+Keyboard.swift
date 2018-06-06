//
//  Manager+Keyboard.swift
//  AudioKitSynthOne
//
//  Created by AudioKit Contributors on 5/25/18.
//  Copyright © 2018 AudioKit. All rights reserved.
//

// Keyboard Pop Over Delegate

extension Manager: KeyboardPopOverDelegate {

    func didFinishSelecting(octaveRange: Int, labelMode: Int, darkMode: Bool) {
        keyboardView.octaveCount = octaveRange
        keyboardView.labelMode = labelMode
        keyboardView.darkMode = darkMode
        keyboardView.setNeedsDisplay()

        saveAppSettingValues()
    }
}

// Keyboard Delegate Note on/off

extension Manager: AKKeyboardDelegate {

    public func noteOn(note: MIDINoteNumber, velocity: MIDIVelocity = 127) {
        sustainer.play(noteNumber: note, velocity: velocity)
    }

    public func noteOff(note: MIDINoteNumber) {
        sustainer.stop(noteNumber: note)
    }
}
