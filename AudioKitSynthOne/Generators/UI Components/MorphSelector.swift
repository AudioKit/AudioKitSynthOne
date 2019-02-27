//
//  MorphSelector.swift
//  AudioKitSynthOne
//
//  Created by AudioKit Contributors on 9/4/16.
//  Copyright © 2016 AudioKit. All rights reserved.
//

import Foundation
import UIKit

@IBDesignable
class MorphSelector: UIView, S1Control {

    var callback: (Double) -> Void = { _ in }
    var defaultCallback: () -> Void = { }

    var value: Double = 0 {
        didSet {
            if value < 0.0 { value = 0.0 }
            if value > 1.0 { value = 1.0 }
            setNeedsDisplay()

            let valueAsString = String(format: "%.2f", value)

            switch valueAsString {
                case "0.00":
                    accessibilityValue = valueAsString + NSLocalizedString(", Pure Triangle Wave", comment: ", Pure Triangle Wave")
                case "0.33":
                    accessibilityValue = valueAsString + NSLocalizedString(", Pulse 50% Wave", comment: ", Pulse 50% Wave")
                case "0.66":
                    accessibilityValue = valueAsString + NSLocalizedString(", Pulse 10% Wave", comment: ", Pulse 10% Wave")
                case "1.00":
                    accessibilityValue = valueAsString + NSLocalizedString(", Pure Saw Wave", comment: ", Pure Saw Wave")
                default:
                    accessibilityValue = valueAsString
            }
        }
    }

    //// Color Declarations
    @IBInspectable open var color: UIColor = #colorLiteral(red: 0.1333333333, green: 0.1333333333, blue: 0.1333333333, alpha: 1)
    @IBInspectable open var selected: UIColor = #colorLiteral(red: 0.9294117647, green: 0.5333333333, blue: 0, alpha: 1)
    @IBInspectable open var unselected: UIColor = #colorLiteral(red: 0.5333333333, green: 0.5333333333, blue: 0.5333333333, alpha: 1)
    @IBInspectable open var selectedBG: UIColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 0.18)

    override open func prepareForInterfaceBuilder() {
        super.prepareForInterfaceBuilder()

        contentMode = .scaleAspectFill
        clipsToBounds = true
    }

    open class override var requiresConstraintBasedLayout: Bool {
        return true
    }

    override public init(frame: CGRect) {
        super.init(frame: frame)
		accessibilityInit()
    }

    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
		accessibilityInit()
    }

    func accessibilityInit() {
        accessibilityTraits = [
            .adjustable,
            .allowsDirectInteraction,
            .updatesFrequently
        ]
    }

    override open func draw(_ rect: CGRect) {
        MorphSelectorStyleKit.drawMorphSelector(value: CGFloat(value),
                                                width: self.bounds.width,
                                                height: self.bounds.height)
    }

    override open func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if let touch = touches.first {
            let touchLocation = touch.location(in: self)
            value = Double(touchLocation.x / self.frame.width)
            callback(value)
        }
        setNeedsDisplay()
    }

    override open func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        if let touch = touches.first {
            let touchLocation = touch.location(in: self)
            value = Double(touchLocation.x / self.frame.width)
            callback(value)
            //print("Morph \(value.decimalString)")
        }
        setNeedsDisplay()
    }

    override open func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        UIAccessibility.post(notification: .announcement, argument: nil)
    }

	override func accessibilityIncrement() {
		value += 0.01
		callback(value)
	}

	override func accessibilityDecrement() {
		value -= 0.01
		callback(value)
	}

}