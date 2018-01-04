//
//  TransposeButton.swift
//  SynthUISpike
//
//  Created by Matthew Fecher on 8/1/17.
//  Copyright © 2017 Matthew Fecher. All rights reserved.
//

import UIKit
import AudioKit

class TransposeButton: UILabel, AKSynthOneControl {
    
    // *********************************************************
    // MARK: - Make Label ToggleButton
    // *********************************************************
    
    
    private var _value: Double = 0
    var value: Double {
        get {
            return _value
        }
        set {
            if newValue > 0 {
                _value = 1
                self.backgroundColor = #colorLiteral(red: 0.4961370826, green: 0.4989871979, blue: 0.5060116649, alpha: 1)
            } else {
                _value = 0
                self.backgroundColor = #colorLiteral(red: 0.2549019754, green: 0.2745098174, blue: 0.3019607961, alpha: 1)
            }
            setNeedsDisplay()
        }
    }
    
    public var callback: (Double)->Void = { _ in }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        clipsToBounds = true
        layer.cornerRadius = 2
        layer.borderWidth = 1
        layer.borderColor = #colorLiteral(red: 0.09411764706, green: 0.09411764706, blue: 0.09411764706, alpha: 1)
    }
    
    // *********************************************************
    // MARK: - Handle Touches
    // *********************************************************
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        for _ in touches {
            
            // toggle
            if value > 0 {
                value = 0
            } else {
                value = 1
            }
            
            callback(value)
        }
    }
}
