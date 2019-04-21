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
                 "Francis Preve",
                 "JEC",
                 "Red Sky Lullaby",
                 "Sound of Izrael",
                 "Sound of Izrael 2",
                 "Starter Bank"]

// Do not rename any of these properties or you will break AppSettings read/write
class AppSettings: Codable {

    // MARK: - Settings

    var settingID = "main"
    var firstRun = true
    var isPreRelease = false
    var signedMailingList = false
    var backgroundAudio = false
    var neverSleep = false
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
    var bufferLengthRawValue = 9 // 512 // was 7 

    // This is musically useful when you:
    // 1) don't want a preset to have a specific tuning
    // 2) You want to hold the tuning constant while you browse presets.
    //
    //Settings: "Save Tuning Panel w/Presets" -> saveTuningWithPreset = True/False
    //True means: "DO load preset's tuning (nil = reset current tuning to 12et) when preset is loaded.
    //DO save current tuning (12et = nil) when preset is saved"
    //False means: "DO NOT load preset's tuning when preset is loaded.  DO NOT save current tuning when preset is saved"
    var saveTuningWithPreset = true

    // When false will launch in 12ET; when true in the last-used tuning
    var launchWithLastTuning = false

    var pushNotifications = false
    var userEmail = ""
    var launches = 0

    // Presets version
    var presetsVersion = 1.28

    // Keyboard
    var labelMode = 1
    var octaveRange = 2
    var darkMode = false
    var showKeyboard = 1.0 // 1 show, 0 hide
    var whiteKeysOnly = false

    // Save State
    var currentBankIndex = 0
    var currentPresetIndex = 0
    var currentTuningBankIndex = Tunings.bundleBankIndex

    // MARK: - MIDI Learn Settings

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
    var sequencerToggleCC = 255
    var arpIntervalCC = 255
    var arpToggleCC = 255
    var octaveStepperCC = 255
    var arpDirectionButtonCC = 255
    var seqStepsStepperCC = 255
    var arpSeqTempoMultiplierCC = 255
    var transposeStepperCC = 255 // on keyboard but I'm grouping with arp/seq

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
    var adsrPitchTrackingKnobCC = 255

    // fxController
    var sampleRateCC = 255
    var autoPanRateCC = 255
    var autoPanAmountCC = 255
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
    var holdButtonCC = 255
    var monoButtonCC = 255

    // MARK: - Init

    init() { }

    // MARK: - INIT: JSON Parsing into object

