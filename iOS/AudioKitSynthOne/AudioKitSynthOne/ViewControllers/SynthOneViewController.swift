//
//  SynthOneViewController.swift
//  AudioKitSynthOne
//
//  Created by Aurelius Prochazka on 7/8/17.
//  Copyright © 2017 AudioKit. All rights reserved.
//

import UIKit
import AudioKit

public class SynthOneViewController: UIViewController, AKKeyboardDelegate {
    
    @IBOutlet weak var topContainerView: UIView!
    @IBOutlet weak var keyboardView: AKKeyboardView?
    @IBOutlet weak var oscViewButton: UIButton!
    @IBOutlet weak var adsrViewButton: UIButton!
    
    var conductor = Conductor.sharedInstance
    
    // **********************************************************
    // MARK: - Define view controllers
    // **********************************************************
    
    private lazy var adsrViewController: ADSRViewController = {
        // Load Storyboard
        let storyboard = UIStoryboard(name: "Main", bundle: Bundle.main)
        
        // Instantiate View Controller
        var viewController = storyboard.instantiateViewController(withIdentifier: "ADSRViewController") as! ADSRViewController
        
        // Add View Controller as Child View Controller
        self.add(asChildViewController: viewController)
        
        return viewController
    }()
    
    private lazy var mixerViewController: SourceMixerViewController = {
        let storyboard = UIStoryboard(name: "Main", bundle: Bundle.main)
        var viewController = storyboard.instantiateViewController(withIdentifier: "SourceMixerViewController") as! SourceMixerViewController
        self.add(asChildViewController: viewController)
        return viewController
    }()
    
    
    // **********************************************************
    // MARK: - viewDidLoad
    // **********************************************************
    
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
        // oscViewPressed(oscViewButton)
        adsrViewPressed(adsrViewButton)
    }

//    func changeParameter(_ param: AKSynthOneParameter) -> ((_: Double) -> Void) {
//        return { value in
//            self.conductor.synth.parameters[param.rawValue] = value
//        }
//    }
    
    // **********************************************************
    // MARK: - IBActions
    // **********************************************************
    
    @IBAction func oscViewPressed(_ sender: UIButton) {
        remove(asChildViewController: adsrViewController)
        add(asChildViewController: mixerViewController)
    }
    @IBAction func adsrViewPressed(_ sender: UIButton) {
        remove(asChildViewController: mixerViewController)
        add(asChildViewController: adsrViewController)
    }
    
    // **********************************************************
    // MARK: - Note on/off
    // **********************************************************
    
    public func noteOn(note: MIDINoteNumber) {
        print("NOTE ON: \(note)")
        conductor.synth.play(noteNumber: note, velocity: 127)
    }
    public func noteOff(note: MIDINoteNumber) {
        conductor.synth.stop(noteNumber: note)
    }
    
    // **********************************************************
    // MARK: - View Navigation/Embed Helper Methods
    // **********************************************************
    
    private func add(asChildViewController viewController: UIViewController) {
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
    
    private func remove(asChildViewController viewController: UIViewController) {
        // Notify Child View Controller
        viewController.willMove(toParentViewController: nil)
        
        // Remove Child View From Superview
        viewController.view.removeFromSuperview()
        
        // Notify Child View Controller
        viewController.removeFromParentViewController()
    }
}
