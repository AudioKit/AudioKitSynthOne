//
//  NavButton.swift
//  AudioKitSynthOne
//
//  Created by AudioKit Contributors on 8/6/17.
//  Copyright © 2017 AudioKit. All rights reserved.
//

import UIKit

@IBDesignable
class NavButton: UIView {

    // MARK: - ToggleButton

    private var isOn = false
    var value: Double {
        get {
            return isOn ? 1 : 0
        }
        set {
            isOn = value == 1.0
        }
    }

    enum Direction: CGFloat {
        case left = 0
        case right = 180
    }

    var arrowDirection: Direction = .left {
        didSet {
            rotation = arrowDirection.rawValue
        }
    }

    public var callback: (Double) -> Void = { _ in }

    // Make Button Text Editable in IB
    @IBInspectable open var buttonText: String = "Hello"
    @IBInspectable open var rotation: CGFloat = 0

    override func draw(_ rect: CGRect) {
        NavButtonStyleKit.drawNavButton(frame: CGRect(x: 0,
                                                      y: 0,
                                                      width: self.bounds.width,
                                                      height: self.bounds.height),
                                        isOn: CGFloat(value),
                                        rotation: rotation,
                                        text: buttonText)
    }

    // MARK: - Handle Touches

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        for _ in touches {
            callback(value)
        }
    }

    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        for _ in touches {
        }
    }

}
