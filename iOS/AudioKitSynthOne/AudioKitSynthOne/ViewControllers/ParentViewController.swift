//
//  SynthOneViewController.swift
//  AudioKitSynthOne
//
//  Created by Aurelius Prochazka on 7/8/17.
//  Copyright © 2017 AudioKit. All rights reserved.
//

import UIKit
import AudioKit
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
    @IBOutlet weak var transposeStepper: Stepper!
    @IBOutlet weak var octaveStepper: Stepper!
    @IBOutlet weak var configKeyboardButton: SynthUIButton!
    @IBOutlet weak var bluetoothButton: AKBluetoothMIDIButton!
    @IBOutlet weak var modWheelSettings: SynthUIButton!
    @IBOutlet weak var midiLearnToggle: SynthUIButton!
    @IBOutlet weak var pitchPad: AKVerticalPad!
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
    
    var appSettings = AppSetting()
    var isDevView = false
 
    let midi = AKMIDI()  ///TODO: REMOVE
    var sustainMode = false
  
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
    
    fileprivate lazy var devViewController: DevViewController = {
        let mainStoryboard = UIStoryboard(name: "Main", bundle: Bundle.main)
        var viewController = mainStoryboard.instantiateViewController(withIdentifier: "DevViewController") as! DevViewController
        return viewController
    }()
    
    fileprivate lazy var padViewController: TouchPadViewController = {
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
        
        keyboardView?.delegate = self
        keyboardView?.polyphonicMode = true
        
        // Conductor start
        conductor.start()
        
        // Set Header as Delegate
        if let headerVC = self.childViewControllers.first as? HeaderViewController {
            headerVC.delegate = self
            headerVC.headerDelegate = self
        }
        
        // Set AKKeyboard octave range
        octaveStepper.minValue = -2
        octaveStepper.maxValue = 4
        
        // Set transpose range and default value
        transposeStepper.minValue = -24
        transposeStepper.value = 0
        transposeStepper.maxValue = 24
        
        // Make bluetooth button look pretty
        bluetoothButton.centerPopupIn(view: view)
        bluetoothButton.layer.cornerRadius = 2
        bluetoothButton.layer.borderWidth = 1
        
        // Load App Settings
        if Disk.exists("settings.json", in: .documents) {
            loadSettingsFromDevice()
        } else {
            setDefaultsFromAppSettings()
            saveAppSettings()
        }
        
        // Load Presets
        displayPresetsController()
        
        // Setup Callbacks
        setupCallbacks()
        
        // Temporary MIDI IN
        // TODO: Remove
        midi.createVirtualPorts()
        midi.openInput("Session 1")
        midi.addListener(self)
    }
    
    public override func viewDidAppear(_ animated: Bool) {
       
        // Set initial subviews
        switchToChildView(.oscView, isTopView: true)
        switchToChildView(.adsrView, isTopView: false)
        
        // On four runs show dialog and request review
        //        if appSettings.launches == 4 { reviewPopUp() }
        //        if appSettings.launches % 10 == 0 { skRequestReview() }
        
        // Keyboard show or hide on launch
        keyboardToggle.value = appSettings.showKeyboard
      
        if !keyboardToggle.isOn {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
               self.keyboardToggle.callback(0.0)
            }
        }
        
        // Increase number of launches
        appSettings.launches = appSettings.launches + 1
        saveAppSettingValues()
        
    }
    
    // ********************************************************
    // MARK: - Callbacks
    // ********************************************************
    
    func setupCallbacks() {
        
        transposeStepper.callback = { value in
            AKLog("still need to hook up")
        }
        
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
            //self.auMainController.midiKnobs.forEach { $0.midiLearnMode = self.midiLearnToggle.isSelected }
            
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
            self.keyboardView.polyphonicMode = !self.monoButton.isSelected
            self.conductor.synth.setAK1Parameter(.isMono, value)
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
                let scaledValue = Double.scaleRangeLog(value, rangeMin: 30, rangeMax: 7000)
                self.conductor.synth.setAK1Parameter(.cutoff, scaledValue*3)
                
                //self.mixerViewController.cutoff.knobValue = CGFloat(value)
            case 1:
                // Tremolo
                // TODO: MH, do you want to add Tremolo here?
                break
            case 2:
                // LFO 2 Amt
                self.conductor.synth.setAK1Parameter(.lfo2Amplitude, value)
            default:
                break
                
            }
        }
        
        pitchPad.callback = { value in
            var bendValue = 1.0
            if value < 0.5 {
                bendValue = Double.scaleEntireRange(value, fromRangeMin: 0.0, fromRangeMax: 0.5, toRangeMin: 0.5, toRangeMax: 1.0)
            } else {
                 bendValue = Double.scaleEntireRange(value, fromRangeMin: 0.5, fromRangeMax: 1.0, toRangeMin: 1.0, toRangeMax: 2.0)
            }
           self.conductor.synth.setAK1Parameter(.detuningMultiplier, bendValue)
        }
        
        pitchPad.completionHandler = {  _, touchesEnded, reset in
            if touchesEnded && !reset {
                self.pitchPad.resetToCenter()
            }
            if reset {
               self.conductor.synth.setAK1Parameter(.detuningMultiplier, 1.0)
            }
        }
        
    }
    
    func stopAllNotes() {
        self.keyboardView.allNotesOff()
        conductor.synth.stopAllNotes()
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
            
            popOverController.preferredContentSize = CGSize(width: 300, height: 280)
            if let presentation = popOverController.popoverPresentationController {
                presentation.backgroundColor = #colorLiteral(red: 0.1568627451, green: 0.1568627451, blue: 0.1568627451, alpha: 1)
                presentation.sourceRect = midiButton.bounds
            }
        }
        
        if segue.identifier == "SegueToMOD" {
            let popOverController = segue.destination as! PopUpMODController
            popOverController.delegate = self
            popOverController.modWheelDestination = Int(activePreset.modWheelRouting)
            popOverController.preferredContentSize = CGSize(width: 300, height: 170)
            if let presentation = popOverController.popoverPresentationController {
                presentation.backgroundColor = #colorLiteral(red: 0.1568627451, green: 0.1568627451, blue: 0.1568627451, alpha: 1)
                presentation.sourceRect = midiButton.bounds
            }
        }
    }
    
    fileprivate func add(asChildViewController viewController: UIViewController, isTopContainer: Bool = true) {
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

// **********************************************************
// MARK: - Mod Wheel Settings Pop Over Delegate
// **********************************************************

extension ParentViewController: ModWheelDelegate {
    
    func didSelectRouting(newDestination: Int) {
        activePreset.modWheelRouting = Double(newDestination)
    }
}


// **********************************************************
// MARK: - MIDI Settings Pop Over Delegate
// **********************************************************

extension ParentViewController: MIDISettingsPopOverDelegate {
    
    func resetMIDILearn() {
        //auMainController.midiKnobs.forEach { $0.midiCC = 255 }
        //saveAppSettingValues()
    }
    
    func didSelectMIDIChannel(newChannel: Int) {
        if newChannel > -1 {
            midiChannelIn = MIDIByte(newChannel)
            omniMode = false
        } else {
            midiChannelIn = 0
            omniMode = true
        }
        saveAppSettingValues()
    }
    
    func didSetBackgroundAudio() {
        saveAppSettingValues()
    }
}

// **********************************************************
// MARK: - Embedded Views Delegate
// **********************************************************

extension ParentViewController: HeaderDelegate {
    
    func displayLabelTapped() {
        if !isPresetsDisplayed {
            
            // Hide Keyboard
            keyboardView.isShown = keyboardToggle.isOn
            self.keyboardToggle.callback(0.0)
            self.keyboardToggle.value = 0.0
            
            // Save previous bottom panel
            prevBottomChildView = bottomChildView
           
            // Animate
            self.topPanelheight.constant = 0
            self.view.layoutIfNeeded()
                // Add Panel to Top
                self.displayPresetsController()
                self.switchToChildView(self.topChildView!, isTopView: false)
                self.topChildView = nil
                
                // Animate panel
                UIView.animate(withDuration: Double(0.2), animations: {
                    self.topPanelheight.constant = 299
                    self.view.layoutIfNeeded()
                })
            
        } else {
            
            // Show Keyboard
            if keyboardView.isShown {
                self.keyboardToggle.value = 1.0
                self.keyboardBottomConstraint.constant = 0
                self.keyboardToggle.setTitle("Hide", for: .normal)
            }
            
            // Add Panel to Top
            self.switchToChildView(self.bottomChildView!)

            // Add Panel to bottom
            self.isPresetsDisplayed = true
            if self.prevBottomChildView == self.topChildView {
                self.prevBottomChildView = self.prevBottomChildView?.rightView()
            }
            self.switchToChildView(self.prevBottomChildView!, isTopView: false)
            self.isPresetsDisplayed = false

        }
    }
    
    func homePressed() {
        displayLabelTapped()
    }
    
    func devPressed() {
        isDevView = !isDevView
        
        if isDevView {
            topContainerView.subviews.forEach({ $0.removeFromSuperview() })
            add(asChildViewController: devViewController)
        } else {
            switchToChildView(topChildView!)
        }
    }
    
    func randomPresetPressed() {
        presetsViewController.randomPreset()
    }
    
    func prevPresetPressed() {
        presetsViewController.prevPreset()
    }
    
    func nextPresetPressed() {
        presetsViewController.nextPreset()
    }
    
    func savePresetPressed() {
       presetsViewController.editPressed()
    }
}

// **************************************************
// MARK: - Presets Delegate
// **************************************************

extension ParentViewController: PresetsDelegate {
    
    func presetDidChange(_ newActivePreset: Preset) {
        activePreset = newActivePreset
        
        if let headerVC = self.childViewControllers.first as? HeaderViewController {
            headerVC.activePreset = activePreset
        }
      
        // Set parameters from preset
        self.loadPreset()
        
        DispatchQueue.main.async {
            self.conductor.updateAllUI()
        }
        
        // Display new preset name in header
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
            let message = "\(self.activePreset.position): \(self.activePreset.name)"
            self.updateDisplay(message)
        }
        
        // UI Updates for non-bound controls
        DispatchQueue.main.async {
            // Octave position
            self.keyboardView.firstOctave = self.activePreset.octavePosition + 2
            self.octaveStepper.value = Double(self.activePreset.octavePosition)
        }
    }
    
    func updateDisplay(_ message: String) {
        if let headerVC = self.childViewControllers.first as? HeaderViewController {
            headerVC.displayLabel.text = message
        }
    }
    
    func saveEditedPreset(name: String, category: Int) {
        activePreset.name = name
        activePreset.category = category
        activePreset.isUser = true
        saveValuesToPreset()
    }
}

