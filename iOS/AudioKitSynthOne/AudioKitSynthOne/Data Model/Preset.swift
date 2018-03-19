//
//  Preset.swift
//  AudioKit Synth One
//
//  Created by Matthew Fecher on 7/23/16.
//  Copyright © 2016 AudioKit. All rights reserved.
//

import Foundation


// ******************************************************
// MARK: - Preset
// ******************************************************

class Preset: Codable {
    
    var uid = UUID().uuidString
    var position = 0 // Preset #
    var name = "Init"
    var bank = "User"
    
    // Synth VC
    var octavePosition = 0
    var isMono = 0.0
    var isHoldMode = 0.0
    var isArpMode = 0.0
    var syncRateToTempo = 1.0
    
    // Controls VC
    var masterVolume = 0.5 // Master Volume
   
    var vco1Volume = 0.75
    var vco2Volume = 0.75
    var vco1Semitone = 0.0 // VCO1 Semitones
    var vco2Semitone = 0.0 // VCO2 Semitones
    var vco2Detuning = 0.0 // VCO2 Detune (Hz)
    var vcoBalance = 0.5 // VCO1/VCO2 Mix
    var subVolume = 0.0 // SubOsc Mix
    var fmVolume = 0.0 // FM Mix
    var fmMod = 0.0 // FM Modulation Amt
    var noiseVolume = 0.0 // Noise Mix
 
    var cutoff = 2000.0 // Cutoff Knob Position
    var rez = 0.1 // Filter Q/Rez
    var filterType = 0.0 // 0 = lopass, 1=bandpass, 2=hipassh.s
    var delayTime = 0.5 // Delay (seconds)
    var delayMix = 0.5 // Dry/Wet
    var delayFeedback = 0.1
    var reverbFeedback = 0.5 // Amt
    var reverbMix = 0.5 // Dry/Wet
    var reverbHighPass = 80.0 // Highpass filter freq for Filter
    var midiBendRange = 2.0 // MIDI bend range in +/- semitones
    var crushFreq = 44100.0 // Crusher Frequency
    var autoPanAmount = 0.0
    var autoPanRate = 2.0 // AutoPan Rate
    var filterADSRMix = 0.0 // Filter Envelope depth
    var glide = 0.0 // Mono glide amount
    
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
    var reverbToggled = 1.0
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
    var seqPatternNote = [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0]
    var seqOctBoost = [false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false]
    var seqNoteOn = [true, true, true, true,true, true, true, true,true, true, true, true,true, true, true, true]
    
    // Arp
    var arpDirection = 0.0
    var arpInterval = 12.0
    var arpOctave = 1.0
    var arpRate = 120.0
    var arpIsSequencer = false
    var arpTotalSteps = 8.0
    
    // Author
    var author = ""
    var category = 0
    var isUser = true
    var isFavorite = false
    var userText = "AudioKit Synth One preset. Created by YOUR NAME HERE."
    
    // LFO Routings
    var cutoffLFO = 0.0
    var resonanceLFO = 0.0
    var oscMixLFO = 0.0
    var sustainLFO = 0.0
    var decayLFO = 0.0
    var noiseLFO = 0.0
    var fmLFO = 0.0
    var detuneLFO = 0.0
    var filterEnvLFO = 0.0
    var pitchLFO = 0.0
    var bitcrushLFO = 0.0
    var autopanLFO = 0.0
    
    // MOD Wheel Routings
    var modWheelRouting = 0.0
    
    // ******************************************************
    // MARK: - Init
    // ******************************************************
 
    init() {

     }

    convenience init(position: Int) {
        self.init()
        
        // Preset Number/Position
        self.position = position
        
    }
    
    
    //*****************************************************************
    // MARK: - Class Function to Return array of Presets
    //*****************************************************************
    
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
    
    //*****************************************************************
    // MARK: - JSON Parsing into object
    //*****************************************************************

