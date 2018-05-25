//
//  ParentViewController.swift
//  AudioKitSynthOne
//
//  Created by Aurelius Prochazka on 7/8/17.
//  Copyright © 2017 AudioKit. All rights reserved.
//

import AudioKit
import UIKit
import Disk

protocol EmbeddedViewsDelegate {
    func switchToChildView(_ newView: ChildView, isTopView: Bool)
}

protocol BottomEmbeddedViewsDelegate {
    func switchToBottomChildView(_ newView: ChildView)
}

public class ParentViewController: UpdatableViewController {
    
    @IBOutlet weak var topContainerView: UIView!
    @IBOutlet weak var bottomContainerView: UIView!
    
    @IBOutlet weak var keyboardView: SynthKeyboard!
    @IBOutlet weak var keyboardBottomConstraint: NSLayoutConstraint!
    @IBOutlet weak var topPanelheight: NSLayoutConstraint!
    
    @IBOutlet weak var midiButton: SynthUIButton!
    @IBOutlet weak var holdButton: SynthUIButton!
    @IBOutlet weak var monoButton: SynthUIButton!
    @IBOutlet weak var keyboardToggle: SynthUIButton!
    @IBOutlet weak var octaveStepper: Stepper!
    @IBOutlet weak var configKeyboardButton: SynthUIButton!
    @IBOutlet weak var bluetoothButton: AKBluetoothMIDIButton!
    @IBOutlet weak var modWheelSettings: SynthUIButton!
    @IBOutlet weak var midiLearnToggle: SynthUIButton!
    @IBOutlet weak var pitchbend: AKVerticalPad!
    @IBOutlet weak var modWheelPad: AKVerticalPad!
  
    
    var embeddedViewsDelegate: EmbeddedViewsDelegate?
    
    var topChildView: ChildView?
    var bottomChildView: ChildView?
    var prevBottomChildView: ChildView?
    var isPresetsDisplayed: Bool = false
    var activePreset = Preset()
    
    var midiChannelIn: MIDIChannel = 0
    var midiInputs = [MIDIInput]()
    var omniMode = true
    var notesFromMIDI = Set<MIDINoteNumber>()
    var appSettings = AppSetting()
    var isDevView = false
    
    let midi = AKMIDI()  ///TODO: REMOVE
    var sustainMode = false
    var sustainer: SDSustainer!
    var pcJustTriggered = false
    var midiKnobs = [MIDIKnob]()
    var signedMailingList = false
    
    // AudioBus
    private var audioUnitPropertyListener: AudioUnitPropertyListener!
    var midiInput: ABMIDIReceiverPort?
    
    // ********************************************************
    // MARK: - Define child view controllers
    // ********************************************************
    
    lazy var adsrViewController: ADSRViewController = {
        let mainStoryboard = UIStoryboard(name: "Main", bundle: Bundle.main)
        var viewController = mainStoryboard.instantiateViewController(withIdentifier: ChildView.adsrView.identifier()) as! ADSRViewController
        return viewController
    }()
    
    lazy var mixerViewController: SourceMixerViewController = {
        let mainStoryboard = UIStoryboard(name: "Main", bundle: Bundle.main)
        var viewController = mainStoryboard.instantiateViewController(withIdentifier: ChildView.oscView.identifier()) as! SourceMixerViewController
        return viewController
    }()
    
    lazy var devViewController: DevViewController = {
        let mainStoryboard = UIStoryboard(name: "Main", bundle: Bundle.main)
        var viewController = mainStoryboard.instantiateViewController(withIdentifier: "DevViewController") as! DevViewController
        viewController.delegate = self
        return viewController
    }()
    
    lazy var padViewController: TouchPadViewController = {
        let mainStoryboard = UIStoryboard(name: "Main", bundle: Bundle.main)
        var viewController = mainStoryboard.instantiateViewController(withIdentifier: ChildView.padView.identifier()) as! TouchPadViewController
        return viewController
    }()
    
