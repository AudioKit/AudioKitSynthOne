//
//  FlatToggleButton.swift
//  AudioKitSynthOne
//
//  Created by AudioKit Contributors on 8/28/17.
//  Copyright © 2017 AudioKit. All rights reserved.
//

import UIKit

@IBDesignable
class FlatToggleButton: ToggleButton {

    override func draw(_ rect: CGRect) {
        FlatToggleButtonStyleKit.drawRoundButton(isToggled: isOn)
    }

}
