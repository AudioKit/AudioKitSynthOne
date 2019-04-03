//
//  RateKnob.swift
//  AudioKitSynthOne
//
//  Created by AudioKit Contributors on 8/5/17.
//  Copyright © 2017 AudioKit. All rights reserved.
//

import UIKit

public class RateKnob: MIDIKnob {

    var rate: Rate {
        return Rate(rawValue: Int(knobValue * CGFloat(Rate.count))) ?? Rate.sixtyFourth
    }

    private var _value: Double = 0

    override public var value: Double {
        get {
            if timeSyncMode {
                return rate.frequency
            } else {
                return _value
            }
        }
        set(newValue) {
            _value = onlyIntegers ? round(newValue) : newValue
            _value = range.clamp(_value)
            if !timeSyncMode {
                knobValue = CGFloat(_value.normalized(from: range, taper: taper))
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
        callback(value)
        lastX = touchPoint.x
        lastY = touchPoint.y
    }
}
