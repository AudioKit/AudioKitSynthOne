//
//  SynthUIButton.swift
//  AudioKitSynthOne
//
//  Created by Matthew Fecher on 8/8/17.
//  Copyright © 2017 AudioKit. All rights reserved.
//

import UIKit

class SynthUIButton: UIButton, AKSynthOneControl {

    var callback: (Double)->Void = { _ in }

    private var isOn = false
    
    override var isSelected: Bool {
        didSet {
            isOn = isSelected
            self.backgroundColor = isOn ? #colorLiteral(red: 0.368627451, green: 0.368627451, blue: 0.3882352941, alpha: 1) : #colorLiteral(red: 0.3058823529, green: 0.3058823529, blue: 0.3254901961, alpha: 1)
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

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        clipsToBounds = true
        layer.cornerRadius = 2
        layer.borderWidth = 1
//        layer.borderColor = #colorLiteral(red: 0.09803921569, green: 0.09803921569, blue: 0.09803921569, alpha: 1) as! CGColor
    }
    
    // *********************************************************
    // MARK: - Handle Touches
    // *********************************************************
    
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        for _ in touches {
            isSelected = !isSelected
            self.setNeedsDisplay()
            callback(value)
        }
    }
    
}

