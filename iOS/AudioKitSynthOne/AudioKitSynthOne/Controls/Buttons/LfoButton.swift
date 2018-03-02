//
//  LfoButton.swift
//  AudioKit Synth One
//
//  Created by Matthew Fecher on 7/28/17.
//  Copyright © 2017 Matthew Fecher. All rights reserved.
//

import UIKit

@IBDesignable
class LfoButton: UIView, AKSynthOneControl {
    
    var callback: (Double)->Void = { _ in }
    var value: Double = 0 {
        didSet {
            print ("value: \(value)")
            setNeedsDisplay()
        }
    }
    
    var lfo1Active: Bool = false
    var lfo2Active: Bool = false
    
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
            
            if touchPoint.x < btnWidth/2 {
                lfo1Active = !lfo1Active
            } else {
                lfo2Active = !lfo2Active
            }
            
            var newValue = 0.00
            if lfo1Active { newValue += 1 }
            if lfo2Active { newValue += 2 }
            
            print ("newValue \(newValue)")
            value = newValue
            
            setNeedsDisplay()
            callback(value)
        }
    }
    
}
