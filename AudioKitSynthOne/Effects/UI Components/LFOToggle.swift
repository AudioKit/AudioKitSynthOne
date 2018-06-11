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

    var lfo1Active: Bool = false
    var lfo2Active: Bool = false

    let width: CGFloat = 100

    // Make Button Text Editable in IB
    @IBInspectable open var buttonText: String = "Hello"

    // Draw Button
    override func draw(_ rect: CGRect) {
        LfoBtnStyleKit.drawLfoButton(lfoSelected: CGFloat(value), buttonText: buttonText)
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

}
