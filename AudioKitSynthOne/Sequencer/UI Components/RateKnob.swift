//
//  RateKnob.swift
//  AudioKitSynthOne
//
//  Created by AudioKit Contributors on 8/5/17.
//  Copyright © 2017 AudioKit. All rights reserved.
//

import UIKit

public class RateKnob: MIDIKnob {
    private var internalValue: Double = 0
    
    var rate: Rate {
        return Rate(rawValue: Int(knobValue * CGFloat(Rate.count))) ?? Rate.sixtyFourth
    }

    override public var value: Double {
        get {
            if timeSyncMode {
                return rate.frequency
            } else {
                return internalValue
            }
        }
        set(newValue) {
            internalValue = onlyIntegers ? round(newValue) : newValue
            internalValue = range.clamp(internalValue)
            if !timeSyncMode {
                knobValue = CGFloat(internalValue.normalized(from: range, taper: taper))
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
        isUserInteractionEnabled = true
        contentMode = .redraw
    }

    override func setPercentagesWithTouchPoint(_ touchPoint: CGPoint) {

        // Knobs assume up or right is increasing, and down or left is decreasing
        knobValue += (touchPoint.x - lastX) * knobSensitivity
        knobValue -= (touchPoint.y - lastY) * knobSensitivity
        knobValue = (0.0 ... 1.0).clamp(knobValue)
        if timeSyncMode {
            value = rate.frequency
        } else {
            value = Double(knobValue).denormalized(to: range, taper: taper)
        }
        setValueCallback(value)
        lastX = touchPoint.x
        lastY = touchPoint.y
    }
}
