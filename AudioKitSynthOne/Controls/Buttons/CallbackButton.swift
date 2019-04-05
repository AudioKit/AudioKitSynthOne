//
//  CallbackButton.swift
//  AudioKitSynthOne
//
//  Created by AudioKit Contributors on 9/12/17.
//  Copyright © 2017 AudioKit. All rights reserved.
//

class CallbackButton: UIButton {

    var callback: (Double) -> Void = { _ in }

    var valuePressed = 0.0

    // Init / Lifecycle
    required public init?(coder: NSCoder) {
        super.init(coder: coder)
    }

    // MARK: - Handle Touches

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        for _ in touches {
            valuePressed = 1
            callback(valuePressed)
        }
    }
    
}
