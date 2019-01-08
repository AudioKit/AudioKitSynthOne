//
//  ToggleButton.swift
//  AudioKitSynthOne
//
//  Created by AudioKit Contributors on 7/22/17.
//  Copyright © 2018 AudioKit. All rights reserved.
//

import UIKit

@IBDesignable
class ToggleButton: UIView, S1Control {

    // MARK: - ToggleButton

    var isOn: Bool {
        return value == 1
    }

    var callback: (Double) -> Void = { _ in }

    var value: Double = 0.0 {
        didSet {
            setNeedsDisplay()

			accessibilityValue = isOn ? "On" : "Off"
        }
    }

    override func draw(_ rect: CGRect) {
        ToggleButtonStyleKit.drawRoundButton(frame: CGRect(x: 0,
                                                           y: 0,
                                                           width: self.bounds.width,
                                                           height: self.bounds.height),
                                             isToggled: isOn)
    }

    // MARK: - Handle Touches

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        for _ in touches {
            value = isOn ? 0 : 1
            setNeedsDisplay()
            callback(value)
        }
    }

}
