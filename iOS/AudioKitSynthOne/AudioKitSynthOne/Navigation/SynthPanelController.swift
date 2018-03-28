//
//  NavChildView.swift
//  AudioKitSynthOne
//
//  Created by Matthew Fecher on 8/30/17.
//  Copyright © 2017 AudioKit. All rights reserved.
//

import UIKit

// Handles the Left/Right Navigation between Synth Panels

class SynthPanelController: UpdatableViewController {
    
    @IBOutlet weak var nav1Button: NavButton!
    @IBOutlet weak var nav2Button: NavButton!
    
    var navDelegate: EmbeddedViewsDelegate?
    var navDelegateBottom: BottomEmbeddedViewsDelegate?
    var isTopContainer: Bool = true
    
    var viewType = ChildView.oscView
    var leftView = ChildView.seqView
    var rightView = ChildView.adsrView

    override func viewDidLoad() {
        super.viewDidLoad()

        leftView = self.viewType.leftView()
        rightView = self.viewType.rightView()
        
        navButtonsSetup()
    }
    
    func navButtonsSetup() {
        
        // Left Nav Button
        nav1Button.callback = { _ in
           self.navDelegate?.switchToChildView(self.leftView, isTopView: self.isTopContainer)
        }
        
        // Right Nav Button
        nav2Button.callback = { _ in
           self.navDelegate?.switchToChildView(self.rightView, isTopView: self.isTopContainer)
        }
    }
    
    func updateNavButtons() {
        
        leftView = viewType.leftView()
        rightView = viewType.rightView()
        
        guard let parentController = self.parent as? ParentViewController else { return }
        
        if parentController.keyboardToggle.value == 0 && !parentController.isPresetsDisplayed {
            
            // Make sure the same view doesn't appear twice on the screen
            if leftView == parentController.topChildView || leftView == parentController.bottomChildView {
                leftView = leftView.leftView()
            }
            
            if rightView == parentController.topChildView || rightView == parentController.bottomChildView {
                rightView = rightView.rightView()
            }
        }
        
        // Update button text
        nav1Button.buttonText = leftView.btnText()
        nav2Button.buttonText = rightView.btnText()
        nav1Button.setNeedsDisplay()
        nav2Button.setNeedsDisplay()
    }

}
