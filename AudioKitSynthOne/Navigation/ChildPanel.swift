//
//  ChildPanel.swift
//  AudioKitSynthOne
//
//  Created by AudioKit Contributors on 8/30/17.
//  Copyright © 2017 AudioKit. All rights reserved.
//

import Foundation

public enum ChildPanel: Int {
    case main = 0
    case adsr = 1
    case touchPad = 2
    case fx = 3
    case arpSeq = 4
    case tunings = 5

    static let maxValue = 5

    func identifier() -> String {
        switch self {
        case .main:
            return "MainPanel"
        case .adsr:
            return "ADSRPanel"
        case .touchPad:
            return "TouchPadPanel"
        case .fx:
            return "FXPanel"
        case .arpSeq:
            return "ArpSeqPanel"
        case .tunings:
            return "TuningsPanel"
        }
    }

    func buttonText() -> String {
        switch self {
        case .main:
            return "MAIN"
        case .adsr:
            return "ADSR"
        case .touchPad:
            return "PAD"
        case .fx:
            return "FX"
        case .arpSeq:
            return "ARP"
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
