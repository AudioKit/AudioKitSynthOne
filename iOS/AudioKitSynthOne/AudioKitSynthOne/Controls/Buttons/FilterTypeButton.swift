//
//  FilterTypeButton.swift
//  AudioKitSynthOne
//
//  Created by Matthew Fecher on 8/23/17.
//  Copyright © 2017 AudioKit. All rights reserved.
//

import UIKit

class FilterTypeButton: UIButton, AKSynthOneControl {

    var callback: (Double) -> Void = { _ in }

    private var _value: Double = 0
    var value: Double {
        get {
            return _value
        }

        set {
            _value = (0 ... 3).clamp(newValue)
            DispatchQueue.main.async {
                switch self._value {
                case 0:
                    // low pass
                    self.setTitle("Low Pass", for: .normal)
                case 1:
                    // band pass
                    self.setTitle("Band Pass", for: .normal)
                case 2:
                    // high pass
                    self.setTitle("High Pass", for: .normal)
                case 3:
                    // reset to low pass
                    fallthrough
                default:
                    // low pass
                    self._value = 0
                    self.setTitle("Low Pass", for: .normal)
                }
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
