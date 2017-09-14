//
//  SynthOneViewController.swift
//  AudioKitSynthOne
//
//  Created by Aurelius Prochazka on 7/8/17.
//  Copyright © 2017 AudioKit. All rights reserved.
//

import UIKit
import AudioKit

protocol EmbeddedViewsDelegate {
    func switchToChildView(_ newView: ChildView)
}

protocol BottomEmbeddedViewsDelegate {
    func switchToBottomChildView(_ newView: ChildView)
}

public class SynthOneViewController: UIViewController, AKKeyboardDelegate {
    
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
    
    var conductor = Conductor.sharedInstance
    var embeddedViewsDelegate: EmbeddedViewsDelegate?
    
    var topChildView: ChildView?
    var bottomChildView: ChildView?
    var isPresetsDisplayed: Bool = false
    var activePreset = Preset()
    var activeArp = Arpeggiator()
    
    // ********************************************************
    // MARK: - Define child view controllers
    // ********************************************************
    
    fileprivate lazy var adsrViewController: ADSRViewController = {
        // Load Storyboard
        let storyboard = UIStoryboard(name: "Main", bundle: Bundle.main)
        
        // Instantiate View Controller
        var viewController = storyboard.instantiateViewController(withIdentifier: ChildView.adsrView.identifier()) as! ADSRViewController
        
        // Add View Controller as Child View Controller
        self.add(asChildViewController: viewController)
        
        return viewController
    }()
    
    fileprivate lazy var mixerViewController: SourceMixerViewController = {
        let storyboard = UIStoryboard(name: "Main", bundle: Bundle.main)
        var viewController = storyboard.instantiateViewController(withIdentifier: ChildView.oscView.identifier()) as! SourceMixerViewController
        self.add(asChildViewController: viewController)
        return viewController
    }()
    
    fileprivate lazy var devViewController: SettingsViewController = {
        let storyboard = UIStoryboard(name: "Main", bundle: Bundle.main)
        var viewController = storyboard.instantiateViewController(withIdentifier: "DevViewController") as! SettingsViewController
        self.add(asChildViewController: viewController)
        return viewController
    }()
    
    fileprivate lazy var padViewController: TouchPadViewController = {
        let storyboard = UIStoryboard(name: "Main", bundle: Bundle.main)
        var viewController = storyboard.instantiateViewController(withIdentifier: ChildView.padView.identifier()) as! TouchPadViewController
        self.add(asChildViewController: viewController)
        return viewController
    }()
    
    fileprivate lazy var fxViewController: FXViewController = {
        let storyboard = UIStoryboard(name: "Main", bundle: Bundle.main)
        var viewController = storyboard.instantiateViewController(withIdentifier: ChildView.fxView.identifier()) as! FXViewController
        self.add(asChildViewController: viewController)
        return viewController
    }()
    
    fileprivate lazy var seqViewController: SeqViewController = {
        let storyboard = UIStoryboard(name: "Main", bundle: Bundle.main)
        var viewController = storyboard.instantiateViewController(withIdentifier: ChildView.seqView.identifier()) as! SeqViewController
        self.add(asChildViewController: viewController)
        return viewController
    }()
    
    fileprivate lazy var presetsViewController: PresetsViewController = {
        let storyboard = UIStoryboard(name: "Main", bundle: Bundle.main)
        var viewController = storyboard.instantiateViewController(withIdentifier: "PresetsViewController") as! PresetsViewController
        self.add(asChildViewController: viewController)
        return viewController
    }()
    
    
    // ********************************************************
    // MARK: - viewDidLoad
    // ********************************************************
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        
        keyboardView?.delegate = self
        keyboardView?.polyphonicMode = true
        
        print("Trying to change conductor change parameter")
        
        conductor.changeParameter = { param in
            return { value in
                self.conductor.synth.parameters[param.rawValue] = value
            }
        }
        
        conductor.start()
        
        // Set Header as Delegate
        if let headerVC = self.childViewControllers.first as? HeaderViewController {
            headerVC.delegate = self
            headerVC.headerDelegate = self
        }
        
