//
//  Manager+EmbeddedViewsDelegate.swift
//  AudioKitSynthOne
//
//  Created by AudioKit Contributors on 5/25/18.
//  Copyright © 2018 AudioKit. All rights reserved.
//

// Embedded Views Delegate

extension Manager: EmbeddedViewsDelegate {

    func switchToChildPanel(_ newView: ChildPanel, isOnTop: Bool = true) {

        // remove all child views
        if isOnTop {
            topContainerView.subviews.forEach({ $0.removeFromSuperview() })
        } else {
            bottomContainerView.subviews.forEach({ $0.removeFromSuperview() })
        }

        switch newView {
        case .adsr:
            add(asChildViewController: adsrPanel, isTopContainer: isOnTop)
            adsrPanel.navDelegate = self
            adsrPanel.isTopContainer = isOnTop
        case .main:
            add(asChildViewController: mainPanel, isTopContainer: isOnTop)
            mainPanel.navDelegate = self
            mainPanel.isTopContainer = isOnTop
        case .touchPad:
            add(asChildViewController: touchPadPanel, isTopContainer: isOnTop)
            touchPadPanel.navDelegate = self
            touchPadPanel.isTopContainer = isOnTop
        case .fx:
            add(asChildViewController: fxPanel, isTopContainer: isOnTop)
            fxPanel.navDelegate = self
            fxPanel.isTopContainer = isOnTop
        case .arpSeq:
            add(asChildViewController: arpSeqPanel, isTopContainer: isOnTop)
            arpSeqPanel.navDelegate = self
            arpSeqPanel.isTopContainer = isOnTop
        case .tunings:
            add(asChildViewController: tuningsPanel, isTopContainer: isOnTop)
            tuningsPanel.navDelegate = self
            tuningsPanel.isTopContainer = isOnTop
        }

        // Update panel navigation
        if isOnTop { isPresetsDisplayed = false }
        updatePanelNav()
    }

    func updatePanelNav() {
        // Update NavButtons

        // Get all Child Synth Panels
        var synthPanels = [Panel]()
        for view in childViewControllers {
            guard let synthPanel = view as? Panel else { continue }
            synthPanels.append(synthPanel)
        }

        // Get current Top and Bottom Panels
        let topPanel = synthPanels.filter { $0.isTopContainer }.last
        let bottomPanel = synthPanels.filter { !$0.isTopContainer }.last

        // Update Bottom Panel NavButtons
        topChildPanel = topPanel?.currentPanel
        DispatchQueue.main.async {
            topPanel?.updateNavButtons()
        }

        // Update Bottom Panel NavButtons
        if keyboardToggle.value == 0 || isPresetsDisplayed {
            bottomChildPanel = bottomPanel?.currentPanel
            DispatchQueue.main.async {
                bottomPanel?.updateNavButtons()
            }
        }
    }
}
