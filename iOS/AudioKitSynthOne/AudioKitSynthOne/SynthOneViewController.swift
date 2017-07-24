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

    public override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view, typically from a nib.
        keyboardView?.delegate = self
        keyboardView?.polyphonicMode = true

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
        // override in subclasses
    }
}
