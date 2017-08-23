//
//  TempoStepper.swift
//  AudioKitSynthOne
//
//  Created by Matthew Fecher on 8/14/17.
//  Copyright © 2017 AudioKit. All rights reserved.
//

import UIKit

@IBDesignable
class TempoStepper: Stepper {
    
    let tempoPath = UIBezierPath(roundedRect: CGRect(x: 3.5, y: 0.5, width: 75, height: 32), cornerRadius: 1)
    var knobSensitivity: CGFloat = 0.005
    var lastX: CGFloat = 0
    var lastY: CGFloat = 0
    
    public var taper: Double = 1.0 // Linear by default
    
    var range: ClosedRange = 0.0...1.0 {
        didSet {
            knobValue = CGFloat(Double(knobValue).normalized(range: range, taper: taper))
        }
    }
    
    // Knob properties
    var knobValue: CGFloat = 0.5 {
        didSet {
            self.setNeedsDisplay()
        }
    }
    
    private var _value: Double = 0
    
    var tempoValue: Double {
        get {
            return _value
        }
        set(newValue) {
            _value = range.clamp(newValue)
            
            _value = round(_value)
            knobValue = CGFloat(newValue.normalized(range: range, taper: taper))
        }
    }
    
    // Init / Lifecycle
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        minusPath = UIBezierPath(roundedRect: CGRect(x: 3.5, y: 38.5, width: 35, height: 32), cornerRadius: 1)
        plusPath = UIBezierPath(roundedRect: CGRect(x: 43.5, y: 38.5, width: 35, height: 32), cornerRadius: 1)
        
        minValue = 60
        maxValue = 180
        
        range = (Double(minValue) ... Double(maxValue))
        
        tempoValue = 120 // BPM
        
        text = "120"
    }
    
    // *********************************************************
    // MARK: - Draw
    // *********************************************************
    
    override func draw(_ rect: CGRect) {
        TempoStyleKit.drawTempoStepper(valuePressed: valuePressed, text: "\(Int(tempoValue)) bpm")
    }
    
    // *********************************************************
    // MARK: - Handle Touches
    // *********************************************************
    
    /// Handle new touches
    
    override open func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        
        if let touch = touches.first {
            let touchLocation = touch.location(in: self)
            
            if minusPath.contains(touchLocation) {
                if tempoValue > Double(minValue) {
                    tempoValue -= 1
                    valuePressed = 1
                }
            }
            
            if plusPath.contains(touchLocation) {
                if tempoValue < Double(maxValue) {
                    tempoValue += 1
                    valuePressed = 2
                }
            }
            
            if tempoPath.contains(touchLocation) {
                let touchPoint = touch.location(in: self)
                lastX = touchPoint.x
                lastY = touchPoint.y
            }
            
            self.callback(tempoValue)
            self.setNeedsDisplay()
        }
    }
    
    override public func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        if valuePressed == 0 {
            for touch in touches {
                let touchPoint = touch.location(in: self)
                setPercentagesWithTouchPoint(touchPoint)
            }
        }
    }
    
    // Helper
    func setPercentagesWithTouchPoint(_ touchPoint: CGPoint) {
        // Knobs assume up or right is increasing, and down or left is decreasing
        knobValue += (touchPoint.x - lastX) * knobSensitivity
        knobValue -= (touchPoint.y - lastY) * knobSensitivity
        
        knobValue = (0.0 ... 1.0).clamp(knobValue)
        
        tempoValue = Double(knobValue).denormalized(range: range, taper: taper)
        
        callback(tempoValue)
        lastX = touchPoint.x
        lastY = touchPoint.y
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        for _ in touches {
            valuePressed = 0
            self.setNeedsDisplay()
        }
    }
    
}
