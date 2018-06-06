//
//  ColorKnob.swift
//  SuperFM
//
//  Created by AudioKit Contributors on 11/20/17.
//  Copyright © 2017 AudioKit Pro. All rights reserved.
//

// TODO: This class is not referenced anywhere in the synth, should we just delete is and the StyleKit file?


import UIKit

@IBDesignable
public class ColorKnob: Knob {

    // Knob Color
    @IBInspectable open var knobColor: UIColor = UIColor(red: 0.357, green: 0.631, blue: 0.729, alpha: 1.000)

    public override func draw(_ rect: CGRect) {
        ColorKnobStyleKit.drawFMKnob(frame: CGRect(x: 0, y: 0, width: self.bounds.width, height: self.bounds.height), knobValue: knobValue) //, knobTopColor: knobColor )
    }

}
