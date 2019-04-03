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

    // MARK: - ToggleButton

    private var _value: Double = 0 {
        didSet {
            accessibilityValue = (_value == 1.0) ?
                NSLocalizedString("On", comment: "On") :
                NSLocalizedString("Off", comment: "Off")
        }
    }
    var value: Double {
        get {
            return _value
        }
        set {
            if newValue > 0 {
                _value = 1
            } else {
                _value = 0
            }
            setNeedsDisplay()
        }
    }

    public var callback: (Double) -> Void = { _ in }
    var defaultCallback: () -> Void = { }

    override func draw(_ rect: CGRect) {
        ArpButtonStyleKit.drawArpButton(frame: CGRect(x: 0,
                                                      y: 0,
                                                      width: self.bounds.width,
                                                      height: self.bounds.height),
                                        isToggled: value > 0 ? true : false)
    }

    // MARK: - Handle Touches

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        for _ in touches {
            value = 1 - value
            callback(value)
        }
    }

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

}
