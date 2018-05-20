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
    
    lazy var tuningsViewController: TuningsViewController = {
        let mainStoryboard = UIStoryboard(name: "Main", bundle: Bundle.main)
        var viewController = mainStoryboard.instantiateViewController(withIdentifier: ChildView.tuningsView.identifier()) as! TuningsViewController
        viewController.delegate = self
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
        presetsViewController.signedMailingList = appSettings.signedMailingList
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
        if appSettings.launches % 15 == 0 && !appSettings.pushNotifications { pushPopUp() }
        
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
            popOverController.velocitySensitive = appSettings.velocitySensitive
            
            popOverController.preferredContentSize = CGSize(width: 300, height: 320)
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
        presetsViewController.signedMailingList = appSettings.signedMailingList
        isPresetsDisplayed = true
    }
}


// **********************************************************
// MARK: - Mailing List PopOver Delegate
// **********************************************************


extension ParentViewController: MailingListDelegate {
    func didSignMailingList(email: String) {
        
        signedMailingList = true
        
        DispatchQueue.main.async {
            if let headerVC = self.childViewControllers.first as? HeaderViewController {
                headerVC.updateMailingListButton(self.signedMailingList)
            }
        }
        userSignedMailingList(email: email)
    }
    
    func userSignedMailingList(email: String) {
        appSettings.signedMailingList = true
        appSettings.userEmail = email
        saveAppSettingValues()
        
        presetsViewController.signedMailingList = appSettings.signedMailingList
        //presetController.loadFactoryPresets()
    }
}


// **********************************************************
// MARK: - Mod Wheel Settings Pop Over Delegate
// **********************************************************

extension ParentViewController: ModWheelDelegate {
    
    func didSelectRouting(newDestination: Int) {
        activePreset.modWheelRouting = Double(newDestination)
        let s = conductor.synth!

        switch activePreset.modWheelRouting {
        case 0:
            // Cutoff
            conductor.updateSingleUI(.cutoff, control: nil, value: s.getAK1Parameter(.cutoff))
        case 1:
            // LFO 1 Rate
            modWheelPad.setVerticalValue01(Double(s.getAK1DependentParameter(.lfo1Rate)))
        case 2:
            // LFO 2 Rate
            modWheelPad.setVerticalValue01(Double(s.getAK1DependentParameter(.lfo2Rate)))
        default:
            break
        }

    }
}

extension ParentViewController: AboutDelegate {
    
    func showDevPanel() {
        isDevView = false
        devPressed() 
    }
}

// **********************************************************
// MARK: - MIDI Settings Pop Over Delegate
// **********************************************************

extension ParentViewController: MIDISettingsPopOverDelegate {
    
