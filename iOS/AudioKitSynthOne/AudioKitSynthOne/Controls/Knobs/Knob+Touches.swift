//
//  Knob+Touches.swift
//  AudioKit Synth One
//
//  Created by AudioKit Contributors on 1/9/16.
//  Copyright © 2016 AudioKit. All rights reserved.
//

import UIKit

extension Knob {

    override public func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        for touch in touches {
            let touchPoint = touch.location(in: self)
            lastX = touchPoint.x
            lastY = touchPoint.y
        }
    }

    override public func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        for touch in touches {
            let touchPoint = touch.location(in: self)
            setPercentagesWithTouchPoint(touchPoint)
        }
    }

}
