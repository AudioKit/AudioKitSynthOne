//
//  CutoffKnob.swift
//  SynthUISpike
//
//  Created by Matthew Fecher on 7/22/17.
//  Copyright © 2017 Matthew Fecher. All rights reserved.
//

import UIKit

class CutoffKnob: Knob {

    //*****************************************************************
    // MARK: - Knob Scaling Helpers
    //*****************************************************************
    
    func cutoffFreqFromValue(_ value: Double) -> Double {
        // Logarithmic scale: knobvalue to frequency
        let scaledValue = Double.scaleRangeLog(value, rangeMin: 30, rangeMax: 7000)
        return scaledValue * 4
    }
    
    func cutoffFreq() -> Double {
        // Logarithmic scale: knobvalue to frequency
        let scaledValue = Double.scaleRangeLog(Double(knobValue), rangeMin: 30, rangeMax: 7000)
        return scaledValue * 4
    }

}