        setupCallbacks()
        
        octaveStepper.minValue = -3
        octaveStepper.maxValue = 4
        
        // Load Presets
        displayPresetsController()
    }
    
    public override func viewDidAppear(_ animated: Bool) {
        keyboardToggle.isSelected = false
        
        // Set initial subviews
        switchToChildView(.oscView)
        switchToBottomChildView(.seqView)
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            self.keyboardToggle.callback(0.0)
        }
    }
    
    // ********************************************************
    // MARK: - Callbacks
    // ********************************************************
    
    func setupCallbacks() {
        
        conductor.bind(monoButton, to: AKSynthOneParameter.isMono)
        
        octaveStepper.callback = { value in
            self.keyboardView.firstOctave = Int(value) + 3
        }
        
        configKeyboardButton.callback = { _ in
            self.configKeyboardButton.isSelected = false
            self.performSegue(withIdentifier: "SegueToKeyboardPopOver", sender: self)
        }
        
        midiButton.callback = { _ in
            self.midiButton.isSelected = false
            self.performSegue(withIdentifier: "SegueToMIDIPopOver", sender: self)
            
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
        }
    }
    
    // **********************************************************
    // MARK: - Note on/off
    // **********************************************************
    
    public func noteOn(note: MIDINoteNumber) {
        // print("NOTE ON: \(note)")
        conductor.synth.play(noteNumber: note, velocity: 127)
    }
    public func noteOff(note: MIDINoteNumber) {
        conductor.synth.stop(noteNumber: note)
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
                presentation.backgroundColor = #colorLiteral(red: 0.2, green: 0.2, blue: 0.2, alpha: 1)
            }
        }
        
        if segue.identifier == "SegueToMIDIPopOver" {
            let popOverController = segue.destination as! PopUpMIDIController
            // popOverController.delegate = self
            // popOverController.modWheelDestination = ??
            popOverController.preferredContentSize = CGSize(width: 300, height: 320)
            if let presentation = popOverController.popoverPresentationController {
                presentation.backgroundColor = #colorLiteral(red: 0.2, green: 0.2, blue: 0.2, alpha: 1)
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
        
        // Configure Child View
        viewController.view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        
        // Notify Child View Controller
        viewController.didMove(toParentViewController: self)
    }
    
    func displayPresetsController() {
        // Display Presets View
        topContainerView.subviews.forEach({ $0.removeFromSuperview() })
        add(asChildViewController: presetsViewController)
        presetsViewController.presetsDelegate = self
        isPresetsDisplayed = true
    }
    
    // **********************************************************
    // MARK: - Preset Load/Save
    // **********************************************************
    
    func loadPreset() {
        conductor.synth.parameters[AKSynthOneParameter.masterVolume.rawValue] = activePreset.masterVolume
        conductor.synth.parameters[AKSynthOneParameter.isMono.rawValue] = activePreset.isMono
        conductor.synth.parameters[AKSynthOneParameter.glide.rawValue] = activePreset.glide
        
        conductor.synth.parameters[AKSynthOneParameter.index1.rawValue] = activePreset.waveform1
        conductor.synth.parameters[AKSynthOneParameter.index2.rawValue] = activePreset.waveform2
        
        conductor.synth.parameters[AKSynthOneParameter.morph1SemitoneOffset.rawValue] = activePreset.vco1Semitone
        conductor.synth.parameters[AKSynthOneParameter.morph2SemitoneOffset.rawValue] = activePreset.vco2Semitone
        conductor.synth.parameters[AKSynthOneParameter.morph2Detuning.rawValue] = activePreset.vco2Detuning
        conductor.synth.parameters[AKSynthOneParameter.morph1Volume.rawValue] = activePreset.vco1Volume
        conductor.synth.parameters[AKSynthOneParameter.morph2Volume.rawValue] = activePreset.vco2Volume
        conductor.synth.parameters[AKSynthOneParameter.morphBalance.rawValue] = activePreset.vcoBalance
        
        conductor.synth.parameters[AKSynthOneParameter.subVolume.rawValue] = activePreset.subVolume
        conductor.synth.parameters[AKSynthOneParameter.subOctaveDown.rawValue] = activePreset.subOsc24Toggled
        conductor.synth.parameters[AKSynthOneParameter.subIsSquare.rawValue] = activePreset.subOscSquareToggled
        
        conductor.synth.parameters[AKSynthOneParameter.fmVolume.rawValue] = activePreset.fmVolume
        conductor.synth.parameters[AKSynthOneParameter.fmAmount.rawValue] = activePreset.fmMod
        conductor.synth.parameters[AKSynthOneParameter.noiseVolume.rawValue] = activePreset.noiseVolume
        
        conductor.synth.parameters[AKSynthOneParameter.cutoff.rawValue] = activePreset.cutoff
        conductor.synth.parameters[AKSynthOneParameter.resonance.rawValue] = activePreset.rez
        
        conductor.synth.parameters[AKSynthOneParameter.filterADSRMix.rawValue] = activePreset.filterADSRMix
        conductor.synth.parameters[AKSynthOneParameter.filterAttackDuration.rawValue] = activePreset.filterAttack
        conductor.synth.parameters[AKSynthOneParameter.filterDecayDuration.rawValue] = activePreset.filterDecay
        conductor.synth.parameters[AKSynthOneParameter.filterSustainLevel.rawValue] = activePreset.filterSustain
        conductor.synth.parameters[AKSynthOneParameter.filterReleaseDuration.rawValue] = activePreset.filterRelease
        
        conductor.synth.parameters[AKSynthOneParameter.attackDuration.rawValue] = activePreset.attackDuration
        conductor.synth.parameters[AKSynthOneParameter.decayDuration.rawValue] = activePreset.decayDuration
        conductor.synth.parameters[AKSynthOneParameter.sustainLevel.rawValue] = activePreset.sustainLevel
        conductor.synth.parameters[AKSynthOneParameter.releaseDuration.rawValue] = activePreset.releaseDuration
        
        conductor.synth.parameters[AKSynthOneParameter.bitCrushSampleRate.rawValue] = activePreset.crushFreq
        
        conductor.synth.parameters[AKSynthOneParameter.autoPanOn.rawValue] = activePreset.autoPanToggled
        conductor.synth.parameters[AKSynthOneParameter.autoPanFrequency.rawValue] = activePreset.autoPanRate
        
        conductor.synth.parameters[AKSynthOneParameter.reverbOn.rawValue] = activePreset.reverbToggled
        conductor.synth.parameters[AKSynthOneParameter.reverbFeedback.rawValue] = activePreset.reverbFeedback
        conductor.synth.parameters[AKSynthOneParameter.reverbHighPass.rawValue] = activePreset.reverbFeedback
        conductor.synth.parameters[AKSynthOneParameter.reverbMix.rawValue] = activePreset.reverbMix
        
        conductor.synth.parameters[AKSynthOneParameter.delayOn.rawValue] = activePreset.delayToggled
        conductor.synth.parameters[AKSynthOneParameter.delayFeedback.rawValue] = activePreset.delayFeedback
        conductor.synth.parameters[AKSynthOneParameter.delayTime.rawValue] = activePreset.delayTime
        conductor.synth.parameters[AKSynthOneParameter.delayMix.rawValue] = activePreset.delayMix
        
        conductor.synth.parameters[AKSynthOneParameter.lfo1Index.rawValue] = activePreset.lfoWaveform
        conductor.synth.parameters[AKSynthOneParameter.lfo1Amplitude.rawValue] = activePreset.lfoAmplitude
        conductor.synth.parameters[AKSynthOneParameter.lfo1Rate.rawValue] = activePreset.lfoRate
        conductor.synth.parameters[AKSynthOneParameter.lfo2Index.rawValue] = activePreset.lfo2Waveform
        conductor.synth.parameters[AKSynthOneParameter.lfo2Amplitude.rawValue] = activePreset.lfo2Amplitude
        conductor.synth.parameters[AKSynthOneParameter.lfo2Rate.rawValue] = activePreset.lfo2Rate
        
        // LFO Routings
        conductor.synth.parameters[AKSynthOneParameter.cutoffLFO.rawValue] = activePreset.cutoffLFO
        conductor.synth.parameters[AKSynthOneParameter.resonanceLFO.rawValue] = activePreset.resonanceLFO
        conductor.synth.parameters[AKSynthOneParameter.oscMixLFO.rawValue] = activePreset.oscMixLFO
        conductor.synth.parameters[AKSynthOneParameter.sustainLFO.rawValue] = activePreset.sustainLFO
        conductor.synth.parameters[AKSynthOneParameter.index1LFO.rawValue] = activePreset.index1LFO
        conductor.synth.parameters[AKSynthOneParameter.index2LFO.rawValue] = activePreset.index2LFO
        conductor.synth.parameters[AKSynthOneParameter.fmLFO.rawValue] = activePreset.fmLFO
        conductor.synth.parameters[AKSynthOneParameter.detuneLFO.rawValue] = activePreset.detuneLFO
        conductor.synth.parameters[AKSynthOneParameter.filterEnvLFO.rawValue] = activePreset.filterEnvLFO
        conductor.synth.parameters[AKSynthOneParameter.pitchLFO.rawValue] = activePreset.pitchLFO
        conductor.synth.parameters[AKSynthOneParameter.bitcrushLFO.rawValue] = activePreset.bitcrushLFO
        conductor.synth.parameters[AKSynthOneParameter.autopanLFO.rawValue] = activePreset.autopanLFO
        
        // Arp
        activeArp.beatCounter = 0
        activeArp.direction = activePreset.arpDirection
        activeArp.interval = activePreset.arpInterval
        activeArp.octave = activePreset.arpOctave
        activeArp.rate = activePreset.arpRate
        activeArp.isSequencer = activePreset.arpIsSequencer
        activeArp.totalSteps = activePreset.arpTotalSteps
        activeArp.seqPattern = activePreset.seqPatternNote
        activeArp.seqNoteOn = activePreset.seqNoteOn
        activeArp.seqOctBoost = activePreset.seqOctBoost
        activeArp.isOn = activePreset.isArpMode
        
        // Update arpVC
        seqViewController.arpeggiator = activeArp
        seqViewController.setupControlValues()
        
        // Arp Toggle
        //arpToggle.isSelected = !preset.arpToggled
        
        // filterMix = 18,
        // tempoSync
        // octave position
    }
    
    func savePreset() {
        activePreset.vcoBalance = conductor.synth.parameters[AKSynthOneParameter.morphBalance.rawValue]
        activePreset.rez = conductor.synth.parameters[AKSynthOneParameter.resonance.rawValue]
        activePreset.cutoff = conductor.synth.parameters[AKSynthOneParameter.cutoff.rawValue]
        presetsViewController.savePreset(activePreset)
    }
}

