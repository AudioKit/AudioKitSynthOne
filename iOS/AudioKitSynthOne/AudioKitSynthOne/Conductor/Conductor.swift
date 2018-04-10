//
//  Conductor.swift
//  AudioKitSynthOne
//
//  Created by Aurelius Prochazka on 7/23/17.
//  Copyright © 2017 AudioKit. All rights reserved.
//

import AudioKit

protocol AKSynthOneControl: class {
    var value: Double { get set }
    var callback: (Double) -> Void { get set }
}

typealias AKSynthOneControlCallback = (AKSynthOneParameter, AKSynthOneControl?) -> ((_: Double) -> Void)

class Conductor: AKSynthOneProtocol {
    static var sharedInstance = Conductor()
    var syncRateToTempo = true
    var neverSleep = false
    var banks: [Bank] = []
    var synth: AKSynthOne!
    var bindings: [(AKSynthOneParameter, AKSynthOneControl)] = []
    
    func bind(_ control: AKSynthOneControl, to param: AKSynthOneParameter, callback closure: AKSynthOneControlCallback? = nil) {
        let binding = (param, control)
        bindings.append(binding)
        let control = binding.1
        if let cb = closure {
            control.callback = cb(param, control)
        } else {
            // default closure
            control.callback = changeParameter(param, control)
        }
    }
    
    var changeParameter: AKSynthOneControlCallback  = { param, control in
        return { value in
            sharedInstance.synth.setAK1Parameter(param, value)
            sharedInstance.updateSingleUI(param, control: control, value: value)
          }
        }
        {
        didSet {
            AKLog("WARNING: changeParameter callback changed")
        }
    }

    func updateSingleUI(_ param: AKSynthOneParameter, control inputControl: AKSynthOneControl?, value inputValue: Double) {
        
        // cannot access synth until it is initialized and started
        if !started {return}

        // for every binding of type param
        for binding in bindings {
            if param == binding.0 {
                let control = binding.1
                
                // don't update the control if it is the one performing the callback because it has already been updated
                if let inputControl = inputControl {
                    if control !== inputControl {
                        control.value = inputValue
                        //AKLog("updateSingleUI:param:\(param.rawValue), value:\(inputValue)")
                    } else {
                        //AKLog("UpdateSingleUI: duplicate control...loop avoided")
                    }
                } else {
                    // nil control = global update (i.e., preset, dependencies, etc.)
                    control.value = inputValue
                    //AKLog("updateSingleUI:param:\(param.rawValue), value:\(inputValue)")
                }
            }
        }

        // View controllers can own objects which are not updated by the bindings scheme.
        // For example, ADSRViewController has AKADSRView's which do not conform to AKSynthOneControl
        viewControllers.forEach {
            $0.updateUI(param, control: inputControl, value: inputValue)
        }
    }
    
    // Call when a global update needs to happen.  i.e., on launch, foreground, and/or when a Preset is loaded.
    func updateAllUI() {
        let parameterCount = AKSynthOneParameter.AKSynthOneParameterCount.rawValue
        for address in 0..<parameterCount {
            guard let param: AKSynthOneParameter = AKSynthOneParameter(rawValue: address)
                else {
                    AKLog("ERROR: AKSynthOneParameter enum out of range: \(address)")
                    return
            }
            let value = self.synth.getAK1Parameter(param)
            updateSingleUI(param, control: nil, value: value)
        }
        
        // Display Preset Name again
        let parentVC = self.viewControllers.filter { $0 is ParentViewController }.first as! ParentViewController
        updateDisplayLabel("\(parentVC.activePreset.position): \(parentVC.activePreset.name)")
    }

    public var viewControllers: Set<UpdatableViewController> = []
    
    fileprivate var started = false
    
