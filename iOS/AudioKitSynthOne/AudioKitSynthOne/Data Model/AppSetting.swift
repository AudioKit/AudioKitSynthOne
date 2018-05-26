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

let initBanks = ["BankA", "User", "Brice Beasley", "DJ Puzzle", "Red Sky Lullaby"]

class AppSetting: Codable {

    var settingID = "main"
    var firstRun = true
    var isPreRelease = true
    var signedMailingList = true
    var backgroundAudioOn = true
    var midiChannel = 0
    var omniMode = true
    var plotFilled = true
    var velocitySensitive = false
    var freezeArpRate = false // true = don't modify when preset changes
    var freezeDelay = false // true = don't modify when preset changes
    var freezeReverb = false // true = don't modify when preset changes
    var dspParamPortamentoHalfTime = 0.1

    var saveTuningWithPreset = false
    var pushNotifications = true
    var userEmail = ""
    var launches = 0

    // Presets version
    var presetsVersion = 1.08

    // MIDI Learn Settings

    // mixer controller
    var masterVolumeCC = 255
    var morph1SelectorCC = 255
    var morph2SelectorCC = 255
    var morph1SemitoneOffsetCC = 255
    var morph2SemitoneOffsetCC = 255
    var morph2DetuningCC = 255
    var morphBalanceCC = 255
    var morph1VolumeCC = 255
    var morph2VolumeCC = 255
    var cutoffCC = 74 // 74: MIDI Standard CC for filter cutoff
    var rezCC = 71 // 71: MIDI Standard CC for filter res
    var subVolumeCC = 255
    var fmVolumeCC = 255
    var fmAmountCC = 255
    var noiseVolumeCC = 255
    var glideKnobCC = 255

    // seq controller
    var arpIntervalCC = 255

    // adsr
    var attackKnobCC = 255
    var decayKnobCC = 255
    var sustainKnobCC = 255
    var releaseKnobCC = 255
    var filterAttackKnobCC = 255
    var filterDecayKnobCC = 255
    var filterSustainKnobCC = 255
    var filterReleaseKnobCC = 255
    var filterADSRMixKnobCC = 255

    // fxController
    var sampleRateCC = 255
    var autoPanRateCC = 255
    var reverbSizeCC = 255
    var reverbLowCutCC = 255
    var reverbMixCC = 255
    var delayTimeCC = 255
    var delayFeedbackCC = 255
    var delayMixCC = 255
    var lfo1AmpCC = 255
    var lfo2AmpCC = 255
    var lfo1RateCC = 255
    var lfo2RateCC = 255
    var phaserMixCC = 255
    var phaserRateCC = 255
    var phaserFeedbackCC = 255
    var phaserNotchWidthCC = 255

    // Keyboard
    var labelMode = 1
    var octaveRange = 2
    var darkMode = false
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
        plotFilled = dictionary["plotFilled"] as? Bool ?? plotFilled
        velocitySensitive = dictionary["velocitySensitive"] as? Bool ?? velocitySensitive
        freezeArpRate = dictionary["freezeArpRate"] as? Bool ?? freezeArpRate
        freezeDelay = dictionary["freezeDelay"] as? Bool ?? freezeDelay
        freezeReverb = dictionary["freezeReverb"] as? Bool ?? freezeReverb
        saveTuningWithPreset = dictionary["saveTuningWithPreset"] as? Bool ?? saveTuningWithPreset
        presetsVersion = dictionary["presetsVersion"] as? Double ?? presetsVersion
        dspParamPortamentoHalfTime = dictionary["dspParamPortamentoHalfTime"] as? Double ?? dspParamPortamentoHalfTime
        
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
