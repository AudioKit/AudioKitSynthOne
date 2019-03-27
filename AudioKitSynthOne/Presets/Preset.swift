//
//  Preset.swift
//  AudioKitSynthOne
//
//  Created by AudioKit Contributors on 7/23/16.
//  Copyright © 2016 AudioKit. All rights reserved.
//

import Foundation
import AudioKit

// MARK: - Preset

class Preset: Codable {

    // You MUST match these property names with the dictionary key used by init (below)
    // or you will forever lose the original preset.

    var uid = UUID().uuidString
    var position = 0 // Preset #
    var name = "Init"
    var bank = "User"

    // Synth VC
    var octavePosition = 0
    var isMono = 0.0
    var isHoldMode = 0.0
    var isArpMode = 0.0
    var isLegato = 0.0
    var tempoSyncToArpRate = 1.0

    // Controls VC
    var masterVolume = 0.5 // Master Volume

    var vco1Volume = 0.75
    var vco2Volume = 0.75
    var vco1Semitone = 0.0 // VCO1 Semitones
    var vco2Semitone = 0.0 // VCO2 Semitones
    var vco2Detuning = 0.0 // VCO2 Detune (Hz)
    var vcoBalance = 0.0 // VCO1/VCO2 Mix
    var subVolume = 0.0 // SubOsc Mix
    var fmVolume = 0.0 // FM Mix
    var fmAmount = 0.0 // FM Modulation
    var noiseVolume = 0.0 // Noise Mix

    var cutoff = 4_000.0 // Cutoff Knob Position
    var resonance = 0.1 // Filter Q/Rez
    var filterType = 0.0 // 0 = lopass, 1=bandpass, 2=hipassh.s
    var delayTime = 0.5 // Delay (seconds)
    var delayMix = 0.5 // Dry/Wet
    var delayFeedback = 0.1
    var reverbFeedback = 0.5 // Amt
    var reverbMix = 0.5 // Dry/Wet
    var reverbHighPass = 80.0 // Highpass filter freq for Filter
    var midiBendRange = 2.0 // MIDI bend range in +/- semitones
    var crushFreq = 48_000.0 // Crusher Frequency
    var autoPanAmount = 0.0
    var autoPanFrequency = 2.0 // AutoPan Rate
    var filterADSRMix = 0.0 // Filter Envelope depth
    var glide = 0.0 // Mono glide amount
    var widen = 0.0
    var phaserMix = 0.0
    var phaserRate = 12.0
    var phaserFeedback = 0.0
    var phaserNotchWidth = 800.00

    // ADSR
    var attackDuration = 0.05
    var decayDuration = 0.05
    var sustainLevel = 0.8
    var releaseDuration = 0.05

    var filterAttack = 0.05
    var filterDecay = 0.5
    var filterSustain = 1.0
    var filterRelease = 0.5

    // Toggle Presets
    var delayToggled = 0.0
    var reverbToggled = 0.0
    var subOsc24Toggled = 0.0
    var subOscSquareToggled = 0.0

    // Waveforms
    var waveform1 = 0.0
    var waveform2 = 0.0

    var lfoWaveform = 0.0 // LFO wave index
    var lfoAmplitude = 0.0 // LFO Amp (Hz)
    var lfoRate = 0.0 // LFO Rate
    var lfo2Waveform = 0.0
    var lfo2Amplitude = 0.0
    var lfo2Rate = 0.0

    // Seq Pattern
    var seqPatternNote = Array(repeating: 0, count: 16)
    var seqOctBoost = Array(repeating: false, count: 16)
    var seqNoteOn = Array(repeating: true, count: 16)

    // Arp
    var arpDirection = 0.0
    var arpInterval = 12.0
    var arpOctave = 1.0
    var arpRate = 120.0
    var arpIsSequencer = false
    var arpTotalSteps = 8.0
    var arpSeqTempoMultiplier = 0.25
    var transpose = 0
    var adsrPitchTracking = 0.0

