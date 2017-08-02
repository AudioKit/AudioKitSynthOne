//
//  ArrowButton.swift
//  SynthUISpike
//
//  Created by Matthew Fecher on 8/2/17.
//  Copyright © 2017 Matthew Fecher. All rights reserved.
//

import UIKit

@IBDesignable
class Stepper: UIView {
    
    public var callback: (Double)->Void = { _ in }
    
    var minusPath = UIBezierPath(roundedRect: CGRect(x: 0.5, y: 2, width: 35, height: 32), cornerRadius: 1)
    var plusPath = UIBezierPath(roundedRect: CGRect(x: 70.5, y: 2, width: 35, height: 32), cornerRadius: 1)
    
    var minValue = 0
    var maxValue = 4
    
    var value = 0
    
    private var valuePressed: CGFloat = 0
    
    /// Text / label to display
    open var text = "0"
    
    // *********************************************************
    // MARK: - Draw
    // *********************************************************
    
    override func draw(_ rect: CGRect) {
        StepperStyleKit.drawStepper(valuePressed: valuePressed, text: "\(value)")
    }
    
    // *********************************************************
    // MARK: - Handle Touches
    // *********************************************************
    
    /// Handle new touches
    override open func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if let touch = touches.first {
            let touchLocation = touch.location(in: self)
            if minusPath.contains(touchLocation) {
                if value > minValue {
                    value -= 1
                    valuePressed = 1
                }
            }
            if plusPath.contains(touchLocation) {
                if value < maxValue {
                    value += 1
                    valuePressed = 2
                }
            }
            self.callback(Double(value))
            self.setNeedsDisplay()
        }
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        for _ in touches {
            valuePressed = 0
         self.setNeedsDisplay()
        }
    }
    
    
}
