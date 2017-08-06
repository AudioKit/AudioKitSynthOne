//
//  RateKnob.swift
//  AudioKitSynthOne
//
//  Created by Aurelius Prochazka on 8/5/17.
//  Copyright © 2017 AudioKit. All rights reserved.
//

import UIKit
import AudioKit

public class RateKnob: Knob {

    var conductor = Conductor.sharedInstance
    
    var rate: Rate {
        return Rate(rawValue: Int(knobValue * CGFloat(Rate.count))) ?? Rate.eightBars
  
    }

    func update() {
        print("Updating to sync: \(sync)")
        if conductor.syncRatesToTempo {
//            self.range = 0 ... 14 // Int -> Rate
//            self.onlyIntegers = true
        } else {
//            self.range = 0 ... 10 // Hz
//            self.onlyIntegers = false
        }
    }

    private var _value: Double = 0

    override public var value: Double {
        get {
            if conductor.syncRatesToTempo {
                return rate.frequency
            } else {
                return _value
            }
        }
        set(newValue) {
            if conductor.syncRatesToTempo {
                var closestKnobValue: Int = 0
                var smallestDifference = 1000000000.0
                for i in 0 ... Rate.count {
                    let difference: Double = abs(rate.frequency - newValue)
                    if  difference < smallestDifference {
                        smallestDifference = difference
                        closestKnobValue = i
                    }
                }
                //knobValue = CGFloat(closestKnobValue) / numValues
            } else {
                _value = range.clamp(newValue)

                _value = onlyIntegers ? round(_value) : _value
                knobValue = CGFloat(newValue.normalized(range: range, taper: taper))
            }
        }
    }


    // Init / Lifecycle
    override init(frame: CGRect) {
        super.init(frame: frame)
        contentMode = .redraw
    }

    required public init?(coder: NSCoder) {
        super.init(coder: coder)
        self.isUserInteractionEnabled = true
        contentMode = .redraw
    }

    override func setPercentagesWithTouchPoint(_ touchPoint: CGPoint) {
        // Knobs assume up or right is increasing, and down or left is decreasing

        knobValue += (touchPoint.x - lastX) * knobSensitivity
        knobValue -= (touchPoint.y - lastY) * knobSensitivity

        if knobValue > 1.0 {
            knobValue = 1.0
        }
        if knobValue < 0.0 {
            knobValue = 0.0
        }

        if conductor.syncRatesToTempo {
            value = rate.frequency
            print(rate)
        } else {
            value = Double(knobValue).denormalized(range: range, taper: taper)
        }

        callback(value)
        lastX = touchPoint.x
        lastY = touchPoint.y
    }
}
