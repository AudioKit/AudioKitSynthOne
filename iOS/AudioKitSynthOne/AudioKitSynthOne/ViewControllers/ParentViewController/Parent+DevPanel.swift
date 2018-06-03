//
//  Parent+DevPanel.swift
//  AudioKitSynthOne
//
//  Created by AudioKit Contributors on 5/25/18.
//  Copyright © 2018 AudioKit. All rights reserved.
//

extension ParentViewController: AboutDelegate {

    func showDevPanel() {
        isDevView = false
        devPressed()
    }
}

// DevPanelDelegate protocol functions

extension ParentViewController: DevPanelDelegate {

    func freezeArpRateChanged(_ value: Bool) {
        appSettings.freezeArpRate = value
    }

    func freezeReverbChanged(_ value: Bool) {
        appSettings.freezeReverb = value
    }

    func freezeDelayChanged(_ value: Bool) {
        appSettings.freezeDelay = value
    }

    func portamentoChanged(_ value: Double) {
        appSettings.portamentoHalfTime = value
    }
}
