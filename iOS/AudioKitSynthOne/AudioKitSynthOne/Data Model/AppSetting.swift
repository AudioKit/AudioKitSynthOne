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
    var backgroundAudioOn = true
    var midiChannel = 0
    var omniMode = true
    var plotFilled = true
    var velocitySensitive = true
    
    var launches = 0
    
    // Presets version
    var presetsVersion = 1.00
    
    // Banks
    var banks = ["bankA", "user"]
    
    // MIDI Learn Settings
    
    // mixer controller
    var masterVolume_CC = 255
    var morph1Selector_CC = 255
    var morph2Selector_CC = 255
    var morph1SemitoneOffset_CC = 255
    var morph2SemitoneOffset_CC = 255
    var morph2Detuning_CC = 255
    var morphBalance_CC = 255
    var morph1Volume_CC = 255
    var morph2Volume_CC = 255
    var cutoff_CC = 74 // 74: MIDI Standard CC for filter cutoff
    var rez_CC = 71 // 71: MIDI Standard CC for filter res
    var subVolume_CC = 255
    var fmVolume_CC = 255
    var fmAmount_CC = 255
    var noiseVolume_CC = 255
    var glideKnob_CC = 255
    
    // seq controller
    var arpInterval_CC = 255
    
    // adsr
    var attackKnob_CC = 255
    var decayKnob_CC = 255
    var sustainKnob_CC = 255
    var releaseKnob_CC = 255
    var filterAttackKnob_CC = 255
    var filterDecayKnob_CC = 255
    var filterSustainKnob_CC = 255
    var filterReleaseKnob_CC = 255
    var filterADSRMixKnob_CC = 255
    
    // fxController
    var sampleRate_CC = 255
    var autoPanRate_CC = 255
    var reverbSize_CC = 255
    var reverbLowCut_CC = 255
    var reverbMix_CC = 255
    var delayTime_CC = 255
    var delayFeedback_CC = 255
    var delayMix_CC = 255
    var lfo1Amp_CC = 255
    var lfo2Amp_CC = 255
    var lfo1Rate_CC = 255
    var lfo2Rate_CC = 255
    var phaserMix_CC = 255
    var phaserRate_CC = 255
    var phaserFeedback_CC = 255
    var phaserNotchWidth_CC = 255
    
    // Keyboard
    var labelMode = 1
    var octaveRange = 2
    var darkMode = true
    var showKeyboard = 1.0 // 1 show, 0 hide
    
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
        backgroundAudioOn = dictionary["backgroundAudioOn"] as? Bool ?? backgroundAudioOn
        midiChannel = dictionary["midiChannel"] as? Int ?? midiChannel
        omniMode = dictionary["omniMode"] as? Bool ?? omniMode
        plotFilled =  dictionary["plotFilled"] as? Bool ?? plotFilled
        velocitySensitive =  dictionary["velocitySensitive"] as? Bool ?? velocitySensitive
        
        presetsVersion = dictionary["presetsVersion"] as? Double ?? presetsVersion
        banks = dictionary["banks"] as? [String] ?? banks
        
        masterVolume_CC = dictionary["masterVolume_CC"] as? Int ?? masterVolume_CC
        morph1Selector_CC = dictionary["morph1Selector_CC"] as? Int ?? morph1Selector_CC
        morph2Selector_CC = dictionary["morph2Selector_CC"] as? Int ?? morph2Selector_CC
        morph1SemitoneOffset_CC = dictionary["morph1SemitoneOffset_CC"] as? Int ?? morph1SemitoneOffset_CC
        morph2SemitoneOffset_CC = dictionary["morph2SemitoneOffset_CC"] as? Int ?? morph2SemitoneOffset_CC
        morph2Detuning_CC = dictionary["morph2Detuning_CC"] as? Int ?? morph2Detuning_CC
        morphBalance_CC = dictionary["morphBalance_CC"] as? Int ?? morphBalance_CC
        morph1Volume_CC = dictionary["morph1Volume_CC"] as? Int ?? morph1Volume_CC
        morph2Volume_CC = dictionary["morph2Volume_CC"] as? Int ?? morph2Volume_CC
        
        cutoff_CC = dictionary["cutoff_CC"] as? Int ?? cutoff_CC
        rez_CC = dictionary["rez_CC"] as? Int ?? rez_CC
        subVolume_CC = dictionary["subVolume_CC"] as? Int ?? subVolume_CC
        fmVolume_CC = dictionary["fmVolume_CC"] as? Int ?? fmVolume_CC
        noiseVolume_CC = dictionary["noiseVolume_CC"] as? Int ?? noiseVolume_CC
        glideKnob_CC = dictionary["glideKnob_CC"] as? Int ?? glideKnob_CC
        
        arpInterval_CC = dictionary["arpInterval_CC"] as? Int ?? arpInterval_CC
        
        attackKnob_CC = dictionary["attackKnob_CC"] as? Int ?? attackKnob_CC
        decayKnob_CC = dictionary["decayKnob_CC"] as? Int ?? decayKnob_CC
        sustainKnob_CC = dictionary["sustainKnob_CC"] as? Int ?? sustainKnob_CC
        releaseKnob_CC = dictionary["releaseKnob_CC"] as? Int ?? releaseKnob_CC
        filterAttackKnob_CC = dictionary["filterAttackKnob_CC"] as? Int ?? filterAttackKnob_CC
        filterDecayKnob_CC = dictionary["filterDecayKnob_CC"] as? Int ?? filterDecayKnob_CC
        filterSustainKnob_CC = dictionary["filterSustainKnob_CC"] as? Int ?? filterSustainKnob_CC
        filterReleaseKnob_CC = dictionary[" filterReleaseKnob_CC"] as? Int ?? filterReleaseKnob_CC
        filterADSRMixKnob_CC = dictionary[" filterADSRMixKnob_CC"] as? Int ?? filterADSRMixKnob_CC
        
        sampleRate_CC = dictionary["sampleRate_CC"] as? Int ?? sampleRate_CC
        delayTime_CC = dictionary["delayTime_CC"] as? Int ?? delayTime_CC
        delayFeedback_CC = dictionary["delayFeedback_CC"] as? Int ?? delayFeedback_CC
        delayMix_CC = dictionary["delayMix_CC"] as? Int ?? delayMix_CC
        lfo1Amp_CC = dictionary["lfo1Amp_CC"] as? Int ?? lfo1Amp_CC
        lfo2Amp_CC = dictionary["lfo2Amp_CC"] as? Int ?? lfo2Amp_CC
        lfo1Rate_CC = dictionary["lfo1Rate_CC"] as? Int ?? lfo1Rate_CC
        lfo2Rate_CC = dictionary["lfo2Rate_CC"] as? Int ?? lfo2Rate_CC
        phaserMix_CC = dictionary["phaserMix_CC"] as? Int ?? phaserMix_CC
        phaserRate_CC = dictionary["phaserRate_CC"] as? Int ?? phaserRate_CC
        phaserFeedback_CC = dictionary["phaserFeedback_CC"] as? Int ?? phaserFeedback_CC
        phaserNotchWidth_CC = dictionary["phaserNotchWidth_CC"] as? Int ?? phaserNotchWidth_CC
        reverbSize_CC = dictionary["reverbSize_CC"] as? Int ?? reverbSize_CC
        reverbLowCut_CC = dictionary["reverbLowCut_CC"] as? Int ?? reverbLowCut_CC
        reverbMix_CC = dictionary["reverbMix_CC"] as? Int ?? reverbMix_CC
        
        // Keyboard
        labelMode = dictionary["labelMode"] as? Int ?? labelMode
        octaveRange = dictionary["octaveRange"] as? Int ?? octaveRange
        darkMode = dictionary["darkMode"] as? Bool ?? darkMode
        showKeyboard = dictionary["showKeyboard"] as? Double ?? showKeyboard
        
        velocitySensitive = dictionary["velocitySensitive"] as? Bool ?? velocitySensitive
    }
    
}

