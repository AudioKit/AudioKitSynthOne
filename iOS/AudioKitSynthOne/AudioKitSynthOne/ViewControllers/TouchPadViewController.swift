//
//  TouchPadViewController.swift
//  AudioKitSynthOne
//
//  Created by Matthew Fecher on 7/25/17.
//  Copyright © 2017 AudioKit. All rights reserved.
//

import UIKit

class TouchPadViewController: UpdatableViewController {
    
    @IBOutlet weak var touchPad1: AKTouchPadView!
    @IBOutlet weak var touchPad2: AKTouchPadView!
    
    @IBOutlet weak var touchPad1Label: UILabel!
    @IBOutlet weak var touchPad2Label: UILabel!
    
    var cutoff: Double = 0.0
    var rez: Double = 0.0
    var oscBalance: Double = 0.0
    var detuningMultiplier: Double = 0.0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        touchPad1.verticalRange = 0.5 ... 2
        touchPad1.verticalTaper = log(3) / log(2)
        
        touchPad2.verticalRange = 120 ... 28000
        touchPad2.verticalTaper = 4.04
        
        updateCallbacks()
    }
    
    override func updateCallbacks() {
        touchPad1.callback = { horizontal, vertical in
            self.conductor.synth.parameters[AKSynthOneParameter.detuningMultiplier.rawValue] = vertical
            self.conductor.synth.parameters[AKSynthOneParameter.morphBalance.rawValue] = horizontal
        }
        touchPad2.callback = { horizontal, vertical in
            self.conductor.synth.parameters[AKSynthOneParameter.cutoff.rawValue] = vertical
            self.conductor.synth.parameters[AKSynthOneParameter.resonance.rawValue] = horizontal
            
        }
    }
    
    override func updateUI(_ param: AKSynthOneParameter, value: Double) {
        
        switch param {
        case .morphBalance:
            oscBalance = value
        case .detuningMultiplier:
            detuningMultiplier = value
        case .cutoff:
            cutoff = value
        case .resonance:
            rez = value
        default:
            _ = 0
            // do nothin
        }
        
        updateLabels()
    }
    
    func updateLabels() {
        touchPad1Label.text = "Pitch Bend: \(detuningMultiplier.decimalString), DCO Balance: \(oscBalance.decimalString)"
        touchPad2Label.text = "Cutoff: \(cutoff.decimalString) Hz, Rez: \(rez.decimalString)"
    }
    
    
}

