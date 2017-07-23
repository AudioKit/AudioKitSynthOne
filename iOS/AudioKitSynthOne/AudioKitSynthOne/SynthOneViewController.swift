//
//  ViewController.swift
//  AudioKitSynthOne
//
//  Created by Aurelius Prochazka on 7/8/17.
//  Copyright © 2017 AudioKit. All rights reserved.
//

import UIKit
import AudioKit

public class SynthOneViewController: AUViewController, AKKeyboardDelegate {
    @IBOutlet weak var keyboardView: AKKeyboardView?

    var conductor = Conductor.sharedInstance

    @IBOutlet weak var displayLabel: UILabel?
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
        
        // Do any additional setup after loading the view, typically from a nib.
        keyboardView?.delegate = self
        keyboardView?.polyphonicMode = true

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

        conductor.synth.viewControllers.insert(self)
    }

    func changeParameter(_ param: AKSynthOneParameter) -> ((_: Double) -> Void) {
        return { value in
            self.conductor.synth.parameters[param.rawValue] = value
        }
    }
    
    override public func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    public func noteOn(note: MIDINoteNumber) {
        print("NOTE ON: \(note)")
        conductor.synth.play(noteNumber: note, velocity: 127)
    }
    public func noteOff(note: MIDINoteNumber) {
        conductor.synth.stop(noteNumber: note)
    }

    func updateUI(_ param: AKSynthOneParameter, value: Double) {
        let vc = self
        switch param {
        case .morph1PitchOffset:
            vc.osc1SemiKnob?.value = Double(value)
            vc.displayLabel?.text = "DCO1: \(value) semitones"
        case .morph2PitchOffset:
            vc.osc2SemiKnob?.value = Double(value)
            vc.displayLabel?.text = "DCO2: \(value) semitones"
        case .detuningMultiplier:
            vc.osc2DetuneKnob?.value = Double(value)
            vc.displayLabel?.text = "DCO2: \(value)X"
        case .morphBalance:
            vc.oscMixKnob?.value = Double(value)
            vc.displayLabel?.text = "OSC MIX: \(value)"
        case .morph1Mix:
            vc.osc1VolKnob?.value = Double(value)
            vc.displayLabel?.text = "OSC1: \(value)"
        case .morph2Mix:
            vc.osc2VolKnob?.value = Double(value)
            vc.displayLabel?.text = "OSC2: \(value)"
        case .resonance:
            vc.rezKnob?.value = Double(value)
            vc.displayLabel?.text = "Resonance: \(value)"
        case .subOscMix:
            vc.subMixKnob?.value = Double(value)
            vc.displayLabel?.text = "Sub Mix: \(value)"
        case .fmMix:
            vc.fmMixKnob?.value = Double(value)
            vc.displayLabel?.text = "FM Mix: \(value)"
        case .fmMod:
            vc.fmModKnob?.value = Double(value)
            vc.displayLabel?.text = "FM Mod \(value)"
        case .noiseMix:
            vc.noiseMixKnob?.value = Double(value)
            vc.displayLabel?.text = "Noise Mix: \(value)"
        default:
            _ = 0
            // do nothing
        }
    }
}
