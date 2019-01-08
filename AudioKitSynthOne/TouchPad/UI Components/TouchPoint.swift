//
//  TouchPoint.swift
//  AudioKitSynthOne
//
//  Created by AudioKit Contributors on 8/29/17.
//  Copyright © 2017 AudioKit. All rights reserved.
//

import UIKit

@IBDesignable
class TouchPoint: UIView {

    var x = 0.0
    var y = 0.0
    var width = 63.0

    override func draw(_ rect: CGRect) {
         TouchPointStyleKit.drawTouchPoint(frame: CGRect(x: x, y: y, width: width, height: width) )
    }

}

class ModWheelTouchPoint: UIView {

    var x = 0.0
    var y = 0.0
    var width = 61.0

    override func draw(_ rect: CGRect) {
        ModWheelStyleKit.drawTouchPoint(frame: CGRect(x: x, y: y, width: width, height: width) )
    }

}
