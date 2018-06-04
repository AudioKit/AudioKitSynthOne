//
//  MIDIInput.swift
//  AudioKit Synth One
//
//  Created by AudioKit Contributors on 11/12/17.
//  Copyright © 2017 AudioKit Pro. All rights reserved.
//

import Foundation

class MIDIInput {
    var name = "Session 1"
    var isOpen = true

    init() {
    }

    convenience init(name: String, isOpen: Bool) {
        self.init()

        self.name = name
        self.isOpen = isOpen
    }
}
