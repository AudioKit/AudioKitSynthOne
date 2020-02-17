//
//  ArpButton.swift
//  AudioKitSynthOne
//
//  Created by AudioKit Contributors on 8/1/17.
//  Copyright © 2018 AudioKit. All rights reserved.
//

import UIKit

@IBDesignable
class ArpButton: UIView, S1Control {

    // MARK: - Init

    required public init?(coder: NSCoder) {
        super.init(coder: coder)
        self.isUserInteractionEnabled = true
        contentMode = .redraw
    }

    override public func prepareForInterfaceBuilder() {
        super.prepareForInterfaceBuilder()
        contentMode = .scaleAspectFit
        clipsToBounds = true
    }

    public class override var requiresConstraintBasedLayout: Bool {
        return true
    }

    private var internalValue: Double = 0 {
        didSet {
            accessibilityValue = (internalValue == 1.0) ?
                NSLocalizedString("On", comment: "On") :
                NSLocalizedString("Off", comment: "Off")
        }
    }

    // MARK: - S1Control

    var value: Double {
        get {
            return internalValue
        }
        set {
            if newValue > 0 {
                internalValue = 1
            } else {
                internalValue = 0
            }
            setNeedsDisplay()
        }
    }

    public var setValueCallback: (Double) -> Void = { _ in }
    var resetToDefaultCallback: () -> Void = { }

    // MARK: - Draw

    override func draw(_ rect: CGRect) {
        ArpButtonStyleKit.drawArpButton(frame: CGRect(x: 0,
                                                      y: 0,
                                                      width: self.bounds.width,
                                                      height: self.bounds.height),
                                        isToggled: value > 0 ? true : false)
    }

    // MARK: - Touches

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let _ = touches.first else {
            return
        }
        value = 1 - value
        setValueCallback(value)
    }
}
