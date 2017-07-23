//
//  Conductor.swift
//  AudioKitSynthOne
//
//  Created by Aurelius Prochazka on 7/23/17.
//  Copyright © 2017 AudioKit. All rights reserved.
//

import AudioKit

class Conductor {
    static var sharedInstance = Conductor()

    var synth = AKSynthOne()

    init() {
        AudioKit.output = synth
        AudioKit.start()
    }
}
