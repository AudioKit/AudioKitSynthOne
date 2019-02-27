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
        FlatToggleButtonStyleKit.drawRoundButton(frame: CGRect(x: 0,
                                                               y: 0,
                                                               width: self.bounds.width,
                                                               height: self.bounds.height),
                                                               isToggled: isOn)
    }

}
