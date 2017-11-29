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

public class ParentViewController: UIViewController {
    
    @IBOutlet weak var topContainerView: UIView!
    @IBOutlet weak var bottomContainerView: UIView!
    
    @IBOutlet weak var keyboardView: SynthKeyboard!
    @IBOutlet weak var keyboardBottomConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var midiButton: SynthUIButton!
    @IBOutlet weak var holdButton: SynthUIButton!
    @IBOutlet weak var monoButton: SynthUIButton!
    @IBOutlet weak var keyboardToggle: SynthUIButton!
    @IBOutlet weak var octaveStepper: Stepper!
    @IBOutlet weak var configKeyboardButton: SynthUIButton!
    @IBOutlet weak var bluetoothButton: AKBluetoothMIDIButton!
    @IBOutlet weak var modWheelPad: AKVerticalPad!
    @IBOutlet weak var pitchPad: AKVerticalPad!
    
    var conductor = Conductor.sharedInstance
    var embeddedViewsDelegate: EmbeddedViewsDelegate?
    
    var topChildView: ChildView?
    var bottomChildView: ChildView?
    var isPresetsDisplayed: Bool = false
    var activePreset = Preset()
    var midiChannelIn: MIDIChannel = 0
    var appSettings = AppSetting()
    
    let midi = AKMIDI()  ///TODO:REMOVE
  
    // ********************************************************
    // MARK: - Define child view controllers
    // ********************************************************
    
    lazy var adsrViewController: ADSRViewController = {
        let mainStoryboard = UIStoryboard(name: "Main", bundle: Bundle.main)
        var viewController = mainStoryboard.instantiateViewController(withIdentifier: ChildView.adsrView.identifier()) as! ADSRViewController
        return viewController
    }()
    
    fileprivate lazy var mixerViewController: SourceMixerViewController = {
        let mainStoryboard = UIStoryboard(name: "Main", bundle: Bundle.main)
        var viewController = mainStoryboard.instantiateViewController(withIdentifier: ChildView.oscView.identifier()) as! SourceMixerViewController
        return viewController
    }()
    
    fileprivate lazy var devViewController: SettingsViewController = {
        let mainStoryboard = UIStoryboard(name: "Main", bundle: Bundle.main)
        var viewController = mainStoryboard.instantiateViewController(withIdentifier: "DevViewController") as! SettingsViewController
        return viewController
    }()
    
    fileprivate lazy var padViewController: TouchPadViewController = {
        let mainStoryboard = UIStoryboard(name: "Main", bundle: Bundle.main)
        var viewController = mainStoryboard.instantiateViewController(withIdentifier: ChildView.padView.identifier()) as! TouchPadViewController
        return viewController
    }()
    
    fileprivate lazy var fxViewController: FXViewController = {
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
        
        conductor.start()
        
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
        
        // ModWheel
        modWheelPad.resetToPosition(0.5, 0.0)
        
        // On four runs show dialog and request review
        //        if appSettings.launches == 4 { reviewPopUp() }
        //        if appSettings.launches % 8 == 0 { skRequestReview() }
        
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
        
        octaveStepper.callback = { value in
            self.keyboardView.firstOctave = Int(value) + 2
        }
        
        configKeyboardButton.callback = { _ in
            self.configKeyboardButton.value = 0
            self.performSegue(withIdentifier: "SegueToKeyboardPopOver", sender: self)
        }
       
        midiButton.callback = { _ in
            self.midiButton.value = 0
            self.performSegue(withIdentifier: "SegueToMIDIPopOver", sender: self)
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
            }
            
            // Animate Keyboard
            let newConstraintValue: CGFloat = (value == 1.0) ? 0 : -129
            UIView.animate(withDuration: Double(0.4), animations: {
                self.keyboardBottomConstraint.constant = newConstraintValue
                self.view.layoutIfNeeded()
            })
            
            self.saveAppSettingValues()
        }
        
        modWheelPad.callback = { value in
            // Modify Vibrato?
        }
        
        pitchPad.callback = { value in
            // Change Pitch
           
        }
        
        pitchPad.completionHandler = {  _, touchesEnded, reset in
            if touchesEnded && !reset {
                self.pitchPad.resetToCenter()
            }
            if reset {
                // self.conductor.core.globalbend = 0.0
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
        if segue.identifier == "SegueToKeyboardPopOver" {
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
        
        if segue.identifier == "SegueToMIDIPopOver" {
            let popOverController = segue.destination as! PopUpMIDIController
            // popOverController.delegate = self
            // popOverController.modWheelDestination = ??
            popOverController.preferredContentSize = CGSize(width: 300, height: 320)
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
// MARK: - Embedded Views Delegate
// **********************************************************

extension ParentViewController: HeaderDelegate {
    
    func displayLabelTapped() {
        if !isPresetsDisplayed {
            displayPresetsController()
        } else {
            switchToChildView(topChildView!)
        }
    }
    
    func homePressed() {
        displayLabelTapped()
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
        saveValuesToPreset()
        displayAlertController("Preset Saved", message: "Preset \(activePreset.name) saved.")
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
        
        // Display new preset name in header
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
            let message = "\(self.activePreset.position): \(self.activePreset.name)"
            self.updateDisplay(message)
        }
        
        // UI Updates for non-kernal stuff
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
        
        // Update NavButtons
        topChildView = topPanel?.viewType
        bottomChildView = bottomPanel?.viewType
        bottomPanel?.updateNavButtons()
        topPanel?.updateNavButtons()
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
        
        DispatchQueue.main.async {
            self.keyboardView.pressAdded(noteNumber, velocity: velocity)
        }
    }
    
    public func receivedMIDINoteOff(noteNumber: MIDINoteNumber, velocity: MIDIVelocity, channel: MIDIChannel) {
        guard !keyboardView.holdMode else { return }
        
        DispatchQueue.main.async {
            self.keyboardView.pressRemoved(noteNumber)
        }
    }
}


