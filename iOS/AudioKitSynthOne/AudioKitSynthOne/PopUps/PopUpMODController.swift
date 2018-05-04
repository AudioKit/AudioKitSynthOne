//
//  PopUpMODController.swift
//  AudioKitSynthOne
//
//  Created by Matthew Fecher on 12/26/17.
//  Copyright © 2017 AudioKit. All rights reserved.
//

import UIKit

protocol ModWheelDelegate {
    func didSelectRouting(newDestination: Int)
}

class PopUpMODController: UIViewController {

    @IBOutlet weak var modWheelSegment: UISegmentedControl!
    var delegate: ModWheelDelegate?
    var modWheelDestination = 0
    @IBOutlet weak var pitchUpperRange: Stepper!
    @IBOutlet weak var pitchLowerRange: Stepper!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        modWheelSegment.selectedSegmentIndex = modWheelDestination
        
        // TODO MARCUS: Set Values of PitchWheel from Kernel?
        
        pitchUpperRange.maxValue = 24
        pitchUpperRange.minValue = 0
        pitchLowerRange.maxValue = 0
        pitchLowerRange.minValue = -24
        
        pitchUpperRange.value = 12
        pitchLowerRange.value = -12
    }
    
    override func viewDidAppear(_ animated: Bool) {
       
    }

    @IBAction func routingValueDidChange(_ sender: UISegmentedControl) {
        delegate?.didSelectRouting(newDestination: sender.selectedSegmentIndex)
    }
    
    @IBAction func closeButton(_ sender: UIButton) {
        dismiss(animated: true, completion: nil)
    }
    
}
