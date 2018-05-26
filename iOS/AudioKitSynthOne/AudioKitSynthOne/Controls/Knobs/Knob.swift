//
//  KnobView.swift
//  AudioKit Synth One
//
//  Created by Matthew Fecher on 7/20/17.
//  Copyright © 2017 Matthew Fecher. All rights reserved.
//

import UIKit

@IBDesignable
public class Knob: UIView, AKSynthOneControl {

    var onlyIntegers: Bool = false

    var callback: (Double) -> Void = { _ in }

    public var taper: Double = 1.0 // Linear by default

    var range: ClosedRange = 0.0...1.0 {
        didSet {
            _value = range.clamp(_value)
            knobValue = CGFloat(Double(knobValue).normalized(from: range, taper: taper))
        }
    }

    private var _value: Double = 0

    var value: Double {
        get {
            return _value
        }

        set(newValue) {
            _value = onlyIntegers ? round(newValue) : newValue
            _value = range.clamp(_value)
            knobValue = CGFloat(newValue.normalized(from: range, taper: taper))
        }
    }

    // Knob properties
    var knobValue: CGFloat = 0.0 {
        didSet {
            self.setNeedsDisplay()
        }
    }
    var knobFill: CGFloat = 0
    var knobSensitivity: CGFloat = 0.005
    var lastX: CGFloat = 0
    var lastY: CGFloat = 0

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

    override public func prepareForInterfaceBuilder() {
        super.prepareForInterfaceBuilder()

        contentMode = .scaleAspectFit
        clipsToBounds = true
    }

    public class override var requiresConstraintBasedLayout: Bool {
        return true
    }

    public override func draw(_ rect: CGRect) {
        KnobStyleKit.drawKnobOne(frame: CGRect(x: 0, y: 0, width: self.bounds.width, height: self.bounds.height), knobValue: knobValue)
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
}
