//
//  TempoStepper.swift
//  AudioKitSynthOne
//
//  Created by AudioKit Contributors on 8/14/17.
//  Copyright © 2017 AudioKit. All rights reserved.
//

import UIKit

@IBDesignable
class TempoStepper: Stepper {

    let tempoPath = UIBezierPath(roundedRect: CGRect(x: 3.5, y: 0.5, width: 75, height: 32), cornerRadius: 1)
    var knobSensitivity: CGFloat = 0.005
    var lastX: CGFloat = 0
    var lastY: CGFloat = 0

    public var taper: Double = 1.0 // Linear by default

    public override var value: Double {
        get {
            return internalValue
        }
        set {
            internalValue = round(newValue)
            range = Double(minValue) ... Double(maxValue)
            internalValue = range.clamp(internalValue)
            knobValue = CGFloat(newValue.normalized(from: range, taper: taper))
            setNeedsDisplay()

			accessibilityValue = String(format: "%.0f", value) + NSLocalizedString("B P M", comment: "BPM, Beats Per Minute")
        }
    }

    // Knob properties
    var knobValue: CGFloat = 0.5 {
        didSet {
            setNeedsDisplay()
        }
    }

    // Init / Lifecycle
    override init(frame: CGRect) {
        super.init(frame: frame)
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.minusPath = UIBezierPath(roundedRect: CGRect(x: 3.5, y: 38.5, width: 35, height: 32), cornerRadius: 1)
        self.plusPath = UIBezierPath(roundedRect: CGRect(x: 43.5, y: 38.5, width: 35, height: 32), cornerRadius: 1)
        self.maxValue = 360
        self.minValue = 60
        self.range = (Double(self.minValue) ... Double(self.maxValue))
        self.internalValue = 120
        self.text = String(self.internalValue)
    }

    // MARK: - Draw

    override func draw(_ rect: CGRect) {
        TempoStyleKit.drawTempoStepper(frame: CGRect(x: 0,
                                                     y: 0,
                                                     width: self.bounds.width,
                                                     height: self.bounds.height),
                                       valuePressed: valuePressed, text: "\(Int(value)) bpm")
    }

    // MARK: - Handle Touches

    /// Handle new touches

    override open func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if let touch = touches.first {
            let touchLocation = touch.location(in: self)
            if minusPath.contains(touchLocation) {
                if self.value > Double(self.minValue) {
                    self.value -= 1
                    self.valuePressed = 1
                }
            }
            if self.plusPath.contains(touchLocation) {
                if value < Double(maxValue) {
                    self.value += 1
                    self.valuePressed = 2
                }
            }
            if tempoPath.contains(touchLocation) {
                let touchPoint = touch.location(in: self)
                self.lastX = touchPoint.x
                self.lastY = touchPoint.y
            }
            callback(value)
            setNeedsDisplay()
        }
    }

    override public func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        if self.valuePressed == 0 {
            for touch in touches {
                let touchPoint = touch.location(in: self)
                setPercentagesWithTouchPoint(touchPoint)
            }
        }
    }

    // Helper
    func setPercentagesWithTouchPoint(_ touchPoint: CGPoint) {

        // Knobs assume up or right is increasing, and down or left is decreasing
        knobValue += (touchPoint.x - lastX) * knobSensitivity
        knobValue -= (touchPoint.y - lastY) * knobSensitivity
        knobValue = (0.0 ... 1.0).clamp(knobValue)
        value = Double(knobValue).denormalized(to: range, taper: taper)
        callback(value)
        lastX = touchPoint.x
        lastY = touchPoint.y
    }

    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        for _ in touches {
            valuePressed = 0
            setNeedsDisplay()
        }
    }

	override func accessibilityIncrement() {
		value += 1.0
	}

	override func accessibilityDecrement() {
		value -= 1.0
	}
}