    /// Initialization from Dictionary/JSON
    init(dictionary: [String: Any]) {
        settingID = dictionary["settingID"] as? String ?? settingID
        launches = dictionary["launches"] as? Int ?? launches
        firstRun = dictionary["firstRun"] as? Bool ?? firstRun
        isPreRelease = dictionary["isPreRelease"] as? Bool ?? isPreRelease
        signedMailingList = dictionary["signedMailingList"] as? Bool ?? signedMailingList
        backgroundAudio = dictionary["backgroundAudio"] as? Bool ?? backgroundAudio
        neverSleep = dictionary["neverSleep"] as? Bool ?? neverSleep
        midiChannel = dictionary["midiChannel"] as? Int ?? midiChannel
        omniMode = dictionary["omniMode"] as? Bool ?? omniMode
        bufferLengthRawValue = dictionary["bufferLengthRawValue"] as? Int ?? bufferLengthRawValue
        midiSources = dictionary["midiSources"] as? [String] ?? midiSources
        plotFilled = dictionary["plotFilled"] as? Bool ?? plotFilled
        velocitySensitive = dictionary["velocitySensitive"] as? Bool ?? velocitySensitive
        presetsVersion = dictionary["presetsVersion"] as? Double ?? presetsVersion
        saveTuningWithPreset = dictionary["saveTuningWithPreset"] as? Bool ?? saveTuningWithPreset
        launchWithLastTuning = dictionary["launchWithLastTuning"] as? Bool ?? launchWithLastTuning

        // HAQ Panel
        freezeArpRate = dictionary["freezeArpRate"] as? Bool ?? freezeArpRate
        freezeDelay = dictionary["freezeDelay"] as? Bool ?? freezeDelay
        freezeReverb = dictionary["freezeReverb"] as? Bool ?? freezeReverb
        freezeArpSeq = dictionary["freezeArpSeq"] as? Bool ?? freezeArpSeq
        whiteKeysOnly = dictionary["whiteKeysOnly"] as? Bool ?? whiteKeysOnly

        // KEYBOARD
        labelMode = dictionary["labelMode"] as? Int ?? labelMode
        octaveRange = dictionary["octaveRange"] as? Int ?? octaveRange
        darkMode = dictionary["darkMode"] as? Bool ?? darkMode
        showKeyboard = dictionary["showKeyboard"] as? Double ?? showKeyboard

        // PRESET STATE
        currentBankIndex = dictionary["currentBankIndex"] as? Int ?? currentBankIndex
        currentPresetIndex = dictionary["currentPresetIndex"] as? Int ?? currentPresetIndex
        currentTuningBankIndex = dictionary["currentTuningBankIndex"] as? Int ?? currentTuningBankIndex

        // MIDI Learn GENERATOR
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
        fmAmountCC = dictionary["fmAmountCC"] as? Int ?? fmAmountCC 
        noiseVolumeCC = dictionary["noiseVolumeCC"] as? Int ?? noiseVolumeCC
        glideKnobCC = dictionary["glideKnobCC"] as? Int ?? glideKnobCC

        // MIDI Learn ARP/SEQ
        sequencerToggleCC = dictionary["sequencerToggleCC"] as? Int ?? sequencerToggleCC
        arpIntervalCC = dictionary["arpIntervalCC"] as? Int ?? arpIntervalCC
        arpToggleCC = dictionary["arpToggleCC"] as? Int ?? arpToggleCC
        octaveStepperCC = dictionary["octaveStepperCC"] as? Int ?? octaveStepperCC
        arpDirectionButtonCC = dictionary["arpDirectionButtonCC"] as? Int ?? arpDirectionButtonCC
        seqStepsStepperCC = dictionary["seqStepsStepperCC"] as? Int ?? seqStepsStepperCC
        arpSeqTempoMultiplierCC = dictionary["arpSeqTempoMultiplierCC"] as? Int ?? arpSeqTempoMultiplierCC

        // MIDI Learn ADSR
        attackKnobCC = dictionary["attackKnobCC"] as? Int ?? attackKnobCC
        decayKnobCC = dictionary["decayKnobCC"] as? Int ?? decayKnobCC
        sustainKnobCC = dictionary["sustainKnobCC"] as? Int ?? sustainKnobCC
        releaseKnobCC = dictionary["releaseKnobCC"] as? Int ?? releaseKnobCC
        filterAttackKnobCC = dictionary["filterAttackKnobCC"] as? Int ?? filterAttackKnobCC
        filterDecayKnobCC = dictionary["filterDecayKnobCC"] as? Int ?? filterDecayKnobCC
        filterSustainKnobCC = dictionary["filterSustainKnobCC"] as? Int ?? filterSustainKnobCC
        filterReleaseKnobCC = dictionary["filterReleaseKnobCC"] as? Int ?? filterReleaseKnobCC
        filterADSRMixKnobCC = dictionary["filterADSRMixKnobCC"] as? Int ?? filterADSRMixKnobCC
        adsrPitchTrackingKnobCC = dictionary["adsrPitchTrackingKnobCC"] as? Int ?? adsrPitchTrackingKnobCC

        // MIDI Learn EFX
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
        autoPanRateCC = dictionary["autoPanRateCC"] as? Int ?? autoPanRateCC
        autoPanAmountCC = dictionary["autoPanAmountCC"] as? Int ?? autoPanAmountCC

        // MIDI Learn Keyboard
        transposeStepperCC = dictionary["transposeStepperCC"] as? Int ?? transposeStepperCC
        holdButtonCC = dictionary["holdButtonCC"] as? Int ?? holdButtonCC
        monoButtonCC = dictionary["monoButtonCC"] as? Int ?? monoButtonCC
    }
}
