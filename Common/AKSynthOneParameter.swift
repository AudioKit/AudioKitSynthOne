//
//  AKSynthOneParameter.swift
//  AudioKit
//
//  Created by Aurelius Prochazka on 7/23/17.
//  Copyright © 2017 AudioKit. All rights reserved.
//

/// Parameter lookup
public enum AKSynthOneParameter: Int {
    case index1 = 0,
    index2 = 1,
    morphBalance = 2,
    morph1SemitoneOffset = 3,
    morph2SemitoneOffset = 4,
    morph1Volume = 5,
    morph2Volume = 6,
    subVolume = 7,
    subOctaveDown = 8,
    subIsSquare = 9,
    fmVolume = 10,
    fmAmount = 11,
    noiseVolume = 12,
    lfo1Index = 13,
    lfo1Amplitude = 14,
    lfo1Rate = 15,
    cutoff = 16,
    resonance = 17,
    filterMix = 18,
    filterADSRMix = 19,
    isMono = 20,
    glide = 21,
    filterAttackDuration = 22,
    filterDecayDuration = 23,
    filterSustainLevel = 24,
    filterReleaseDuration = 25,
    attackDuration = 26,
    decayDuration = 27,
    sustainLevel = 28,
    releaseDuration = 29,
    morph2Detuning = 30,
    detuningMultiplier = 31,
    masterVolume = 32,
    bitCrushDepth = 33,
    bitCrushSampleRate = 34,
    autoPanOn = 35,
    autoPanFrequency = 36,
    reverbOn = 37,
    reverbFeedback = 38,
    reverbHighPass = 39,
    reverbMix = 40,
    delayOn = 41,
    delayFeedback = 42,
    delayTime = 43,
    delayMix = 44,
    lfo2Index = 45,
    lfo2Amplitude = 46,
    lfo2Rate = 47,
    cutoffLFO = 48,
    resonanceLFO = 49,
    oscMixLFO = 50,
    sustainLFO = 51,
    index1LFO = 52,
    index2LFO = 53,
    fmLFO = 54,
    detuneLFO = 55,
    filterEnvLFO = 56,
    pitchLFO = 57,
    bitcrushLFO = 58,
    autopanLFO = 59,
    arpDirection = 60,
    arpInterval = 61,
    arpIsOn = 62,
    arpOctave = 63,
    arpRate = 64,
    arpIsSequencer = 65,
    arpTotalSteps = 66,
    arpSeqPattern00 = 67, // arpSeqPattern* must be sequential 16 enums
    arpSeqPattern01 = 68,
    arpSeqPattern02 = 69,
    arpSeqPattern03 = 70,
    arpSeqPattern04 = 71,
    arpSeqPattern05 = 72,
    arpSeqPattern06 = 73,
    arpSeqPattern07 = 74,
    arpSeqPattern08 = 75,
    arpSeqPattern09 = 76,
    arpSeqPattern10 = 77,
    arpSeqPattern11 = 78,
    arpSeqPattern12 = 79,
    arpSeqPattern13 = 80,
    arpSeqPattern14 = 81,
    arpSeqPattern15 = 82,
    arpSeqOctBoost00 = 83,  // arpSeqOctBoost* must be sequential 16 enums
    arpSeqOctBoost01 = 84,
    arpSeqOctBoost02 = 85,
    arpSeqOctBoost03 = 86,
    arpSeqOctBoost04 = 87,
    arpSeqOctBoost05 = 88,
    arpSeqOctBoost06 = 89,
    arpSeqOctBoost07 = 90,
    arpSeqOctBoost08 = 91,
    arpSeqOctBoost09 = 92,
    arpSeqOctBoost10 = 93,
    arpSeqOctBoost11 = 94,
    arpSeqOctBoost12 = 95,
    arpSeqOctBoost13 = 96,
    arpSeqOctBoost14 = 97,
    arpSeqOctBoost15 = 98,
    arpSeqNoteOn00 = 99,   // arpSeqNoteOn* must be sequential 16 enums
    arpSeqNoteOn01 = 100,
    arpSeqNoteOn02 = 101,
    arpSeqNoteOn03 = 102,
    arpSeqNoteOn04 = 103,
    arpSeqNoteOn05 = 104,
    arpSeqNoteOn06 = 105,
    arpSeqNoteOn07 = 106,
    arpSeqNoteOn08 = 107,
    arpSeqNoteOn09 = 108,
    arpSeqNoteOn10 = 109,
    arpSeqNoteOn11 = 110,
    arpSeqNoteOn12 = 111,
    arpSeqNoteOn13 = 112,
    arpSeqNoteOn14 = 113,
    arpSeqNoteOn15 = 114,
    filterType = 115 // 0 = lowpass, 1 = bandpass, 2 = hipass

    
    public func simpleDescription() -> String {
        switch self {
        case .index1: return "index1"
        case .index2: return "index2"
        case .morphBalance: return "morphBalance"
        case .morph1SemitoneOffset: return "morph1SemitoneOffset"
        case .morph2SemitoneOffset: return "morph2SemitoneOffset"
        case .morph1Volume: return "morph1Volume"
        case .morph2Volume: return "morph2Volume"
        case .subVolume: return "subVolume"
        case .subOctaveDown: return "subOctaveDown"
        case .subIsSquare: return "subIsSquare"
        case .fmVolume: return "fmVolume"
        case .fmAmount: return "fmAmount"
        case .noiseVolume: return "noiseVolume"
        case .lfo1Index: return "lfo1Index"
        case .lfo1Amplitude: return "lfo1Amplitude"
        case .lfo1Rate: return "lfo1Rate"
        case .cutoff: return "cutoff"
        case .resonance: return "resonance"
        case .filterMix: return "filterMix"
        case .filterADSRMix: return "filterADSRMix"
        case .isMono: return "isMono"
        case .glide: return "glide"
        case .filterAttackDuration: return "filterAttackDuration"
        case .filterDecayDuration: return "filterDecayDuration"
        case .filterSustainLevel: return "filterSustainLevel"
        case .filterReleaseDuration: return "filterReleaseDuration"
        case .attackDuration: return "attackDuration"
        case .decayDuration: return "decayDuration"
        case .sustainLevel: return "sustainLevel"
        case .releaseDuration: return "releaseDuration"
        case .morph2Detuning: return "morph2Detuning"
        case .detuningMultiplier: return "detuningMultiplier"
        case .masterVolume: return "masterVolume"
        case .bitCrushDepth: return "bitCrushDepth"
        case .bitCrushSampleRate: return "bitCrushSampleRate"
        case .autoPanOn: return "autoPanOn"
        case .autoPanFrequency: return "autoPanFrequency"
        case .reverbOn: return "reverbOn"
        case .reverbFeedback: return "reverbFeedback"
        case .reverbHighPass: return "reverbHighPass"
        case .reverbMix: return "reverbMix"
        case .delayOn: return "delayOn"
        case .delayFeedback: return "delayFeedback"
        case .delayTime: return "delayTime"
        case .delayMix: return "delayMix"
        case .lfo2Index: return "lfo2Index"
        case .lfo2Amplitude: return "lfo2Amplitude"
        case .lfo2Rate: return "lfo2Rate"
        case .cutoffLFO: return "cutoffLFO"
        case .resonanceLFO: return "resonanceLFO"
        case .oscMixLFO: return "oscMixLFO"
        case .sustainLFO: return "sustainLFO"
        case .index1LFO: return "index1LFO"
        case .index2LFO: return "index2LFO"
        case .fmLFO: return "fmLFO"
        case .detuneLFO: return "detuneLFO"
        case .filterEnvLFO: return "filterEnvLFO"
        case .pitchLFO: return "pitchLFO"
        case .bitcrushLFO: return "bitcrushLFO"
        case .autopanLFO: return "autopanLFO"
        case .arpDirection: return "arpDirection"
        case .arpInterval: return "arpInterval"
        case .arpIsOn: return "arpIsOn"
        case .arpOctave: return "arpOctave"
        case .arpRate: return "arpRate"
        case .arpIsSequencer: return "arpIsSequencer"
        case .arpTotalSteps: return "arpTotalSteps"
        case .arpSeqPattern00: return "arpSeqPattern00"
        case .arpSeqPattern01: return "arpSeqPattern01"
        case .arpSeqPattern02: return "arpSeqPattern02"
        case .arpSeqPattern03: return "arpSeqPattern03"
        case .arpSeqPattern04: return "arpSeqPattern04"
        case .arpSeqPattern05: return "arpSeqPattern05"
        case .arpSeqPattern06: return "arpSeqPattern06"
        case .arpSeqPattern07: return "arpSeqPattern07"
        case .arpSeqPattern08: return "arpSeqPattern08"
        case .arpSeqPattern09: return "arpSeqPattern09"
        case .arpSeqPattern10: return "arpSeqPattern10"
        case .arpSeqPattern11: return "arpSeqPattern11"
        case .arpSeqPattern12: return "arpSeqPattern12"
        case .arpSeqPattern13: return "arpSeqPattern13"
        case .arpSeqPattern14: return "arpSeqPattern14"
        case .arpSeqPattern15: return "arpSeqPattern15"
        case .arpSeqOctBoost00: return "arpSeqOctBoost00"
        case .arpSeqOctBoost01: return "arpSeqOctBoost01"
        case .arpSeqOctBoost02: return "arpSeqOctBoost02"
        case .arpSeqOctBoost03: return "arpSeqOctBoost03"
        case .arpSeqOctBoost04: return "arpSeqOctBoost04"
        case .arpSeqOctBoost05: return "arpSeqOctBoost05"
        case .arpSeqOctBoost06: return "arpSeqOctBoost06"
        case .arpSeqOctBoost07: return "arpSeqOctBoost07"
        case .arpSeqOctBoost08: return "arpSeqOctBoost08"
        case .arpSeqOctBoost09: return "arpSeqOctBoost09"
        case .arpSeqOctBoost10: return "arpSeqOctBoost10"
        case .arpSeqOctBoost11: return "arpSeqOctBoost11"
        case .arpSeqOctBoost12: return "arpSeqOctBoost12"
        case .arpSeqOctBoost13: return "arpSeqOctBoost13"
        case .arpSeqOctBoost14: return "arpSeqOctBoost14"
        case .arpSeqOctBoost15: return "arpSeqOctBoost15"
        case .arpSeqNoteOn00: return "arpSeqNoteOn00"
        case .arpSeqNoteOn01: return "arpSeqNoteOn01"
        case .arpSeqNoteOn02: return "arpSeqNoteOn02"
        case .arpSeqNoteOn03: return "arpSeqNoteOn03"
        case .arpSeqNoteOn04: return "arpSeqNoteOn04"
        case .arpSeqNoteOn05: return "arpSeqNoteOn05"
        case .arpSeqNoteOn06: return "arpSeqNoteOn06"
        case .arpSeqNoteOn07: return "arpSeqNoteOn07"
        case .arpSeqNoteOn08: return "arpSeqNoteOn08"
        case .arpSeqNoteOn09: return "arpSeqNoteOn09"
        case .arpSeqNoteOn10: return "arpSeqNoteOn10"
        case .arpSeqNoteOn11: return "arpSeqNoteOn11"
        case .arpSeqNoteOn12: return "arpSeqNoteOn12"
        case .arpSeqNoteOn13: return "arpSeqNoteOn13"
        case .arpSeqNoteOn14: return "arpSeqNoteOn14"
        case .arpSeqNoteOn15: return "arpSeqNoteOn15"
        case .filterType: return "filterType"
        }
    }
    
    public static func desc(forRawValue _rawValue: Int) -> String {
        var retVal : String = ""
        if let sd = AKSynthOneParameter(rawValue: _rawValue)?.simpleDescription() {
            retVal = sd
        }
        return retVal
    }
    
    public static let count: Int = {
        var max: Int = 0
        while let _ = AKSynthOneParameter(rawValue: max) { max += 1 }
        return max
    }()

}

