//
//  TransposeButton.swift
//  SynthUISpike
//
//  Created by Matthew Fecher on 8/1/17.
//  Copyright © 2017 Matthew Fecher. All rights reserved.
//

import UIKit

class TransposeButton: UILabel {
    
    // *********************************************************
    // MARK: - Make Label ToggleButton
    // *********************************************************
    
    private var isOn = false {
        didSet {
            if isOn {
                self.backgroundColor = #colorLiteral(red: 0.2745098039, green: 0.2705882353, blue: 0.2784313725, alpha: 1)
            } else {
                self.backgroundColor = #colorLiteral(red: 0.2117647059, green: 0.2078431373, blue: 0.2156862745, alpha: 1)
            }
        }
    }
    
    var value: Double {
        get {
            return isOn ? 1 : 0
        }
        set {
            isOn = value == 1.0
        }
    }
    
    public var callback: (Double)->Void = { _ in }
    
    // *********************************************************
    // MARK: - Handle Touches
    // *********************************************************
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        for _ in touches {
            isOn = !isOn
            self.setNeedsDisplay()
            callback(value)
        }
    }
}
