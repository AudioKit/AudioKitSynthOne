//
//  ToggleSwitch.swift
//  AudioKitSynthOne
//
//  Created by AudioKit Contributors on 8/2/17.
//  Copyright © 2017 AudioKit. All rights reserved.
//

import UIKit

@IBDesignable
class ToggleSwitch: UIView, AKS1Control {

    // MARK: - ToggleButton

    var isOn = false {
        didSet {
            setNeedsDisplay()
        }
    }

    var value: Double = 0 {
        didSet {
            isOn = (value == 1)
            setNeedsDisplay()
        }
    }
    public var callback: (Double) -> Void = { _ in }

    override func draw(_ rect: CGRect) {
        ToggleSwitchStyleKit.drawToggleSwitch(isToggled: value == 0 ? false : true )
    }

    // MARK: - Handle Touches

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        for _ in touches {
            value = 1 - value
            callback(value)
        }
    }
}
