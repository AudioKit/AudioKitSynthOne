//
//  ADSRViewController.swift
//  AudioKitSynthOne
//
//  Created by Matthew Fecher on 7/24/17.
//  Copyright © 2017 AudioKit. All rights reserved.
//

import UIKit
import AudioKit
import AudioKitUI

class ADSRViewController: SynthPanelController {
    
    @IBOutlet var adsrView: AKADSRView!
    @IBOutlet var filterADSRView: AKADSRView!
    @IBOutlet weak var attackKnob: Knob!
    @IBOutlet weak var decayKnob: Knob!
    @IBOutlet weak var sustainKnob: Knob!
    @IBOutlet weak var releaseKnob: Knob!
    @IBOutlet weak var filterAttackKnob: Knob!
    @IBOutlet weak var filterDecayKnob: Knob!
    @IBOutlet weak var filterSustainKnob: Knob!
    @IBOutlet weak var filterReleaseKnob: Knob!
    @IBOutlet weak var filterADSRMixKnob: Knob!
 
    override func viewDidLoad() {
        super.viewDidLoad()
       
        filterADSRMixKnob.range = 0.0 ... 1.2
        attackKnob.range = 0.000001 ... 1
        releaseKnob.range = 0.004 ... 2.0
        viewType = .adsrView
        
        conductor.bind(attackKnob,        to: .attackDuration)
        conductor.bind(decayKnob,         to: .decayDuration)
        conductor.bind(sustainKnob,       to: .sustainLevel)
        conductor.bind(releaseKnob,       to: .releaseDuration)
        conductor.bind(filterAttackKnob,  to: .filterAttackDuration)
        conductor.bind(filterDecayKnob,   to: .filterDecayDuration)
        conductor.bind(filterSustainKnob, to: .filterSustainLevel)
        conductor.bind(filterReleaseKnob, to: .filterReleaseDuration)
        conductor.bind(filterADSRMixKnob, to: .filterADSRMix)
        
        updateCallbacks()
    }
    
    override func updateCallbacks() {
        super.updateCallbacks()
        
        adsrView.callback = { att, dec, sus, rel in
            self.conductor.synth.setAK1Parameter(.attackDuration, att)
            self.conductor.synth.setAK1Parameter(.decayDuration, dec)
            self.conductor.synth.setAK1Parameter(.sustainLevel, sus)
            self.conductor.synth.setAK1Parameter(.releaseDuration, rel)
        }
        
        filterADSRView.callback = { att, dec, sus, rel in
            self.conductor.synth.setAK1Parameter(.filterAttackDuration, att)
            self.conductor.synth.setAK1Parameter(.filterDecayDuration, dec)
            self.conductor.synth.setAK1Parameter(.filterSustainLevel, sus)
            self.conductor.synth.setAK1Parameter(.filterReleaseDuration, rel)
        }
    }
    
    override func updateUI(_ param: AKSynthOneParameter, value: Double) {
        
        super.updateUI(param, value: value)
        
        switch param {
        case .attackDuration:
            adsrView.attackDuration = value
        case .decayDuration:
            adsrView.decayDuration = value
        case .sustainLevel:
            adsrView.sustainLevel = value
        case .releaseDuration:
            adsrView.releaseDuration = value
        case .filterAttackDuration:
            filterADSRView.attackDuration = value
        case .filterDecayDuration:
            filterADSRView.decayDuration = value
        case .filterSustainLevel:
            filterADSRView.sustainLevel = value
        case .filterReleaseDuration:
            filterADSRView.releaseDuration = value
            
        default:
            _ = 0
            // do nothing
        }
        adsrView.setNeedsDisplay()
        filterADSRView.setNeedsDisplay()
    }
    
    
}
