//
//  ADSRViewController.swift
//  AudioKitSynthOne
//
//  Created by Matthew Fecher on 7/24/17.
//  Copyright © 2017 AudioKit. All rights reserved.
//

import UIKit
import AudioKit

class ADSRViewController: UpdatableViewController {

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
    
    @IBOutlet weak var nav1Button: NavButton!
    @IBOutlet weak var nav2Button: NavButton!
    
    var navDelegate: EmbeddedViewsDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        filterADSRMixKnob.range = 0.0 ... 1.2
        attackKnob.range = 0.000001 ... 1
        releaseKnob.range = 0.004 ... 2.0

        conductor.bind(attackKnob,        to: .attackDuration)
        conductor.bind(decayKnob,         to: .decayDuration)
        conductor.bind(sustainKnob,       to: .sustainLevel)
        conductor.bind(releaseKnob,       to: .releaseDuration)
        conductor.bind(filterAttackKnob,  to: .filterAttackDuration)
        conductor.bind(filterDecayKnob,   to: .filterDecayDuration)
        conductor.bind(filterSustainKnob, to: .filterSustainLevel)
        conductor.bind(filterReleaseKnob, to: .filterReleaseDuration)
        conductor.bind(filterADSRMixKnob, to: .filterADSRMix)
        
        navButtonsSetup()
    }
    
    func navButtonsSetup() {
        // Nav Button Callbacks
        nav1Button.callback = { _ in
            self.navDelegate?.switchToChildView(.oscView)
        }
        
        nav2Button.callback = { _ in
            self.navDelegate?.switchToChildView(.fxView)
        }
        
    }

    override func updateCallbacks() {

        super.updateCallbacks()

        adsrView.callback = { att, dec, sus, rel in
            self.conductor.synth.parameters[AKSynthOneParameter.attackDuration.rawValue] = att
            self.conductor.synth.parameters[AKSynthOneParameter.decayDuration.rawValue] = dec
            self.conductor.synth.parameters[AKSynthOneParameter.sustainLevel.rawValue] = sus
            self.conductor.synth.parameters[AKSynthOneParameter.releaseDuration.rawValue] = rel
        }

        filterADSRView.callback = { att, dec, sus, rel in
            self.conductor.synth.parameters[AKSynthOneParameter.filterAttackDuration.rawValue] = att
            self.conductor.synth.parameters[AKSynthOneParameter.filterDecayDuration.rawValue] = dec
            self.conductor.synth.parameters[AKSynthOneParameter.filterSustainLevel.rawValue] = sus
            self.conductor.synth.parameters[AKSynthOneParameter.filterReleaseDuration.rawValue] = rel
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
