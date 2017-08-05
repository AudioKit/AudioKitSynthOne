//
//  Knob+TempoSync.swift
//  AudioKitSynthOne
//
//  Created by Matthew Fecher on 8/5/17.
//  Copyright © 2017 AudioKit. All rights reserved.
//

import UIKit

var tempo = Tempo(bpm: 80)

public enum Rate: Int {
    
    case eightBars = 0
    case fourBars
    case twoBars
    case bar
    case half
    case halfTriplet
    case quarter
    case quarterTriplet
    case eighth
    case eighthTriplet
    case sixteenth
    case sixteenthTriplet
    case thirtySecondth
    case sixtyFourth
    
    func rateString() -> String {
        switch self {
        case .eightBars:
            return "8 bars"
        case .fourBars:
            return "4 bars"
        case .twoBars:
            return "2 bars"
        case .bar:
            return "1 bar"
        case .half:
            return "1/2 note"
        case .halfTriplet:
            return "1/2 triplet"
        case .quarter:
            return "1/4 note"
        case .quarterTriplet:
            return "1/4 triplet"
        case .eighth:
            return "1/8 note"
        case .eighthTriplet:
            return "1/8 triplet"
        case .sixteenth:
            return "1/16 note"
        case .sixteenthTriplet:
            return "1/16 triplet"
        case .thirtySecondth:
            return "1/32 note"
        case .sixtyFourth:
            return "1/64 note"
        default:
            return "unknown"
        }
    }
    
    func rateFreq() -> Double {
        // code to caculate Freq Tempo
        return 0.0
    }
    
    func rateTime() -> Double {
        switch self {
        case .eightBars:
            return tempo.eightBars()
        case .fourBars:
            return tempo.fourBars()
        case .twoBars:
            return tempo.twoBars()
        case .bar:
            return tempo.bar()
        case .half:
            return tempo.half()
        case .halfTriplet:
            return tempo.halfTriplet()
        case .quarter:
            return tempo.quarter()
        case .quarterTriplet:
            return tempo.quarterTriplet()
        case .eighth:
            return tempo.eighth()
        case .eighthTriplet:
            return tempo.eighthTriplet()
        case .sixteenth:
            return tempo.sixteenth()
        case .sixteenthTriplet:
            return tempo.sixteenthTriplet()
        case .thirtySecondth:
            return tempo.thirtysecondth()
        case .sixtyFourth:
            return tempo.sixtyFourth()
        default:
            return 1.0
        }
    }
    
}

