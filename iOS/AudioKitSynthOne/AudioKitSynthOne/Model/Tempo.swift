//
//  Tempo.swift
//  SynthUISpike
//
//  Created by Matthew Fecher on 8/5/17.
//  Copyright © 2017 Matthew Fecher. All rights reserved.
//

struct Tempo {
    var bpm: Double
    var knobSync: Bool
    
    func seconds(duration: Double = 0.25) -> Double {
        return 1.0 / self.bpm * 60.0 * 4.0 * duration
    }
    
    func eightBars() -> Double {
        return seconds(duration: 8)
    }
    
    func fourBars() -> Double {
        return seconds(duration: 4)
    }
    
    func threeBars() -> Double {
        return seconds(duration: 3)
    }
    
    func twoBars() -> Double {
        return seconds(duration: 2)
    }
    
    func bar() -> Double {
        return seconds(duration: 1)
    }
    
    func half() -> Double {
        return seconds(duration: 0.5)
    }
    
    func halfTriplet() -> Double {
        return quarter() * 1.5
    }
    
    func quarter() -> Double {
        return seconds(duration: 0.25)
    }
    
    func quarterTriplet() -> Double {
        return quarter() / 1.5
    }
    
    func eighth() -> Double {
        return quarter() / 2
    }
    
    func eighthTriplet() -> Double {
        return quarter() / 3
    }
    
    func sixteenth() -> Double {
        return quarter() / 4
    }
    
    func sixteenthTriplet() -> Double {
        return quarter() / 6
    }
    
    func thirtysecondth() -> Double {
        return quarter() / 8
    }
    
    func sixtyfourth() -> Double {
        return quarter() / 16
    }
}
