//
//  DevViewController.swift
//  AudioKitSynthOne
//
//  Created by Matthew Fecher on 7/25/17.
//  Copyright © 2017 AudioKit. All rights reserved.
//

import UIKit

class TouchPadViewController: UpdatableViewController {
    
    @IBOutlet weak var touchPad1: AKTouchPadView!
    @IBOutlet weak var touchPad2: AKTouchPadView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        touchPad1.verticalRange = 0.5 ... 2
        touchPad1.verticalTaper = log(3) / log(2)

        touchPad2.verticalRange = 120 ... 28000
        touchPad2.verticalTaper = 4.04


        // Do any additional setup after loading the view.
        updateCallbacks()
    }
    
    
    override func updateCallbacks() {
        touchPad1.callback = { horizontal, vertical in
            self.conductor.synth.parameters[AKSynthOneParameter.morphBalance.rawValue] = horizontal
            self.conductor.synth.parameters[AKSynthOneParameter.detuningMultiplier.rawValue] = vertical
        }
        touchPad2.callback = { horizontal, vertical in
            self.conductor.synth.parameters[AKSynthOneParameter.resonance.rawValue] = horizontal
            self.conductor.synth.parameters[AKSynthOneParameter.cutoff.rawValue] = vertical
        }
    }
    
    override func updateUI(_ param: AKSynthOneParameter, value: Double) {
        
    }
    
    
}