    // Author
    var author = ""
    var category = 0
    var isUser = true
    var isFavorite = false
    var userText = "AudioKit Synth One. Preset by ..."

    // LFO Routings
    var cutoffLFO = 0.0
    var resonanceLFO = 0.0
    var oscMixLFO = 0.0
    var reverbMixLFO = 0.0
    var decayLFO = 0.0
    var noiseLFO = 0.0
    var fmLFO = 0.0
    var detuneLFO = 0.0
    var filterEnvLFO = 0.0
    var pitchLFO = 0.0
    var bitcrushLFO = 0.0
    var tremoloLFO = 0.0

    // MOD Wheel Routings
    var modWheelRouting = 0.0

    // Pitchbend
    var pitchbendMinSemitones = 0.0
    var pitchbendMaxSemitones = 0.0

    // REVERB/MASTER DYNAMICS
    var compressorMasterRatio = 0.0
    var compressorReverbInputRatio = 0.0
    var compressorReverbWetRatio = 0.0
    var compressorMasterThreshold = 0.0
    var compressorReverbInputThreshold = 0.0
    var compressorReverbWetThreshold = 0.0
    var compressorMasterAttack = 0.0
    var compressorReverbInputAttack = 0.0
    var compressorReverbWetAttack = 0.0
    var compressorMasterRelease = 0.0
    var compressorReverbInputRelease = 0.0
    var compressorReverbWetRelease = 0.0
    var compressorMasterMakeupGain = 0.0
    var compressorReverbInputMakeupGain = 0.0
    var compressorReverbWetMakeupGain = 0.0
    var delayInputCutoffTrackingRatio = 0.75
    var delayInputResonance = 0.0

    // bandlimiting
    var oscBandlimitEnable = 1.0

    // tuning
    var frequencyA4 = 440.0
    var tuningName: String?
    var tuningMasterSet: [Double]?

        // MARK: - Init

    init() {}

    convenience init(position: Int) {
        self.init()

        // Preset Number/Position
        self.position = position
    }

    // MARK: - Class Function to Return array of Presets

    // Return Array of Presets
    class public func parseDataToPresets(jsonArray: [Any]) -> [Preset] {
        var presets = [Preset]()
        for presetJSON in jsonArray {
            if let presetDictionary = presetJSON as? [String: Any] {
                let retrievedPreset = Preset(dictionary: presetDictionary)
                presets.append(retrievedPreset)
            }
        }
        return presets
    }

    // Return Single Preset
    class public func parseDataToPreset(presetJSON: Any) -> Preset {
        if let presetDictionary = presetJSON as? [String: Any] {
            return Preset(dictionary: presetDictionary)
        }
        return Preset()
    }

    // MARK: - JSON Parsing into object

    // Init from Dictionary/JSON
    // You MUST match the property name with the dictionary key or you will forever lose the original preset.

