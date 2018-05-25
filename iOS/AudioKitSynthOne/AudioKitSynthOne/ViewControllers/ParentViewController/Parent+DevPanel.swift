//
//  Parent+DevPanel.swift
//  AudioKitSynthOne
//
//  Created by Aurelius Prochazka on 5/25/18.
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

    public func freezeArpChanged(_ value: Bool) {
        appSettings.freezeArpRate = value
    }

    public func getFreezeArpChangedValue() -> Bool {
        return appSettings.freezeArpRate
    }

}
