//
//  MorphSelector.swift
//  AudioKit Synth One
//
//  Created by Aurelius Prochazka on 9/4/16.
//  Copyright © 2016 AudioKit. All rights reserved.
//

import Foundation
import UIKit

@IBDesignable
class MorphSelector: UIView, AKSynthOneControl {

    var callback: (Double)->Void = { _ in }

    var value: Double = 0 {
        didSet {
            if value < 0.0 { value = 0.0 }
            if value > 1.0 { value = 1.0 }
            setNeedsDisplay()
        }
    }
    
    //// Color Declarations
    @IBInspectable open var color: UIColor      = UIColor(red: 0.133, green: 0.133, blue: 0.133, alpha: 1.000)
    @IBInspectable open var selected: UIColor   = UIColor(red: 0.929, green: 0.533, blue: 0.000, alpha: 1.000)
    @IBInspectable open var unselected: UIColor = UIColor(red: 0.533, green: 0.533, blue: 0.533, alpha: 1.000)
    @IBInspectable open var selectedBG: UIColor = UIColor(red: 1.000, green: 1.000, blue: 1.000, alpha: 0.181)
        
    override open func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if let touch = touches.first {
            let touchLocation = touch.location(in: self)
            value = Double(touchLocation.x / self.frame.width)
            callback(value)
        }
        setNeedsDisplay()
    }
    
    override open func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        if let touch = touches.first {
            let touchLocation = touch.location(in: self)
            value = Double(touchLocation.x / self.frame.width)
            callback(value)
        }
        setNeedsDisplay()
    }
    
    override open func prepareForInterfaceBuilder() {
        super.prepareForInterfaceBuilder()
        
        contentMode = .scaleAspectFill
        clipsToBounds = true
    }

    
    open class override var requiresConstraintBasedLayout : Bool {
        return true
    }

    
    override public init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    
    override open func draw(_ rect: CGRect) {
        
        //// Variable Declarations
        let color1 = value <= 0.25 ? selected : unselected
        let color2 = value > 0.25 && value <= 0.5 ? selected : unselected
        let color3 = value > 0.5 && value <= 0.75 ? selected : unselected
        let color4 = value > 0.75 && value <= 1 ? selected : unselected
        let xValue: CGFloat = CGFloat(value) * 0.75 * self.frame.width + 6.0 / 259.0 * self.frame.width
        
        //// Frames
        let frame = CGRect(x: 0, y: 0, width: self.frame.width, height: self.frame.height)
        
        
        //// background Drawing
        let backgroundPath = UIBezierPath(rect: CGRect(x: frame.minX, y: frame.minY, width: 259, height: 53))
        color.setFill()
        backgroundPath.fill()
        
        
        //// Triangle Drawing
        let trianglePath = UIBezierPath()
        trianglePath.move(to: CGPoint(x: frame.minX + 0.05092 * frame.width, y: frame.minY + 0.52830 * frame.height))
        trianglePath.addLine(to: CGPoint(x: frame.minX + 0.07409 * frame.width, y: frame.minY + 0.37736 * frame.height))
        trianglePath.addLine(to: CGPoint(x: frame.minX + 0.12042 * frame.width, y: frame.minY + 0.67925 * frame.height))
        trianglePath.addLine(to: CGPoint(x: frame.minX + 0.15903 * frame.width, y: frame.minY + 0.37736 * frame.height))
        trianglePath.addLine(to: CGPoint(x: frame.minX + 0.18606 * frame.width, y: frame.minY + 0.52830 * frame.height))
        color1.setStroke()
        trianglePath.lineWidth = 2
        trianglePath.stroke()
        
        
        //// Square Drawing
        let squarePath = UIBezierPath()
        squarePath.move(to: CGPoint(x: frame.minX + 0.27240 * frame.width, y: frame.minY + 0.52830 * frame.height))
        squarePath.addLine(to: CGPoint(x: frame.minX + 0.27240 * frame.width, y: frame.minY + 0.37736 * frame.height))
        squarePath.addLine(to: CGPoint(x: frame.minX + 0.31487 * frame.width, y: frame.minY + 0.37736 * frame.height))
        squarePath.addLine(to: CGPoint(x: frame.minX + 0.31487 * frame.width, y: frame.minY + 0.67925 * frame.height))
        squarePath.addLine(to: CGPoint(x: frame.minX + 0.35734 * frame.width, y: frame.minY + 0.67925 * frame.height))
        squarePath.addLine(to: CGPoint(x: frame.minX + 0.35734 * frame.width, y: frame.minY + 0.37736 * frame.height))
        squarePath.addLine(to: CGPoint(x: frame.minX + 0.39981 * frame.width, y: frame.minY + 0.37736 * frame.height))
        squarePath.addLine(to: CGPoint(x: frame.minX + 0.39981 * frame.width, y: frame.minY + 0.52830 * frame.height))
        color2.setStroke()
        squarePath.lineWidth = 2
        squarePath.stroke()
        
        
        //// HighPWMValue Drawing
        let highPWMValuePath = UIBezierPath()
        highPWMValuePath.move(to: CGPoint(x: frame.minX + 0.52688 * frame.width, y: frame.minY + 0.52830 * frame.height))
        highPWMValuePath.addLine(to: CGPoint(x: frame.minX + 0.52688 * frame.width, y: frame.minY + 0.37736 * frame.height))
        highPWMValuePath.addLine(to: CGPoint(x: frame.minX + 0.55005 * frame.width, y: frame.minY + 0.37736 * frame.height))
        highPWMValuePath.addLine(to: CGPoint(x: frame.minX + 0.55005 * frame.width, y: frame.minY + 0.69811 * frame.height))
        highPWMValuePath.addLine(to: CGPoint(x: frame.minX + 0.59252 * frame.width, y: frame.minY + 0.69811 * frame.height))
        highPWMValuePath.addLine(to: CGPoint(x: frame.minX + 0.59252 * frame.width, y: frame.minY + 0.37736 * frame.height))
        highPWMValuePath.addLine(to: CGPoint(x: frame.minX + 0.61568 * frame.width, y: frame.minY + 0.37736 * frame.height))
        highPWMValuePath.addLine(to: CGPoint(x: frame.minX + 0.61568 * frame.width, y: frame.minY + 0.52830 * frame.height))
        color3.setStroke()
        highPWMValuePath.lineWidth = 2
        highPWMValuePath.stroke()
        
        
        //// Sawtooth Drawing
        let sawtoothPath = UIBezierPath()
        sawtoothPath.move(to: CGPoint(x: frame.minX + 0.74337 * frame.width, y: frame.minY + 0.54717 * frame.height))
        sawtoothPath.addLine(to: CGPoint(x: frame.minX + 0.77812 * frame.width, y: frame.minY + 0.37736 * frame.height))
        sawtoothPath.addLine(to: CGPoint(x: frame.minX + 0.77812 * frame.width, y: frame.minY + 0.71698 * frame.height))
        sawtoothPath.addLine(to: CGPoint(x: frame.minX + 0.84376 * frame.width, y: frame.minY + 0.37736 * frame.height))
        sawtoothPath.addLine(to: CGPoint(x: frame.minX + 0.84376 * frame.width, y: frame.minY + 0.71698 * frame.height))
        sawtoothPath.addLine(to: CGPoint(x: frame.minX + 0.88468 * frame.width, y: frame.minY + 0.54717 * frame.height))
        color4.setStroke()
        sawtoothPath.lineWidth = 2
        sawtoothPath.stroke()
        
        
        //// Chosen Area Drawing
        let chosenAreaPath = UIBezierPath(rect: CGRect(x: xValue, y: 4.5, width: (self.frame.width * 0.2), height: (self.frame.height * 0.8)))
        selectedBG.setFill()
        chosenAreaPath.fill()
        UIColor.clear.setStroke()
        chosenAreaPath.lineWidth = 1
        chosenAreaPath.stroke()
        
    }
}


