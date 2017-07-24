//
//  ViewController.swift
//  AudioKitSynthOne
//
//  Created by Aurelius Prochazka on 7/8/17.
//  Copyright © 2017 AudioKit. All rights reserved.
//

import UIKit
import AudioKit

public class UpdatableViewController: UIViewController {

    let conductor = Conductor.sharedInstance

    public override func viewDidLoad() {
        super.viewDidLoad()
        conductor.viewControllers.insert(self)
    }

    func updateUI(_ param: AKSynthOneParameter, value: Double) {
        // override in subclasses
    }
    
    func updateCallbacks() {
        
    }
}

public class SynthOneViewController: UIViewController, AKKeyboardDelegate {
    @IBOutlet weak var keyboardView: AKKeyboardView?

    var conductor = Conductor.sharedInstance

    public override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view, typically from a nib.
        keyboardView?.delegate = self
        keyboardView?.polyphonicMode = true

        print("Trying to change conductor change parameter")

        conductor.changeParameter = { param in
            return { value in
                self.conductor.synth.parameters[param.rawValue] = value
            }
        }

        conductor.start()
    }

//    func changeParameter(_ param: AKSynthOneParameter) -> ((_: Double) -> Void) {
//        return { value in
//            self.conductor.synth.parameters[param.rawValue] = value
//        }
//    }

    public func noteOn(note: MIDINoteNumber) {
        print("NOTE ON: \(note)")
        conductor.synth.play(noteNumber: note, velocity: 127)
    }
    public func noteOff(note: MIDINoteNumber) {
        conductor.synth.stop(noteNumber: note)
    }
}
