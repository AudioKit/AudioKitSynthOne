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

    public override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        conductor.updateAllUI()
    }

    func updateUI(_ param: AKSynthOneParameter, value: Double) {
        for binding in conductor.bindings {
            if param == binding.0 {
                var control = binding.1
                control.value = value
            }
        }
    }
    
    ///Subclasses should call super and call it LAST, AFTER bindings are set.
    func updateCallbacks() {
        for binding in conductor.bindings {
            var control = binding.1
            control.callback = conductor.changeParameter(binding.0)
        }
    }
}