    lazy var fxViewController: FXViewController = {
        let mainStoryboard = UIStoryboard(name: "Main", bundle: Bundle.main)
        var viewController = mainStoryboard.instantiateViewController(withIdentifier: ChildView.fxView.identifier()) as! FXViewController
        return viewController
    }()
    
    lazy var seqViewController: SeqViewController = {
        let mainStoryboard = UIStoryboard(name: "Main", bundle: Bundle.main)
        var viewController = mainStoryboard.instantiateViewController(withIdentifier: ChildView.seqView.identifier()) as! SeqViewController
        return viewController
    }()
    
    lazy var tuningsViewController: TuningsViewController = {
        let mainStoryboard = UIStoryboard(name: "Main", bundle: Bundle.main)
        var viewController = mainStoryboard.instantiateViewController(withIdentifier: ChildView.tuningsView.identifier()) as! TuningsViewController
        return viewController
    }()

    lazy var presetsViewController: PresetsViewController = {
        let mainStoryboard = UIStoryboard(name: "Main", bundle: Bundle.main)
        var viewController = mainStoryboard.instantiateViewController(withIdentifier: "PresetsViewController") as! PresetsViewController
        return viewController
    }()
    
    // ********************************************************
    // MARK: - viewDidLoad
    // ********************************************************
    
    public override func viewDidLoad() {
        super.viewDidLoad()

        // Conductor start
        conductor.start()
        sustainer = SDSustainer(conductor.synth)

        keyboardView?.delegate = self
        keyboardView?.polyphonicMode = conductor.synth.getAK1Parameter(.isMono) > 0 ? true : false

        // Set Header as Delegate
        if let headerVC = self.childViewControllers.first as? HeaderViewController {
            headerVC.delegate = self
            headerVC.headerDelegate = self
        }
        
        // Set AKKeyboard octave range
        octaveStepper.minValue = -2
        octaveStepper.maxValue = 4
        
        // Make bluetooth button look pretty
        bluetoothButton.centerPopupIn(view: view)
        bluetoothButton.layer.cornerRadius = 2
        bluetoothButton.layer.borderWidth = 1
        
        // Setup Callbacks
        setupCallbacks()
        
        // Load Presets
        displayPresetsController()
        
        // Temporary MIDI IN
        DispatchQueue.global(qos: .background).async {
            self.midi.createVirtualPorts()
            self.midi.openInput("Session 1")
            self.midi.addListener(self)
        }
        
        // Pre-load views and Set initial subviews
        switchToChildView(.fxView, isTopView: true)
        switchToChildView(.adsrView, isTopView: true)
        switchToChildView(.oscView, isTopView: true)
        switchToChildView(.seqView, isTopView: false)
        
        // Pre-load dev panel view
        add(asChildViewController: devViewController, isTopContainer: true)
        devViewController.view.removeFromSuperview()
        
        // IAA MIDI
        var callbackStruct = AudioOutputUnitMIDICallbacks(
            userData: nil,
            MIDIEventProc: {
                (first, status, data1, data2, offset) in
                AudioKit.midi.sendMessage([MIDIByte(status), MIDIByte(data1), MIDIByte(data2)])},
            MIDISysExProc: {
                (firstPointer, secondPinter, anotherInt32) in
                print("Not handling sysex")}
        )
        
        let connectIAAMDI = AudioUnitSetProperty(AudioKit.engine.outputNode.audioUnit!,
                                                 kAudioOutputUnitProperty_MIDICallbacks,
                                                 kAudioUnitScope_Global,
                                                 0,
                                                 &callbackStruct,
                                                 UInt32(MemoryLayout<AudioOutputUnitMIDICallbacks>.size))
        if connectIAAMDI != 0 {
            AKLog("Something bad happened")
        }
        
        
        // Setup AudioBus MIDI Input
        setupAudioBusInput()
    }
    
