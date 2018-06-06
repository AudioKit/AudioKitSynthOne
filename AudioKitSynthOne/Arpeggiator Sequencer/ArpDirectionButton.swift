//
//  ArpDirectionButton.swift
//  AudioKitSynthOne
//
//  Created by AudioKit Contributors on 8/2/17.
//  Copyright © 2018 AudioKit. All rights reserved.
//

import UIKit

@IBDesignable
class ArpDirectionButton: UIView, S1Control {

    // MARK: - LFO Button

    public var callback: (Double) -> Void = { _ in }

    private var width: CGFloat = 35.0

    var value = 0.0 {
        didSet {
           setNeedsDisplay()
        }
    }

    // Draw Button
    override func draw(_ rect: CGRect) {
        ArpDirectionStyleKit.drawArpDirectionButton(directionSelected: CGFloat(value))
    }

    // MARK: - Handle Touches

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        for touch in touches {
            let touchPoint = touch.location(in: self)

            switch touchPoint.x {
            case 0..<width:
                value = 0
            case width...width * 2:
                value = 1
            default:
                value = 2
            }
            callback(value)
        }
    }
}
