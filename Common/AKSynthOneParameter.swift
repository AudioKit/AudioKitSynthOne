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
    cutoffLFO = 48
}

