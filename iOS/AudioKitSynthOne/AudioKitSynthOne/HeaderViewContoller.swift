//
//  HeaderViewContoller.swift
//  AudioKitSynthOne
//
//  Created by Aurelius Prochazka on 7/23/17.
//  Copyright © 2017 AudioKit. All rights reserved.
//

import UIKit
import AudioKit

class HeaderViewController: SynthOneViewController {

    public override func viewDidLoad() {
        super.viewDidLoad()
        displayLabel?.text = "Hey Matt!"
        conductor.synth.parameters[AKSynthOneParameter.fmMod.rawValue] = 0.66
    }


}
