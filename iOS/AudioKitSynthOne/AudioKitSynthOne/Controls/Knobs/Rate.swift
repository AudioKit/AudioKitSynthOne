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
    case threeBars
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
    
    static let count: Int = {
        var max: Int = 0
        while let _ = Rate(rawValue: max) { max += 1 }
        return max
    }()
    
    public var description: String {
        switch self {
        case .eightBars:
            return "8 bars"
        case .fourBars:
            return "4 bars"
        case .threeBars:
            return "3 bars"
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
        case .threeBars:
            return seconds(bars: 3)
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
        let s = Conductor.sharedInstance.synth!
        return (beatsPerBar * bars) / (s.getAK1Parameter(.arpRate) * minutesPerSecond) / (triplet ? 1.5 : 1)
    }
    
    private static func findMinimum(_ value: Double, comparator: (Int)->Double) -> Rate {
        var closestRate = Rate(rawValue: 0)
        var smallestDifference = 1000000000.0
        for i in 0 ..< Rate.count {
            let difference: Double = abs(comparator(i) - value)
            if  difference < smallestDifference {
                smallestDifference = difference
                closestRate = Rate(rawValue: i)
            }
        }
        return closestRate!
    }
    
    static func fromFrequency(_ frequency: Double) -> Rate {

        return(Rate.findMinimum(frequency, comparator: { (i) -> Double in
            Rate(rawValue: i)!.frequency
        }))
//        var closestRate = Rate(rawValue: 0)
//        var smallestDifference = 1000000000.0
//        for i in 0 ..< Rate.count {
//            let difference: Double = abs(Rate(rawValue: i)!.frequency - frequency)
//            if  difference < smallestDifference {
//                smallestDifference = difference
//                closestRate = Rate(rawValue: i)
//            }
//        }
//        return closestRate!
    }
    
    static func fromTime(_ time: Double) -> Rate {
        return(Rate.findMinimum(time, comparator: { (i) -> Double in
            Rate(rawValue: i)!.time
        }))
//        var closestRate = Rate(rawValue: 0)
//        var smallestDifference = 1000000000.0
//        for i in 0 ..< Rate.count {
//            let difference: Double = abs(Rate(rawValue: i)!.time - time)
//            if  difference < smallestDifference {
//                smallestDifference = difference
//                closestRate = Rate(rawValue: i)
//            }
//        }
//        return closestRate!
    }
}

