//
//  ArrowButton.swift
//  AudioKitSynthOne
//
//  Created by AudioKit Contributors on 8/2/17.
//  Copyright © 2018 AudioKit. All rights reserved.
//

import UIKit

@IBDesignable
public class Stepper: UIView, S1Control {

    // MARK: - S1Control
    public internal(set) var value: Double {
        get {
            return internalValue
        }
        set {
            internalValue = range.clamp(round(newValue))
            setNeedsDisplay()
        }
    }

    public var callback: (Double) -> Void = { _ in }

    var defaultCallback: () -> Void = { }

    // MARK: - Stepper
    
    var minusPath = UIBezierPath(roundedRect: CGRect(x: 0.5, y: 2, width: 35, height: 32), cornerRadius: 1)

    var plusPath = UIBezierPath(roundedRect: CGRect(x: 70.5, y: 2, width: 35, height: 32), cornerRadius: 1)
	
    var minValue = 0.0 {
        didSet {
            range = (Double(minValue) ... Double(maxValue))
            internalValue = range.clamp(internalValue)
        }
    }

    var maxValue = 3.0 {
        didSet {
            range = (Double(minValue) ... Double(maxValue))
            internalValue = range.clamp(internalValue)
        }
    }

	internal var internalValue: Double = 0 {
		didSet {
			accessibilityValue = String(format: "%.0f", internalValue)
		}
	}

    var range: ClosedRange = 0.0...1.0

    var valuePressed: CGFloat = 0

    /// Text / label to display
    open var text = "0"

    // Init / Lifecycle
    override init(frame: CGRect) {
        super.init(frame: frame)
		accessibilityTraits = UIAccessibilityTraits.adjustable
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        range = (Double(minValue) ... Double(maxValue))
        internalValue = 1
        text = "1"
    }

    // MARK: - Draw

    override public func draw(_ rect: CGRect) {
        StepperStyleKit.drawStepper(frame: CGRect(x: 0,
                                                  y: 0,
                                                  width: self.bounds.width,
                                                  height: self.bounds.height),
                                    valuePressed: valuePressed, text: "\(Int(value))")
    }

    // MARK: - Handle Touches

    /// Handle new touches
    override open func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if let touch = touches.first {
            let touchLocation = touch.location(in: self)
            if minusPath.contains(touchLocation) {
                if value > minValue {
                    value -= 1
                    valuePressed = 1
                }
            }
            if plusPath.contains(touchLocation) {
                if value < maxValue {
                    value += 1
                    valuePressed = 2
                }
            }
            callback(value)
            setNeedsDisplay()
        }
    }

    override public func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        for _ in touches {
            valuePressed = 0
            setNeedsDisplay()
        }
    }

	
	/**
	Accessibility Functions needed for Accessibile Adjustable Trait
	*/

    override public func accessibilityIncrement() {
		if value < maxValue {
			value += 1
			valuePressed = 2
		}
		let newValue = String(format: "%.00f", value)
		accessibilityValue = newValue
		callback(value)
	}
	
	override public func accessibilityDecrement() {
		if value > minValue {
			value -= 1
			valuePressed = 1
			let newValue = String(format: "%.00f", value)
			accessibilityValue = newValue
			callback(value)
		}
	}

}
