//
//  ArrowButton.swift
//  AudioKit Synth One
//
//  Created by Matthew Fecher on 8/2/17.
//  Copyright © 2017 Matthew Fecher. All rights reserved.
//

import UIKit

@IBDesignable
class Stepper: UIView, AKSynthOneControl {

    public var callback: (Double) -> Void = { _ in }

    var minusPath = UIBezierPath(roundedRect: CGRect(x: 0.5, y: 2, width: 35, height: 32), cornerRadius: 1)
    var plusPath = UIBezierPath(roundedRect: CGRect(x: 70.5, y: 2, width: 35, height: 32), cornerRadius: 1)

    var minValue = 0.0 {
        didSet {
            range = (Double(minValue) ... Double(maxValue))
            _value = range.clamp(_value)
        }
    }
    var maxValue = 3.0 {
        didSet {
            range = (Double(minValue) ... Double(maxValue))
            _value = range.clamp(_value)
        }
    }

    internal var _value: Double = 0

    public internal(set) var value: Double {
        get {
            return _value
        }
        set {
            _value = round(_value)
            _value = range.clamp(newValue)
            setNeedsDisplay()
        }
    }

    var range: ClosedRange = 0.0...1.0

    var valuePressed: CGFloat = 0

    /// Text / label to display
    open var text = "0"

    // Init / Lifecycle
    override init(frame: CGRect) {
        super.init(frame: frame)
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        range = (Double(minValue) ... Double(maxValue))
        _value = 1
        text = "1"
    }

    // *********************************************************
    // MARK: - Draw
    // *********************************************************

    override func draw(_ rect: CGRect) {
        StepperStyleKit.drawStepper(valuePressed: valuePressed, text: "\(Int(value))")
    }

    // *********************************************************
    // MARK: - Handle Touches
    // *********************************************************

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
            self.callback(value)
            self.setNeedsDisplay()
        }
    }

    override public func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        for touch in touches {
            let _ = touch.location(in: self)
        }
    }

    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        for _ in touches {
            valuePressed = 0
            self.setNeedsDisplay()
        }
    }
}
