//
//  LFOWavePicker.swift
//  AudioKitSynthOne
//
//  Created by AudioKit Contributors on 8/4/17.
//  Copyright © 2018 AudioKit. All rights reserved.
//

import UIKit

@IBDesignable
class LFOWavePicker: UIView, S1Control {

    var callback: (Double) -> Void = { _ in }
    var defaultCallback: () -> Void = { }
    var value: Double = 0 {
        didSet {
           setNeedsDisplay()
			switch value {
			case 0:
				accessibilityValue = NSLocalizedString("Sine Wave", comment: "Sine Wave")
			case 1:
				accessibilityValue = NSLocalizedString("Square Wave", comment: "Square Wave")
			case 2:
				accessibilityValue = NSLocalizedString("Ramp Up Saw Wave", comment: "Ramp Up Saw Wave")
			default:
				accessibilityValue = NSLocalizedString("Ramp Down Saw Wave", comment: "Ramp Down Saw Wave")
			}
        }
    }

    // Draw Button
    override func draw(_ rect: CGRect) {
        LFOPickerStyleKit.drawLFOWaveformPicker(frame: CGRect(x: 0,
                                                              y: 0,
                                                              width: self.bounds.width,
                                                              height: self.bounds.height),
                                                fraction: CGFloat(value / 3.0))
    }

    // MARK: - Handle Touches

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        for touch in touches {
            let touchPoint = touch.location(in: self)
            let w = self.bounds.width

            switch touchPoint.x {
            case 0 ..< w * 0.25:
                value = 0
            case w * 0.25 ..< w * 0.50:
                value = 1
            case w * 0.50 ..< w * 0.75:
                value = 2
            default:
                value = 3
            }

            setNeedsDisplay()
            callback(value)
        }
    }

	override func accessibilityActivate() -> Bool {
		if value < 3 {
			value += 1
		} else {
			value = 0
		}
		return true
	}

	override func accessibilityIncrement() {
		if value < 3 {
			value += 1
		}
	}

	override func accessibilityDecrement() {
		if value > 0 {
			value -= 1
		}
	}

    required public init?(coder: NSCoder) {
        super.init(coder: coder)
        isUserInteractionEnabled = true
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

}