    func resetMIDILearn() {
        midiKnobs.forEach { $0.midiCC = 255 }
        saveAppSettingValues()
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
    
    func didToggleVelocity() {
        appSettings.velocitySensitive = !appSettings.velocitySensitive
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
            if let cv = topChildView {
                switchToChildView(cv)
            }
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
    
    func morePressed() {
        print("Segue \(signedMailingList)")
        if signedMailingList {
            performSegue(withIdentifier: "SegueToMore", sender: self)
        } else {
            performSegue(withIdentifier: "SegueToMailingList", sender: self)
        }
    }
    
    func panicPressed() {
        conductor.synth.reset() // kinder, gentler panic
        //self.conductor.synth.resetDSP() // nuclear panic option
        
        // Turn off held notes on keybaord
        keyboardView.allNotesOff()
        
        self.displayAlertController("Midi Panic", message: "All notes have been turned off.")
    }
    
    func aboutPressed() {
        self.performSegue(withIdentifier: "SegueToAbout", sender: self)
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
    
    func saveEditedPreset(name: String, category: Int, bank: String) {
        activePreset.name = name
        activePreset.category = category
        activePreset.bank = bank
        // activePreset.isUser = true
        saveValuesToPreset()
    }
    
    func banksDidUpdate() {
        saveBankSettings()
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
        case .tuningsView:
            add(asChildViewController: tuningsViewController, isTopContainer: isTopView)
            tuningsViewController.navDelegate = self
            tuningsViewController.isTopContainer = isTopView
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
        sustainer.play(noteNumber: note, velocity: velocity)
    }
    
    public func noteOff(note: MIDINoteNumber) {
        sustainer.stop(noteNumber: note)
    }
}

// **********************************************************
// MARK: - DevPanelDelegate protocol functions
// **********************************************************

extension ParentViewController: DevPanelDelegate {
    
    public func freezeArpChanged(_ value: Bool) {
        appSettings.freezeArpRate = value
    }
    
    public func getFreezeArpChangedValue() -> Bool {
        return appSettings.freezeArpRate
    }

}

// **********************************************************
// MARK: - TuningPanelDelegate protocol functions
// **********************************************************

extension ParentViewController: TuningPanelDelegate {
    
    public func storeTuningWithPresetDidChange(_ value: Bool) {
        appSettings.saveTuningWithPreset = value
    }
    
    public func getStoreTuningWithPresetValue() -> Bool {
        return appSettings.saveTuningWithPreset
    }
}

// **********************************************************
// MARK: - AKMIDIListener protocol functions
// **********************************************************

extension ParentViewController: AKMIDIListener  {
    
    public func receivedMIDINoteOn(noteNumber: MIDINoteNumber, velocity: MIDIVelocity, channel: MIDIChannel) {
        guard channel == midiChannelIn || omniMode else { return }
        var newVelocity = velocity
        if !appSettings.velocitySensitive { newVelocity = 127 }
        
        DispatchQueue.main.async {
            self.keyboardView.pressAdded(noteNumber, velocity: newVelocity)
            self.notesFromMIDI.insert(noteNumber)
        }
    }
    
    public func receivedMIDINoteOff(noteNumber: MIDINoteNumber, velocity: MIDIVelocity, channel: MIDIChannel) {
        guard (channel == midiChannelIn || omniMode) && !keyboardView.holdMode else { return }
        
        DispatchQueue.main.async {
            self.keyboardView.pressRemoved(noteNumber)
            self.notesFromMIDI.remove(noteNumber)
            
            // Mono Mode
            if !self.keyboardView.polyphonicMode {
                let remainingNotes = self.notesFromMIDI.filter { $0 != noteNumber }
                if let highest = remainingNotes.max() {
                    self.keyboardView.pressAdded(highest, velocity: velocity)
                }
            }
        }
    }
    
    // Assign MIDI CC to active MIDI Learn knobs
    func assignMIDIControlToKnobs(cc: MIDIByte) {
        let activeMIDILearnKnobs = midiKnobs.filter { $0.isActive }
        activeMIDILearnKnobs.forEach {
            $0.midiCC = cc
            $0.isActive = false
        }
    }
    
    // MIDI Controller input
    public func receivedMIDIController(_ controller: MIDIByte, value: MIDIByte, channel: MIDIChannel) {
        guard channel == midiChannelIn || omniMode else { return }
        /// AKLog("Channel: \(channel+1) controller: \(controller) value: \(value)")
        
        // If any MIDI Learn knobs are active, assign the CC
        DispatchQueue.main.async {
            if self.midiLearnToggle.isSelected { self.assignMIDIControlToKnobs(cc: controller) }
        }
        
        // Handle MIDI Control Messages
        switch controller {
            
        // Mod Wheel
        case AKMIDIControl.modulationWheel.rawValue:
            DispatchQueue.main.async {
                self.modWheelPad.setVerticalValueFrom(midiValue: value)
            }
            
        // Sustain Pedal
        case AKMIDIControl.damperOnOff.rawValue:
            if value > 0 && !sustainMode {
                sustainer.sustain(down: true)
                sustainMode = true
            } else if sustainMode {
                sustainer.sustain(down: false)
                sustainMode = false
            }
            
          default:
            break
        }
        
        // Bank Change msb/cc0
        if controller == 0 {
            guard channel == midiChannelIn || omniMode else { return }
            
            if Int(value) != self.presetsViewController.bankIndex {
                AKLog ("DIFFERENT MSB")
                DispatchQueue.main.async {
                    self.presetsViewController.didSelectBank(index: Int(value))
                }
            }
           
        }
        
        // Check for MIDI learn knobs that match controller
        let matchingKnobs = midiKnobs.filter { $0.midiCC == controller }
        
        // Set new knob values from MIDI for matching knobs
        matchingKnobs.forEach { midiKnob in
            DispatchQueue.main.async {
                midiKnob.setKnobValueFrom(midiValue: value)
            }
        }
    }
    
    // MIDI Program/Patch Change
    public func receivedMIDIProgramChange(_ program: MIDIByte, channel: MIDIChannel) {
        guard channel == midiChannelIn || omniMode else { return }
        guard !pcJustTriggered else { return }
       
        DispatchQueue.main.async {
            self.presetsViewController.didSelectPreset(index: Int(program))
        }
        
        // Prevent multiple triggers from multiple MIDI inputs
        pcJustTriggered = true
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            self.pcJustTriggered = false
        }
    }
    
    // MIDI Pitch Wheel
    public func receivedMIDIPitchWheel(_ pitchWheelValue: MIDIWord, channel: MIDIChannel) {
        guard channel == midiChannelIn || omniMode else { return }
        guard let s = Conductor.sharedInstance.synth else { return }
        let val01 = Double.scaleRangeZeroToOne(Double(pitchWheelValue), rangeMin: 0, rangeMax: 16383)
        s.setAK1DependentParameter(.pitchbend, val01, 0)
        // UI will be updated by dependentParameterDidChange()
    }

    // After touch
    public func receivedMIDIAfterTouch(_ pressure: MIDIByte, channel: MIDIChannel) {
        guard channel == midiChannelIn || omniMode else { return }
        //         self.conductor.tremolo.frequency = Double(pressure)/20.0
        // self.auMainController.tremoloKnob.setKnobValueFrom(midiValue: pressure)
    }
    
    // MIDI Setup Change
    public func receivedMIDISetupChange() {
        AKLog("midi setup change, midi.inputNames: \(midi.inputNames)")
        
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

