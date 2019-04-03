//
//  AKTouchPadView.swift
//  AudioKit
//
//  Created by AudioKit Contributors, revision history on Github.
//  Copyright © 2017 AudioKit. All rights reserved.
//

import AudioKit
import UIKit

public class AKVerticalPad: UIView {

    // touch properties
    var firstTouch: UITouch?

    public typealias AKVerticalPadCallback = (Double) -> Void
    var callback: AKVerticalPadCallback = { _ in }

    public typealias AKVerticalPadCompletionHandler = (Double, Bool, Bool) -> Void
    var completionHandler: AKVerticalPadCompletionHandler = { _, _, _ in }

    private var x: CGFloat = 0
    private var y: CGFloat = 0
    private var lastX: CGFloat = 0
    private var lastY: CGFloat = 0
    private var centerPointX: CGFloat = 0
    private var yVisualAdjust: CGFloat = 6

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

    var touchPointView: ModWheelTouchPoint!

    override init (frame: CGRect) {
        super.init(frame: frame)
    }

    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        centerPointX = self.bounds.size.width / 2

        // Setup Touch Visual Indicators
        touchPointView = ModWheelTouchPoint(frame: CGRect(x: -200, y: -200, width: 58, height: 58))
        touchPointView.center = CGPoint(x: centerPointX, y: self.bounds.size.height / 2)
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
            if touchPoint.y > (self.bounds.minY + 0) && touchPoint.y < (self.bounds.maxY) {
                setPercentagesWithTouchPoint(touchPoint, began: false)
            }
        }
    }

    // return indicator to center of view
    override public func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        completionHandler(verticalValue, true, false)
    }

    // Linear Scale MIDI 0...127 to 0.0...1.0
    func setVerticalValueFrom(midiValue: MIDIByte) {
        verticalValue = Double(midiValue).normalized(from: 0...127)
        let verticalPos = self.bounds.height - (self.bounds.height * CGFloat(verticalValue))
        touchPointView.center = CGPoint(x: centerPointX, y: verticalPos + yVisualAdjust)
        callback(verticalValue)
    }

    // Linear Scale from PitchWheel
    func setVerticalValueFromPitchWheel(midiValue: MIDIWord) {
        verticalValue = Double(midiValue).normalized(from: 0...16_383)
        let verticalPos = self.bounds.height - (self.bounds.height * CGFloat(verticalValue))
        touchPointView.center = CGPoint(x: centerPointX, y: verticalPos + yVisualAdjust)
        callback(verticalValue)
    }

    func setVerticalValue01(_ inputValue01: Double) {
        verticalValue = (0...1).clamp(inputValue01)
        let verticalPos = self.bounds.height - (self.bounds.height * CGFloat(verticalValue))
        touchPointView.center = CGPoint(x: centerPointX, y: verticalPos + yVisualAdjust)
        // do not call callback() !
    }

    func resetToCenter() {
        resetToPosition(0.5, 0.5)
    }

    func resetToPosition(_ newPercentX: Double = 0.5, _ newPercentY: Double) {
        let centerPointY = self.bounds.size.height * CGFloat((1 - newPercentY))

        UIView.animate(
            withDuration: 0.05,
            delay: 0.0,
            options: UIView.AnimationOptions(),
            animations: { self.touchPointView.center = CGPoint(x: self.centerPointX,
                                                               y: centerPointY + self.yVisualAdjust)
            },
            completion: { _ in
                self.x = CGFloat(newPercentX)
                self.y = CGFloat(newPercentY)

                self.verticalValue = Double(self.y).denormalized(to: self.verticalRange, taper: self.verticalTaper)
                self.completionHandler(self.verticalValue, true, true)
            }
        )
    }

    func setPercentagesWithTouchPoint(_ touchPoint: CGPoint, began: Bool = false) {
        y = CGFloat((0.0 ... 1.0).clamp(1 - touchPoint.y / self.bounds.size.height))
        let hx: CGFloat = 1.1
        let hc: CGFloat = -(hx-1)/2
        y = CGFloat((0.0 ... 1.0).clamp(y * hx + hc))
        touchPointView.center = CGPoint(x: centerPointX, y: touchPoint.y + yVisualAdjust)
        verticalValue = Double(y).denormalized(to: verticalRange, taper: verticalTaper)
        callback(verticalValue)
    }
}

// This is just to suppress warnings when passing AKVerticalPad as a payload to DSP setter
extension AKVerticalPad: S1Control {
    var defaultCallback: () -> Void {
        get {
            return { }
        }
        set { }
    }

    var value: Double {
        get {
            return verticalValue
        }
        set(newValue) {
            verticalValue = newValue
        }
    }
}
