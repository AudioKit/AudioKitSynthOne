//
//  PopUpViewController.swift
//  keyboard-scale-popup
//
//  Created by Matthew Fecher on 11/27/16.
//  Copyright © 2016 audiokit. All rights reserved.
//

import UIKit

protocol KeyboardPopOverDelegate {
    func didFinishSelecting(octaveRange: Int, labelMode: Int)
}

class PopUpKeyboardController: UIViewController {
    
    
    @IBOutlet weak var octaveRangeSegment: UISegmentedControl!
    @IBOutlet weak var labelModeSegment: UISegmentedControl!
    
    var delegate: KeyboardPopOverDelegate?
    
    var labelMode: Int = 1
    var octaveRange: Int = 2
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // set currently selected scale picks
        octaveRangeSegment.selectedSegmentIndex = octaveRange - 1
        labelModeSegment.selectedSegmentIndex = labelMode
    }
    
    @IBAction func octaveRangeDidChange(_ sender: UISegmentedControl) {
        
        octaveRange = sender.selectedSegmentIndex + 1
       
        delegate?.didFinishSelecting(octaveRange: octaveRange, labelMode: labelMode)
    }
    
    @IBAction func keyLabelDidChange(_ sender: UISegmentedControl) {
        
           labelMode = sender.selectedSegmentIndex
        
           delegate?.didFinishSelecting(octaveRange: octaveRange, labelMode: labelMode)
    }
    
    
    @IBAction func closeButton(_ sender: UIButton) {
       // delegate?.didFinishSelecting(root: selectedRoot, scaleType: selectedScaleType)
        dismiss(animated: true, completion: nil)
 
    }


}
