//
//  Tempo.swift
//  AudioKit Synth One
//
//  Created by Matthew Fecher on 8/5/17.
//  Copyright © 2017 Matthew Fecher. All rights reserved.
//

struct Tempo {
    var bpm: Double
    
    func seconds(bars: Double = 1.0) -> Double {
        return 1.0 / self.bpm * 60.0 * 4.0 * duration
    }
    
    func eightBars() -> Double {
        return seconds(bars: 8)
    }
    
    func fourBars() -> Double {
        return seconds(bars: 4)
    }
    
    func threeBars() -> Double {
        return seconds(bars: 3)
    }
    
    func twoBars() -> Double {
        return seconds(bars: 2)
    }
    
    func bar() -> Double {
        return seconds(bars: 1)
    }
    
    func half() -> Double {
        return seconds(bars: 1/2)
    }
    
    func halfTriplet() -> Double {
        return half() / 1.5
    }
    
    func quarter() -> Double {
        return seconds(bars: 1/4)
    }
    
    func quarterTriplet() -> Double {
        return quarter() / 1.5
    }
    
    func eighth() -> Double {
        return seconds(bars: 1/8)
    }
    
    func eighthTriplet() -> Double {
        return eighth() / 1.5
    }
    
    func sixteenth() -> Double {
        return seconds(bars: 1/16)
    }
    
    func sixteenthTriplet() -> Double {
        return sixteenth() / 1.5
    }
    
    func thirtysecondth() -> Double {
        return seconds(bars: 1/32)
    }
    
    func sixtyFourth() -> Double {
        return seconds(bars: 1/64)
    }
}
