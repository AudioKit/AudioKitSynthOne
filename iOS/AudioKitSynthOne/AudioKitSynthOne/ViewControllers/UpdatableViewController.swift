//
//  UpdatableViewController.swift
//  AudioKitSynthOne
//
//  Created by Matthew Fecher on 7/25/17.
//  Copyright © 2017 AudioKit. All rights reserved.
//

import UIKit
import AudioKit

public class UpdatableViewController: UIViewController {
    
    let conductor = Conductor.sharedInstance
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        conductor.viewControllers.insert(self)
    }
    
    func updateUI(_ param: AKSynthOneParameter, value: Double) {
        // override in subclasses
    }
    
    func updateCallbacks() {
        
    }
}
