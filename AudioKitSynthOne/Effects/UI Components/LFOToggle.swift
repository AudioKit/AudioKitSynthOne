//
//  LFOToggle.swift
//  AudioKitSynthOne
//
//  Created by AudioKit Contributors on 7/28/17.
//  Copyright © 2018 AudioKit. All rights reserved.
//

import UIKit

@IBDesignable
class LFOToggle: UIView, S1Control {

    var callback: (Double) -> Void = { _ in }
    var defaultCallback: () -> Void = { }
    var value: Double = 0 {
        didSet {
            // Code for activating LFO state from Preset load
            lfo1Active = false
            lfo2Active = false
            switch value {
            case 1:
                lfo1Active = true
            case 2:
                lfo2Active = true
            case 3:
                lfo1Active = true
                lfo2Active = true
            default:
                break
            }
            setNeedsDisplay()
        }
    }

	var lfo1Active: Bool = false {
		didSet {
			updateAccessibilityValue()
		}
	}
	var lfo2Active: Bool = false {
		didSet {
			updateAccessibilityValue()
		}
	}

    let width: CGFloat = 100

    // Make Button Text Editable in IB
    @IBInspectable open var buttonText: String = "Hello"

	required init?(coder aDecoder: NSCoder) {
		super.init(coder: aDecoder)
        isUserInteractionEnabled = true
        contentMode = .redraw

		accessibilityHint = NSLocalizedString(
			"Up for toggle 1, Down for toggle 2.",
			comment: ("Up for toggle 1, Down for toggle 2." )
		)
	}

    override public func prepareForInterfaceBuilder() {
        super.prepareForInterfaceBuilder()

        contentMode = .scaleAspectFit
        clipsToBounds = true
    }

    public class override var requiresConstraintBasedLayout: Bool {
        return true
    }

    // Draw Button
    override func draw(_ rect: CGRect) {
        LFOButtonStyleKit.drawLFOButton(frame: CGRect(x: 0,
                                                      y: 0,
                                                      width: self.bounds.width,
                                                      height: self.bounds.height),
                                        lfoSelected: CGFloat(value), buttonText: buttonText)
    }

    // MARK: - Handle Touches

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        for touch in touches {
            let touchPoint = touch.location(in: self)
            if touchPoint.x < width / 2 {
                lfo1Active = !lfo1Active
            } else {
                lfo2Active = !lfo2Active
            }
            var newValue = 0.00
            if lfo1Active { newValue += 1 }
            if lfo2Active { newValue += 2 }
            value = newValue
            callback(value)
        }
    }

	override func accessibilityIncrement() {
		lfo1Active = !lfo1Active
		var newValue = 0.00
		if lfo1Active { newValue += 1 }
		if lfo2Active { newValue += 2 }
		value = newValue
		callback(value)
	}

	override func accessibilityDecrement() {
		lfo2Active = !lfo2Active
		var newValue = 0.00
		if lfo1Active { newValue += 1 }
		if lfo2Active { newValue += 2 }
		value = newValue
		callback(value)
	}

	func updateAccessibilityValue() {
		accessibilityValue = NSLocalizedString("L F O Toggle 1 ", comment: "L F O Toggle 1, (LFO) Low Frequency Oscillator") +
			(lfo1Active ? NSLocalizedString("On,", comment: "On") : NSLocalizedString("Off,", comment: "Off,")) +
			NSLocalizedString("L F O Toggle 2 ", comment: "L F O Toggle 1, (LFO) Low Frequency Oscillator") +
			(lfo2Active ? NSLocalizedString("On,", comment: "On") : NSLocalizedString("Off,", comment: "Off"))
	}
}