// **********************************************************
// MARK: - Embedded Views Delegate
// **********************************************************

extension SynthOneViewController: HeaderDelegate {
    
    func displayLabelTapped() {
        if !isPresetsDisplayed {
            displayPresetsController()
        } else {
            switchToChildView(topChildView!)
        }
    }
    
    func prevPresetPressed() {
        presetsViewController.prevPreset()
    }
    
    func nextPresetPressed() {
        presetsViewController.nextPreset()
    }
    
    func savePresetPressed() {
        savePreset()
    }
}

// **********************************************************
// MARK: - Embedded Views Delegate
// **********************************************************

extension SynthOneViewController: EmbeddedViewsDelegate {
    
    func switchToChildView(_ newView: ChildView) {
        // remove all child views
        topContainerView.subviews.forEach({ $0.removeFromSuperview() })
        
        switch newView {
        case .adsrView:
            add(asChildViewController: adsrViewController)
            adsrViewController.navDelegate = self
            adsrViewController.isTopContainer = true
            adsrViewController.viewType = .adsrView
        case .oscView:
            add(asChildViewController: mixerViewController)
            mixerViewController.navDelegate = self
            mixerViewController.isTopContainer = true
            mixerViewController.viewType = .oscView
        case .padView:
            add(asChildViewController: padViewController)
            padViewController.navDelegate = self
            padViewController.isTopContainer = true
            padViewController.viewType = .padView
        case .fxView:
            add(asChildViewController: fxViewController)
            fxViewController.navDelegate = self
            fxViewController.isTopContainer = true
            fxViewController.viewType = .fxView
        case .seqView:
            add(asChildViewController: seqViewController)
            seqViewController.navDelegate = self
            seqViewController.isTopContainer = true
            seqViewController.viewType = .seqView
        }
        
        // Update panel navigation
        isPresetsDisplayed = false
        updatePanelNav()
    }
    
}

