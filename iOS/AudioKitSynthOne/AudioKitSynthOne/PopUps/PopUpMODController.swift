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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        modWheelSegment.selectedSegmentIndex = modWheelDestination
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
