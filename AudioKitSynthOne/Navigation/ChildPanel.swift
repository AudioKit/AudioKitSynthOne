//
//  ChildView.swift
//  AudioKitSynthOne
//
//  Created by AudioKit Contributors on 8/30/17.
//  Copyright © 2017 AudioKit. All rights reserved.
//

import Foundation

public enum ChildPanel: Int {
    case mainPanel = 0
    case adsrView = 1
    case padView = 2
    case fxView = 3
    case seqView = 4
    case tuningsView = 5

    static let maxValue = 5

    func identifier() -> String {
        switch self {
        case .mainPanel:
            return "MainPanel"
        case .adsrView:
            return "ADSRViewController"
        case .padView:
            return "TouchPadViewController"
        case .fxView:
            return "FXViewController"
        case .seqView:
            return "SeqViewController"
        case .tuningsView:
            return "TuningsViewController"
        }
    }

    func buttonText() -> String {
        switch self {
        case .mainPanel:
            return "MAIN"
        case .adsrView:
            return "ADSR"
        case .padView:
            return "PAD"
        case .fxView:
            return "FX"
        case .seqView:
            return "ARP"
        case .tuningsView:
            return "TUNE"
        }
    }

    func leftView() -> ChildPanel {
        var leftValue = self.rawValue - 1
        if leftValue < 0 { leftValue = ChildPanel.maxValue }
        return ChildPanel(rawValue: leftValue)!
    }

    func rightView() -> ChildPanel {
        var rightValue = self.rawValue + 1
        if rightValue > ChildPanel.maxValue { rightValue = 0 }
        return ChildPanel(rawValue: rightValue)!
    }
}
