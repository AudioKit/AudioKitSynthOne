//
//  LfoButton.swift
//  SynthUISpike
//
//  Created by Matthew Fecher on 7/28/17.
//  Copyright © 2017 Matthew Fecher. All rights reserved.
//

import UIKit

@IBDesignable
class LfoButton: UIView, AKSynthOneControl {
    
    var callback: (Double)->Void = { _ in }
    var value: Double = 0

    // Make Button Text Editable in IB
    @IBInspectable open var buttonText: String = "Hello"
    
    // Draw Button
    override func draw(_ rect: CGRect) {
        LfoBtnStyleKit.drawLfoButton(lfoSelected: CGFloat(value), buttonText: buttonText)
    }
    
    // *********************************************************
    // MARK: - Handle Touches
    // *********************************************************
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        for _ in touches {
            value += 1
            if value == 3 { value = 0 }
            setNeedsDisplay()
            callback(value)
        }
    }
    
}
