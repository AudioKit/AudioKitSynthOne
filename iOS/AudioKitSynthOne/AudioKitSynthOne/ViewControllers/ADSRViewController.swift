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

    @IBOutlet weak var adsrView: AKADSRView!
    @IBOutlet weak var filterADSRView: AKADSRView!
    @IBOutlet weak var attackKnob: Knob!
    @IBOutlet weak var decayKnob: Knob!
    @IBOutlet weak var sustainKnob: Knob!
    @IBOutlet weak var releaseKnob: Knob!
    @IBOutlet weak var filterAttackKnob: Knob!
    @IBOutlet weak var filterDecayKnob: Knob!
    @IBOutlet weak var filterSustainKnob: Knob!
    @IBOutlet weak var filterReleaseKnob: Knob!
    @IBOutlet weak var filterADSRMixKnob: Knob!

    override func updateCallbacks() {
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

        attackKnob.callback = conductor.changeParameter(.attackDuration)
        decayKnob.callback = conductor.changeParameter(.decayDuration)
        sustainKnob.callback = conductor.changeParameter(.sustainLevel)
        releaseKnob.callback = conductor.changeParameter(.releaseDuration)

        filterAttackKnob.callback = conductor.changeParameter(.filterAttackDuration)
        filterDecayKnob.callback = conductor.changeParameter(.filterDecayDuration)
        filterSustainKnob.callback = conductor.changeParameter(.filterSustainLevel)
        filterReleaseKnob.callback = conductor.changeParameter(.filterReleaseDuration)

        filterADSRMixKnob.callback = conductor.changeParameter(.filterADSRMix)
    }
    
    override func updateUI(_ param: AKSynthOneParameter, value: Double) {
        
        switch param {
        case .attackDuration:
            attackKnob.value = value
            adsrView.attackDuration = value
        case .decayDuration:
            decayKnob.value = value
            adsrView.decayDuration = value
        case .sustainLevel:
            sustainKnob.value = value
            adsrView.sustainLevel = value
        case .releaseDuration:
            releaseKnob.value = value
            adsrView.releaseDuration = value
        case .filterAttackDuration:
            filterAttackKnob.value = value
            filterADSRView.attackDuration = value
        case .filterDecayDuration:
            filterDecayKnob.value = value
            filterADSRView.decayDuration = value
        case .filterSustainLevel:
            filterSustainKnob.value = value
            filterADSRView.sustainLevel = value
        case .filterReleaseDuration:
            filterReleaseKnob.value = value
            filterADSRView.releaseDuration = value
        case .filterADSRMix:
            filterADSRMixKnob.value = value

        default:
            _ = 0
            // do nothing
        }
        adsrView.setNeedsDisplay()
    }
 

}
