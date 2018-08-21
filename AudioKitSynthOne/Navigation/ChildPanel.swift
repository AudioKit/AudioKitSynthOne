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
            return "EnvelopesPanel"
        case .touchPad:
            return "TouchPadPanel"
        case .effects:
            return "EffectsPanel"
        case .sequencer:
            return "SequencerPanel"
        case .tunings:
            return "TuningsPanel"
        }
    }

    func buttonText() -> String {
        switch self {
        case .generators:
            return NSLocalizedString("MAIN", comment: "Main Panel Abbreviation")
        case .envelopes:
            return NSLocalizedString("ENV", comment: "Envelope Panel Abbreviation")
        case .touchPad:
            return NSLocalizedString("PAD", comment: "TouchPad Panel Abbreviation")
        case .effects:
            return NSLocalizedString("FX", comment: "FX/LFO Panel Abbreviation")
        case .sequencer:
            return NSLocalizedString("SEQ", comment: "Arp/Sequencer Panel Abbreviation")
        case .tunings:
            return NSLocalizedString("TUNE", comment: "Tuning Panel Abbreviation")
        }
    }

    func leftPanel() -> ChildPanel {
        var leftValue = self.rawValue - 1
        if leftValue < 0 { leftValue = ChildPanel.maxValue }
        return ChildPanel(rawValue: leftValue) ?? ChildPanel.generators
    }

    func rightPanel() -> ChildPanel {
        var rightValue = self.rawValue + 1
        if rightValue > ChildPanel.maxValue { rightValue = 0 }
        return ChildPanel(rawValue: rightValue) ?? ChildPanel.generators
    }
}
