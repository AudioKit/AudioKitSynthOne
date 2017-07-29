//
//  LfoButton.swift
//  SynthUISpike
//
//  Created by Matthew Fecher on 7/28/17.
//  Copyright © 2017 Matthew Fecher. All rights reserved.
//

import UIKit

@IBDesignable
class LfoButton: UIView {
    
    // *********************************************************
    // MARK: - LFO Button
    // *********************************************************
    
    var lfoSelected: Int = 0
    
    public var callback: (Int)->Void = { _ in }
    
    // Make Button Text Editable in IB
    @IBInspectable open var buttonText: String = "Hello"
    
    // Draw Button
    override func draw(_ rect: CGRect) {
        LfoBtnStyleKit.drawLfoButton(lfoSelected: CGFloat(lfoSelected), buttonText: buttonText)
    }
    
    // *********************************************************
    // MARK: - Handle Touches
    // *********************************************************
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        for _ in touches {
            lfoSelected += 1
            if lfoSelected == 3 { lfoSelected = 0 }
            setNeedsDisplay()
            callback(lfoSelected)
        }
    }
    
}
