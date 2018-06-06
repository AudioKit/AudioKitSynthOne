//
//  Parent+EmbeddedViewsDelegate.swift
//  AudioKitSynthOne
//
//  Created by AudioKit Contributors on 5/25/18.
//  Copyright © 2018 AudioKit. All rights reserved.
//

// Embedded Views Delegate

extension ParentViewController: EmbeddedViewsDelegate {

    func switchToChildView(_ newView: ChildView, isTopView: Bool = true) {

        // remove all child views
        if isTopView {
            topContainerView.subviews.forEach({ $0.removeFromSuperview() })
        } else {
            bottomContainerView.subviews.forEach({ $0.removeFromSuperview() })
        }

        switch newView {
        case .adsrView:
            add(asChildViewController: adsrViewController, isTopContainer: isTopView)
            adsrViewController.navDelegate = self
            adsrViewController.isTopContainer = isTopView
        case .oscView:
            add(asChildViewController: mixerViewController, isTopContainer: isTopView)
            mixerViewController.navDelegate = self
            mixerViewController.isTopContainer = isTopView
        case .padView:
            add(asChildViewController: padViewController, isTopContainer: isTopView)
            padViewController.navDelegate = self
            padViewController.isTopContainer = isTopView
        case .fxView:
            add(asChildViewController: fxViewController, isTopContainer: isTopView)
            fxViewController.navDelegate = self
            fxViewController.isTopContainer = isTopView
        case .seqView:
            add(asChildViewController: seqViewController, isTopContainer: isTopView)
            seqViewController.navDelegate = self
            seqViewController.isTopContainer = isTopView
        case .tuningsView:
            add(asChildViewController: tuningsViewController, isTopContainer: isTopView)
            tuningsViewController.navDelegate = self
            tuningsViewController.isTopContainer = isTopView
        }

        // Update panel navigation
        if isTopView { isPresetsDisplayed = false }
        updatePanelNav()
    }

    func updatePanelNav() {
        // Update NavButtons

        // Get all Child Synth Panels
        var synthPanels = [PanelViewController]()
        for view in childViewControllers {
            guard let synthPanel = view as? PanelViewController else { continue }
            synthPanels.append(synthPanel)
        }

        // Get current Top and Bottom Panels
        let topPanel = synthPanels.filter { $0.isTopContainer }.last
        let bottomPanel = synthPanels.filter { !$0.isTopContainer }.last

        // Update Bottom Panel NavButtons
        topChildView = topPanel?.viewType
        DispatchQueue.main.async {
            topPanel?.updateNavButtons()
        }

        // Update Bottom Panel NavButtons
        if keyboardToggle.value == 0 || isPresetsDisplayed {
            bottomChildView = bottomPanel?.viewType
            DispatchQueue.main.async {
                bottomPanel?.updateNavButtons()
            }
        }
    }
}
