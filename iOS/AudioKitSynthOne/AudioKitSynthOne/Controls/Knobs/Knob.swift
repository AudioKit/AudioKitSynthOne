//
//  KnobView.swift
//  AudioKit Synth One
//
//  Created by Matthew Fecher on 7/20/17.
//  Copyright © 2017 Matthew Fecher. All rights reserved.
//

import UIKit
import AudioKit

protocol AKSynthOneControl {
    var value: Double { get set }
    var callback: (Double)->Void { get set }
}
 
@IBDesignable
public class Knob: UIView, AKSynthOneControl {

    var onlyIntegers: Bool = false

    public var callback: (Double)->Void = { _ in }

    public var taper: Double = 1.0 // Linear by default

    var range: ClosedRange = 0.0...1.0 {
        didSet {
            knobValue = CGFloat(Double(knobValue).normalized(range: range, taper: taper))
        }
    }

    var value: Double = 0 {
        didSet {
            value = range.clamp(value)

            value = onlyIntegers ? round(value) : value
            knobValue = CGFloat(value.normalized(range: range, taper: taper))
        }
    }
    
    // Knob properties
    var knobValue: CGFloat = 0.0 {
        didSet {
            setNeedsDisplay()
        }
    }
    var knobFill: CGFloat = 0
    var knobSensitivity: CGFloat = 0.005
    var lastX: CGFloat = 0
    var lastY: CGFloat = 0
    
    // Init / Lifecycle
    override init(frame: CGRect) {
        super.init(frame: frame)
        contentMode = .redraw
    }
    
    required public init?(coder: NSCoder) {
        super.init(coder: coder)
        self.isUserInteractionEnabled = true
        contentMode = .redraw
    }
    
    override public func prepareForInterfaceBuilder() {
        super.prepareForInterfaceBuilder()
        
        contentMode = .scaleAspectFit
        clipsToBounds = true
    }
    
    public class override var requiresConstraintBasedLayout: Bool {
        return true
    }
    
    public override func draw(_ rect: CGRect) {
        KnobStyleKit.drawKnobOne(frame: CGRect(x:0,y:0, width: self.bounds.width, height: self.bounds.height), knobValue: knobValue)
    }
    
    // Helper
    func setPercentagesWithTouchPoint(_ touchPoint: CGPoint) {
        // Knobs assume up or right is increasing, and down or left is decreasing
        
        knobValue += (touchPoint.x - lastX) * knobSensitivity
        knobValue -= (touchPoint.y - lastY) * knobSensitivity

        if knobValue > 1.0 {
            knobValue = 1.0
        }
        if knobValue < 0.0 {
            knobValue = 0.0
        }

        value = Double(knobValue).denormalized(range: range, taper: taper)
        
        callback(value)
        lastX = touchPoint.x
        lastY = touchPoint.y
    }
    
}
