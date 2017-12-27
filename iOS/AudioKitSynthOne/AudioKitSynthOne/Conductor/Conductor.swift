//
//  Conductor.swift
//  AudioKitSynthOne
//
//  Created by Aurelius Prochazka on 7/23/17.
//  Copyright © 2017 AudioKit. All rights reserved.
//

import AudioKit

protocol AKSynthOneControl {
    var value: Double { get set }
    var callback: (Double)->Void { get set }
}

class Conductor: AKSynthOneProtocol {
    
    static var sharedInstance = Conductor()

    var tempo: BPM = 120
    var syncRatesToTempo = false
    var backgroundAudioOn = true
    
    var synth: AKSynthOne!
    
    var bindings: [(AKSynthOneParameter, AKSynthOneControl)] = []
    
    func bind(_ control: AKSynthOneControl, to param: AKSynthOneParameter) {
        bindings.append((param, control))
    }
    
    var changeParameter: (AKSynthOneParameter)->((_: Double) -> Void)  = { param in
        return { value in
            //AKLog("changing \(param.rawValue) \(param.simpleDescription()) to: \(value)")
            sharedInstance.synth.setAK1Parameter(param, value)
            //sharedInstance.updateAllUI()
            sharedInstance.updateSingleUI(param)
           
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
        synth.delegate = self
        synth.rampTime = 0.0 // Handle ramping internally instead of the ramper hack
        
        ///DEFAULT TUNING
        _ = AKPolyphonicNode.tuningTable.defaultTuning()
        //_ = AKPolyphonicNode.tuningTable.presetPersian17NorthIndian15Bhairav() //uncomment to hear a microtonal scale
        //_ = AKPolyphonicNode.tuningTable.hexany(3, 5, 15, 19)
        //_ = AKPolyphonicNode.tuningTable.hexany(3, 2.111, 5.111, 8.111)
        //_ = AKPolyphonicNode.tuningTable.hexany(1, 17, 19, 23)
        //_ = AKPolyphonicNode.tuningTable.presetHighlandBagPipes()
        //AKPolyphonicNode.tuningTable.tuningTable(fromFrequencies: [1,3,9,27,81,243,729,2187,6561,19683,59049,177147])

        AudioKit.output = synth
        AudioKit.start()
    }
    
    func updateAllCallbacks() {
        for vc in viewControllers {
            vc.updateCallbacks()
        }
    }
    
    func updateSingleUI(_ param: AKSynthOneParameter) {
        for vc in self.viewControllers {
            vc.updateUI(param, value: synth.getAK1Parameter(param) )
            if !vc.isKind(of: HeaderViewController.self) {
                vc.updateUI(param, value: synth.getAK1Parameter(param) )
            }
        }
    }
    
    func updateAllUI() {
        //TODO:count params
        for address in 0..<120 {
            guard let param: AKSynthOneParameter = AKSynthOneParameter(rawValue: Int32(Int(address)))
                else {
                    AKLog("ERROR: AKSynthOneParameter enum out of range: \(address)")
                    return
                }
            updateSingleUI(param)
        }
    }
    
    //MARK: - AKSynthOneProtocol
    func paramDidChange(_ param: AKSynthOneParameter, _ value: Double) {
        AKLog("param:\(param), value:\(value)")
        DispatchQueue.main.async {
            for vc in Conductor.sharedInstance.viewControllers {
                vc.updateUI(param, value: Double(value))
            }
        }
    }
    
    func arpBeatCounterDidChange(_ beat: Int) {
        DispatchQueue.main.async {
            for vc in Conductor.sharedInstance.viewControllers {
                if vc.isKind(of: SeqViewController.self) {
                    if let vc2 = vc as? SeqViewController {
                        vc2.updateLED(beatCounter: beat)
                    }
                }
            }
        }
    }
    
    func heldNotesDidChange() {
        ///TODO:Route this to keyboard view controller (I'll change this so it returns the current array of held notes)
        //AKLog("")
    }
    
    func playingNotesDidChange() {
        ///TODO:Route this to keyboard view controller (I'll change this to return the current array of playing notes)
        //AKLog("")
    }
    
    // Start/Pause AK Engine (Conserve energy by turning background audio off)
    // TODO: Add AUv3 requirements
    func startEngine(completionHandler: AKCallback? = nil) {
        AKLog("engine.isRunning: \(AudioKit.engine.isRunning)")
        if !AudioKit.engine.isRunning {
            do {
                try AudioKit.engine.start()
                AKLog("AudioKit: engine is started.")
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                    completionHandler?()
                }
            } catch {
                AKLog("Unable to start the audio engine.", file: "Probably fatal error")
            }
            
            return
        }
        completionHandler?()
    }
    
    func stopEngine() {
        AudioKit.engine.pause()
    }
}
