//
//  LFOWavePicker.swift
//  SynthUISpike
//
//  Created by Matthew Fecher on 8/4/17.
//  Copyright © 2017 Matthew Fecher. All rights reserved.
//

import UIKit

@IBDesignable
class LFOWavePicker: UIView, AKSynthOneControl {
    
    var callback: (Double)->Void = { _ in }
    var value: Double = 0 {
        didSet {
           setNeedsDisplay()
        }
    }
    
    // Draw Button
    override func draw(_ rect: CGRect) {
        LFOPickerStyleKit.drawLFOWaveformPicker(fraction: CGFloat(value/3.0))
    }
    
    // *********************************************************
    // MARK: - Handle Touches
    // *********************************************************
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        for touch in touches {
            let touchPoint = touch.location(in: self)
            let w = self.bounds.width
         
            switch touchPoint.x {
            case 0 ..< w * 0.25:
                value = 0
            case w * 0.25 ..< w * 0.50:
                value = 1
            case w * 0.50 ..< w * 0.75:
                value = 2
            default:
                value = 3
            }
            
            self.setNeedsDisplay()
            callback(value)
        }
    }
}


