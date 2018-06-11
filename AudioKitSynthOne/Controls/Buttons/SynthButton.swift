//
//  SynthButton.swift
//  AudioKitSynthOne
//
//  Created by AudioKit Contributors on 8/8/17.
//  Copyright © 2017 AudioKit. All rights reserved.
//

import UIKit

class SynthButton: UIButton, S1Control {

    var callback: (Double) -> Void = { _ in }

    var isOn: Bool {
        return value == 1
    }

    override var isSelected: Bool {
        didSet {
            self.backgroundColor = isOn ? #colorLiteral(red: 0.3058823529, green: 0.3058823529, blue: 0.3254901961, alpha: 1) : #colorLiteral(red: 0.2, green: 0.2, blue: 0.2, alpha: 1)
        }
    }

    var value: Double = 0.0 {
        didSet {
            isSelected = value == 1.0
            setNeedsDisplay()
        }
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)

        clipsToBounds = true
        layer.cornerRadius = 2
        layer.borderWidth = 1
    }

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        for _ in touches {
            value = isOn ? 0 : 1
            self.setNeedsDisplay()
            callback(value)
        }
    }
}
