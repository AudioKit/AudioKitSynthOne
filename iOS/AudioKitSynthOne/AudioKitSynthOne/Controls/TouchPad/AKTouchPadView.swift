//
//  AKTouchPadView.swift
//  AudioKit
//
//  Created by Aurelius Prochazka, revision history on Github.
//  Copyright © 2017 AudioKit. All rights reserved.
//

import UIKit

public class AKTouchPadView: UIView {
    
    // touch properties
    var firstTouch: UITouch?

    public typealias AKTouchPadCallback = (Double, Double, Bool) -> Void
    var callback: AKTouchPadCallback = { _, _, _ in }

    private var x: CGFloat = 0
    private var y: CGFloat = 0
    private var lastX: CGFloat = 0
    private var lastY: CGFloat = 0

    public var horizontalTaper: Double = 1.0 // Linear by default

    public var horizontalRange: ClosedRange = 0.0...1.0 {
        didSet {
            x = CGFloat(horizontalValue.normalized(range: horizontalRange, taper: horizontalTaper))
        }
    }

    public var horizontalValue: Double = 0 {
        didSet {
            horizontalValue = horizontalRange.clamp(horizontalValue)
            x = CGFloat(horizontalValue.normalized(range: horizontalRange, taper: horizontalTaper))
        }
    }

    public var verticalTaper: Double = 1.0 // Linear by default

    public var verticalRange: ClosedRange = 0.0...1.0 {
        didSet {
            x = CGFloat(verticalValue.normalized(range: verticalRange, taper: verticalTaper))
        }
    }

    public var verticalValue: Double = 0 {
        didSet {
            verticalValue = verticalRange.clamp(verticalValue)
            x = CGFloat(verticalValue.normalized(range: verticalRange, taper: verticalTaper))
        }
    }

    var touchImageView: UIImageView!

    override init (frame : CGRect) {
        super.init(frame : frame)
    }
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)

        // Setup Touch Visual Indicators
        touchImageView = UIImageView(frame: CGRect(x: -200, y: -200, width: 85, height: 85))
        touchImageView.image = UIImage(named: "touchpoint2")
        touchImageView.center = CGPoint(x: self.bounds.size.width/2, y: self.bounds.size.height/2)

        self.addSubview(touchImageView)
    }
    
    override public func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        for touch in touches {
            let touchPoint = touch.location(in: self)
            lastX = touchPoint.x
            lastY = touchPoint.y
            setPercentagesWithTouchPoint(touchPoint)
        }
    }
    
    override public func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        for touch in touches {
            let touchPoint = touch.location(in: self)
            setPercentagesWithTouchPoint(touchPoint)
        }
    }
    
    override public func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        // return indicator to center of view
        callback(horizontalValue, verticalValue, true)
    }

    func resetToCenter() {
        resetToPosition(0.5, 0.5)
    }
    
    func resetToPosition(_ newPercentX: Double, _ newPercentY: Double) {
        let centerPointX = self.bounds.size.width * CGFloat(newPercentX)
        let centerPointY = self.bounds.size.height * CGFloat((1 - newPercentY))
   
        UIView.animate(
            withDuration: 0.2,
            delay: 0.0,
            options: UIViewAnimationOptions(),
            animations: { self.touchImageView.center = CGPoint(x: centerPointX, y: centerPointY) },
            completion: { finished in
                self.x = CGFloat(newPercentX)
                self.y = CGFloat(newPercentY)

                self.horizontalValue = Double(self.x).denormalized(range: self.horizontalRange, taper: self.horizontalTaper)
                self.verticalValue = Double(self.y).denormalized(range: self.verticalRange, taper: self.verticalTaper)
                self.callback(self.horizontalValue, self.verticalValue, false)
        })
    }
    
    func setPercentagesWithTouchPoint(_ touchPoint: CGPoint) {
        x = CGFloat((0.0 ... 1.0).clamp(touchPoint.x / self.bounds.size.width))
        y = CGFloat((0.0 ... 1.0).clamp(1 - touchPoint.y / self.bounds.size.height))

        touchImageView.center = CGPoint(x: touchPoint.x, y: touchPoint.y)
        horizontalValue = Double(x).denormalized(range: horizontalRange, taper: horizontalTaper)
        verticalValue = Double(y).denormalized(range: verticalRange, taper: verticalTaper)
        callback(horizontalValue, verticalValue, false)
    }
    
}
