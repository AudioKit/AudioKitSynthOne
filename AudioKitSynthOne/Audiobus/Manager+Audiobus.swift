//
//  Manager+Audiobus.swift
//  AudioKitSynthOne
//
//  Created by AudioKit Contributors on 5/25/18.
//  Copyright © 2018 AudioKit. All rights reserved.
//

// AudioBus MIDI Input & Preset Loading

extension Manager: ABAudiobusControllerStateIODelegate {

    // MARK: - AudioBus Preset Delegate

    public func audiobusStateDictionaryForCurrentState() -> [AnyHashable: Any]! {
        return [ "preset": activePreset.position]
    }

    public func loadState(fromAudiobusStateDictionary dictionary: [AnyHashable: Any]!,
                          responseMessage outResponseMessage: AutoreleasingUnsafeMutablePointer<NSString?>!) {

        if let abDictionary = dictionary as? [String: Any] {
            activePreset.position = abDictionary["preset"] as? Int ?? 0
            DispatchQueue.main.async {
                self.presetsViewController.didSelectPreset(index: self.activePreset.position)
            }
        }
    }
}
