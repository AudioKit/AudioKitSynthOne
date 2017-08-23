//
//  FilterTypeButton.swift
//  AudioKitSynthOne
//
//  Created by Matthew Fecher on 8/23/17.
//  Copyright © 2017 AudioKit. All rights reserved.
//

import UIKit

class FilterTypeButton: UIButton {

    var callback: (Double)->Void = { _ in }
    var value: Double = 0 {
        didSet {
            switch value {
            case 0:
                // cutoff
                self.setTitle("low pass", for: .normal)
            case 1:
                // highpass
                   self.setTitle("high pass", for: .normal)
            case 2:
                // bandpass
                 self.setTitle("band pass", for: .normal)
            default:
                break
            }
        }
    }
    
    
    // *********************************************************
    // MARK: - Handle Touches
    // *********************************************************
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        for _ in touches {
            value += 1
            if value == 3 { value = 0 }
            setNeedsDisplay()
            callback(value)
        }
    }

}
