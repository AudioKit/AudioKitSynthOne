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
    /*
     fileprivate func remove(asChildViewController viewController: UIViewController) {
     // Notify Child View Controller
     viewController.willMove(toParentViewController: nil)
     
     // Remove Child View From Superview
     viewController.view.removeFromSuperview()
     
     // Notify Child View Controller
     viewController.removeFromParentViewController()
     } */
}

// **********************************************************
// MARK: - Embedded Views Delegate
// **********************************************************

extension SynthOneViewController: EmbeddedViewsDelegate {
    
    func switchToChildView(_ newView: ChildView) {
        // remove all child views
        topContainerView.subviews.forEach({ $0.removeFromSuperview() })
        
        print("TOP Delegate \(newView)")
        
        switch newView {
        case .adsrView:
            add(asChildViewController: adsrViewController)
            adsrViewController.navDelegate = self
            adsrViewController.isTopContainer = true
        case .oscView:
            add(asChildViewController: mixerViewController)
            mixerViewController.navDelegate = self
            mixerViewController.isTopContainer = true
        case .devView:
            add(asChildViewController: devViewController)
        case .padView:
            add(asChildViewController: padViewController)
            padViewController.navDelegate = self
            padViewController.isTopContainer = true
        case .fxView:
            add(asChildViewController: fxViewController)
            fxViewController.navDelegate = self
            fxViewController.isTopContainer = true
        case .seqView:
            add(asChildViewController: seqViewController)
            seqViewController.navDelegate = self
            seqViewController.isTopContainer = true
        }
    }
}

extension SynthOneViewController: BottomEmbeddedViewsDelegate {
    
    func switchToBottomChildView(_ newView: ChildView) {
        // remove all child views
        bottomContainerView.subviews.forEach({ $0.removeFromSuperview() }) // this gets things done
        
        print("Bottom Delegate \(newView)")
        
        switch newView {
        case .adsrView:
            add(asChildViewController: adsrViewController, isTopContainer: false)
            adsrViewController.navDelegateBottom = self
            adsrViewController.isTopContainer = false
        case .oscView:
            add(asChildViewController: mixerViewController, isTopContainer: false)
            mixerViewController.navDelegateBottom = self
            mixerViewController.isTopContainer = false
        case .devView:
            
            break
        case .padView:
            add(asChildViewController: padViewController, isTopContainer: false)
            padViewController.navDelegateBottom = self
            padViewController.isTopContainer = false
        case .fxView:
            add(asChildViewController: fxViewController, isTopContainer: false)
            fxViewController.navDelegateBottom = self
            fxViewController.isTopContainer = false
        case .seqView:
            add(asChildViewController: seqViewController, isTopContainer: false)
            seqViewController.navDelegateBottom = self
            seqViewController.isTopContainer = false
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
