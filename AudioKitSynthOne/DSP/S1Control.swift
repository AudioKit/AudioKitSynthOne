//
//  S1Control.swift
//  AudioKitSynthOne
//
//  Created by Marcus W. Hobbs on 3/29/19.
//  Copyright © 2019 AudioKit. All rights reserved.
//

protocol S1Control: class {

    var value: Double { get set }

    var callback: (Double) -> Void { get set }

    var defaultCallback: () -> Void { get set }
}

typealias S1ControlCallback = (S1Parameter, S1Control?) -> ((_: Double) -> Void)

typealias S1ControlDefaultCallback = (S1Parameter, S1Control?) -> (() -> Void)
