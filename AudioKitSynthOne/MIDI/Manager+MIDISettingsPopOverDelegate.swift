//
//  Manager+MIDISettingsPopoverDelegate.swift
//  AudioKitSynthOne
//
//  Created by AudioKit Contributors on 5/25/18.
//  Copyright © 2018 AudioKit. All rights reserved.
//

// MIDI Settings Pop Over Delegate

extension Manager: MIDISettingsPopOverDelegate {

    func resetMIDILearn() {
        for control in midiControls { control.midiCC = 255 }
        saveAppSettingValues()
    }

    func didSelectMIDIChannel(newChannel: Int) {
        if newChannel > -1 {
            conductor.midiInChannel = MIDIByte(newChannel)
            conductor.isOmniMode = false
        } else {
            conductor.midiInChannel = 0
            conductor.isOmniMode = true
        }
        saveAppSettingValues()
    }

    func didToggleVelocity() {
        appSettings.velocitySensitive = !appSettings.velocitySensitive
        saveAppSettingValues()
    }

    func didChangeMIDISources(_ midiSources: [MIDIInput]) {
        midiInputs = midiSources
        saveAppSettingValues()
    }

    func didToggleBackgroundAudio(_ value: Bool) {
        saveAppSettingValues()
    }
    
    func didToggleNeverSleep() {
        saveAppSettingValues()
    }
    
    func didSetBuffer() {
        saveAppSettingValues()
    }

    func didToggleStoreTuningWithPreset(_ value: Bool) {
        appSettings.saveTuningWithPreset = value
        saveAppSettingValues()
    }

    func didToggleLaunchWithLastTuning(_ value: Bool) {
        appSettings.launchWithLastTuning = value
        saveAppSettingValues()
    }

}
