//
//  PopUpMODController.swift
//  AudioKitSynthOne
//
//  Created by Matthew Fecher on 12/26/17.
//  Copyright © 2017 AudioKit. All rights reserved.
//

import UIKit

class PopUpMODController: UIViewController {

    @IBOutlet weak var modWheelSement: UISegmentedControl!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    @IBAction func routingValueDidChange(_ sender: UISegmentedControl) {
        print("New Mod Wheel Routing: \(sender.selectedSegmentIndex)")
    }
    
    @IBAction func closeButton(_ sender: UIButton) {
        dismiss(animated: true, completion: nil)
    }
    
}
