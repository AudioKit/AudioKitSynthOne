//
//  TuningBank.swift
//  AudioKitSynthOne
//
//  Created by Marcus W. Hobbs on 12/15/18.
//  Copyright © 2018 AudioKit. All rights reserved.
//

import Foundation

class TuningBank: Codable, CustomStringConvertible {
    // conforming to Codable: don't change these property names
    var name = "Bundled"
    var isEditable = false
    var tunings = [Tuning]()
    var order = 0

    var description: String {
        return "name:\(name), isEditable:\(isEditable), tunings:\(tunings), order:\(order)"
    }

    init() {}

    /// Codable: property names must match dictionary keys
    init(dictionary: [String: Any]) {
        name = dictionary["name"] as? String ?? "Bundled"
        isEditable = dictionary["masterSet"] as? Bool ?? false
        tunings = dictionary["tunings"] as? [Tuning] ?? [Tuning]()
        order = dictionary["order"] as? Int ?? 0
    }

}
