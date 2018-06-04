//
//  ToggleButton.swift
//  AudioKit Synth One
//
//  Created by AudioKit Contributors on 7/22/17.
//  Copyright © 2017 Matthew Fecher. All rights reserved.
//

import UIKit

@IBDesignable
class ToggleButton: UIView, AKSynthOneControl {

    // MARK: - ToggleButton

    var isOn: Bool {
        return value == 1
    }

    var callback: (Double) -> Void = { _ in }

    var value: Double = 0.0 {
        didSet {
            setNeedsDisplay()
        }
    }

    override func draw(_ rect: CGRect) {
        ToggleButtonStyleKit.drawRoundButton(isToggled: isOn)
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
