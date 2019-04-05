//
//  VerticalSlider.swift
//  AudioKitSynthOne
//
//  Created by AudioKit Contributors on 1/11/16.
//  Copyright (c) 2016 AudioKit. All rights reserved.

import UIKit

@IBDesignable
class VerticalSlider: UIControl, S1Control {

    var callback: (Double) -> Void = { _ in }
    var defaultCallback: () -> Void = { }
    var minValue: CGFloat = 0.0
    var maxValue: CGFloat = 1.0
    var currentValue: CGFloat = 0.5 {
        didSet {
            if currentValue < minValue {
                currentValue = minValue
            }
            if currentValue > maxValue {
                currentValue = maxValue
            }
            self.sliderValue = CGFloat((currentValue - minValue) / (maxValue - minValue))
			accessibilityValue = String(format: "%.f", round((currentValue - 0.5) * 24.0))
            setupView()
        }
    }

	lazy var accessibilityChangeAmount: CGFloat = 1.0 / 24.0
    var knobSize = CGSize(width: 40, height: 28)
    var barMargin: CGFloat = 20.0
    var knobRect: CGRect!
    var barLength: CGFloat = 132.0
    var isSliding = false
	var sliderY: CGFloat = 0.0
    var sliderValue: CGFloat = 0.5 {
        didSet {
            sliderY = convertValueToY(currentValue) - knobSize.height / 2
        }
    }

    var value: Double {
        get {
            return currentToActualValue(currentValue)
        }
        set {
            currentValue = actualToInternalValue(newValue)
            self.setNeedsDisplay()
        }
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        contentMode = .redraw
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        self.isUserInteractionEnabled = true
        contentMode = .redraw
       
    }

    class override var requiresConstraintBasedLayout: Bool {
        return true
    }
}

// MARK: - Lifecycle
extension VerticalSlider {
    override func awakeFromNib() {
        super.awakeFromNib()
        self.setupView()
    }

    func setupView() {
        if Conductor.sharedInstance.device == .phone {
            self.knobSize = CGSize(width: 34, height: 17)
        }
        self.knobRect = CGRect(x: 0, y: self.sliderY, width: self.knobSize.width, height: self.knobSize.height)
      
        if Conductor.sharedInstance.device == .phone {
            self.barLength = self.bounds.height - 8
            self.barMargin = -5
        } else {
            self.barLength = self.bounds.height - (barMargin * 2)
        }
    }

    override func draw(_ rect: CGRect) {
        SliderStyleKit.drawVerticalSlider(frame: CGRect(x: 0,
                                                        y: 0,
                                                        width: self.bounds.width,
                                                        height: self.bounds.height), sliderY: sliderY)
    }

    override func prepareForInterfaceBuilder() {
        super.prepareForInterfaceBuilder()
        self.setupView()
    }
}

// MARK: - Helpers
extension VerticalSlider {
    func convertYToValue(_ y: CGFloat) -> CGFloat {
        let offsetY = self.bounds.height - self.barMargin - y
        let value = (offsetY * self.maxValue) / self.barLength
        return value
    }

    func convertValueToY(_ value: CGFloat) -> CGFloat {
        let rawY = (value * self.barLength) / self.maxValue
        let offsetY = bounds.height - self.barMargin - rawY
        return offsetY
    }

    func currentToActualValue(_ value: CGFloat) -> Double {
		let temp = Double(value).normalized(from: -12...12)
        return temp
    }

    func actualToInternalValue(_ actualValue: Double) -> CGFloat {
		let temp = CGFloat(actualValue.normalized(from: -12...12))
        return temp
    }

}

// MARK: - Control Touch Handling
extension VerticalSlider {
    override func beginTracking(_ touch: UITouch, with event: UIEvent?) -> Bool {
        self.isSliding = true
        let rawY = touch.location(in: self).y
        self.currentValue = convertYToValue(rawY)
        self.callback(Double(currentValue) )
        self.setNeedsDisplay()
        
        return true
    }

    override func continueTracking(_ touch: UITouch, with event: UIEvent?) -> Bool {
        let rawY = touch.location(in: self).y
        if isSliding {
            self.currentValue = convertYToValue(rawY)
            self.callback( Double(currentValue) )
            self.setNeedsDisplay()
        }
        return true
    }

    override func endTracking(_ touch: UITouch?, with event: UIEvent?) {
        self.isSliding = false
		UIAccessibility.post(notification: UIAccessibility.Notification.announcement, argument: accessibilityValue)
    }


	/**
	Ac
	*/
	override func accessibilityIncrement() {
		self.currentValue += self.accessibilityChangeAmount
		self.callback( Double(self.currentValue) )
		self.setNeedsDisplay()
	}

	/**
	*/
	override func accessibilityDecrement() {
		self.currentValue -= self.accessibilityChangeAmount
		self.callback( Double(self.currentValue) )
		self.setNeedsDisplay()
	}
}
