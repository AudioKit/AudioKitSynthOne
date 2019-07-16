//
//  KeyboardView+Drawing.swift
//  AudioKitSynthOne
//
//  Created by Marcus W. Hobbs on 7/17/19.
//  Copyright © 2019 AudioKit. All rights reserved.
//

extension KeyboardView {

    // MARK: - Storyboard Rendering

    override open func prepareForInterfaceBuilder() {

        super.prepareForInterfaceBuilder()
        updateOneOctaveSize()
        contentMode = .redraw
        clipsToBounds = true
    }

    /// Keyboard view size
    override open var intrinsicContentSize: CGSize {

        return CGSize(width: 1_024, height: 84)
    }

    /// Require constraints
    open class override var requiresConstraintBasedLayout: Bool {

        return true
    }

    // MARK: - Draw Keyboard

    override open func draw(_ rect: CGRect) {

        if tuningMode {
            drawMicrotonal(rect)
        } else {
            draw12ET(rect)
        }
    }
}
