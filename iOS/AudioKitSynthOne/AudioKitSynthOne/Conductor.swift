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

    var tempo: BPM = 120
    var syncRatesToTempo = false

    var synth: AKSynthOne!

    var bindings: [(AKSynthOneParameter, AKSynthOneControl)] = []

    func bind(_ control: AKSynthOneControl, to param: AKSynthOneParameter) {
        bindings.append((param, control))
    }
    
    var changeParameter: (AKSynthOneParameter)->((_: Double) -> Void)  = { param in
        return { value in
            //AKLog("changing \(param.rawValue) \(param.simpleDescription()) to: \(value)")
            sharedInstance.synth.setAK1Parameter(param, value)
            sharedInstance.updateAllUI()
        }
        } {
        didSet {
            //AKLog("inspect changeParameter")
            updateAllCallbacks()
        }
    }
    
    public var viewControllers: Set<UpdatableViewController> = []
    
    func start() {
        synth = AKSynthOne()
        synth.rampTime = 0.0 // Handle ramping internally instead of the ramper hack
        
        ///DEFAULT TUNING
        _ = AKPolyphonicNode.tuningTable.defaultTuning()
        //_ = AKPolyphonicNode.tuningTable.presetPersian17NorthIndian15Bhairav() //uncomment to hear a microtonal scale
        //_ = AKPolyphonicNode.tuningTable.hexany(3, 5, 15, 19)
        //_ = AKPolyphonicNode.tuningTable.hexany(3, 2.111, 5.111, 8.111)
        //_ = AKPolyphonicNode.tuningTable.hexany(1, 17, 19, 23)
        //_ = AKPolyphonicNode.tuningTable.presetHighlandBagPipes()
        
        AudioKit.output = synth
        AudioKit.start()
    }
    
    func updateAllCallbacks() {
        for vc in viewControllers {
            vc.updateCallbacks()
        }
    }
    
    func updateAllUI() {
        for address in 0..<AKSynthOneParameter.count {
            guard let param: AKSynthOneParameter = AKSynthOneParameter(rawValue: Int(address))
                else {
                    AKLog("ERROR: AKSynthOneParameter enum out of range: \(address)")
                    return
                }
            for vc in viewControllers {
                if !vc.isKind(of: HeaderViewController.self) {
                    vc.updateUI(param, value: synth.getAK1Parameter(param) )
                }
            }
        }
    }
}
