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
    @IBOutlet weak var keyboardView: AKKeyboardView?
    @IBOutlet weak var keyboardBottomConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var midiButton: SynthUIButton!
    @IBOutlet weak var holdButton: SynthUIButton!
    @IBOutlet weak var monoButton: SynthUIButton!
    @IBOutlet weak var keyboardToggle: SynthUIButton!
    @IBOutlet weak var octaveStepper: Stepper!
    
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
    
    fileprivate lazy var devViewController: DevViewController = {
        let storyboard = UIStoryboard(name: "Main", bundle: Bundle.main)
        var viewController = storyboard.instantiateViewController(withIdentifier: ChildView.devView.rawValue) as! DevViewController
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
        
        // Set initial subviews
        switchToChildView(.fxView)
        
        // Set delegates
        if let childVC = self.childViewControllers.first as? HeaderViewController {
            childVC.delegate = self
        }
        
        buttonCallbacks()
        
        octaveStepper.minValue = -2
        octaveStepper.maxValue = 2
    }
    
    //    func changeParameter(_ param: AKSynthOneParameter) -> ((_: Double) -> Void) {
    //        return { value in
    //            self.conductor.synth.parameters[param.rawValue] = value
    //        }
    //    }
    
    func navigationControllerSupportedInterfaceOrientations(_ navigationController: UINavigationController) -> UIInterfaceOrientationMask {
        return UIInterfaceOrientationMask.landscape
    }
    
    
    // ********************************************************
    // MARK: - Callbacks
    // ********************************************************
    
    func buttonCallbacks() {
        
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
