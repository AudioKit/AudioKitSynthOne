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
    var neverSleep = false
    var banks: [Bank] = []
    var synth: AKSynthOne!
    var bindings: [(AKSynthOneParameter, AKSynthOneControl)] = []
    var heldNoteCount: Int = 0

    private var audioUnitPropertyListener: AudioUnitPropertyListener!

    func bind(_ control: AKSynthOneControl, to param: AKSynthOneParameter, callback closure: AKSynthOneControlCallback? = nil) {
        let binding = (param, control)
        bindings.append(binding)
        let control = binding.1
        if let cb = closure {
            // custom closure
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
                    }
                } else {
                    // nil control = global update (i.e., preset change)
                    control.value = inputValue
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
            //TODO:disable for release
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
        
        // DEFAULT TUNING
        _ = AKPolyphonicNode.tuningTable.defaultTuning()
        
        synth = AKSynthOne()
        synth.delegate = self
        synth.rampTime = 0.0 // Handle ramping internally instead of the ramper hack
        
        AudioKit.output = synth

        do {
            try AudioKit.start()
        } catch {
            AKLog("AudioKit did not start!")
            //TODO:Handle synth start failure
        }
        started = true
        audioUnitPropertyListener = AudioUnitPropertyListener { (audioUnit, property) in
            //self.hostAppIcon.image = AudioOutputUnitGetHostIcon(AudioKit.engine.outputNode.audioUnit!, 44)
        }

        do {
            try AudioKit.engine.outputNode.audioUnit!.add(listener: audioUnitPropertyListener, toProperty: kAudioUnitProperty_IsInterAppConnected)
        } catch {
            AKLog("Unsuccessful")
        }
        
        Audiobus.start()
    }
    
    func updateDisplayLabel(_ message: String) {
        let parentVC = self.viewControllers.filter { $0 is ParentViewController }.first as? ParentViewController
        parentVC?.updateDisplay(message)
    }
    
    func updateDisplayLabel(_ param: AKSynthOneParameter, value: Double) {
        let parentVC = self.viewControllers.filter { $0 is HeaderViewController }.first as? HeaderViewController
        parentVC?.updateDisplayLabel(param, value: value)
    }
    
    //MARK: - AKSynthOneProtocol
    
    // called by DSP on main thread
    func dependentParamDidChange(_ param: DependentParam) {
        let fxVC = self.viewControllers.filter { $0 is FXViewController }.first as? FXViewController
        fxVC?.dependentParamDidChange(param)
        let touchPadVC = self.viewControllers.filter { $0 is TouchPadViewController }.first as? TouchPadViewController
        touchPadVC?.dependentParamDidChange(param)
    }
    
    // called by DSP on main thread
    func arpBeatCounterDidChange(_ beat: AKS1ArpBeatCounter) {
        let seqVC = self.viewControllers.filter { $0 is SeqViewController }.first as? SeqViewController
        seqVC?.updateLED(beatCounter: Int(beat.beatCounter), heldNotes: self.heldNoteCount)
    }
    
    // called by DSP on main thread
    func heldNotesDidChange(_ heldNotes: HeldNotes) {
        heldNoteCount = Int(heldNotes.heldNotesCount)
    }
    
    // called by DSP on main thread
    func playingNotesDidChange(_ playingNotes: PlayingNotes) {
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
