//
//  AppSettings.swift
//  AudioKit Synth One
//
//  Created by Matthew Fecher on 7/27/16.
//  Copyright © 2016 AudioKit. All rights reserved.
//

import Foundation
import RealmSwift

// NOTE: Update the schemaVersion in RealmConfig.swift
// Everytime you update the model

class AppSettings: Object {
    
    // ******************************************************
    // MARK: - Properties
    // ******************************************************
    
    dynamic var settingsID = 0 // In case you want multiple settings

    dynamic var backgroundAudio = false
    dynamic var keyPitchBend = false
    dynamic var noteNameDisplay = true
    dynamic var velocitySensitive = false
    
    // ******************************************************
    // MARK: - Realm
    // ******************************************************
    
    override class func primaryKey() -> String? {
        return "settingsID"
    }
    
    convenience init(settingsID: Int) {
        self.init()

        self.settingsID = settingsID
    }

    
}
