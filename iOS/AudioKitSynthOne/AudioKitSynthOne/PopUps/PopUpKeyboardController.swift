//
//  PopUpViewController.swift
//  keyboard-scale-popup
//
//  Created by Matthew Fecher on 11/27/16.
//  Copyright © 2016 audiokit. All rights reserved.
//

import UIKit

protocol KeyboardPopOverDelegate {
    func didFinishSelecting(octaveRange: Int, labelMode: Int, darkMode: Bool)
}

class PopUpKeyboardController: UIViewController {
    
    @IBOutlet weak var octaveRangeSegment: UISegmentedControl!
    @IBOutlet weak var labelModeSegment: UISegmentedControl!
    @IBOutlet weak var keyboardModeSegment: UISegmentedControl!
    
    var delegate: KeyboardPopOverDelegate?
    
    var labelMode: Int = 1
    var octaveRange: Int = 2
    var darkMode: Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // set currently selected scale picks
        octaveRangeSegment.selectedSegmentIndex = octaveRange - 1
        labelModeSegment.selectedSegmentIndex = labelMode
        keyboardModeSegment.selectedSegmentIndex = darkMode ? 1 : 0
        
    }
    
    // Set fonts for UISegmentedControls
    override func viewDidLayoutSubviews() {
        let attr = NSDictionary(object: UIFont(name: "Avenir Next Condensed", size: 15.0)!, forKey: NSFontAttributeName as NSCopying)
        labelModeSegment.setTitleTextAttributes(attr as [NSObject : AnyObject] , for: .normal)
        keyboardModeSegment.setTitleTextAttributes(attr as [NSObject : AnyObject] , for: .normal)
        octaveRangeSegment.setTitleTextAttributes(attr as [NSObject : AnyObject] , for: .normal)
    }
    
    @IBAction func octaveRangeDidChange(_ sender: UISegmentedControl) {
        
        octaveRange = sender.selectedSegmentIndex + 1
       
        delegate?.didFinishSelecting(octaveRange: octaveRange, labelMode: labelMode, darkMode: darkMode)
    }
    
    @IBAction func keyLabelDidChange(_ sender: UISegmentedControl) {
        
           labelMode = sender.selectedSegmentIndex
        
           delegate?.didFinishSelecting(octaveRange: octaveRange, labelMode: labelMode, darkMode: darkMode)
    }
    
    
    @IBAction func keyboardModeDidChange(_ sender: UISegmentedControl) {
        
        if sender.selectedSegmentIndex == 1 {
            darkMode = true
        } else {
            darkMode = false
        }
        
        delegate?.didFinishSelecting(octaveRange: octaveRange, labelMode: labelMode, darkMode: darkMode)
    }
    
    
    @IBAction func closeButton(_ sender: UIButton) {
       // delegate?.didFinishSelecting(root: selectedRoot, scaleType: selectedScaleType)
        dismiss(animated: true, completion: nil)
 
    }


}
