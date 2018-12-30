//
//  Rate.swift
//  AudioKitSynthOne
//
//  Created by AudioKit Contributors on 8/5/17.
//  Copyright © 2017 AudioKit. All rights reserved.
//

import UIKit

public enum Rate: Int, CustomStringConvertible {

    case eightBars = 0
    case sixBars
    case fourBars
    case threeBars
    case twoBars
    case bar
    case barTriplet
    case half
    case halfTriplet
    case quarter
    case quarterTriplet
    case eighth
    case eighthTriplet
    case sixteenth
    case sixteenthTriplet
    case thirtySecondth
    case thirtySecondthTriplet
    case sixtyFourth
    case sixtyFourthTriplet

    // count of enums
    static let count: Int = {
        var max: Int = 0
        while let _ = Rate(rawValue: max) { max += 1 }
        return max
    }()

    public var description: String {
        switch self {
        case .eightBars:
            return "8 bars"
        case .sixBars:
            return "6 bars"
        case .fourBars:
            return "4 bars"
        case .threeBars:
            return "3 bars"
        case .twoBars:
            return "2 bars"
        case .bar:
            return "1 bar"
        case .barTriplet:
            return "1 bar triplet"
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
        case .thirtySecondthTriplet:
            return "1/32 triplet"
        case .sixtyFourth:
            return "1/64 note"
        case .sixtyFourthTriplet:
            return "1/64 triplet"
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
        case .sixBars:
            return seconds(bars: 6)
        case .fourBars:
            return seconds(bars: 4)
        case .threeBars:
            return seconds(bars: 3)
        case .twoBars:
            return seconds(bars: 2)
        case .bar:
            return seconds(bars: 1)
        case .barTriplet:
            return seconds(bars: 1, triplet: true)
        case .half:
            return seconds(bars: 1 / 2)
        case .halfTriplet:
            return seconds(bars: 1 / 2, triplet: true)
        case .quarter:
            return seconds(bars: 1 / 4)
        case .quarterTriplet:
            return seconds(bars: 1 / 4, triplet: true)
        case .eighth:
            return seconds(bars: 1 / 8)
        case .eighthTriplet:
            return seconds(bars: 1 / 8, triplet: true)
        case .sixteenth:
            return seconds(bars: 1 / 16)
        case .sixteenthTriplet:
            return seconds(bars: 1 / 16, triplet: true)
        case .thirtySecondth:
            return seconds(bars: 1 / 32)
        case .thirtySecondthTriplet:
            return seconds(bars: 1 / 32, triplet: true)
        case .sixtyFourth:
            return seconds(bars: 1 / 64)
        case .sixtyFourthTriplet:
            return seconds(bars: 1 / 64, triplet: true)
        }
    }

    var factor: Double {
        switch self {
        case .eightBars:
            return 8
        case .sixBars:
            return 6
        case .fourBars:
            return 4
        case .threeBars:
            return 3
        case .twoBars:
            return 2
        case .bar:
            return 1
        case .barTriplet:
            return 1 / 1.5
        case .half:
            return 1 / 2
        case .halfTriplet:
            return 1 / 2 / 1.5
        case .quarter:
            return 1 / 4
        case .quarterTriplet:
            return 1 / 4 / 1.5
        case .eighth:
            return 1 / 8
        case .eighthTriplet:
            return 1 / 8 / 1.5
        case .sixteenth:
            return 1 / 16
        case .sixteenthTriplet:
            return 1 / 16 / 1.5
        case .thirtySecondth:
            return 1 / 32
        case .thirtySecondthTriplet:
            return 1 / 32 / 1.5
        case .sixtyFourth:
            return 1 / 64
        case .sixtyFourthTriplet:
            return 1 / 64 / 1.5
        }
    }

    func seconds(bars: Double = 1.0, triplet: Bool = false) -> Double {
        guard let s = Conductor.sharedInstance.synth else { return 0.0 }
        let minutesPerSecond = 1.0 / 60.0
        let beatsPerBar = 4.0
        return (beatsPerBar * bars) / (s.getSynthParameter(.arpRate) * minutesPerSecond) / (triplet ? 1.5 : 1)
    }

    private static func findMinimum(_ value: Double, comparator: (Int) -> Double) -> Rate {
        var closestRate = Rate(rawValue: 0)
        var smallestDifference = 1_000_000_000.0
        for i in 0 ..< Rate.count {
            let difference: Double = abs(comparator(i) - value)
            if  difference < smallestDifference {
                smallestDifference = difference
                closestRate = Rate(rawValue: i)
            }
        }
        return closestRate ?? Rate.sixtyFourth
    }

    static func fromFrequency(_ frequency: Double) -> Rate {
        return(Rate.findMinimum(frequency, comparator: { (i) -> Double in
            (Rate(rawValue: i) ?? Rate.sixtyFourth).frequency
        }))
    }

    static func fromTime(_ time: Double) -> Rate {
        return(Rate.findMinimum(time, comparator: { (i) -> Double in
            (Rate(rawValue: i) ?? Rate.sixtyFourth).time
        }))
    }

    static func fromFactor(_ factor: Double) -> Rate {
        return(Rate.findMinimum(factor, comparator: { (i) -> Double in
            (Rate(rawValue: i) ?? Rate.sixtyFourth).factor
        }))
    }
}
