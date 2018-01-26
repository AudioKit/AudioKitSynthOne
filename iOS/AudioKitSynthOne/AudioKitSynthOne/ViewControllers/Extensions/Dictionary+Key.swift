//
//  Dictionary+Key.swift
//  AudioKitSynthOne
//
//  Created by Matthew Fecher on 1/25/18.
//  Copyright © 2018 AudioKit. All rights reserved.
//

import Foundation

// Get the key of a dictionary from a value
extension Dictionary where Value: Equatable {
    func getKey(forValue val: Value) -> Key? {
        return first(where: { $1 == val })?.key
    }
}
