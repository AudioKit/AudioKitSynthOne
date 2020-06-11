//
//  ToggleButton.swift
//  AudioKitSynthOne
//
//  Created by AudioKit Contributors on 7/22/17.
//  Copyright © 2018 AudioKit. All rights reserved.
//

@IBDesignable
class ToggleButton: UIView, S1Control {

    // MARK: - ToggleButton

    var isOn = false {
        didSet {
            setNeedsDisplay()
            accessibilityValue = isOn ? NSLocalizedString("On", comment: "On") : NSLocalizedString("Off", comment: "Off")
        }
    }

    // MARK: - S1Control

    var value: Double = 0 {
        didSet {
            isOn = (value == 1)
        }
    }

    var setValueCallback: (Double) -> Void = { _ in }
    var resetToDefaultCallback: () -> Void = { }

    // MARK: - Draw
    
    override func draw(_ rect: CGRect) {
        ToggleButtonStyleKit.drawRoundButton(frame: CGRect(x: 0,
                                                           y: 0,
                                                           width: self.bounds.width,
                                                           height: self.bounds.height),
                                             isToggled: isOn)
    }

    // MARK: - Touches

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let _ = touches.first else {
            return
        }
        value = 1 - value
        setValueCallback(value)
    }
}
