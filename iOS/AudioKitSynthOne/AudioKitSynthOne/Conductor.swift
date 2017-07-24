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

    var synth: AKSynthOne!

    var changeParameter: (AKSynthOneParameter)->((_: Double) -> Void)  = { _ in
        print("Not implemented properly")
        return { _ in
            print("I said, not implemented properly!")
            }
        } {
                didSet {
                    updateAllCallbacks()
                }
    }

    public var viewControllers: Set<UpdatableViewController> = []

    func start() {
        synth = AKSynthOne()
        AudioKit.output = synth
        AudioKit.start()
    }

    func updateAllCallbacks() {
        for vc in viewControllers {
            vc.updateCallbacks()
        }
    }
}