    // Init from Dictionary/JSON
    init(dictionary: [String: Any]) {
        
        name = dictionary["name"] as? String ?? name
        position = dictionary["position"] as? Int ?? position
        uid = dictionary["uid"] as? String ?? uid
        bank = dictionary["bank"] as? String ?? bank
        
        // Synth VC
        octavePosition = dictionary["octavePosition"] as? Int ?? octavePosition
        isMono = dictionary["isMono"] as? Double ?? isMono
        isHoldMode = dictionary["isHoldMode"] as? Double ?? isHoldMode
        isArpMode = dictionary["isArpMode"] as? Double ?? isArpMode
        syncRateToTempo = dictionary["syncRateToTempo"] as? Double ?? syncRateToTempo
        
        // Controls VC
        masterVolume = dictionary["masterVolume"] as? Double ?? masterVolume
        
        vco1Volume = dictionary["vco1Volume"] as? Double ?? vco1Volume
        vco2Volume = dictionary["vco2Volume"] as? Double ?? vco2Volume
        vco1Semitone = dictionary["vco1Semitone"] as? Double ?? vco1Semitone
        vco2Semitone = dictionary["vco2Semitone"] as? Double ?? vco2Semitone
        vco2Detuning = dictionary["vco2Detuning"] as? Double ?? vco2Detuning
        vcoBalance = dictionary["vcoBalance"] as? Double ?? vcoBalance
        subVolume = dictionary["subVolume"] as? Double ?? subVolume
        fmVolume = dictionary["fmVolume"] as? Double ?? fmVolume
        fmMod = dictionary["fmMod"] as? Double ?? fmMod
        noiseVolume = dictionary["noiseVolume"] as? Double ?? noiseVolume
       
        cutoff = dictionary["cutoff"] as? Double ?? cutoff
        rez = dictionary["rez"] as? Double ?? rez
        filterType = dictionary["filterType"] as? Double ?? filterType
        delayTime = dictionary["delayTime"] as? Double ?? delayTime
        delayFeedback = dictionary["delayFeedback"] as? Double ?? delayFeedback
        delayMix = dictionary["delayMix"] as? Double ?? delayMix
        reverbFeedback = dictionary["reverbFeedback"] as? Double ?? reverbFeedback
        reverbMix = dictionary["reverbMix"] as? Double ?? reverbMix
        reverbHighPass = dictionary["reverbHighPass"] as? Double ?? reverbHighPass
        midiBendRange = dictionary["midiBendRange"] as? Double ?? midiBendRange
        crushFreq = dictionary["crushFreq"] as? Double ?? crushFreq
        autoPanRate = dictionary["autoPanRate"] as? Double ?? autoPanRate
        filterADSRMix = dictionary["filterADSRMix"] as? Double ?? filterADSRMix
        glide = dictionary["glide"] as? Double ?? glide
        
        // ADSR
        attackDuration = dictionary["attackDuration"] as? Double ?? attackDuration
        decayDuration = dictionary["decayDuration"] as? Double ?? decayDuration
        sustainLevel = dictionary["sustainLevel"] as? Double ?? sustainLevel
        releaseDuration = dictionary["releaseDuration"] as? Double ?? releaseDuration
        
        filterAttack = dictionary["filterAttack"] as? Double ?? filterAttack
        filterDecay = dictionary["filterDecay"] as? Double ?? filterDecay
        filterSustain = dictionary["filterSustain"] as? Double ?? filterSustain
        filterRelease = dictionary["filterRelease"] as? Double ?? filterRelease
        
        // Toggle Presets
        delayToggled = dictionary["delayToggled"] as? Double ?? delayToggled
        reverbToggled = dictionary["reverbToggled"] as? Double ?? reverbToggled
        autoPanAmount = dictionary["autoPanAmount"] as? Double ?? autoPanAmount
        subOsc24Toggled = dictionary["subOsc24Toggled"] as? Double ?? subOsc24Toggled
        subOscSquareToggled = dictionary["subOscSquareToggled"] as? Double ?? subOscSquareToggled
        
        // Waveforms
        waveform1 = dictionary["waveform1"] as? Double ?? waveform1
        waveform2 = dictionary["waveform2"] as? Double ?? waveform2
        lfoWaveform = dictionary["lfoWaveform"] as? Double ?? lfoWaveform
        lfoAmplitude = dictionary["lfoAmplitude"] as? Double ?? lfoAmplitude
        lfoRate = dictionary["lfoRate"] as? Double ?? lfoRate
        lfo2Waveform = dictionary["lfo2Waveform"] as? Double ?? lfo2Waveform
        lfo2Amplitude = dictionary["lfo2Amplitude"] as? Double ?? lfo2Amplitude
        lfo2Rate = dictionary["lfo2Rate"] as? Double ?? lfo2Rate
        
        // Seq
        seqPatternNote = dictionary["seqPatternNote"] as? [Int] ?? seqPatternNote
        seqNoteOn = dictionary["seqNoteOn"] as? [Bool] ?? seqNoteOn
        seqOctBoost = dictionary["seqOctBoost"] as? [Bool] ?? seqOctBoost
        
        // Arp
        arpDirection = dictionary["arpDirection"] as? Double ?? arpDirection
        arpInterval = dictionary["arpInterval"] as? Double ?? arpInterval
        arpOctave = dictionary["arpOctave"] as? Double ?? arpOctave
        arpRate = dictionary["arpRate"] as? Double ?? arpRate
        arpIsSequencer = dictionary["arpIsSequencer"] as? Bool ?? arpIsSequencer
        arpTotalSteps = dictionary["arpTotalSteps"] as? Double ?? arpTotalSteps
        
        author = dictionary["author"] as? String ?? author
        category = dictionary["category"] as? Int ?? category
        isUser = dictionary["isUser"] as? Bool ?? isUser
        isFavorite = dictionary["isFavorite"] as? Bool ?? isFavorite
        userText = dictionary["userText"] as? String ?? userText
        
        // LFO Routings
        cutoffLFO = dictionary["cutoffLFO"] as? Double ?? cutoffLFO
        resonanceLFO = dictionary["resonanceLFO"] as? Double ?? resonanceLFO
        oscMixLFO = dictionary["oscMixLFO"] as? Double ?? oscMixLFO
        sustainLFO = dictionary["sustainLFO"] as? Double ?? sustainLFO
        decayLFO = dictionary["decayLFO"] as? Double ?? decayLFO
        noiseLFO = dictionary["noiseLFO"] as? Double ?? noiseLFO
        fmLFO = dictionary["fmLFO"] as? Double ?? fmLFO
        detuneLFO = dictionary["detuneLFO"] as? Double ?? detuneLFO
        filterEnvLFO = dictionary["filterEnvLFO"] as? Double ?? filterEnvLFO
        pitchLFO = dictionary["pitchLFO"] as? Double ?? pitchLFO
        bitcrushLFO = dictionary["bitcrushLFO"] as? Double ?? bitcrushLFO
        autopanLFO = dictionary["autopanLFO"] as? Double ?? autopanLFO
        
        // MOD WHeel
        modWheelRouting = dictionary["modWheelRouting"] as? Double ?? modWheelRouting
        
        // FX
        phaserFeedback = dictionary["phaserFeedback"] as? Double ?? phaserFeedback
        phaserMix = dictionary["phaserMix"] as? Double ?? phaserMix
        phaserRate = dictionary["phaserRate"] as? Double ?? phaserRate
        phaserNotchWidth = dictionary["phaserNotchWidth"] as? Double ?? phaserNotchWidth
    }
}
