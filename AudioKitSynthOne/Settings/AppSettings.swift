//
//  AppSettings.swift
//  AudioKitSynthOne
//
//  Created by AudioKit Contributors on 10/31/17.
//  Copyright © 2018 AudioKit. All rights reserved.
//

import Foundation

let initBanks = ["BankA",
                 "User",
                 "Brice Beasley",
                 "DJ Puzzle",
                 "Electronisounds",
                 "JEC",
                 "Red Sky Lullaby",
                 "Sound of Izrael",
                 "Starter Bank"]

class AppSettings: Codable {

    var settingID = "main"
    var firstRun = true
    var isPreRelease = false
    var signedMailingList = false
    var backgroundAudio = false
    var midiChannel = 0
    var midiSources = ["AudioKit Synth One"]
    var omniMode = true
    var plotFilled = true
    var velocitySensitive = false
    var freezeArpRate = false // true = don't modify when preset changes
    var freezeDelay = false // true = don't modify current delay parameters when preset changes
    var freezeReverb = false // true = don't modify current reverb parameters when preset changes
    var freezeArpSeq = false // true = don't modify current arp+seq parameters when preset changes
    var portamentoHalfTime = 0.1 // global portamento HALFTIME for dsp params that are smoothed

    //Settings: "Save Tuning Panel w/Presets" -> saveTuningWithPreset = True/False
    //True means: "DO load preset's tuning (nil = reset current tuning to 12et) when preset is loaded.
    //DO save current tuning (12et = nil) when preset is saved"
    //False means: "DO NOT load preset's tuning when preset is loaded.  DO NOT save current tuning when preset is saved"
    var saveTuningWithPreset = true
    var pushNotifications = false
    var userEmail = ""
    var launches = 0

    // Presets version
    var presetsVersion = 1.22

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
    var resonanceCC = 71 // 71: MIDI Standard CC for filter res
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

    // Save State
    var currentBankIndex = 0
    var currentPresetIndex = 0

    init() {
    }

    // MARK: - JSON Parsing into object

