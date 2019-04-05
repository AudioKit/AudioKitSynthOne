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
        guard note < 128 else {
            let title = NSLocalizedString("Too High", comment: "Alert Title: Too High")
            let message = NSLocalizedString("MIDI Note > 127. G8 is the highest playable key. Take it down a notch 😉",
                                            comment: "Alert Message: Too High")
            displayAlertController(title, message: message)
            return
        }
        let transformedNoteNumber = appSettings.whiteKeysOnly ? whiteKeysOnlyMap[Int(note)] : note
        sustainer.play(noteNumber: transformedNoteNumber, velocity: velocity)
    }

    public func noteOff(note: MIDINoteNumber) {
        guard note < 128 else { return }
        let transformedNoteNumber = appSettings.whiteKeysOnly ? whiteKeysOnlyMap[Int(note)] : note
        sustainer.stop(noteNumber: transformedNoteNumber)
    }
}
