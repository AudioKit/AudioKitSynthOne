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
            if self.timeSyncMode {
                return rate.frequency
            } else {
                return _value
            }
        }
        set(newValue) {
            _value = onlyIntegers ? round(newValue) : newValue
            _value = range.clamp(_value)
            if !timeSyncMode {
                self.knobValue = CGFloat(_value.normalized(from: self.range, taper: self.taper))
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
        self.knobValue += (touchPoint.x - self.lastX) * self.knobSensitivity
        self.knobValue -= (touchPoint.y - self.lastY) * self.knobSensitivity
        self.knobValue = (0.0 ... 1.0).clamp(self.knobValue)
        if timeSyncMode {
            self.value = rate.frequency
        } else {
            self.value = Double(knobValue).denormalized(to: range, taper: taper)
        }
        self.callback(value)
        self.lastX = touchPoint.x
        self.lastY = touchPoint.y
    }
}
