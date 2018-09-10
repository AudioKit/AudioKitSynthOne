//
//  ChannelStepper.swift
//  AudioKitSynthOne
//
//  Created by AudioKit Contributors on 12/26/17.
//  Copyright © 2017 AudioKit. All rights reserved.
//

import UIKit

@IBDesignable
class ChannelStepper: Stepper {

    // MARK: - Draw

    override func draw(_ rect: CGRect) {
        let displayText = (value == 0) ? "∞" : String(Int(value))
		accessibilityValue = (value == 0 ? NSLocalizedString("Omni", comment: "Omni") : String(Int(value)))
        StepperStyleKit.drawStepper(valuePressed: valuePressed, text: displayText)
    }

}
