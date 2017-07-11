//
//  ViewController.swift
//  AudioKitSynthOne
//
//  Created by Aurelius Prochazka on 7/8/17.
//  Copyright © 2017 AudioKit. All rights reserved.
//

import UIKit
import AudioKit

class ViewController: UIViewController, AKKeyboardDelegate {
    @IBOutlet weak var keyboardView: AKKeyboardView!
    
    var synth: AKSynthOne!
    
//    var conductor = Conductor()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        keyboardView.delegate = self
        keyboardView.polyphonicMode = true
        synth = AKSynthOne()
        AudioKit.output = synth
        AudioKit.start()
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    func noteOn(note: MIDINoteNumber) {
        print("NOTE ON: \(note)")
        synth.play(noteNumber: note, velocity: 127)
    }
    func noteOff(note: MIDINoteNumber) {
        synth.stop(noteNumber: note)
    }
    @IBAction func change(_ sender: UISlider) {
        synth.parameters[31] = Double(sender.value)
    }
}
