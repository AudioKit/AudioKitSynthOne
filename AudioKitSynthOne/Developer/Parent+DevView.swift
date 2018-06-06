//
//  Parent+DevView.swift
//  AudioKitSynthOne
//
//  Created by AudioKit Contributors on 5/25/18.
//  Copyright © 2018 AudioKit. All rights reserved.
//

extension ParentViewController: AboutDelegate {

    func showDevView() {
        isDevView = false
        devPressed()
    }
}

// DevViewDelegate protocol functions

extension ParentViewController: DevViewDelegate {

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
