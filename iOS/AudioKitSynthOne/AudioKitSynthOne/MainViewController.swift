//
//  MainViewController.swift
//  AudioKitSynthOne
//
//  Created by Aurelius Prochazka on 7/23/17.
//  Copyright © 2017 AudioKit. All rights reserved.
//

import UIKit
import AudioKit

public class MainViewController: SynthOneViewController {

    @IBOutlet weak var sub24Toggle: ToggleButton?
    @IBOutlet weak var subSqrToggle: ToggleButton?

    @IBOutlet weak var osc1SemiKnob: Knob?
    @IBOutlet weak var osc2SemiKnob: Knob?
    @IBOutlet weak var osc2DetuneKnob: Knob?
    @IBOutlet weak var oscMixKnob: Knob?
    @IBOutlet weak var osc1VolKnob: Knob?
    @IBOutlet weak var osc2VolKnob: Knob?
    @IBOutlet weak var cutoffKnob: CutoffKnob?
    @IBOutlet weak var rezKnob: Knob?
    @IBOutlet weak var subMixKnob: Knob?
    @IBOutlet weak var fmMixKnob: Knob?
    @IBOutlet weak var fmModKnob: Knob?
    @IBOutlet weak var noiseMixKnob: Knob?
    @IBOutlet weak var masterVolKnob: Knob?

    public override func viewDidLoad() {
        super.viewDidLoad()

        if let t = osc1SemiKnob   { t.callback = changeParameter(.morph1PitchOffset) }
        if let t = osc2SemiKnob   { t.callback = changeParameter(.morph2PitchOffset) }
        if let t = osc2DetuneKnob { t.callback = changeParameter(.detuningMultiplier) }
        if let t = oscMixKnob     { t.callback = changeParameter(.morphBalance) }
        if let t = osc1VolKnob    { t.callback = changeParameter(.morph1Mix) }
        if let t = osc2VolKnob    { t.callback = changeParameter(.morph2Mix) }
        if let t = rezKnob        { t.callback = changeParameter(.resonance) }
        if let t = subMixKnob     { t.callback = changeParameter(.subOscMix) }
        if let t = fmMixKnob      { t.callback = changeParameter(.fmMix) }
        if let t = fmModKnob      { t.callback = changeParameter(.fmMod) }
        if let t = noiseMixKnob   { t.callback = changeParameter(.noiseMix) }

    }

    override func updateUI(_ param: AKSynthOneParameter, value: Double) {
        print("Updating \(param.rawValue) in main")
       switch param {
        case .morph1PitchOffset:
            osc1SemiKnob?.value = value
        case .morph2PitchOffset:
            osc2SemiKnob?.value = value
        case .detuningMultiplier:
            osc2DetuneKnob?.value = value
        case .morphBalance:
            oscMixKnob?.value = value
        case .morph1Mix:
            osc1VolKnob?.value = value
        case .morph2Mix:
            osc2VolKnob?.value = value
        case .resonance:
            rezKnob?.value = value
        case .subOscMix:
            subMixKnob?.value = value
        case .fmMix:
            fmMixKnob?.value = value
        case .fmMod:
            fmModKnob?.value = value
        case .noiseMix:
            noiseMixKnob?.value = value
        default:
            _ = 0
            // do nothing
        }
    }
}