    public override func viewDidAppear(_ animated: Bool) {
        
        // Load App Settings
        if Disk.exists("settings.json", in: .documents) {
            loadSettingsFromDevice()
        } else {
            setDefaultsFromAppSettings()
            saveAppSettings()
        }
        
        // Set Mailing List Button
        signedMailingList = appSettings.signedMailingList
        if let headerVC = self.childViewControllers.first as? HeaderViewController {
            headerVC.updateMailingListButton(appSettings.signedMailingList)
        }
        
        // Load Banks
        if Disk.exists("banks.json", in: .documents) {
            loadBankSettings() 
        } else {
            createInitBanks()
        }
        
        // Check preset versions
        let currentPresetVersion = AppSetting().presetsVersion
        if appSettings.presetsVersion < currentPresetVersion {
            presetsViewController.upgradePresets()
            // Save appSettings
            appSettings.presetsVersion = currentPresetVersion
            saveAppSettings()
        }
        
        presetsViewController.loadBanks()
        
        // Show email list if first run
        if appSettings.firstRun && !appSettings.signedMailingList {
            performSegue(withIdentifier: "SegueToMailingList", sender: self)
            appSettings.firstRun = false
        }
        
        // On four runs show dialog and request review
        if appSettings.launches == 5 && !appSettings.isPreRelease { reviewPopUp() }
        if appSettings.launches % 20 == 0 && !appSettings.isPreRelease { skRequestReview() }
        
        // Push Notifications request
        if appSettings.launches == 9 { pushPopUp() }
        if appSettings.launches % 15 == 0 && !appSettings.pushNotifications && !appSettings.isPreRelease { pushPopUp() }
        
        // Keyboard show or hide on launch
        keyboardToggle.value = appSettings.showKeyboard
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.55) {
            self.keyboardToggle.callback(self.appSettings.showKeyboard)
        }
        
        // Increase number of launches
        appSettings.launches = appSettings.launches + 1
        saveAppSettingValues()
        
        // Get MIDI Knobs
        midiKnobs += mixerViewController.view.subviews.filter { $0 is MIDIKnob } as! [MIDIKnob]
        midiKnobs += adsrViewController.view.subviews.filter { $0 is MIDIKnob } as! [MIDIKnob]
        midiKnobs += fxViewController.view.subviews.filter { $0 is MIDIKnob } as! [MIDIKnob]
        midiKnobs += seqViewController.view.subviews.filter { $0 is MIDIKnob } as! [MIDIKnob]
        midiKnobs += devViewController.view.subviews.filter { $0 is MIDIKnob } as! [MIDIKnob]
        midiKnobs += tuningsViewController.view.subviews.filter { $0 is MIDIKnob } as! [MIDIKnob]

