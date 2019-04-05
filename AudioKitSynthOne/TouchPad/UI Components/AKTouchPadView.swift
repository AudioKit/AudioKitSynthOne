//
//  AKTouchPadView.swift
//  AudioKit
//
//  Created by AudioKit Contributors, revision history on Github.
//  Copyright © 2017 AudioKit. All rights reserved.
//

import UIKit

public class AKTouchPadView: UIView {

    // touch properties
    var firstTouch: UITouch?

    public typealias AKTouchPadCallback = (Double, Double, Bool) -> Void
    var callback: AKTouchPadCallback = { _, _, _ in }

    public typealias AKTouchPadCompletionHandler = (Double, Double, Bool, Bool) -> Void
    var completionHandler: AKTouchPadCompletionHandler = { _, _, _, _ in }

    var x: CGFloat = 0
    var y: CGFloat = 0
    private var lastX: CGFloat = 0
    private var lastY: CGFloat = 0

    public var horizontalTaper: Double = 1.0 // Linear by default

    public var horizontalRange: ClosedRange = 0.0...1.0 {
        didSet {
            x = CGFloat(horizontalValue.normalized(from: horizontalRange, taper: horizontalTaper))
        }
    }

    public var horizontalValue: Double = 0 {
        didSet {
            horizontalValue = horizontalRange.clamp(horizontalValue)
            x = CGFloat(horizontalValue.normalized(from: horizontalRange, taper: horizontalTaper))
        }
    }

    public var verticalTaper: Double = 1.0 // Linear by default

    public var verticalRange: ClosedRange = 0.0...1.0 {
        didSet {
            y = CGFloat(verticalValue.normalized(from: verticalRange, taper: verticalTaper))
        }
    }

    public var verticalValue: Double = 0 {
        didSet {
            verticalValue = verticalRange.clamp(verticalValue)
            y = CGFloat(verticalValue.normalized(from: verticalRange, taper: verticalTaper))
        }
    }

    var touchPointView: TouchPoint!

    override init (frame: CGRect) {
        super.init(frame: frame)
    }

    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)

        // Setup Touch Visual Indicators
        var width = 63.0
        if Conductor.sharedInstance.device == .phone { width = 44.0 }
        touchPointView = TouchPoint(frame: CGRect(x: -200, y: -200, width: width, height: width))
        touchPointView.width = width
        touchPointView.center = CGPoint(x: self.bounds.size.width / 2, y: self.bounds.size.height / 2)
        touchPointView.isOpaque = false
        addSubview(touchPointView)
    }

    override public func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        for touch in touches {
            let touchPoint = touch.location(in: self)
            lastX = touchPoint.x
            lastY = touchPoint.y
            setPercentagesWithTouchPoint(touchPoint, began: true)
        }
    }

    override public func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        for touch in touches {
            let touchPoint = touch.location(in: self)
            setPercentagesWithTouchPoint(touchPoint, began: false)
        }
    }

    // return indicator to center of view
    override public func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        completionHandler(horizontalValue, verticalValue, true, false)
    }

    func resetToCenter() {
        resetToPosition(0.5, 0.5)
    }

    func resetToPosition(_ newPercentX: Double, _ newPercentY: Double) {
        let centerPointX = self.bounds.size.width * CGFloat(newPercentX)
        let centerPointY = self.bounds.size.height * CGFloat(1 - newPercentY)
        UIView.animate(
            withDuration: 0.2,
            delay: 0.0,
            options: UIView.AnimationOptions(),
            animations: {
                self.touchPointView.center = CGPoint(x: centerPointX, y: centerPointY)
            },
            completion: { _ in
                self.x = CGFloat(newPercentX)
                self.y = CGFloat(newPercentY)
                self.horizontalValue = Double(self.x).denormalized(to: self.horizontalRange,
                                                                   taper: self.horizontalTaper)
                self.verticalValue = Double(self.y).denormalized(to: self.verticalRange, taper: self.verticalTaper)
                self.completionHandler(self.horizontalValue, self.verticalValue, true, true)
            })
    }

    func updateTouchPoint(_ newX: Double, _ newY: Double) {
        let centerPointX = self.bounds.size.width * CGFloat(newX)
        let centerPointY = self.bounds.size.height * CGFloat(1 - newY)
        x = CGFloat(newX)
        y = CGFloat(newY)
        touchPointView.center = CGPoint(x: centerPointX, y: centerPointY)
    }


    //TODO: come back here
    func setPercentagesWithTouchPoint(_ touchPoint: CGPoint, began: Bool = false) {
        x = CGFloat((0.0 ... 1.0).clamp(touchPoint.x / self.bounds.size.width))
        y = CGFloat((0.0 ... 1.0).clamp(1 - touchPoint.y / self.bounds.size.height))
        touchPointView.center = CGPoint(x: touchPoint.x, y: touchPoint.y)
        horizontalValue = Double(x).denormalized(to: horizontalRange, taper: horizontalTaper)
        verticalValue = Double(y).denormalized(to: verticalRange, taper: verticalTaper)
        callback(horizontalValue, verticalValue, began)
    }
}
