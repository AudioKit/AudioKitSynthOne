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

    // MARK: - Init

    override public init(frame: CGRect) {
        super.init(frame: frame)
        accessibilityInit()
    }

    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        accessibilityInit()
    }

    override open func prepareForInterfaceBuilder() {
        super.prepareForInterfaceBuilder()
        contentMode = .scaleAspectFill
        clipsToBounds = true
    }

    open class override var requiresConstraintBasedLayout: Bool {
        return true
    }

    // MARK: - S1Control

    var value: Double = 0 {
        didSet {
            value = (0.0 ... 1.0).clamp(value)
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

    var setValueCallback: (Double) -> Void = { _ in }
    var resetToDefaultCallback: () -> Void = { }

    // MARK: - Properties
    
    @IBInspectable open var color: UIColor = #colorLiteral(red: 0.1333333333, green: 0.1333333333, blue: 0.1333333333, alpha: 1)
    @IBInspectable open var selected: UIColor = #colorLiteral(red: 0.9294117647, green: 0.5333333333, blue: 0, alpha: 1)
    @IBInspectable open var unselected: UIColor = #colorLiteral(red: 0.5333333333, green: 0.5333333333, blue: 0.5333333333, alpha: 1)
    @IBInspectable open var selectedBG: UIColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 0.18)

    // MARK: - Draw

    override open func draw(_ rect: CGRect) {
        MorphSelectorStyleKit.drawMorphSelector(value: CGFloat(value),
                                                width: self.bounds.width,
                                                height: self.bounds.height)
    }

    // MARK: - Touches

    override open func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        for touch in touches {
            if touch != touches.first {
                let touchLocation = touch.location(in: self)
                value = Double(touchLocation.x / self.frame.width)
            }
            setValueCallback(value)
        }
        setNeedsDisplay()
    }

    override open func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        if let touch = touches.first {
            let touchLocation = touch.location(in: self)
            value = Double(touchLocation.x / self.frame.width)
            setValueCallback(value)
        }
        setNeedsDisplay()
    }

    override open func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        UIAccessibility.post(notification: .announcement, argument: nil)
    }

    // MARK: - Accessibility

    func accessibilityInit() {
        accessibilityTraits = [
            .adjustable,
            .allowsDirectInteraction,
            .updatesFrequently
        ]
    }

	override func accessibilityIncrement() {
		value += 0.01
		setValueCallback(value)
	}

	override func accessibilityDecrement() {
		value -= 0.01
		setValueCallback(value)
	}
}
