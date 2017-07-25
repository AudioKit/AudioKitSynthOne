//
//  ADSRViewController.swift
//  AudioKitSynthOne
//
//  Created by Matthew Fecher on 7/24/17.
//  Copyright © 2017 AudioKit. All rights reserved.
//

import UIKit

class ADSRViewController: UpdatableViewController {

    @IBOutlet weak var attackKnob: Knob!
    @IBOutlet weak var decayKnob: Knob!
    @IBOutlet weak var sustainKnob: Knob!
    @IBOutlet weak var releaseKnob: Knob!
    
    override func viewDidLoad() {
        super.viewDidLoad()

    }

    override func updateCallbacks() {
        attackKnob.callback = conductor.changeParameter(.attackDuration)
        decayKnob.callback = conductor.changeParameter(.decayDuration)
        sustainKnob.callback = conductor.changeParameter(.sustainLevel)
        releaseKnob.callback = conductor.changeParameter(.releaseDuration)
    }
    
    override func updateUI(_ param: AKSynthOneParameter, value: Double) {
        
        switch param {
        case .attackDuration:
            attackKnob.value = value
        case .decayDuration:
            decayKnob.value = value
        case .sustainLevel:
            sustainKnob.value = value
        case .releaseDuration:
            releaseKnob.value = value
            
        default:
            _ = 0
            // do nothing
        }
    }
 

}
