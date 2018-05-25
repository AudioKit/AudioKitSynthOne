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

    var callback: (Double) -> Void = { _ in }

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

    override open func prepareForInterfaceBuilder() {
        super.prepareForInterfaceBuilder()

        contentMode = .scaleAspectFill
        clipsToBounds = true
    }

    open class override var requiresConstraintBasedLayout: Bool {
        return true
    }

    override public init(frame: CGRect) {
        super.init(frame: frame)
    }

    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    override open func draw(_ rect: CGRect) {
        MorphSelectorStyleKit.drawMorphSelector(value: CGFloat(value), width: self.bounds.width, height: self.bounds.height)
    }

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
            //print("Morph \(value.decimalString)")
        }
        setNeedsDisplay()
    }
}
