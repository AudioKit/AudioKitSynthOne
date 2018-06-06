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
    var leftPanel = ChildPanel.arpSeq
    var rightPanel = ChildPanel.adsr

    override func viewDidLoad() {
        super.viewDidLoad()

        leftPanel = self.viewType.leftPanel()
        rightPanel = self.viewType.rightPanel()

        navButtonsSetup()
    }

    func navButtonsSetup() {

        // Left Nav Button
        nav1Button.callback = { _ in
           self.navDelegate?.switchToChildPanel(self.leftPanel, isOnTop: self.isTopContainer)
        }

        // Right Nav Button
        nav2Button.callback = { _ in
           self.navDelegate?.switchToChildPanel(self.rightPanel, isOnTop: self.isTopContainer)
        }
    }

    func updateNavButtons() {

        leftPanel = viewType.leftPanel()
        rightPanel = viewType.rightPanel()

        guard let manager = self.parent as? Manager else { return }

        if manager.keyboardToggle.value == 0 && !manager.isPresetsDisplayed {

            // Make sure the same view doesn't appear twice on the screen
            if leftPanel == manager.topChildPanel || leftPanel == manager.bottomChildPanel {
                leftPanel = leftPanel.leftPanel()
            }

            if rightPanel == manager.topChildPanel || rightPanel == manager.bottomChildPanel {
                rightPanel = rightPanel.rightPanel()
            }
        }

        // Update button text
        nav1Button.buttonText = leftPanel.buttonText()
        nav2Button.buttonText = rightPanel.buttonText()
        nav1Button.setNeedsDisplay()
        nav2Button.setNeedsDisplay()
    }

}
