//
//  UpdatableViewController.swift
//  AudioKitSynthOne
//
//  Created by AudioKit Contributors on 7/25/17.
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

    // subclasses should update UI elements that do not conform to AKS1Control protocol, should not call super
    func updateUI(_ param: AKS1Parameter, control inputControl: AKS1Control?, value: Double) {}
}
