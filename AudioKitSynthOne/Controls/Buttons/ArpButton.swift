//
//  ArpButton.swift
//  AudioKit Synth One
//
//  Created by AudioKit Contributors on 8/1/17.
//  Copyright © 2017 Matthew Fecher. All rights reserved.
//

import UIKit

@IBDesignable
class ArpButton: UIView, AKSynthOneControl {

    // MARK: - ToggleButton

    private var _value: Double = 0
    var value: Double {
        get {
            return _value
        }
        set {
            if newValue > 0 {
                _value = 1
            } else {
                _value = 0
            }
            setNeedsDisplay()
        }
    }

    public var callback: (Double) -> Void = { _ in }

    override func draw(_ rect: CGRect) {
        ArpButtonStyleKit.drawArpButton(isToggled: value > 0 ? true : false)
    }

    // MARK: - Handle Touches

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        for _ in touches {
            value = 1 - value
            callback(value)
        }
    }
}
