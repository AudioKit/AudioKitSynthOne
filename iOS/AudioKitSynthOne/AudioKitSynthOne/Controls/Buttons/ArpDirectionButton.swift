//
//  ArpDirectionButton.swift
//  SynthUISpike
//
//  Created by Matthew Fecher on 8/2/17.
//  Copyright © 2017 Matthew Fecher. All rights reserved.
//

import UIKit

@IBDesignable
class ArpDirectionButton: UIView {
    
    // *********************************************************
    // MARK: - LFO Button
    // *********************************************************
    
    var arpDirectionSelected: Int = 0
    
    public var callback: (Int)->Void = { _ in }
    
    private var btnWidth: CGFloat = 35.0
    
    // Draw Button
    override func draw(_ rect: CGRect) {
        ArpDirectionStyleKit.drawArpDirectionButton(directionSelected: CGFloat(arpDirectionSelected))
    }
    
    // *********************************************************
    // MARK: - Handle Touches
    // *********************************************************
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        for touch in touches {
            let touchPoint = touch.location(in: self)
            
            switch touchPoint.x {
            case 0..<btnWidth:
                arpDirectionSelected = 0
            case btnWidth...btnWidth*2:
                arpDirectionSelected = 1
            default:
                arpDirectionSelected = 2
            }
   
            setNeedsDisplay()
            callback(arpDirectionSelected)
        }
    }
    
}

