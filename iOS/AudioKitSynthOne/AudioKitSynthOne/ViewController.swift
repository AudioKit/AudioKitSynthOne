//
//  ViewController.swift
//  AudioKitSynthOne
//
//  Created by Aurelius Prochazka on 7/8/17.
//  Copyright © 2017 AudioKit. All rights reserved.
//

import UIKit
import AudioKit

public class ViewController: UIViewController, AKKeyboardDelegate {
    @IBOutlet weak var keyboardView: AKKeyboardView?

    var synth: AKSynthOne!

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
    
//    var conductor = Conductor()
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view, typically from a nib.
        keyboardView?.delegate = self
        keyboardView?.polyphonicMode = true
        synth = AKSynthOne(viewController: self)

        if let t = osc1SemiKnob {t.callback = changeParameter(.morph1PitchOffset) }
        if let t = osc2SemiKnob {t.callback = changeParameter(.morph2PitchOffset) }
        if let t = osc2DetuneKnob {t.callback = changeParameter(.detuningMultiplier) }
        if let t = oscMixKnob {t.callback = changeParameter(.morphBalance) }
        if let t = osc1VolKnob {t.callback = changeParameter(.morph1Mix) }
        if let t = osc2VolKnob {t.callback = changeParameter(.morph2Mix) }
        if let t = rezKnob {t.callback = changeParameter(.resonance) }
        if let t = subMixKnob {t.callback = changeParameter(.subOscMix) }
        if let t = fmMixKnob {t.callback = changeParameter(.fmMix) }
        if let t = fmModKnob {t.callback = changeParameter(.fmMod) }
        if let t = noiseMixKnob {t.callback = changeParameter(.noiseMix) }

        AudioKit.output = synth
        AudioKit.start()

    }

    func changeParameter(_ param: AKSynthOneParameter) -> ((_: Double) -> Void) {
        return { value in
            self.synth.parameters[param.rawValue] = value
        }
    }
    
    override public func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    public func noteOn(note: MIDINoteNumber) {
        print("NOTE ON: \(note)")
        synth.play(noteNumber: note, velocity: 127)
    }
    public func noteOff(note: MIDINoteNumber) {
        synth.stop(noteNumber: note)
    }
}
