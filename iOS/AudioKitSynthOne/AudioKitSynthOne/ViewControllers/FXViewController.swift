//
//  FXViewController.swift
//  AudioKitSynthOne
//
//  Created by Matthew Fecher on 7/26/17.
//  Copyright © 2017 AudioKit. All rights reserved.
//

import UIKit

class FXViewController: UpdatableViewController {
    
    @IBOutlet weak var lfo1Cutoff: RadioButton!
    @IBOutlet weak var lfo1OscMorph: RadioButton!
    @IBOutlet weak var lfo1OscMix: RadioButton!
    @IBOutlet weak var lfo1Pitch: RadioButton!
    @IBOutlet weak var lfo1Detune: RadioButton!
    @IBOutlet weak var lfo1FmMod: RadioButton!
    
    @IBOutlet weak var lfo2Rez: RadioButton!
    @IBOutlet weak var lfo2OscMorph: RadioButton!
    @IBOutlet weak var lfo2OscMix: RadioButton!
    @IBOutlet weak var lfo2Pitch: RadioButton!
    @IBOutlet weak var lfo2Detune: RadioButton!
    @IBOutlet weak var lfo2FmMod: RadioButton!
    
    
    var lfo1Group : [RadioButton] = []
    var lfo2Group : [RadioButton] = []
    

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Setup LFO Radio Buttons
        lfo1Group = [lfo1Cutoff, lfo1OscMorph, lfo1OscMix, lfo1Pitch, lfo1Detune, lfo1FmMod]
        lfo1Group.forEach { $0.alternateButton = lfo1Group }
        
        lfo2Group = [lfo2Rez, lfo2OscMorph, lfo2OscMix, lfo2Pitch, lfo2Detune, lfo2FmMod]
        lfo2Group.forEach { $0.alternateButton = lfo2Group }
        
        // Set Default LFO routing
        lfo1Cutoff.isSelected = true
        lfo2OscMorph.isSelected = true
    }



}
