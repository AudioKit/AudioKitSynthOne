//
//  DevViewController.swift
//  AudioKitSynthOne
//
//  Created by Matthew Fecher on 7/25/17.
//  Copyright © 2017 AudioKit. All rights reserved.
//

import UIKit

class TouchPadViewController: UpdatableViewController {
    
    @IBOutlet weak var touchPadOne: TouchPadView!
    @IBOutlet weak var touchPadTwo: TouchPadView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
    }
    
    
    override func updateCallbacks() {
      /*  touchPadTwo.callback = { touchX, touchY
            
        }
      */
         // resonance.callback            = conductor.changeParameter(.resonance)
        
    }
    
    override func updateUI(_ param: AKSynthOneParameter, value: Double) {
        
        }
    
    
}

