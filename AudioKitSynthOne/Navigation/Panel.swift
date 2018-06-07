//
//  Panel.swift
//  AudioKitSynthOne
//
//  Created by AudioKit Contributors on 8/30/17.
//  Copyright © 2017 AudioKit. All rights reserved.
//

import UIKit

/// A Panel is a View Controller with other panels to the left and right of itself
class Panel: UpdatableViewController {

    @IBOutlet weak var leftNavButton: NavButton!
    @IBOutlet weak var rightNavButton: NavButton!

    weak var navDelegate: EmbeddedViewsDelegate?
//    var bottomNavDelegate: BottomEmbeddedViewsDelegate?
    var isTopContainer: Bool = true

    var currentPanel = ChildPanel.generators
    var leftPanel = ChildPanel.sequencer
    var rightPanel = ChildPanel.envelopes

    override func viewDidLoad() {
        super.viewDidLoad()

        leftPanel = self.currentPanel.leftPanel()
        rightPanel = self.currentPanel.rightPanel()

        leftNavButton.callback = { _ in
           self.navDelegate?.switchToChildPanel(self.leftPanel, isOnTop: self.isTopContainer)
        }

        rightNavButton.callback = { _ in
           self.navDelegate?.switchToChildPanel(self.rightPanel, isOnTop: self.isTopContainer)
        }
    }

    func updateNavButtons() {

        leftPanel = currentPanel.leftPanel()
        rightPanel = currentPanel.rightPanel()

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
        leftNavButton.buttonText = leftPanel.buttonText()
        rightNavButton.buttonText = rightPanel.buttonText()
        leftNavButton.setNeedsDisplay()
        rightNavButton.setNeedsDisplay()
    }

}
