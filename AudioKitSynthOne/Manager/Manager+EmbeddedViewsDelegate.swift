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
        
        if conductor.device == .phone {
            if keyboardToggle.isOn {
                keyboardToggle.value = 0.0
                keyboardToggle.callback(0.0)
            }
        }

        // remove all child views
        if isOnTop {
            topContainerView.subviews.forEach { $0.removeFromSuperview() }
        } else {
            guard conductor.device == .pad else { return }
            bottomContainerView.subviews.forEach { $0.removeFromSuperview() }
        }

        switch newView {
        case .envelopes:
            add(asChildViewController: envelopesPanel, isTopContainer: isOnTop)
            envelopesPanel.navDelegate = self
            envelopesPanel.isTopContainer = isOnTop
        case .generators:
            add(asChildViewController: generatorsPanel, isTopContainer: isOnTop)
            generatorsPanel.navDelegate = self
            generatorsPanel.isTopContainer = isOnTop
        case .touchPad:
            add(asChildViewController: touchPadPanel, isTopContainer: isOnTop)
            touchPadPanel.navDelegate = self
            touchPadPanel.isTopContainer = isOnTop
        case .effects:
            add(asChildViewController: fxPanel, isTopContainer: isOnTop)
            fxPanel.navDelegate = self
            fxPanel.isTopContainer = isOnTop
        case .sequencer:
            add(asChildViewController: sequencerPanel, isTopContainer: isOnTop)
            sequencerPanel.navDelegate = self
            sequencerPanel.isTopContainer = isOnTop
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
        var synthPanels = [PanelController]()
        for view in children {
            guard let synthPanel = view as? PanelController else { continue }
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
