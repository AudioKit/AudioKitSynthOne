//
//  PopUpMIDIController.swift
//  AudioKitSynthOne
//
//  Created by Matthew Fecher on 9/14/17.
//  Copyright © 2017 AudioKit. All rights reserved.
//

//
//  PopUpViewController.swift
//  keyboard-scale-popup
//
//  Created by Matthew Fecher on 11/27/16.
//  Copyright © 2016 audiokit. All rights reserved.
//

import UIKit

protocol MIDIPopOverDelegate {
    //func didFinishSelecting(octaveRange: Int, labelMode: Int, darkMode: Bool)
}

class PopUpMIDIController: UIViewController {
    
    @IBOutlet weak var modWheelRouting: UISegmentedControl!
    
    var delegate: MIDIPopOverDelegate?
    
    var modWheelDestination: Int = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // set currently selected scale picks
        modWheelRouting.selectedSegmentIndex = modWheelDestination
    }
    
    
    @IBAction func modWheelRoutingDidChange(_ sender: UISegmentedControl) {
        
      
        /*if sender.selectedSegmentIndex == 1 {
            darkMode = true
        } else {
            darkMode = false
        }*/
        
        // delegate?.didFinishSelecting()
        
    }
    @IBAction func closeButton(_ sender: UIButton) {
        // delegate?.didFinishSelecting(root: selectedRoot, scaleType: selectedScaleType)
        dismiss(animated: true, completion: nil)
        
    }
    
    
}

