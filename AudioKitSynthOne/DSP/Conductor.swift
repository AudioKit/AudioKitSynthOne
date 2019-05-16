//
//  Conductor.swift
//  AudioKitSynthOne
//
//  Created by AudioKit Contributors on 7/23/17.
//  Copyright © 2017 AudioKit. All rights reserved.
//

import AudioKit

class Conductor: S1Protocol {

    static var sharedInstance = Conductor()

    var neverSleep = false {
        didSet {
            UIApplication.shared.isIdleTimerDisabled = neverSleep
        }
    }

    var backgroundAudio = false

    var banks: [Bank] = []

    var synth: AKSynthOne!

    var bindings: [(S1Parameter, S1Control)] = []

    var defaultValues: [Double] = []

    var heldNoteCount: Int = 0

    private var audioUnitPropertyListener: AudioUnitPropertyListener!

    let lfo1RateEffectsPanelID: Int32 = 1

    let lfo2RateEffectsPanelID: Int32 = 2

    let autoPanEffectsPanelID: Int32 = 3

    let delayTimeEffectsPanelID: Int32 = 4

    let lfo1RateTouchPadID: Int32 = 5

    let lfo1RateModWheelID: Int32 = 6

    let lfo2RateModWheelID: Int32 = 7

    let pitchBendID: Int32 = 8

    let arpSeqTempoMultiplierID: Int32 = 9

    var iaaTimer: Timer = Timer()

    public var viewControllers: Set<UpdatableViewController> = []

    fileprivate var started = false
    
    let device = UIDevice.current.userInterfaceIdiom  

    func updateDefaultValues() {
        let parameterCount = S1Parameter.S1ParameterCount.rawValue
        defaultValues = [Double](repeating: 0, count: Int(parameterCount))
        for address in 0..<parameterCount {
            guard let parameter: S1Parameter = S1Parameter(rawValue: address)
            else {
                AKLog("ERROR: S1Parameter enum out of range: \(address)")
                return
        }
        defaultValues[Int(address)] = self.synth.getSynthParameter(parameter)
      }
    }

    func bind(_ control: S1Control,
              to parameter: S1Parameter,
              callback closure: S1ControlCallback? = nil) {
        let binding = (parameter, control)
        bindings.append(binding)
        let control = binding.1
        if let cb = closure {

            // custom closure
            control.callback = cb(parameter, control)
            control.defaultCallback = defaultParameter(parameter, control)
        } else {

            // default closure
            control.callback = changeParameter(parameter, control)
            control.defaultCallback = defaultParameter(parameter, control)
        }
    }

    var defaultParameter: S1ControlDefaultCallback  = { parameter, control in
        return {
            if sharedInstance.defaultValues.count != S1Parameter.S1ParameterCount.rawValue { return }
            sharedInstance.synth.setSynthParameter(parameter, sharedInstance.defaultValues[Int(parameter.rawValue)])
            sharedInstance.updateSingleUI(parameter, control: nil, value: sharedInstance.defaultValues[Int(parameter.rawValue)])
        }
        } {
        didSet {
            AKLog("WARNING: defaultParameter callback changed")
        }
    }

    var changeParameter: S1ControlCallback  = { parameter, control in
        return { value in
            sharedInstance.synth.setSynthParameter(parameter, value)
            sharedInstance.updateSingleUI(parameter, control: control, value: value)
          }
        } {
        didSet {
            AKLog("WARNING: changeParameter callback changed")
        }
    }

    func updateSingleUI(_ parameter: S1Parameter,
                        control inputControl: S1Control?,
                        value inputValue: Double) {

        // cannot access synth until it is initialized and started
        if !started { return }

        // for every binding of type param
        for binding in bindings where parameter == binding.0 {
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
        // For example, EnvelopesPanel has AKADSRView's which do not conform to S1Control
        for vc in viewControllers {
            vc.updateUI(parameter, control: inputControl, value: inputValue)
        }
    }

    // Call when a global update needs to happen.  i.e., on launch, foreground, and/or when a Preset is loaded.
    func updateAllUI() {
        let parameterCount = S1Parameter.S1ParameterCount.rawValue
        for address in 0..<parameterCount {
            guard let parameter: S1Parameter = S1Parameter(rawValue: address)
                else {
                    AKLog("ERROR: S1Parameter enum out of range: \(address)")
                    return
            }
            let value = self.synth.getSynthParameter(parameter)
            updateSingleUI(parameter, control: nil, value: value)
        }

        // Display Preset Name again
        guard let manager = self.viewControllers.first(
            where: { $0 is Manager }) as? Manager else { return }
        updateDisplayLabel("\(manager.activePreset.position): \(manager.activePreset.name)")
    }

    func start() {
        #if DEBUG
        AKSettings.enableLogging = true
        AKLog("Logging is ON")
        #else
        AKLog("Logging is OFF")
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
            #if DEBUG
            AKLog("AudioKit Started")
            #endif
        } catch {
            AKLog("AudioKit did not start! \(error)")
        }
        started = true

        if let au = AudioKit.engine.outputNode.audioUnit {
            // IAA Host Icon
            audioUnitPropertyListener = AudioUnitPropertyListener { (_, _) in
                let headerVC = self.viewControllers.first(where: { $0 is HeaderViewController })
                    as? HeaderViewController

                headerVC?.hostAppIcon.image = AudioOutputUnitGetHostIcon(au, 44)
            }

            do {
                try au.add(listener: audioUnitPropertyListener,
                           toProperty: kAudioUnitProperty_IsInterAppConnected)
            } catch {
                AKLog("Unsuccessful")
            }
        }
        Audiobus.start()
    }

