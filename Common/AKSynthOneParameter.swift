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
    autopanLFO = 59
    
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
//        default: return String(self.rawValue)
        }
    }
    
    public static func desc(forRawValue _rawValue: Int) -> String {
        var retVal : String = ""
        if let sd = AKSynthOneParameter(rawValue: _rawValue)?.simpleDescription() {
            retVal = sd
        }
        return retVal
    }
}