extension SynthOneViewController: BottomEmbeddedViewsDelegate {
    
    func switchToBottomChildView(_ newView: ChildView) {
        // remove all child views
        bottomContainerView.subviews.forEach({ $0.removeFromSuperview() }) 
        
        switch newView {
        case .adsrView:
            add(asChildViewController: adsrViewController, isTopContainer: false)
            adsrViewController.navDelegateBottom = self
            adsrViewController.isTopContainer = false
            adsrViewController.viewType = .adsrView
        case .oscView:
            add(asChildViewController: mixerViewController, isTopContainer: false)
            mixerViewController.navDelegateBottom = self
            mixerViewController.isTopContainer = false
            mixerViewController.viewType = .oscView
        case .padView:
            add(asChildViewController: padViewController, isTopContainer: false)
            padViewController.navDelegateBottom = self
            padViewController.isTopContainer = false
            padViewController.viewType = .padView
        case .fxView:
            add(asChildViewController: fxViewController, isTopContainer: false)
            fxViewController.navDelegateBottom = self
            fxViewController.isTopContainer = false
            fxViewController.viewType = .fxView
            
        case .seqView:
            add(asChildViewController: seqViewController, isTopContainer: false)
            seqViewController.navDelegateBottom = self
            seqViewController.isTopContainer = false
            seqViewController.viewType = .seqView
        }
        
        // Update panel navigation
        updatePanelNav()
    }
    
