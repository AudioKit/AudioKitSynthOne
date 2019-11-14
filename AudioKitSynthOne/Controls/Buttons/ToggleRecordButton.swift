//
//  ToggleRecordButton.swift
//  AudioKitSynthOne
//
//  Created by Mark Jeschke on 11/13/19.
//  Copyright © 2019 AudioKit. All rights reserved.
//

import UIKit

@IBDesignable
class ToggleRecordButton: UIView, S1Control {

    // MARK: - ToggleButton

    var isOn = false {
        didSet {
            setNeedsDisplay()
            accessibilityValue = isOn ? NSLocalizedString("On", comment: "On") : NSLocalizedString("Off", comment: "Off")
        }
    }

    // MARK: - S1Control

    var value: Double = 0 {
        didSet {
            isOn = (value == 1)
        }
    }

    var setValueCallback: (Double) -> Void = { _ in }
    
    var resetToDefaultCallback: () -> Void = { }
    
    // MARK: - Draw
    
    override func draw(_ rect: CGRect) {
        ToggleRecordButtonStyleKit.drawRoundButton(frame: CGRect(x: 0,
                                                           y: 0,
                                                           width: self.bounds.width,
                                                           height: self.bounds.height),
                                             isToggled: isOn)
    }

    // MARK: - Touches

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        for _ in touches {
            value = 1 - value
            setValueCallback(value)
        }
    }

    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {

        for _ in touches {
            setValueCallback(value)
        }
    }
}