// **********************************************************
// MARK: - Embedded Views Delegate
// **********************************************************

extension ParentViewController: EmbeddedViewsDelegate {
    
    func switchToChildView(_ newView: ChildView, isTopView: Bool = true) {
        
        // remove all child views
        if isTopView {
            topContainerView.subviews.forEach({ $0.removeFromSuperview() })
        } else {
            bottomContainerView.subviews.forEach({ $0.removeFromSuperview() })
        }
        
        switch newView {
        case .adsrView:
            add(asChildViewController: adsrViewController, isTopContainer: isTopView)
            adsrViewController.navDelegate = self
            adsrViewController.isTopContainer = isTopView
        case .oscView:
            add(asChildViewController: mixerViewController, isTopContainer: isTopView)
            mixerViewController.navDelegate = self
            mixerViewController.isTopContainer = isTopView
        case .padView:
            add(asChildViewController: padViewController, isTopContainer: isTopView)
            padViewController.navDelegate = self
            padViewController.isTopContainer = isTopView
        case .fxView:
            add(asChildViewController: fxViewController, isTopContainer: isTopView)
            fxViewController.navDelegate = self
            fxViewController.isTopContainer = isTopView
        case .seqView:
            add(asChildViewController: seqViewController, isTopContainer: isTopView)
            seqViewController.navDelegate = self
            seqViewController.isTopContainer = isTopView
        }
        
        // Update panel navigation
        if isTopView { isPresetsDisplayed = false }
        updatePanelNav()
    }
    