    func updateDisplayLabel(_ message: String) {
        let manager = self.viewControllers.first(where: { $0 is Manager }) as? Manager
        manager?.updateDisplay(message)
    }

    func updateDisplayLabel(_ parameter: S1Parameter, value: Double) {
        let headerVC = self.viewControllers.first(where: { $0 is HeaderViewController }) as? HeaderViewController
        headerVC?.updateDisplayLabel(parameter, value: value)
    }

    // MARK: - S1Protocol

    // called by DSP on main thread
    func dependentParameterDidChange(_ parameter: DependentParameter) {

        // add panels with dependent parameters here

        let effectsPanel = self.viewControllers.first(where: { $0 is EffectsPanelController })
            as? EffectsPanelController
        effectsPanel?.dependentParameterDidChange(parameter)

        let touchPadPanel = self.viewControllers.first(where: { $0 is TouchPadPanelController })
            as? TouchPadPanelController
        touchPadPanel?.dependentParameterDidChange(parameter)

        let sequencerPanel = self.viewControllers.first(where: { $0 is SequencerPanelController }) as? SequencerPanelController
        sequencerPanel?.dependentParameterDidChange(parameter)

        let manager = self.viewControllers.first(where: { $0 is Manager }) as? Manager
        manager?.dependentParameterDidChange(parameter)
    }

    // called by DSP on main thread
    func arpBeatCounterDidChange(_ beat: S1ArpBeatCounter) {
        let sequencerPanel = self.viewControllers.first(where: { $0 is SequencerPanelController })
            as? SequencerPanelController
        sequencerPanel?.updateLED(beatCounter: Int(beat.beatCounter), heldNotes: self.heldNoteCount)
    }

    // called by DSP on main thread
    func heldNotesDidChange(_ heldNotes: HeldNotes) {
        heldNoteCount = Int(heldNotes.heldNotesCount)
    }

    // called by DSP on main thread
    func playingNotesDidChange(_ playingNotes: PlayingNotes) {
        let tuningsPanel = self.viewControllers.first(where: { $0 is TuningsPanelController })
            as? TuningsPanelController
        tuningsPanel?.playingNotesDidChange(playingNotes)
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

    @objc func checkIAAConnectionsEnterBackground() {

        if let audiobusClient = Audiobus.client {

            if !audiobusClient.isConnected && !audiobusClient.isConnectedToInput && !backgroundAudio {
                deactivateSession()
                AKLog("disconnected without timer")
            } else {
                iaaTimer.invalidate()
                iaaTimer = Timer.scheduledTimer(timeInterval: 20 * 60,
                                                target: self,
                                                selector: #selector(self.checkIAAConnectionsEnterBackground),
                                                userInfo: nil, repeats: true)
            }
        }
    }

    func checkIAAConnectionsEnterForeground() {
        iaaTimer.invalidate()
        startEngine()
    }

    func deactivateSession() {

        stopEngine()

        do {
            try AKSettings.session.setActive(false)
        } catch let error as NSError {
            AKLog("error setting session: " + error.description)
        }

        iaaTimer.invalidate()

        AKLog("deactivated session")
    }
}


extension Conductor: S1TuningTable {

    func setTuningTableNPO(_ npo: Int) {
        
        synth.setTuningTableNPO(npo)
    }

    func setTuningTable(_ frequency: Double, index: Int) {

        synth.setTuningTable(frequency, index: index)
    }

    func getTuningTableFrequency(_ index: Int) -> Double {

        return Double( synth.getTuningTableFrequency(index) )
    }
}
