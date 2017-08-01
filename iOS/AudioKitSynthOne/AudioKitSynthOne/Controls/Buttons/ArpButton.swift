//
//  ArpButton.swift
//  SynthUISpike
//
//  Created by Matthew Fecher on 8/1/17.
//  Copyright © 2017 Matthew Fecher. All rights reserved.
//

import UIKit

@IBDesignable
class ArpButton: UIView {
    
    // *********************************************************
    // MARK: - ToggleButton
    // *********************************************************
    
    private var isOn = false
    var value: Double {
        get {
            return isOn ? 1 : 0
        }
        set {
            isOn = value == 1.0
        }
    }
    
    public var callback: (Double)->Void = { _ in }
    
    override func draw(_ rect: CGRect) {
        ArpButtonStyleKit.drawArpButton(isToggled: isOn)
    }
    
    // *********************************************************
    // MARK: - Handle Touches
    // *********************************************************
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        for _ in touches {
            isOn = !isOn
            self.setNeedsDisplay()
            print("calling back")
            callback(value)
        }
    }
    
    
}
