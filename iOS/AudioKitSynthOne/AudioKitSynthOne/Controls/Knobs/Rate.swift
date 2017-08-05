//
//  Rate.swift
//  AudioKitSynthOne
//
//  Created by Matthew Fecher on 8/5/17.
//  Copyright © 2017 AudioKit. All rights reserved.
//

import UIKit

public enum Rate: Int, CustomStringConvertible {
    
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
    
    public var description: String {
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
        }
    }
    
    var frequency: Double {
        // code to caculate Freq Tempo
        return 1.0 / time
    }
    
     var time: Double {
        switch self {
        case .eightBars:
            return seconds(bars: 8)
        case .fourBars:
            return seconds(bars: 4)
        case .twoBars:
            return seconds(bars: 2)
        case .bar:
            return seconds(bars: 1)
        case .half:
            return seconds(bars: 1/2)
        case .halfTriplet:
            return seconds(bars: 1/2, triplet: true)
        case .quarter:
            return seconds(bars: 1/4)
        case .quarterTriplet:
            return seconds(bars: 1/4, triplet: true)
        case .eighth:
            return seconds(bars: 1/8)
        case .eighthTriplet:
            return seconds(bars: 1/8, triplet: true)
        case .sixteenth:
            return seconds(bars: 1/16)
        case .sixteenthTriplet:
            return seconds(bars: 1/16, triplet: true)
        case .thirtySecondth:
            return seconds(bars: 1/32)
        case .sixtyFourth:
            return seconds(bars: 1/64)
        }
    }


    func seconds(bars: Double = 1.0, triplet: Bool = false) -> Double {
        let minutesPerSecond = 1.0 / 60.0
        let beatsPerBar = 4.0
        return (beatsPerBar * bars) / (Conductor.sharedInstance.tempo * minutesPerSecond) / (triplet ? 1.5 : 1)
    }
    
}

