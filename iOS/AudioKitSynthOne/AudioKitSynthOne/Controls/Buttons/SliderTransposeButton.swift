//
//  TransposeButton.swift
//  AudioKit Synth One
//
//  Created by AudioKit Contributors on 8/1/17.
//  Copyright © 2017 Matthew Fecher. All rights reserved.
//

import UIKit

class SliderTransposeButton: UILabel, AKSynthOneControl {

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
                self.backgroundColor = #colorLiteral(red: 0.3725490196, green: 0.3725490196, blue: 0.3921568627, alpha: 1)
                if transposeAmt >= 0 {
                    transposeAmt += transposeAmt
                } else {
                    transposeAmt -= transposeAmt
                                                              }
            } else {
                _value = 0
                self.backgroundColor = #colorLiteral(red: 0.2156862745, green: 0.2156862745, blue: 0.2352941176, alpha: 1)
            }
            setNeedsDisplay()
        }
    }

    var transposeAmt = 0 {
        didSet {
            self.text = String(transposeAmt)
        }
    }

    public var callback: (Double) -> Void = { _ in }

    var isActive = false {
        didSet {
            if isActive {
                layer.borderColor = #colorLiteral(red: 0.8812435269, green: 0.4256765842, blue: 0, alpha: 1)
                layer.borderWidth = 2
            } else {
                layer.borderColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1)
                layer.borderWidth = 1
            }

        }
    }

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
