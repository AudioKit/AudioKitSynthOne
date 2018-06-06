//
//  Panel.swift
//  AudioKitSynthOne
//
//  Created by AudioKit Contributors on 8/30/17.
//  Copyright © 2017 AudioKit. All rights reserved.
//

import UIKit

// Handles the Left/Right Navigation between Synth Panels

class Panel: UpdatableViewController {

    @IBOutlet weak var nav1Button: NavButton!
    @IBOutlet weak var nav2Button: NavButton!

    weak var navDelegate: EmbeddedViewsDelegate?
//    var bottomNavDelegate: BottomEmbeddedViewsDelegate?
    var isTopContainer: Bool = true

    var viewType = ChildPanel.main
    var leftView = ChildPanel.arpSeq
    var rightView = ChildPanel.adsr

    override func viewDidLoad() {
        super.viewDidLoad()

        leftView = self.viewType.leftPanel()
        rightView = self.viewType.rightPanel()

        navButtonsSetup()
    }

    func navButtonsSetup() {

        // Left Nav Button
        nav1Button.callback = { _ in
           self.navDelegate?.switchToChildPanel(self.leftView, isOnTop: self.isTopContainer)
        }

        // Right Nav Button
        nav2Button.callback = { _ in
           self.navDelegate?.switchToChildPanel(self.rightView, isOnTop: self.isTopContainer)
        }
    }

    func updateNavButtons() {

        leftView = viewType.leftPanel()
        rightView = viewType.rightPanel()

        guard let parentController = self.parent as? ParentViewController else { return }

        if parentController.keyboardToggle.value == 0 && !parentController.isPresetsDisplayed {

            // Make sure the same view doesn't appear twice on the screen
            if leftView == parentController.topChildPanel || leftView == parentController.bottomChildPanel {
                leftView = leftView.leftPanel()
            }

            if rightView == parentController.topChildPanel || rightView == parentController.bottomChildPanel {
                rightView = rightView.rightPanel()
            }
        }

        // Update button text
        nav1Button.buttonText = leftView.buttonText()
        nav2Button.buttonText = rightView.buttonText()
        nav1Button.setNeedsDisplay()
        nav2Button.setNeedsDisplay()
    }

}
