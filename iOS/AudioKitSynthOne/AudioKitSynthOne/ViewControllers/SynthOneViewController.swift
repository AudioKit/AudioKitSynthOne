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
    
    public var childViewDidChangeCallback: (ChildView)->Void = { _ in }
    
    var topChildView: ChildView? {
        didSet {
            childViewDidChangeCallback(topChildView!)
        }
    }
    var bottomChildView: ChildView? {
        didSet {
            childViewDidChangeCallback(bottomChildView!)
        }
    }
    
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
        if let childVC = self.childViewControllers.first as? HeaderViewController {
            childVC.delegate = self
        }
        
        setupCallbacks()
        
        octaveStepper.minValue = -3
        octaveStepper.maxValue = 4
        
        // Set initial subviews
        switchToChildView(.oscView)
        switchToBottomChildView(.padView)
    }
    
    public override func viewDidAppear(_ animated: Bool) {
        keyboardToggle.isSelected = false
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
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
            self.performSegue(withIdentifier: "SegueToKeyboardPopOver", sender: self)
            self.configKeyboardButton.isSelected = false
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
            topChildView = .adsrView
        case .oscView:
            add(asChildViewController: mixerViewController)
            mixerViewController.navDelegate = self
            mixerViewController.isTopContainer = true
            topChildView = .oscView
        case .padView:
            add(asChildViewController: padViewController)
            padViewController.navDelegate = self
            padViewController.isTopContainer = true
            topChildView = .padView
        case .fxView:
            add(asChildViewController: fxViewController)
            fxViewController.navDelegate = self
            fxViewController.isTopContainer = true
            topChildView = .fxView
        case .seqView:
            add(asChildViewController: seqViewController)
            seqViewController.navDelegate = self
            seqViewController.isTopContainer = true
            topChildView = .seqView
        }
    }
}

extension SynthOneViewController: BottomEmbeddedViewsDelegate {
    
    func switchToBottomChildView(_ newView: ChildView) {
        // remove all child views
        bottomContainerView.subviews.forEach({ $0.removeFromSuperview() }) // this gets things done
        
        var topPanels = [SynthPanelController]()
        var bottomPanels = [SynthPanelController]()
        childViewControllers.forEach({
        
            if let vc = $0 as? SynthPanelController {
                if vc.isTopContainer {
                    topPanels.append(vc)
                } else {
                    bottomPanels.append(vc)
                }
            }
            
            // bottomPanels.last()
            // topPanels.last()
        })
        print("****")
        
        switch newView {
        case .adsrView:
            add(asChildViewController: adsrViewController, isTopContainer: false)
            adsrViewController.navDelegateBottom = self
            adsrViewController.isTopContainer = false
            bottomChildView = .adsrView
        case .oscView:
            add(asChildViewController: mixerViewController, isTopContainer: false)
            mixerViewController.navDelegateBottom = self
            mixerViewController.isTopContainer = false
            bottomChildView = .oscView
        case .padView:
            add(asChildViewController: padViewController, isTopContainer: false)
            padViewController.navDelegateBottom = self
            padViewController.isTopContainer = false
            bottomChildView = .padView
        case .fxView:
            add(asChildViewController: fxViewController, isTopContainer: false)
            fxViewController.navDelegateBottom = self
            fxViewController.isTopContainer = false
            bottomChildView = .fxView
        case .seqView:
            add(asChildViewController: seqViewController, isTopContainer: false)
            seqViewController.navDelegateBottom = self
            seqViewController.isTopContainer = false
            bottomChildView = .seqView
        }
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
