//
//  UpdatableViewController.swift
//  AudioKitSynthOne
//
//  Created by Matthew Fecher on 7/25/17.
//  Copyright © 2017 AudioKit. All rights reserved.
//

import UIKit

public class UpdatableViewController: UIViewController {
    
    let conductor = Conductor.sharedInstance
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        conductor.viewControllers.insert(self)
    }

    public override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        conductor.updateAllUI()
    }
    
    func updateUI(_ param: AKSynthOneParameter, control inputControl: AKSynthOneControl?, value: Double) {
        // subclasses can update UI elements that do not conform to AKSynthOneControl protocol
    }
}
