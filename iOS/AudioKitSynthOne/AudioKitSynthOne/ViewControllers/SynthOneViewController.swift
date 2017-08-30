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

enum ChildView: String {
    case oscView = "SourceMixerViewController"
    case adsrView = "ADSRViewController"
    case devView = "DevViewController"
    case padView = "TouchPadViewController"
    case fxView = "FXViewController"
    case seqView = "SeqViewController"
}

public class SynthOneViewController: UIViewController, AKKeyboardDelegate {
    
    @IBOutlet weak var topContainerView: UIView!
    
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
    
    // ********************************************************
    // MARK: - Define child view controllers
    // ********************************************************
    
    fileprivate lazy var adsrViewController: ADSRViewController = {
        // Load Storyboard
        let storyboard = UIStoryboard(name: "Main", bundle: Bundle.main)
        
        // Instantiate View Controller
        var viewController = storyboard.instantiateViewController(withIdentifier: ChildView.adsrView.rawValue) as! ADSRViewController
        
        // Add View Controller as Child View Controller
        self.add(asChildViewController: viewController)
        
        return viewController
    }()
    
    fileprivate lazy var mixerViewController: SourceMixerViewController = {
        let storyboard = UIStoryboard(name: "Main", bundle: Bundle.main)
        var viewController = storyboard.instantiateViewController(withIdentifier: ChildView.oscView.rawValue) as! SourceMixerViewController
        self.add(asChildViewController: viewController)
        return viewController
    }()
    
    fileprivate lazy var devViewController: SettingsViewController = {
        let storyboard = UIStoryboard(name: "Main", bundle: Bundle.main)
        var viewController = storyboard.instantiateViewController(withIdentifier: ChildView.devView.rawValue) as! SettingsViewController
        self.add(asChildViewController: viewController)
        return viewController
    }()
    
    fileprivate lazy var padViewController: TouchPadViewController = {
        let storyboard = UIStoryboard(name: "Main", bundle: Bundle.main)
        var viewController = storyboard.instantiateViewController(withIdentifier: ChildView.padView.rawValue) as! TouchPadViewController
        self.add(asChildViewController: viewController)
        return viewController
    }()
    
    fileprivate lazy var fxViewController: FXViewController = {
        let storyboard = UIStoryboard(name: "Main", bundle: Bundle.main)
        var viewController = storyboard.instantiateViewController(withIdentifier: ChildView.fxView.rawValue) as! FXViewController
        self.add(asChildViewController: viewController)
        return viewController
    }()
    
    fileprivate lazy var seqViewController: SeqViewController = {
        let storyboard = UIStoryboard(name: "Main", bundle: Bundle.main)
        var viewController = storyboard.instantiateViewController(withIdentifier: ChildView.seqView.rawValue) as! SeqViewController
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
        
        // Set delegates
        if let childVC = self.childViewControllers.first as? HeaderViewController {
            childVC.delegate = self
        }
        
        setupCallbacks()
        
        octaveStepper.minValue = -3
        octaveStepper.maxValue = 4
        
        // Set initial subviews
        switchToChildView(.oscView)
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
            
            let newConstraintValue: CGFloat = (value == 1.0) ? 0 : -138
            
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
    
    fileprivate func add(asChildViewController viewController: UIViewController) {
        // Add Child View Controller
        addChildViewController(viewController)
        
        // Add Child View as Subview
        topContainerView.addSubview(viewController.view)
        
        // Configure Child View
        viewController.view.frame = topContainerView.bounds
        viewController.view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        
        // Notify Child View Controller
        viewController.didMove(toParentViewController: self)
    }
    
    fileprivate func remove(asChildViewController viewController: UIViewController) {
        // Notify Child View Controller
        viewController.willMove(toParentViewController: nil)
        
        // Remove Child View From Superview
        viewController.view.removeFromSuperview()
        
        // Notify Child View Controller
        viewController.removeFromParentViewController()
    }
    
    fileprivate func removeAllChildViews() {
        remove(asChildViewController: mixerViewController)
        remove(asChildViewController: devViewController)
        remove(asChildViewController: padViewController)
        remove(asChildViewController: fxViewController)
        remove(asChildViewController: seqViewController)
    }
    
}

// **********************************************************
// MARK: - Embedded Views Delegate
// **********************************************************

extension SynthOneViewController: EmbeddedViewsDelegate {
    
    func switchToChildView(_ newView: ChildView) {
        // remove all child views
        removeAllChildViews()
        
        switch newView {
        case .adsrView:
            // ADSR is always here
            //adsrViewController.navDelegate = self
            break;
        case .oscView:
            add(asChildViewController: mixerViewController)
            mixerViewController.navDelegate = self
        case .devView:
            add(asChildViewController: devViewController)
        case .padView:
            add(asChildViewController: padViewController)
            padViewController.navDelegate = self
        case .fxView:
            add(asChildViewController: fxViewController)
            fxViewController.navDelegate = self
        case .seqView:
            add(asChildViewController: seqViewController)
            seqViewController.navDelegate = self
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