        // Set initial preset
        presetsViewController.didSelectPreset(index: 0)
        
    }
    
    // ********************************************************
    // MARK: - Callbacks
    // ********************************************************
    
    func setupCallbacks() {
        
        let s = conductor.synth!
        
        octaveStepper.callback = { value in
            self.keyboardView.firstOctave = Int(value) + 2
        }
        
        configKeyboardButton.callback = { _ in
            self.configKeyboardButton.value = 0
            self.performSegue(withIdentifier: "SegueToKeyboardSettings", sender: self)
        }
        
        midiButton.callback = { _ in
            self.midiButton.value = 0
            self.performSegue(withIdentifier: "SegueToMIDI", sender: self)
        }
        
        modWheelSettings.callback = { _ in
            self.modWheelSettings.value = 0
            self.performSegue(withIdentifier: "SegueToMOD", sender: self)
        }
        
        midiLearnToggle.callback = { _ in
            
            // Toggle MIDI Learn Knobs in subview
            self.midiKnobs.forEach { $0.midiLearnMode = self.midiLearnToggle.isSelected }
            
            // Update display label
            if self.midiLearnToggle.isSelected {
                self.updateDisplay("MIDI Learn: Touch a knob to assign")
            } else {
                self.updateDisplay("MIDI Learn Off")
                self.saveAppSettingValues()
            }
        }
        
        holdButton.callback = { value in
            self.keyboardView.holdMode = !self.keyboardView.holdMode
            if value == 0.0 {
                self.stopAllNotes()
            }
        }
        
        monoButton.callback = { value in
            let monoMode = value > 0 ? true : false
            self.keyboardView.polyphonicMode = !monoMode
            s.setAK1Parameter(.isMono, value)
            self.conductor.updateSingleUI(.isMono, control: self.monoButton, value: value)
        }
        
        keyboardToggle.callback = { value in
            if value == 1 {
                self.keyboardToggle.setTitle("Hide", for: .normal)
            } else {
                self.keyboardToggle.setTitle("Show", for: .normal)
                
                // Add panel to bottom
                if self.bottomChildView == self.topChildView {
                    self.bottomChildView = self.bottomChildView?.rightView()
                }
                self.switchToChildView(self.bottomChildView!, isTopView: false)
            }
            
            // Animate Keyboard
            let newConstraintValue: CGFloat = (value == 1.0) ? 0 : -299
            UIView.animate(withDuration: Double(0.4), animations: {
                self.keyboardBottomConstraint.constant = newConstraintValue
                self.view.layoutIfNeeded()
            })
            
            self.saveAppSettingValues()
        }
        
        modWheelPad.callback = { value in
            switch self.activePreset.modWheelRouting {
            case 0:
                // Cutoff
                let newValue = 1 - value
                let scaledValue = Double.scaleRangeLog(newValue, rangeMin: 40, rangeMax: 7600)
                s.setAK1Parameter(.cutoff, scaledValue*3)
                self.conductor.updateSingleUI(.cutoff, control: self.modWheelPad, value: s.getAK1Parameter(.cutoff))
            case 1:
                // LFO 1 Rate
                let scaledValue = Double.scaleRange(value, rangeMin: 0, rangeMax: 1)
                s.setAK1DependentParameter(.lfo1Rate, scaledValue, self.conductor.lfo1RateModWheelID)
            case 2:
                // LFO 2 Rate
                let scaledValue = Double.scaleRange(value, rangeMin: 0, rangeMax: 1)
                s.setAK1DependentParameter(.lfo2Rate, scaledValue, self.conductor.lfo2RateModWheelID)
            default:
                break
            }
        }

        pitchbend.callback = { value01 in
            s.setAK1DependentParameter(.pitchbend, value01, Conductor.sharedInstance.pitchbendParentVCID)
        }
        pitchbend.completionHandler = {  _, touchesEnded, reset in
            if touchesEnded && !reset {
                self.pitchbend.resetToCenter()
            }
            if reset {
                s.setAK1DependentParameter(.pitchbend, 0.5, Conductor.sharedInstance.pitchbendParentVCID)
            }
        }
    }
    
    func stopAllNotes() {
        self.keyboardView.allNotesOff()
        conductor.synth.stopAllNotes()
    }
    
    override func updateUI(_ param: AKSynthOneParameter, control inputControl: AKSynthOneControl?, value: Double) {
        
        // Even though isMono is a dsp parameter it needs special treatment because this vc's state depends on it
        guard let s = conductor.synth else { return }
        let isMono = s.getAK1Parameter(.isMono)
        if isMono != monoButton.value {
            monoButton.value = isMono
            self.keyboardView.polyphonicMode = isMono > 0 ? false : true
        }
        
        if param == .cutoff {
            if inputControl === modWheelPad || activePreset.modWheelRouting != 0 {
                return
            }
            let mmin = 40.0
            let mmax = 7600.0
            let scaledValue01 = (0...1).clamp(1 - ((log(value)-log(mmin))/(log(mmax)-log(mmin))))
            modWheelPad.setVerticalValue01(scaledValue01)
        }
    }
    
    func dependentParamDidChange(_ param: DependentParam) {
        switch param.param {
            
        case .lfo1Rate:
            if param.payload == conductor.lfo1RateModWheelID {
                return
            }
            if activePreset.modWheelRouting == 1 {
                modWheelPad.setVerticalValue01(Double(param.value01))
            }
            
        case .lfo2Rate:
            if param.payload == conductor.lfo2RateModWheelID {
                return
            }
            if activePreset.modWheelRouting == 2 {
                modWheelPad.setVerticalValue01(Double(param.value01))
            }
            
        case .pitchbend:
            if param.payload == conductor.pitchbendParentVCID {
                return
            }
            pitchbend.setVerticalValue01(Double(param.value01))
            
        default:
            _ = 0
        }
    }

    // **********************************************************
    // MARK: - View Navigation/Embed Helper Methods
    // **********************************************************
    
    override public func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "SegueToKeyboardSettings" {
            let popOverController = segue.destination as! PopUpKeyboardController
            popOverController.delegate = self
            popOverController.octaveRange = keyboardView.octaveCount
            popOverController.labelMode = keyboardView.labelMode
            popOverController.darkMode = keyboardView.darkMode
            
            popOverController.preferredContentSize = CGSize(width: 300, height: 240)
            if let presentation = popOverController.popoverPresentationController {
                presentation.backgroundColor = #colorLiteral(red: 0.1568627451, green: 0.1568627451, blue: 0.1568627451, alpha: 1)
                presentation.sourceRect = configKeyboardButton.bounds
            }
        }
        
        if segue.identifier == "SegueToMIDI" {
            let popOverController = segue.destination as! PopUpMIDIViewController
            popOverController.delegate = self
            let userMIDIChannel = omniMode ? -1 : Int(midiChannelIn)
            popOverController.userChannelIn = userMIDIChannel
            popOverController.midiSources = midiInputs
            popOverController.saveTuningWithPreset = appSettings.saveTuningWithPreset
            popOverController.velocitySensitive = appSettings.velocitySensitive
            
            popOverController.preferredContentSize = CGSize(width: 300, height: 350)
            if let presentation = popOverController.popoverPresentationController {
                presentation.backgroundColor = #colorLiteral(red: 0.1568627451, green: 0.1568627451, blue: 0.1568627451, alpha: 1)
                presentation.sourceRect = midiButton.bounds
            }
        }
        
        if segue.identifier == "SegueToMOD" {
            let popOverController = segue.destination as! PopUpMODController
            popOverController.delegate = self
            popOverController.modWheelDestination = Int(activePreset.modWheelRouting)
            popOverController.preferredContentSize = CGSize(width: 300, height: 290)
            if let presentation = popOverController.popoverPresentationController {
                presentation.backgroundColor = #colorLiteral(red: 0.1568627451, green: 0.1568627451, blue: 0.1568627451, alpha: 1)
                presentation.sourceRect = midiButton.bounds
            }
        }
        
        if segue.identifier == "SegueToAbout" {
            let popOverController = segue.destination as! PopUpAbout
            popOverController.delegate = self
        }
        
        if segue.identifier == "SegueToMailingList" {
            let popOverController = segue.destination as! MailingListController
            popOverController.delegate = self
        }
    }
    
    func add(asChildViewController viewController: UIViewController, isTopContainer: Bool = true) {
        // Add Child View Controller
        addChildViewController(viewController)
        
        // Add Child View as Subview
        if isTopContainer {
            topContainerView.addSubview(viewController.view)
            viewController.view.frame = topContainerView.bounds
        } else {
            bottomContainerView.addSubview(viewController.view)
            viewController.view.frame = bottomContainerView.bounds
        }
        
        viewController.view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        viewController.didMove(toParentViewController: self)
    }
    
    func displayPresetsController() {
        
        // Display Presets View
        topContainerView.subviews.forEach({ $0.removeFromSuperview() })
        add(asChildViewController: presetsViewController)
        presetsViewController.presetsDelegate = self
        isPresetsDisplayed = true
    }
}


