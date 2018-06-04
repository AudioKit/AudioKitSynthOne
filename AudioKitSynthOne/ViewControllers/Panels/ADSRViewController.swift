//
//  ADSRViewController.swift
//  AudioKitSynthOne
//
//  Created by AudioKit Contributors on 7/24/17.
//  Copyright © 2017 AudioKit. All rights reserved.
//

import UIKit
import AudioKit
import AudioKitUI

class ADSRViewController: SynthPanelController {

    @IBOutlet var adsrView: AKADSRView!
    @IBOutlet var filterADSRView: AKADSRView!
    @IBOutlet weak var attackKnob: MIDIKnob!
    @IBOutlet weak var decayKnob: MIDIKnob!
    @IBOutlet weak var sustainKnob: MIDIKnob!
    @IBOutlet weak var releaseKnob: MIDIKnob!
    @IBOutlet weak var filterAttackKnob: MIDIKnob!
    @IBOutlet weak var filterDecayKnob: MIDIKnob!
    @IBOutlet weak var filterSustainKnob: MIDIKnob!
    @IBOutlet weak var filterReleaseKnob: MIDIKnob!
    @IBOutlet weak var filterADSRMixKnob: MIDIKnob!
    @IBOutlet weak var envelopeLabelBackground: UIView!

    override func viewDidLoad() {
        super.viewDidLoad()

        envelopeLabelBackground.layer.cornerRadius = 8

        guard let s = conductor.synth else {
            AKLog("ADSRViewController view state is invalid because synth is not instantiated")
            return
        }

        attackKnob.range = s.getRange(.attackDuration)
        decayKnob.range = s.getRange(.decayDuration)
        sustainKnob.range = s.getRange(.sustainLevel)
        releaseKnob.range = s.getRange(.releaseDuration)

        filterAttackKnob.range = s.getRange(.filterAttackDuration)
        filterDecayKnob.range = s.getRange(.filterDecayDuration)
        filterSustainKnob.range = s.getRange(.filterSustainLevel)
        filterReleaseKnob.range = s.getRange(.filterReleaseDuration)

        filterADSRMixKnob.range = s.getRange(.filterADSRMix)

        viewType = .adsrView

        conductor.bind(attackKnob, to: .attackDuration)
        conductor.bind(decayKnob, to: .decayDuration)
        conductor.bind(sustainKnob, to: .sustainLevel)
        conductor.bind(releaseKnob, to: .releaseDuration)
        conductor.bind(filterAttackKnob, to: .filterAttackDuration)
        conductor.bind(filterDecayKnob, to: .filterDecayDuration)
        conductor.bind(filterSustainKnob, to: .filterSustainLevel)
        conductor.bind(filterReleaseKnob, to: .filterReleaseDuration)
        conductor.bind(filterADSRMixKnob, to: .filterADSRMix)

        adsrView.callback = { att, dec, sus, rel in
            self.conductor.synth.setSynthParameter(.attackDuration, att)
            self.conductor.synth.setSynthParameter(.decayDuration, dec)
            self.conductor.synth.setSynthParameter(.sustainLevel, sus)
            self.conductor.synth.setSynthParameter(.releaseDuration, rel)
            self.conductor.updateAllUI()
        }

        filterADSRView.callback = { att, dec, sus, rel in
            self.conductor.synth.setSynthParameter(.filterAttackDuration, att)
            self.conductor.synth.setSynthParameter(.filterDecayDuration, dec)
            self.conductor.synth.setSynthParameter(.filterSustainLevel, sus)
            self.conductor.synth.setSynthParameter(.filterReleaseDuration, rel)
            self.conductor.updateAllUI()
        }
    }

    override func updateUI(_ param: AKS1Parameter, control: AKS1Control?, value: Double) {
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
