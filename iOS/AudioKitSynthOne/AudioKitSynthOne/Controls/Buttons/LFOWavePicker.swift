//
//  LFOWavePicker.swift
//  SynthUISpike
//
//  Created by Matthew Fecher on 8/4/17.
//  Copyright © 2017 Matthew Fecher. All rights reserved.
//

import UIKit

@IBDesignable
class LFOWavePicker: UIView {
    
    // *********************************************************
    // MARK: - LFO Button
    // *********************************************************
    
    public var callback: (Double)->Void = { _ in }
    
    var waveform = 0.0
    
    // Draw Button
    override func draw(_ rect: CGRect) {
        LFOPickerStyleKit.drawLFOWaveformPicker(fraction: CGFloat(waveform/3.0))
    }
    
    // *********************************************************
    // MARK: - Handle Touches
    // *********************************************************
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        for touch in touches {
            let touchPoint = touch.location(in: self)
            let w = self.bounds.width
         
            switch touchPoint.x {
            case 0..<w*0.25:
                waveform = 0
            case w*0.25..<w*0.50:
                waveform = 1
            case w*0.50..<w*0.75:
                waveform = 2
            default:
                waveform = 3
            }
            
            self.setNeedsDisplay()
            callback(waveform)
        }
    }
}


