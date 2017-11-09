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

    var tempo: BPM = 80
    var syncRatesToTempo = false

    var synth: AKSynthOne!

    var bindings: [(AKSynthOneParameter, AKSynthOneControl)] = []

    func bind(_ control: AKSynthOneControl, to param: AKSynthOneParameter) {
        bindings.append((param, control))
    }

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
        synth.rampTime = 0.0 // Handle ramping internally instead of the ramper hack
        _ = AKPolyphonicNode.tuningTable.defaultTuning() // this is the place to change the default tuning.
        //_ = AKPolyphonicNode.tuningTable.presetPersian17NorthIndian15Bhairav() //uncomment to hear a microtonal scale
        AudioKit.output = synth
        AudioKit.start()
    }

    func updateAllCallbacks() {
        for vc in viewControllers {
            vc.updateCallbacks()
        }
    }

    func updateAllUI() {
        for address in 0...synth.parameters.count {
            guard let param: AKSynthOneParameter = AKSynthOneParameter(rawValue: Int(address))
                else {
                    return
                    
            }
            for vc in viewControllers {
                if !vc.isKind(of: HeaderViewController.self) {
                    vc.updateUI(param, value: synth.parameters[address])
                }
            }
        }
    }
}