    /// Initialization from Dictionary/JSON
    init(dictionary: [String: Any]) {
        settingID = dictionary["settingID"] as? String ?? settingID
        launches = dictionary["launches"] as? Int ?? launches
        firstRun = dictionary["firstRun"] as? Bool ?? firstRun
        isPreRelease = dictionary["isPreRelease"] as? Bool ?? isPreRelease
        signedMailingList = dictionary["signedMailingList"] as? Bool ?? signedMailingList
        backgroundAudio = dictionary["backgroundAudio"] as? Bool ?? backgroundAudio
        midiChannel = dictionary["midiChannel"] as? Int ?? midiChannel
        omniMode = dictionary["omniMode"] as? Bool ?? omniMode
        midiSources = dictionary["midiSources"] as? [String] ?? midiSources
        plotFilled = dictionary["plotFilled"] as? Bool ?? plotFilled
        velocitySensitive = dictionary["velocitySensitive"] as? Bool ?? velocitySensitive
        freezeArpRate = dictionary["freezeArpRate"] as? Bool ?? freezeArpRate
        freezeDelay = dictionary["freezeDelay"] as? Bool ?? freezeDelay
        freezeReverb = dictionary["freezeReverb"] as? Bool ?? freezeReverb
        freezeArpSeq = dictionary["freezeArpSeq"] as? Bool ?? freezeArpSeq
        saveTuningWithPreset = dictionary["saveTuningWithPreset"] as? Bool ?? saveTuningWithPreset
        presetsVersion = dictionary["presetsVersion"] as? Double ?? presetsVersion

        masterVolumeCC = dictionary["masterVolumeCC"] as? Int ?? masterVolumeCC
        morph1SelectorCC = dictionary["morph1SelectorCC"] as? Int ?? morph1SelectorCC
        morph2SelectorCC = dictionary["morph2SelectorCC"] as? Int ?? morph2SelectorCC
        morph1SemitoneOffsetCC = dictionary["morph1SemitoneOffsetCC"] as? Int ?? morph1SemitoneOffsetCC
        morph2SemitoneOffsetCC = dictionary["morph2SemitoneOffsetCC"] as? Int ?? morph2SemitoneOffsetCC
        morph2DetuningCC = dictionary["morph2DetuningCC"] as? Int ?? morph2DetuningCC
        morphBalanceCC = dictionary["morphBalanceCC"] as? Int ?? morphBalanceCC
        morph1VolumeCC = dictionary["morph1VolumeCC"] as? Int ?? morph1VolumeCC
        morph2VolumeCC = dictionary["morph2VolumeCC"] as? Int ?? morph2VolumeCC

        cutoffCC = dictionary["cutoffCC"] as? Int ?? cutoffCC
        resonanceCC = dictionary["resonanceCC"] as? Int ?? resonanceCC
        subVolumeCC = dictionary["subVolumeCC"] as? Int ?? subVolumeCC
        fmVolumeCC = dictionary["fmVolumeCC"] as? Int ?? fmVolumeCC
        noiseVolumeCC = dictionary["noiseVolumeCC"] as? Int ?? noiseVolumeCC
        glideKnobCC = dictionary["glideKnobCC"] as? Int ?? glideKnobCC

        arpIntervalCC = dictionary["arpIntervalCC"] as? Int ?? arpIntervalCC

        attackKnobCC = dictionary["attackKnobCC"] as? Int ?? attackKnobCC
        decayKnobCC = dictionary["decayKnobCC"] as? Int ?? decayKnobCC
        sustainKnobCC = dictionary["sustainKnobCC"] as? Int ?? sustainKnobCC
        releaseKnobCC = dictionary["releaseKnobCC"] as? Int ?? releaseKnobCC
        filterAttackKnobCC = dictionary["filterAttackKnobCC"] as? Int ?? filterAttackKnobCC
        filterDecayKnobCC = dictionary["filterDecayKnobCC"] as? Int ?? filterDecayKnobCC
        filterSustainKnobCC = dictionary["filterSustainKnobCC"] as? Int ?? filterSustainKnobCC
        filterReleaseKnobCC = dictionary[" filterReleaseKnobCC"] as? Int ?? filterReleaseKnobCC
        filterADSRMixKnobCC = dictionary[" filterADSRMixKnobCC"] as? Int ?? filterADSRMixKnobCC

        sampleRateCC = dictionary["sampleRateCC"] as? Int ?? sampleRateCC
        delayTimeCC = dictionary["delayTimeCC"] as? Int ?? delayTimeCC
        delayFeedbackCC = dictionary["delayFeedbackCC"] as? Int ?? delayFeedbackCC
        delayMixCC = dictionary["delayMixCC"] as? Int ?? delayMixCC
        lfo1AmpCC = dictionary["lfo1AmpCC"] as? Int ?? lfo1AmpCC
        lfo2AmpCC = dictionary["lfo2AmpCC"] as? Int ?? lfo2AmpCC
        lfo1RateCC = dictionary["lfo1RateCC"] as? Int ?? lfo1RateCC
        lfo2RateCC = dictionary["lfo2RateCC"] as? Int ?? lfo2RateCC
        phaserMixCC = dictionary["phaserMixCC"] as? Int ?? phaserMixCC
        phaserRateCC = dictionary["phaserRateCC"] as? Int ?? phaserRateCC
        phaserFeedbackCC = dictionary["phaserFeedbackCC"] as? Int ?? phaserFeedbackCC
        phaserNotchWidthCC = dictionary["phaserNotchWidthCC"] as? Int ?? phaserNotchWidthCC
        reverbSizeCC = dictionary["reverbSizeCC"] as? Int ?? reverbSizeCC
        reverbLowCutCC = dictionary["reverbLowCutCC"] as? Int ?? reverbLowCutCC
        reverbMixCC = dictionary["reverbMixCC"] as? Int ?? reverbMixCC

        // Keyboard
        labelMode = dictionary["labelMode"] as? Int ?? labelMode
        octaveRange = dictionary["octaveRange"] as? Int ?? octaveRange
        darkMode = dictionary["darkMode"] as? Bool ?? darkMode
        showKeyboard = dictionary["showKeyboard"] as? Double ?? showKeyboard

        // State
        currentBankIndex = dictionary["currentBankIndex"] as? Int ?? currentBankIndex
        currentPresetIndex = dictionary["currentPresetIndex"] as? Int ?? currentPresetIndex

        velocitySensitive = dictionary["velocitySensitive"] as? Bool ?? velocitySensitive
    }
}