    func start() {
        #if false
            print("Logging is OFF")
        #else
            AKSettings.enableLogging = true
            AKLog("Logging is ON")
        #endif
        
        // Allow audio to play while the iOS device is muted.
        AKSettings.playbackWhileMuted = true
        
        do {
            try AKSettings.setSession(category: .playAndRecord, with: [.defaultToSpeaker, .allowBluetooth, .mixWithOthers])
        } catch {
            AKLog("Could not set session category.")
        }
        
        ///DEFAULT TUNING
        #if true
            _ = AKPolyphonicNode.tuningTable.defaultTuning()
            AKLog("setting tuning to default 12ET")
        #else
            AKLog("setting tuning to custom tuning")
            //_ = AKPolyphonicNode.tuningTable.presetPersian17NorthIndian15Bhairav()
            //_ = AKPolyphonicNode.tuningTable.hexany(3, 5, 15, 19)
            //_ = AKPolyphonicNode.tuningTable.hexany(3, 2.111, 5.111, 8.111)
            //_ = AKPolyphonicNode.tuningTable.hexany(1, 17, 19, 23)
            //_ = AKPolyphonicNode.tuningTable.hexany(1, 15, 45, 75)
            //_ = AKPolyphonicNode.tuningTable.hexany(1, 3, 5, 45) // 071
            //_ = AKPolyphonicNode.tuningTable.hexany(1, 3, 5, 81)
            //_ = AKPolyphonicNode.tuningTable.hexany(1, 3, 5, 121)
            //_ = AKPolyphonicNode.tuningTable.hexany(1, 45, 135, 225)
            //_ = AKPolyphonicNode.tuningTable.presetHighlandBagPipes()
            //AKPolyphonicNode.tuningTable.tuningTable(fromFrequencies: [1,3,9,27,81,243,729,2187,6561,19683,59049,177147])
        #endif
        
        synth = AKSynthOne()
        synth.delegate = self
        synth.rampTime = 0.0 // Handle ramping internally instead of the ramper hack
        
        AudioKit.output = synth
        do {
            try AudioKit.start()
        } catch {
            AKLog("AudioKit did not start!")
        }
        started = true
    }
    
    func updateDisplayLabel(_ message: String) {
        let parentVC = self.viewControllers.filter { $0 is ParentViewController }.first as! ParentViewController
        parentVC.updateDisplay(message)
    }
    
    
    //MARK: - AKSynthOneProtocol
    func paramDidChange(_ param: AKSynthOneParameter, value: Double) {
        DispatchQueue.main.async {
            self.updateSingleUI(param, control: nil, value: value)
        }
    }
    
    func arpBeatCounterDidChange(_ beat: Int) {
        DispatchQueue.main.async {
            let seqVC = self.viewControllers.filter { $0 is SeqViewController }.first as? SeqViewController
            seqVC?.updateLED(beatCounter: beat)
        }
    }
    
    func heldNotesDidChange(_ heldNotes: HeldNotes) {
        ///TODO:Route this to keyboard view controller (I'll change this so it returns the current array of held notes)
        ///TODO:See https://trello.com/c/cainbbJJ
        // AKLog("\(heldNotes)")
        
        // Reset Arp Sequencer LED
        if heldNotes.heldNotesCount == 0 {
            if (synth.getAK1Parameter(.arpIsOn) == 1) && (synth.getAK1Parameter(.arpIsSequencer) == 1) {
                let seqVC = self.viewControllers.filter { $0 is SeqViewController }.first as? SeqViewController
                seqVC?.updateLED(beatCounter: 0)
                print ("GOT HERE 3 ***")
            }
        }
    }
    
    func playingNotesDidChange(_ playingNotes: PlayingNotes) {
        ///TODO:Route this to keyboard view controller (I'll change this to return the current array of playing notes)
        ///TODO:See https://trello.com/c/lQZMyF0V
        //AKLog("\(playingNotes)")
    }
    
    // Start/Pause AK Engine (Conserve energy by turning background audio off)
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
                AKLog("Unable to start the audio engine. Probably fatal error")
            }
            
            return
        }
        completionHandler?()
    }
    
    func stopEngine() {
        AudioKit.engine.pause()
    }
}