    init(dictionary: [String: Any]) {

        guard let s = Conductor.sharedInstance.synth else {
            print("ERROR: can't initialize preset until synth is initialized")
            return
        }

        let p = { parameter in
            return Double(s.getDefault(parameter))
        }

        name = dictionary["name"] as? String ?? name
        position = dictionary["position"] as? Int ?? position
        uid = dictionary["uid"] as? String ?? uid
        bank = dictionary["bank"] as? String ?? bank

        // Synth VC
        octavePosition = dictionary["octavePosition"] as? Int ?? octavePosition
        isMono = dictionary["isMono"] as? Double ?? p(.isMono)
        isHoldMode = dictionary["isHoldMode"] as? Double ?? isHoldMode
        isArpMode = dictionary["isArpMode"] as? Double ?? p(.arpIsOn)
        tempoSyncToArpRate = dictionary["tempoSyncToArpRate"] as? Double ?? p(.tempoSyncToArpRate)
        isLegato = dictionary["isLegato"] as? Double ?? p(.monoIsLegato)

        // Controls VC
        masterVolume = dictionary["masterVolume"] as? Double ?? p(.masterVolume)

        vco1Volume = dictionary["vco1Volume"] as? Double ?? p(.morph1Volume)
        vco2Volume = dictionary["vco2Volume"] as? Double ?? p(.morph2Volume)
        vco1Semitone = dictionary["vco1Semitone"] as? Double ?? p(.morph1SemitoneOffset)
        vco2Semitone = dictionary["vco2Semitone"] as? Double ?? p(.morph2SemitoneOffset)
        vco2Detuning = dictionary["vco2Detuning"] as? Double ?? p(.morph2Detuning)
        vcoBalance = dictionary["vcoBalance"] as? Double ?? p(.morphBalance)
        subVolume = dictionary["subVolume"] as? Double ?? p(.subVolume)
        fmVolume = dictionary["fmVolume"] as? Double ?? p(.fmVolume)
        fmAmount = dictionary["fmAmount"] as? Double ?? p(.fmAmount)
        noiseVolume = dictionary["noiseVolume"] as? Double ?? p(.noiseVolume)

        cutoff = dictionary["cutoff"] as? Double ?? p(.cutoff)
        resonance = dictionary["resonance"] as? Double ?? p(.resonance)
        filterType = dictionary["filterType"] as? Double ?? p(.filterType)
        delayTime = dictionary["delayTime"] as? Double ?? p(.delayTime)
        delayFeedback = dictionary["delayFeedback"] as? Double ?? p(.delayFeedback)
        delayMix = dictionary["delayMix"] as? Double ?? p(.delayMix)
        reverbFeedback = dictionary["reverbFeedback"] as? Double ?? p(.reverbFeedback)
        reverbMix = dictionary["reverbMix"] as? Double ?? p(.reverbMix)
        reverbHighPass = dictionary["reverbHighPass"] as? Double ?? p(.reverbHighPass)

        midiBendRange = dictionary["midiBendRange"] as? Double ?? midiBendRange // unused

        crushFreq = dictionary["crushFreq"] as? Double ?? p(.bitCrushSampleRate)
        autoPanFrequency = dictionary["autoPanFrequency"] as? Double ?? p(.autoPanFrequency)
        filterADSRMix = dictionary["filterADSRMix"] as? Double ?? p(.filterADSRMix)
        glide = dictionary["glide"] as? Double ?? p(.glide)
        widen = dictionary["widen"] as? Double ?? p(.widen)

        // ADSR
        attackDuration = dictionary["attackDuration"] as? Double ?? p(.attackDuration)
        decayDuration = dictionary["decayDuration"] as? Double ?? p(.decayDuration)
        sustainLevel = dictionary["sustainLevel"] as? Double ?? p(.sustainLevel)
        releaseDuration = dictionary["releaseDuration"] as? Double ?? p(.releaseDuration)

        filterAttack = dictionary["filterAttack"] as? Double ?? p(.filterAttackDuration)
        filterDecay = dictionary["filterDecay"] as? Double ?? p(.filterDecayDuration)
        filterSustain = dictionary["filterSustain"] as? Double ?? p(.filterSustainLevel)
        filterRelease = dictionary["filterRelease"] as? Double ?? p(.filterReleaseDuration)

        // Toggle Presets
        delayToggled = dictionary["delayToggled"] as? Double ?? p(.delayOn)
        reverbToggled = dictionary["reverbToggled"] as? Double ?? p(.reverbOn)
        autoPanAmount = dictionary["autoPanAmount"] as? Double ?? p(.autoPanAmount)
        subOsc24Toggled = dictionary["subOsc24Toggled"] as? Double ?? p(.subOctaveDown)
        subOscSquareToggled = dictionary["subOscSquareToggled"] as? Double ?? p(.subIsSquare)

        // Waveforms
        waveform1 = dictionary["waveform1"] as? Double ?? p(.index1)
        waveform2 = dictionary["waveform2"] as? Double ?? p(.index2)
        lfoWaveform = dictionary["lfoWaveform"] as? Double ?? p(.lfo1Index)
        lfoAmplitude = dictionary["lfoAmplitude"] as? Double ?? p(.lfo1Amplitude)
        lfoRate = dictionary["lfoRate"] as? Double ?? p(.lfo1Rate)
        lfo2Waveform = dictionary["lfo2Waveform"] as? Double ?? p(.lfo2Index)
        lfo2Amplitude = dictionary["lfo2Amplitude"] as? Double ?? p(.lfo2Amplitude)
        lfo2Rate = dictionary["lfo2Rate"] as? Double ?? p(.lfo2Rate)

        // Seq
        var seqPatternNoteDefault = [Int]()
        var seqNoteOnDefault = [Bool]()
        var seqOctBoostDefault = [Bool]()
        for i in 0..<16 {
            seqPatternNoteDefault.append(s.getPattern(forIndex: i))
            seqNoteOnDefault.append(s.isNoteOn(forIndex: i))
            seqOctBoostDefault.append(s.getOctaveBoost(forIndex: i))
        }
        seqPatternNote = dictionary["seqPatternNote"] as? [Int] ?? seqPatternNoteDefault
        seqNoteOn = dictionary["seqNoteOn"] as? [Bool] ?? seqNoteOnDefault
        seqOctBoost = dictionary["seqOctBoost"] as? [Bool] ?? seqOctBoostDefault

        // Arp
        arpDirection = dictionary["arpDirection"] as? Double ?? p(.arpDirection)
        arpInterval = dictionary["arpInterval"] as? Double ?? p(.arpInterval)
        arpOctave = dictionary["arpOctave"] as? Double ?? p(.arpOctave)
        arpRate = dictionary["arpRate"] as? Double ?? p(.arpRate)
        arpIsSequencer = dictionary["arpIsSequencer"] as? Bool ?? Bool(p(.arpIsSequencer) > 0 ? true : false)
        arpTotalSteps = dictionary["arpTotalSteps"] as? Double ?? p(.arpTotalSteps)
        arpSeqTempoMultiplier = dictionary["arpSeqTempoMultiplier"] as? Double ?? p(.arpSeqTempoMultiplier)
        transpose = dictionary["transpose"] as? Int ?? Int(p(.transpose))
        adsrPitchTracking = dictionary["adsrPitchTracking"] as? Double ?? p(.adsrPitchTracking)
        
        author = dictionary["author"] as? String ?? author
        category = dictionary["category"] as? Int ?? category
        isUser = dictionary["isUser"] as? Bool ?? isUser
        isFavorite = dictionary["isFavorite"] as? Bool ?? isFavorite
        userText = dictionary["userText"] as? String ?? userText

        // LFO Routings
        cutoffLFO = dictionary["cutoffLFO"] as? Double ?? p(.cutoffLFO)
        resonanceLFO = dictionary["resonanceLFO"] as? Double ?? p(.resonanceLFO)
        oscMixLFO = dictionary["oscMixLFO"] as? Double ?? p(.oscMixLFO)
        reverbMixLFO = dictionary["reverbMixLFO"] as? Double ?? p(.reverbMixLFO)
        decayLFO = dictionary["decayLFO"] as? Double ?? p(.decayLFO)
        noiseLFO = dictionary["noiseLFO"] as? Double ?? p(.noiseLFO)
        fmLFO = dictionary["fmLFO"] as? Double ?? p(.fmLFO)
        detuneLFO = dictionary["detuneLFO"] as? Double ?? p(.detuneLFO)
        filterEnvLFO = dictionary["filterEnvLFO"] as? Double ?? p(.filterEnvLFO)
        pitchLFO = dictionary["pitchLFO"] as? Double ?? p(.pitchLFO)
        bitcrushLFO = dictionary["bitcrushLFO"] as? Double ?? p(.bitcrushLFO)
        tremoloLFO = dictionary["tremoloLFO"] as? Double ?? p(.tremoloLFO)

        // MOD WHeel
        modWheelRouting = dictionary["modWheelRouting"] as? Double ?? modWheelRouting

        // Pitchbend
        pitchbendMaxSemitones = dictionary["pitchbendMaxSemitones"] as? Double ?? p(.pitchbendMaxSemitones)
        pitchbendMinSemitones = dictionary["pitchbendMinSemitones"] as? Double ?? p(.pitchbendMinSemitones)

        // FX
        phaserFeedback = dictionary["phaserFeedback"] as? Double ?? p(.phaserFeedback)
        phaserMix = dictionary["phaserMix"] as? Double ?? p(.phaserMix)
        phaserRate = dictionary["phaserRate"] as? Double ?? p(.phaserRate)
        phaserNotchWidth = dictionary["phaserNotchWidth"] as? Double ?? p(.phaserNotchWidth)

        // REVERB/MASTER DYNAMICS
        compressorMasterRatio = dictionary["compressorMasterRatio"]
            as? Double ?? p(.compressorMasterRatio)
        compressorReverbInputRatio = dictionary["compressorReverbInputRatio"]
            as? Double ?? p(.compressorReverbInputRatio)
        compressorReverbWetRatio = dictionary["compressorReverbWetRatio"]
            as? Double ?? p(.compressorReverbWetRatio)
        compressorMasterThreshold = dictionary["compressorMasterThreshold"]
            as? Double ?? p(.compressorMasterThreshold)
        compressorReverbInputThreshold = dictionary["compressorReverbInputThreshold"]
            as? Double ?? p(.compressorReverbInputThreshold)
        compressorReverbWetThreshold = dictionary["compressorReverbWetThreshold"]
            as? Double ?? p(.compressorReverbWetThreshold)
        compressorMasterAttack = dictionary["compressorMasterAttack"]
            as? Double ?? p(.compressorMasterAttack)
        compressorReverbInputAttack = dictionary["compressorReverbInputAttack"]
            as? Double ?? p(.compressorReverbInputAttack)
        compressorReverbWetAttack = dictionary["compressorReverbWetAttack"]
            as? Double ?? p(.compressorReverbWetAttack)
        compressorMasterRelease = dictionary["compressorMasterRelease"]
            as? Double ?? p(.compressorMasterRelease)
        compressorReverbInputRelease = dictionary["compressorReverbInputRelease"]
            as? Double ?? p(.compressorReverbInputRelease)
        compressorReverbWetRelease = dictionary["compressorReverbWetRelease"]
            as? Double ?? p(.compressorReverbWetRelease)
        compressorMasterMakeupGain = dictionary["compressorMasterMakeupGain"]
            as? Double ?? p(.compressorMasterMakeupGain)
        compressorReverbInputMakeupGain = dictionary["compressorReverbInputMakeupGain"]
            as? Double ?? p(.compressorReverbInputMakeupGain)
        compressorReverbWetMakeupGain = dictionary["compressorReverbWetMakeupGain"]
            as? Double ?? p(.compressorReverbWetMakeupGain)
        delayInputCutoffTrackingRatio = dictionary["delayInputCutoffTrackingRatio"]
            as? Double ?? p(.delayInputCutoffTrackingRatio)
        delayInputResonance = dictionary["delayInputResonance"]
            as? Double ?? p(.delayInputResonance)
        oscBandlimitEnable = dictionary["oscBandlimitEnable"]
            as? Double ?? p(.oscBandlimitEnable)

        // Tuning
        frequencyA4 = dictionary["frequencyA4"] as? Double ?? p(.frequencyA4)
        tuningName = dictionary["tuningName"] as? String // default is nil
        tuningMasterSet = dictionary["tuningMasterSet"] as? [Double] // default is nil
    }
}
