//
//  Conductor.swift
//  AudioKitSynthOne
//
//  Created by AudioKit Contributors on 7/23/17.
//  Copyright © 2017 AudioKit. All rights reserved.
//

import AudioKit

protocol AKS1Control: class {
    var value: Double { get set }
    var callback: (Double) -> Void { get set }
}

typealias AKS1ControlCallback = (AKS1Parameter, AKS1Control?) -> ((_: Double) -> Void)

class Conductor: AKSynthOneProtocol {
    static var sharedInstance = Conductor()
    var neverSleep = false
    var banks: [Bank] = []
    var synth: AKSynthOne!
    var bindings: [(AKS1Parameter, AKS1Control)] = []
    var heldNoteCount: Int = 0
    private var audioUnitPropertyListener: AudioUnitPropertyListener!
    let lfo1RateFXPanelID: Int32 = 1
    let lfo2RateFXPanelID: Int32 = 2
    let autoPanFXPanelID: Int32 = 3
    let delayTimeFXPanelID: Int32 = 4
    let lfo1RateTouchPadID: Int32 = 5
    let lfo1RateModWheelID: Int32 = 6
    let lfo2RateModWheelID: Int32 = 7
    let pitchbendParentVCID: Int32 = 8

    public var viewControllers: Set<UpdatableViewController> = []
    fileprivate var started = false

    func bind(_ control: AKS1Control,
              to param: AKS1Parameter,
              callback closure: AKS1ControlCallback? = nil) {
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

    var changeParameter: AKS1ControlCallback  = { param, control in
        return { value in
            sharedInstance.synth.setSynthParameter(param, value)
            sharedInstance.updateSingleUI(param, control: control, value: value)
          }
        } {
        didSet {
            AKLog("WARNING: changeParameter callback changed")
        }
    }

    func updateSingleUI(_ param: AKS1Parameter,
                        control inputControl: AKS1Control?,
                        value inputValue: Double) {

        // cannot access synth until it is initialized and started
        if !started { return }

        // for every binding of type param
        for binding in bindings where param == binding.0 {
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

        // View controllers can own objects which are not updated by the bindings scheme.
        // For example, ADSRViewController has AKADSRView's which do not conform to AKS1Control
        viewControllers.forEach {
            $0.updateUI(param, control: inputControl, value: inputValue)
        }
    }

    // Call when a global update needs to happen.  i.e., on launch, foreground, and/or when a Preset is loaded.
    func updateAllUI() {
        let parameterCount = AKS1Parameter.AKS1ParameterCount.rawValue
        for address in 0..<parameterCount {
            guard let param: AKS1Parameter = AKS1Parameter(rawValue: address)
                else {
                    AKLog("ERROR: AKS1Parameter enum out of range: \(address)")
                    return
            }
            let value = self.synth.getSynthParameter(param)
            updateSingleUI(param, control: nil, value: value)
        }

        // Display Preset Name again
        guard let parentVC = self.viewControllers.first(
            where: { $0 is ParentViewController }) as? ParentViewController else { return }
        updateDisplayLabel("\(parentVC.activePreset.position): \(parentVC.activePreset.name)")
    }

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
            try AKSettings.setSession(category: .playAndRecord,
                                      with: [.defaultToSpeaker, .allowBluetooth, .mixWithOthers])
        } catch {
            AKLog("Could not set session category: \(error)")
        }

        // DEFAULT TUNING
        _ = AKPolyphonicNode.tuningTable.defaultTuning()

        synth = AKSynthOne()
        synth.delegate = self
        synth.rampDuration = 0.0 // Handle ramping internally instead of the ramper hack

        AudioKit.output = synth

        do {
            try AudioKit.start()
        } catch {
            AKLog("AudioKit did not start! \(error)")
            //TODO:Handle synth start failure
        }
        started = true

        // IAA Host Icon
        audioUnitPropertyListener = AudioUnitPropertyListener { (audioUnit, _) in
            let headerVC = self.viewControllers.first(where: { $0 is HeaderViewController }) as? HeaderViewController
            headerVC?.hostAppIcon.image = AudioOutputUnitGetHostIcon(AudioKit.engine.outputNode.audioUnit!, 44)
        }

        do {
            try AudioKit.engine.outputNode.audioUnit!.add(listener: audioUnitPropertyListener,
                                                          toProperty: kAudioUnitProperty_IsInterAppConnected)
        } catch {
            AKLog("Unsuccessful")
        }

        Audiobus.start()
    }

    func updateDisplayLabel(_ message: String) {
        let parentVC = self.viewControllers.first(where: { $0 is ParentViewController }) as? ParentViewController
        parentVC?.updateDisplay(message)
    }

    func updateDisplayLabel(_ param: AKS1Parameter, value: Double) {
        let headerVC = self.viewControllers.first(where: { $0 is HeaderViewController }) as? HeaderViewController
        headerVC?.updateDisplayLabel(param, value: value)
    }

    // MARK: - AKSynthOneProtocol

    // called by DSP on main thread
    func dependentParamDidChange(_ param: DependentParam) {
        let fxVC = self.viewControllers.first(where: { $0 is FXViewController }) as? FXViewController
        fxVC?.dependentParamDidChange(param)

        let touchPadVC = self.viewControllers.first(where: { $0 is TouchPadViewController }) as? TouchPadViewController
        touchPadVC?.dependentParamDidChange(param)

        let parentVC = self.viewControllers.first(where: { $0 is ParentViewController }) as? ParentViewController
        parentVC?.dependentParamDidChange(param)
    }

    // called by DSP on main thread
    func arpBeatCounterDidChange(_ beat: AKS1ArpBeatCounter) {
        let seqVC = self.viewControllers.first(where: { $0 is SeqViewController }) as? SeqViewController
        seqVC?.updateLED(beatCounter: Int(beat.beatCounter), heldNotes: self.heldNoteCount)
    }

    // called by DSP on main thread
    func heldNotesDidChange(_ heldNotes: HeldNotes) {
        heldNoteCount = Int(heldNotes.heldNotesCount)
    }

    // called by DSP on main thread
    func playingNotesDidChange(_ playingNotes: PlayingNotes) {
        let seqVC = self.viewControllers.first(where: { $0 is TuningsViewController }) as? TuningsViewController
        seqVC?.playingNotesDidChange(playingNotes)
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
