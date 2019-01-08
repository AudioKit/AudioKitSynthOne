//
//  iPhoneToggleButton.swift
//  AudioKitSynthOne
//
//  Created by Matthew Fecher on 1/8/19.
//  Copyright © 2019 AudioKit. All rights reserved.
//

import UIKit

@IBDesignable
class iPhoneToggleButton: ToggleButton {
    
    @IBInspectable open var buttonText: String = "Hello"
    @IBInspectable open var textSize: Int = 14
    
    public override func draw(_ rect: CGRect) {
        TopUIButtonStyleKit.drawUIButton(frame: CGRect(x:0,y:0, width: self.bounds.width, height: self.bounds.height), resizing: .aspectFit, isOn: isOn, text: buttonText, textSize: CGFloat(textSize))
    }
    
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        for _ in touches {
             value = isOn ? 0 : 1
            setNeedsDisplay()
            callback(value)
        }
      
    }
}
