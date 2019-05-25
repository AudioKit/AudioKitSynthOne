//
//  ToggleSwitch.swift
//  AudioKitSynthOne
//
//  Created by AudioKit Contributors on 8/2/17.
//  Copyright © 2017 AudioKit. All rights reserved.
//

@IBDesignable
class ToggleSwitch: UIView, S1Control {

    // MARK: - Properties

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
        ToggleSwitchStyleKit.drawToggleSwitch(isToggled: value == 0 ? false : true )
    }

    // MARK: - Touches

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        for _ in touches {
            value = 1 - value
            setValueCallback(value)
        }
    }

    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {

        for _ in touches {
            setValueCallback(value)
        }
    }
}
