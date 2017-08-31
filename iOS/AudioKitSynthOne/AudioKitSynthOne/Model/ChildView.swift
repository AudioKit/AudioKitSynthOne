//
//  ChildView.swift
//  AudioKitSynthOne
//
//  Created by Matthew Fecher on 8/30/17.
//  Copyright © 2017 AudioKit. All rights reserved.
//

import Foundation

public enum ChildView: Int {
    case oscView = 0
    case adsrView = 1
    case padView = 2
    case fxView = 3
    case seqView = 4
    
    static let maxValue = 4
    
    func identifier() -> String {
        switch self {
        case .oscView: return "SourceMixerViewController"
        case .adsrView: return "ADSRViewController"
        case .padView: return "TouchPadViewController"
        case .fxView: return "FXViewController"
        case .seqView: return "SeqViewController"
        }
    }
    
    func btnText() -> String {
        switch self {
        case .oscView: return "MAIN"
        case .adsrView: return "ADSR"
        case .padView: return "PAD"
        case .fxView: return "EFX"
        case .seqView: return "SEQ"
        }
    }
    
    func leftView() -> ChildView {
        var leftValue = self.rawValue - 1
        if leftValue < 0 { leftValue = ChildView.maxValue }
        return ChildView(rawValue: leftValue)!
    }
    
    func rightView() -> ChildView {
        var rightValue = self.rawValue + 1
        if rightValue > ChildView.maxValue { rightValue = 0 }
        return ChildView(rawValue: rightValue)!
    }
}
