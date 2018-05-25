//
//  Parent+Keyboard.swift
//  AudioKitSynthOne
//
//  Created by Aurelius Prochazka on 5/25/18.
//  Copyright © 2018 AudioKit. All rights reserved.
//

// Keyboard Pop Over Delegate

extension ParentViewController: KeyboardPopOverDelegate {

    func didFinishSelecting(octaveRange: Int, labelMode: Int, darkMode: Bool) {
        keyboardView.octaveCount = octaveRange
        keyboardView.labelMode = labelMode
        keyboardView.darkMode = darkMode
        keyboardView.setNeedsDisplay()

        saveAppSettingValues()
    }
}

// Keyboard Delegate Note on/off

extension ParentViewController: AKKeyboardDelegate {

    public func noteOn(note: MIDINoteNumber, velocity: MIDIVelocity = 127) {
        sustainer.play(noteNumber: note, velocity: velocity)
    }

    public func noteOff(note: MIDINoteNumber) {
        sustainer.stop(noteNumber: note)
    }
}