    func updatePanelNav() {
        // Update NavButtons
        
        // Get all Child Synth Panels
        let synthPanels: [SynthPanelController] = childViewControllers.filter({ $0 is SynthPanelController }) as! [SynthPanelController]
        // Get current Top and Bottom Panels
        let topPanel = synthPanels.filter { $0.isTopContainer }.last
        let bottomPanel = synthPanels.filter { !$0.isTopContainer}.last
        
        // Update NavButtons
        topChildView = topPanel?.viewType
        bottomChildView = bottomPanel?.viewType
        bottomPanel?.updateNavButtons()
        topPanel?.updateNavButtons()
        
        // unwrap header
        guard let headerVC = self.childViewControllers.first as? HeaderViewController else { return }
        headerVC.updateHeaderNavButtons()
    }
    
}

// **********************************************************
// MARK: - Keyboard Pop Over Delegate
// **********************************************************

extension SynthOneViewController: KeyboardPopOverDelegate {
    
    func didFinishSelecting(octaveRange: Int, labelMode: Int, darkMode: Bool) {
        keyboardView.octaveCount = octaveRange
        keyboardView.labelMode = labelMode
        keyboardView.darkMode = darkMode
        keyboardView.setNeedsDisplay()
    }
}

// **************************************************
// MARK: - Presets Delegate
// **************************************************

extension SynthOneViewController: PresetsDelegate {
    
    func presetDidChange(_ newActivePreset: Preset) {
        activePreset = newActivePreset
        updateDisplay("")
        // Set parameters from preset
        loadPreset()
    }
    
    func updateDisplay(_ message: String) {
        if let headerVC = self.childViewControllers.first as? HeaderViewController {
            headerVC.displayLabel.text = "\(activePreset.position): \(activePreset.name)"
        }
    }
    
    func saveEditedPreset(name: String, category: Int) {
        activePreset.name = name
        activePreset.category = category
        activePreset.isUser = true
        savePreset()
    }
}
