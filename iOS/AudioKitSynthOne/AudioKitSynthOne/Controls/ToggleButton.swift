//
//  ToggleButton.swift
//  SynthUISpike
//
//  Created by Matthew Fecher on 7/22/17.
//  Copyright © 2017 Matthew Fecher. All rights reserved.
//

import UIKit

protocol ToggleButtonDelegate {
    func updateToggleState(_ isToggled: Bool, tag: Int)
}

@IBDesignable
class ToggleButton: UIView {
    
    // *********************************************************
    // MARK: - ToggleButton
    // *********************************************************

    var isToggled = false
    var delegate: ToggleButtonDelegate?
    
    override func draw(_ rect: CGRect) {
        ButtonStyleKit.drawRoundButton(isToggled: isToggled)
    }
    
    // *********************************************************
    // MARK: - Handle Touches
    // *********************************************************
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        for _ in touches {
            isToggled = !isToggled
            setNeedsDisplay()
            delegate?.updateToggleState(isToggled, tag: self.tag)
        }
    }
 

}
