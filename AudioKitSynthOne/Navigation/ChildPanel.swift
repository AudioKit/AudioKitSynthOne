//
//  ChildPanel.swift
//  AudioKitSynthOne
//
//  Created by AudioKit Contributors on 8/30/17.
//  Copyright © 2017 AudioKit. All rights reserved.
//

import Foundation

public enum ChildPanel: Int {
    case generators = 0
    case envelopes = 1
    case touchPad = 2
    case effects = 3
    case sequencer = 4
    case tunings = 5

    static let maxValue = 5

    func identifier() -> String {
        switch self {
        case .generators:
            return "GeneratorsPanel"
        case .envelopes:
            return "ADSRPanel"
        case .touchPad:
            return "TouchPadPanel"
        case .effects:
            return "FXPanel"
        case .sequencer:
            return "ArpSeqPanel"
        case .tunings:
            return "TuningsPanel"
        }
    }

    func buttonText() -> String {
        switch self {
        case .generators:
            return "GEN"
        case .envelopes:
            return "ENV"
        case .touchPad:
            return "PAD"
        case .effects:
            return "FX"
        case .sequencer:
            return "SEQ"
        case .tunings:
            return "TUNE"
        }
    }

    func leftPanel() -> ChildPanel {
        var leftValue = self.rawValue - 1
        if leftValue < 0 { leftValue = ChildPanel.maxValue }
        return ChildPanel(rawValue: leftValue)!
    }

    func rightPanel() -> ChildPanel {
        var rightValue = self.rawValue + 1
        if rightValue > ChildPanel.maxValue { rightValue = 0 }
        return ChildPanel(rawValue: rightValue)!
    }
}
