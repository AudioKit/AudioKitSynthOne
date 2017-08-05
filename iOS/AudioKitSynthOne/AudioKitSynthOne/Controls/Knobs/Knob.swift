//
//  KnobView.swift
//  AudioKit Synth One
//
//  Created by Matthew Fecher on 7/20/17.
//  Copyright © 2017 Matthew Fecher. All rights reserved.
//

import UIKit
import AudioKit

open class AKSynthOneControl: UIView {
    open var value: Double = 0
    open var callback: (Double)->Void = { _ in }
}

public enum KnobType {
    case generic, time, rate
}
 
@IBDesignable
public class Knob: AKSynthOneControl {

    var onlyIntegers: Bool = false
    var tempoSync: Bool = false {
        didSet {
             // set Knob Value - Rounding Solution!
        }
    }

    var type: KnobType = .generic
    
    public var taper: Double = 1.0 // Linear by default

    var range: ClosedRange = 0.0...1.0 {
        didSet {
            if tempoSync {
                 // set Knob Value
            } else {
                 knobValue = CGFloat(Double(knobValue).normalized(range: range, taper: taper))
            }
            
        }
    }

    private var _value: Double = 0

    override public var value: Double {
        get {
            return _value
            // TODO: TempoSync
        }
        set(newValue) {
            // TODO: TempoSync
            _value = range.clamp(newValue)

            _value = onlyIntegers ? round(_value) : _value
            knobValue = CGFloat(newValue.normalized(range: range, taper: taper))
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
    
    
    // MARK: - RETURN DISPLAY, refactor, maybe this is a knob extension?
    /*
    var ms = 100.00
    
    func returnSyncValues() {
        // Knob Did Change
        switch value {
     
     case 0:
             ms = appTempo.sixtyfourth()
             print("1/64")
             print ("\(ms)ms")
     
        case 1:
            ms = appTempo.thirtysecondth()
            print("1/32")
            print ("\(ms)ms")
            
        case 2:
            ms = appTempo.sixteenthTriplet()
            print("1/16T")
            print ("\(ms)ms")
            
        case 3:
            ms = appTempo.sixteenth()
            print("1/16")
            print ("\(ms)ms")
            
        case 4:
            ms = appTempo.eighthTriplet()
            print("1/8T")
            print ("\(ms)ms")
            
        case 5:
            ms = appTempo.eighth()
            print("1/8")
            print ("\(ms)ms")
            
        case 6:
            ms = appTempo.quarterTriplet()
            print("1/4T")
            print ("\(ms)ms")
            
        case 7:
            ms = appTempo.quarter()
            print("1/4")
            print ("\(ms)ms")
     
     
        case 8:
        ms = appTempo.halfTriplet()
        print("1/2T")
        print ("\(ms)ms")
            
        case 9:
            ms = appTempo.half()
            print("1/2")
            print ("\(ms)ms")
            
        case 10:
            ms = appTempo.bar()
            print("1 Bar")
            print ("\(ms)ms")
            
        case 11:
            ms = appTempo.twoBars()
            print("2 Bars")
            print ("\(ms)ms")
            
        case 12:
            ms = appTempo.threeBars()
            print("3 Bars")
            print ("\(ms)ms")
            
        case 13:
            ms = appTempo.fourBars()
            print("4 Bars")
            print ("\(ms)ms")
            
        case 14:
            ms = appTempo.eightBars()
            print("8 Bars")
            print ("\(ms)ms")
            
        default:
            print("what what")
            
        }
        */
}
