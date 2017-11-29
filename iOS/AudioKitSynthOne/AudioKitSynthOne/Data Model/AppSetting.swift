//
//  AppSetting.swift
//  AK1
//
//  Created by Matthew Fecher on 10/31/17.
//  Copyright © 2017 Matthew Fecher. All rights reserved.
//

import Foundation

// ******************************************************
// MARK: - App Settings
// ******************************************************

class AppSetting: Codable {
    
    var settingID = "main"
    var firstRun = true
    var isPreRelease = true
    var signedMailingList = true
    
    var launches = 0
    
    // Presets version
    var presetsVersion = 1.00
    
    // Banks
    var banks = ["factory", "user"]
    
    // MIDI Learn Settings
    var vol1_CC = 255
    var masterVolume_CC = 255
    var autoPanRate_CC = 255

    var reverbAmt_CC = 255
    var reverbMix_CC = 255
  
    var crush_CC = 255
    var tremolo_CC = 255
    
    var delayTime_CC = 255
    var delayFeedback_CC = 255
    var delayMix_CC = 255
    
    var cutoff_CC = 74 // 74: MIDI Standard CC for filter cutoff
    var rez_CC = 71 // 71: MIDI Standard CC for filter res
    var lfoAmt_CC = 255
    var lfoRate_CC = 255
    
    // Keyboard
    var labelMode = 1
    var octaveRange = 2
    var darkMode = true
    var showKeyboard = 1.0 // 1 show, 0 hide
    
    var velocitySensitive = true
    
    // ******************************************************
    // MARK: - Init
    // ******************************************************
    
    init() {
    }
    
    //*****************************************************************
    // MARK: - JSON Parsing into object
    //*****************************************************************
    
    // Init from Dictionary/JSON
    init(dictionary: [String: Any]) {
        
        settingID = dictionary["settingID"] as? String ?? settingID
        launches = dictionary["launches"] as? Int ?? launches
        firstRun = dictionary["firstRun"] as? Bool ?? firstRun
        isPreRelease = dictionary["isPreRelease"] as? Bool ?? isPreRelease
        signedMailingList = dictionary["signedMailingList"] as? Bool ?? signedMailingList
        
        presetsVersion = dictionary["presetsVersion"] as? Double ?? presetsVersion
        banks = dictionary["banks"] as? [String] ?? banks
        
        vol1_CC = dictionary["vol1_CC"] as? Int ?? vol1_CC
        masterVolume_CC = dictionary["masterVolume_CC"] as? Int ?? masterVolume_CC
        autoPanRate_CC = dictionary["autoPanRate_CC"] as? Int ?? autoPanRate_CC
        
        reverbAmt_CC = dictionary["reverbAmt_CC"] as? Int ?? reverbAmt_CC
        reverbMix_CC = dictionary["reverbMix_CC"] as? Int ?? reverbMix_CC
        
        crush_CC = dictionary["crush_CC"] as? Int ?? crush_CC
        tremolo_CC = dictionary["tremolo_CC"] as? Int ?? tremolo_CC
        
        delayTime_CC = dictionary["delayTime_CC"] as? Int ?? delayTime_CC
        delayFeedback_CC = dictionary["delayFeedback_CC"] as? Int ?? delayFeedback_CC
        delayMix_CC = dictionary["delayMix_CC"] as? Int ?? delayMix_CC
        
        cutoff_CC = dictionary["cutoff_CC"] as? Int ?? cutoff_CC
        rez_CC = dictionary["rez_CC"] as? Int ?? rez_CC
        lfoAmt_CC = dictionary["lfoAmt_CC"] as? Int ?? lfoAmt_CC
        lfoRate_CC = dictionary["lfoRate_CC"] as? Int ?? lfoRate_CC
        
        // Keyboard
        labelMode = dictionary["labelMode"] as? Int ?? labelMode
        octaveRange = dictionary["octaveRange"] as? Int ?? octaveRange
        darkMode = dictionary["darkMode"] as? Bool ?? darkMode
        showKeyboard = dictionary["showKeyboard"] as? Double ?? showKeyboard
        
        velocitySensitive = dictionary["velocitySensitive"] as? Bool ?? velocitySensitive
    }
    
}

