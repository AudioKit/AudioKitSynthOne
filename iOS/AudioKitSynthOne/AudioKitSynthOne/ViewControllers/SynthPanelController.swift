//
//  NavChildView.swift
//  AudioKitSynthOne
//
//  Created by Matthew Fecher on 8/30/17.
//  Copyright © 2017 AudioKit. All rights reserved.
//

import UIKit

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
        setupChildViewCallbacks()
    }
    
    func setupChildViewCallbacks() {
        
        // Check to see if a duplicate view is adjacent
        guard let parentController = self.parent as? SynthOneViewController else { return }
        
        parentController.childViewDidChangeCallback = { value in
         
            self.viewType = value
            self.leftView = self.viewType.leftView()
            self.rightView = self.viewType.rightView()
            
            print ("callback \(self.viewType.identifier())")
            
            if self.leftView == parentController.topChildView || self.leftView == parentController.bottomChildView {
                self.leftView = self.leftView.leftView()
            }
            
            if self.rightView == parentController.topChildView || self.rightView == parentController.bottomChildView {
                self.rightView = self.rightView.rightView()
            }
            
            self.updateNavButtons()
        }
        
    }
    
    func navButtonsSetup() {
        
        nav1Button.callback = { _ in
            if self.isTopContainer {
                self.navDelegate?.switchToChildView(self.leftView)
            } else {
                self.navDelegateBottom?.switchToBottomChildView(self.leftView)
            }
        }
        
        nav2Button.callback = { _ in
            
            if self.isTopContainer {
                self.navDelegate?.switchToChildView(self.rightView)
            } else {
                self.navDelegateBottom?.switchToBottomChildView(self.rightView)
            }
            
        }
    }
    
    func updateNavButtons() {
        nav1Button.buttonText = leftView.btnText()
        nav2Button.buttonText = rightView.btnText()
        nav1Button.setNeedsDisplay()
        nav2Button.setNeedsDisplay()
    }

}
