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
        midiKnobs.forEach { $0.midiCC = 255 }
        saveAppSettingValues()
    }

    func didSelectMIDIChannel(newChannel: Int) {
        if newChannel > -1 {
            midiChannelIn = MIDIByte(newChannel)
            omniMode = false
        } else {
            midiChannelIn = 0
            omniMode = true
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

    func didChangeMIDISources(_ midiSources: [MIDIInput]) {
        midiInputs = midiSources
        saveAppSettingValues()
    }

    public func storeTuningWithPresetDidChange(_ value: Bool) {
        appSettings.saveTuningWithPreset = value
    }
}