    func updatePanelNav() {
        // Update NavButtons
        
        // Get all Child Synth Panels
        let synthPanels = childViewControllers.filter { $0 is SynthPanelController } as! [SynthPanelController]
        // Get current Top and Bottom Panels
        let topPanel = synthPanels.filter { $0.isTopContainer }.last
        let bottomPanel = synthPanels.filter { !$0.isTopContainer}.last
        
       
       // Update Bottom Panel NavButtons
        topChildView = topPanel?.viewType
        DispatchQueue.main.async {
           topPanel?.updateNavButtons()
        }
        
        // Update Bottom Panel NavButtons
        if keyboardToggle.value == 0 || isPresetsDisplayed {
            bottomChildView = bottomPanel?.viewType
            DispatchQueue.main.async {
               bottomPanel?.updateNavButtons()
            }
        }
    }
}

// **********************************************************
// MARK: - Keyboard Pop Over Delegate
// **********************************************************

extension ParentViewController: KeyboardPopOverDelegate {
    
    func didFinishSelecting(octaveRange: Int, labelMode: Int, darkMode: Bool) {
        keyboardView.octaveCount = octaveRange
        keyboardView.labelMode = labelMode
        keyboardView.darkMode = darkMode
        keyboardView.setNeedsDisplay()
        
        saveAppSettingValues()
    }
}

// **********************************************************
// MARK: - Keyboard Delegate Note on/off
// **********************************************************

extension ParentViewController: AKKeyboardDelegate {
    
    public func noteOn(note: MIDINoteNumber, velocity: MIDIVelocity = 127) {
        conductor.synth.play(noteNumber: note, velocity: velocity)
    }
    
