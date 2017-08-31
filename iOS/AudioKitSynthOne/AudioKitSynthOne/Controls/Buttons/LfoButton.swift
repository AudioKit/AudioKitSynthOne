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
    let btnWidth: CGFloat = 100

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
        for touch in touches {
            let touchPoint = touch.location(in: self)
            
            var newValue = 0.00
            if touchPoint.x < btnWidth/2 {
                if value == 1 {
                    newValue = 0
                } else {
                    newValue = 1
                }
            } else {
                if value == 2 {
                    newValue = 0
                } else {
                   newValue = 2
                }
            }
            
            value = newValue
            
            setNeedsDisplay()
            callback(value)
        }
    }
    
}
