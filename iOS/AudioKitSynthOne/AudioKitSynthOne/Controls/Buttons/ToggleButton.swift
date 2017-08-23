//
//  ToggleButton.swift
//  AudioKit Synth One
//
//  Created by Matthew Fecher on 7/22/17.
//  Copyright © 2017 Matthew Fecher. All rights reserved.
//

import UIKit

@IBDesignable
class ToggleButton: UIView, AKSynthOneControl {
    
    // *********************************************************
    // MARK: - ToggleButton
    // *********************************************************

    var isOn = false

    var callback: (Double)->Void = { _ in }

    var value: Double {
        get {
            return isOn ? 1 : 0
        }
        set {
            isOn = value == 1.0
        }
    }
    
    @IBInspectable open var buttonColor: UIColor = UIColor(red: 0.306, green: 0.306, blue: 0.325, alpha: 1.000)

    override func draw(_ rect: CGRect) {
        ToggleButtonStyleKit.drawRoundButton(isToggled: isOn, backgroundColor: buttonColor)
    }
    
    // *********************************************************
    // MARK: - Handle Touches
    // *********************************************************
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        for _ in touches {
            isOn = !isOn
            self.setNeedsDisplay()
            callback(value)
        }
    }
 

}