    public func noteOff(note: MIDINoteNumber) {
        DispatchQueue.main.async {
            self.conductor.synth.stop(noteNumber: note)
        }
    }
}

// **********************************************************
// MARK: - AKMIDIListener protocol functions
// **********************************************************

extension ParentViewController: AKMIDIListener  {
    
    public func receivedMIDINoteOn(noteNumber: MIDINoteNumber, velocity: MIDIVelocity, channel: MIDIChannel) {
        guard channel == midiChannelIn || omniMode else { return }
        
        DispatchQueue.main.async {
            self.keyboardView.pressAdded(noteNumber, velocity: velocity)
        }
    }
    
    public func receivedMIDINoteOff(noteNumber: MIDINoteNumber, velocity: MIDIVelocity, channel: MIDIChannel) {
        guard (channel == midiChannelIn || omniMode) && !keyboardView.holdMode else { return }
        
        DispatchQueue.main.async {
            self.keyboardView.pressRemoved(noteNumber)
        }
    }
   /*
    // Assign MIDI CC to active MIDI Learn knobs
    func assignMIDIControlToKnobs(cc: MIDIByte) {
        let activeMIDILearnKnobs = auMainController.midiKnobs.filter { $0.isActive }
        activeMIDILearnKnobs.forEach {
            $0.midiCC = cc
            $0.isActive = false
        }
    }
    */
    
    // MIDI Controller input
    public func receivedMIDIController(_ controller: MIDIByte, value: MIDIByte, channel: MIDIChannel) {
        guard channel == midiChannelIn || omniMode else { return }
        print("Channel: \(channel+1) controller: \(controller) value: \(value)")
        
        // If any MIDI Learn knobs are active, assign the CC
//        DispatchQueue.main.async {
//            if self.midiLearnToggle.isSelected { self.assignMIDIControlToKnobs(cc: controller) }
//        }
        
        // Handle MIDI Control Messages
        switch controller {
        case AKMIDIControl.modulationWheel.rawValue:
            DispatchQueue.main.async {
                self.modWheelPad.setVerticalValueFrom(midiValue: value)
            }
            
        // Sustain Pedal
        case AKMIDIControl.damperOnOff.rawValue:
            if value == 127 {
                sustainMode = true
            } else {
                sustainMode = false
                // stop all notes not being held by midi controller
//                for note in 0 ... 127 {
//                    if !notesFromMIDI.contains(MIDINoteNumber(note)) {
//                        conductor.core.stop(note: MIDINoteNumber(note), channel: 0)
//                    }
//                }
            }
            
        default:
            break
        }
        
        // Check for MIDI learn knobs that match controller
        // let matchingKnobs = auMainController.midiKnobs.filter { $0.midiCC == controller }
        
        // Set new knob values from MIDI for matching knobs
        /* matchingKnobs.forEach { midiKnob in
            DispatchQueue.main.async {
                midiKnob.setKnobValueFrom(midiValue: value)
            }
        }
        */
    }
    
    // MIDI Program/Patch Change
    public func receivedMIDIProgramChange(_ program: MIDIByte, channel: MIDIChannel) {
        guard channel == midiChannelIn || omniMode else { return }
        
        // Smoothly cycle through presets if MIDI input is greater than preset count
        // currentPresetIndex = Int(program) % (totalPresets+1)
        
//        DispatchQueue.main.async {
//            self.presetController.setCurrentPresetFrom(index: self.currentPresetIndex)
//        }
    }
    
    // MIDI Pitch Wheel
    public func receivedMIDIPitchWheel(_ pitchWheelValue: MIDIWord, channel: MIDIChannel) {
        guard channel == midiChannelIn || omniMode else { return }
        
        DispatchQueue.main.async {
            self.pitchPad.setVerticalValueFromPitchWheel(midiValue: pitchWheelValue)
        }
    }
    
    // After touch
    public func receivedMIDIAfterTouch(_ pressure: MIDIByte, channel: MIDIChannel) {
        guard channel == midiChannelIn || omniMode else { return }
        //         self.conductor.tremolo.frequency = Double(pressure)/20.0
        // self.auMainController.tremoloKnob.setKnobValueFrom(midiValue: pressure)
    }
    
    // MIDI Setup Change
    public func receivedMIDISetupChange() {
        print("midi setup change, midi.inputNames: \(midi.inputNames)")
        
        let midiInputNames = midi.inputNames
        midiInputNames.forEach { inputName in
            
            // check to see if input exists
            if let index = midiInputs.index(where: { $0.name == inputName }) {
                midiInputs.remove(at: index)
            }
            
            let newMIDI = MIDIInput(name: inputName, isOpen: true)
            midiInputs.append(newMIDI)
            midi.openInput(inputName)
        }
    }
    
}


