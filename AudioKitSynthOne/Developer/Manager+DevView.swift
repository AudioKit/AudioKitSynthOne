//
//  Manager+DevView.swift
//  AudioKitSynthOne
//
//  Created by AudioKit Contributors on 5/25/18.
//  Copyright © 2018 AudioKit. All rights reserved.
//

extension Manager: AboutDelegate {

    func showDevView() {
        isDevView = false
        devPressed()
    }
}

// DevViewDelegate protocol functions

extension Manager: DevViewDelegate {

    func freezeArpRateChanged(_ value: Bool) {
        appSettings.freezeArpRate = value
        Conductor.sharedInstance.updateDisplayLabel("Freeze Arp Rate: \(value == false ? "false" : "true")")
        saveAppSettings()
    }

    func freezeReverbChanged(_ value: Bool) {
        appSettings.freezeReverb = value
        Conductor.sharedInstance.updateDisplayLabel("Freeze Reverb: \(value == false ? "false" : "true")")
        saveAppSettings()
    }

    func freezeDelayChanged(_ value: Bool) {
        appSettings.freezeDelay = value
        Conductor.sharedInstance.updateDisplayLabel("Freeze Delay: \(value == false ? "false" : "true")")
        saveAppSettings()
    }

    func freezeArpSeqChanged(_ value: Bool) {
        appSettings.freezeArpSeq = value
        Conductor.sharedInstance.updateDisplayLabel("Freeze Arp+Sequencer: \(value == false ? "false" : "true")")
        saveAppSettings()
    }

    func portamentoChanged(_ value: Double) {
        appSettings.portamentoHalfTime = value
        Conductor.sharedInstance.updateDisplayLabel("dsp smoothing half time: \(value.decimalString)")
        saveAppSettings()
    }

    func whiteKeysOnlyChanged(_ value: Bool) {
        appSettings.whiteKeysOnly = value
        Conductor.sharedInstance.updateDisplayLabel("White Keys Only: \(value == false ? "false" : "true")")
        saveAppSettings()
    }
}
