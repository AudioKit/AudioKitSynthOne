//
//  KeyboardShowButton.swift
//  AudioKitSynthOne
//
//  Created by Matthew Fecher on 3/18/18.
//  Copyright © 2018 AudioKit. All rights reserved.
//

import UIKit

class KeyboardShowButton: SynthUIButton {
    override var isSelected: Bool {
        didSet {
            self.backgroundColor = isOn ? #colorLiteral(red: 0.2, green: 0.2, blue: 0.2, alpha: 1) : #colorLiteral(red: 0.3058823529, green: 0.3058823529, blue: 0.3254901961, alpha: 1)
        }
    }
}

