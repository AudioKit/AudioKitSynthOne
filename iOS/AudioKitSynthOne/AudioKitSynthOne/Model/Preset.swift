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
    
    // Synth VC
    var holdToggled = false
    var monoToggled = false
    var arpToggled = false
    var octavePosition = 0
    
    // Controls VC
    var masterVolume = 0.5 // Master Volume
    
    // Seq Pattern
    var seqPatternNote = [1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0]
    var seqNoteOn = [true, true, true, true,true, true, true, true,true, true, true, true,true, true, true, true]
   
    var vco1Semitone = 0.0 // VCO1 Semitones
    var vco2Semitone = 0.0 // VCO2 Semitones
    var vco2Detuning = 0.0 // VCO2 Detune (Hz)
    var vcoBalance = 0.5 // VCO1/VCO2 Mix
    var subVolume = 0.0 // SubOsc Mix
    var fmVolume = 0.0 // FM Mix
    var fmMod = 0.0 // FM Modulation Amt
    var noiseVolume = 0.0 // Noise Mix
    var lfoAmplitude = 0.0 // LFO Amp (Hz)
    var lfoRate = 0.0 // LFO Rate
    var cutoff = 0.99 // Cutoff Knob Position
    var rez = 0.1 // Filter Q/Rez
    var delayTime = 0.5 // Delay (seconds)
    var delayMix = 0.5 // Dry/Wet
    var reverbFeedback = 0.5 // Amt
    var reverbMix = 0.5 // Dry/Wet
    var midiBendRange = 2.0 // MIDI bend range in +/- semitones
    var crushAmt = 0.0 // Crusher Knob Position
    var autoPanRate = 2.0 // AutoPan Rate
    var filterADSRMix = 0.0 // Filter Envelope depth
    var glide = 0.0 // Mono glide amount
    
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
    var vco1Toggled = true
    var vco2Toggled = true
    var filterToggled = true
    var delayToggled = false
    var reverbToggled = false
    var crusherToggled = false
    var autoPanToggled = false
    var subOsc24Toggled = false
    var subOscSquareToggled = false
    var verbHighPassToggled = false
    
    // Waveforms
    var waveform1 = 0.0
    var waveform2 = 0.0
    var lfoWaveform = 0.0
    
    // Arp
    var arpDirection = 0.0
    var arpInterval = 12.0
    var arpOctave = 1.0
    var arpRate = 120.0
    var arpIsSequencer = false
    var arpTotalSteps = 7.0
    
    // Author
    var author = ""
    var category = 0
    var isUser = true
    var isFavorite = false
    
    // ******************************************************
    // MARK: - Init
    // ******************************************************
 
    init() {

     }

    convenience init(position: Int) {
        self.init()
        
        // Preset Number/Position
        self.position = position
        
        /*
        // Populate Sequence pattern with 16 steps
        for _ in 0...15 {
            let seqPattern = SeqPatternNote()
            seqPattern.seqNote = 0
            seqPatterns.append(seqPattern)
            
            let seqNoteOn = SeqNoteOn()
            seqNoteOn.noteOn = true
            seqNotesOn.append(seqNoteOn)
        }
        */
    }
    
    
    //*****************************************************************
    // MARK: - Class Function to Return array of Presets
    //*****************************************************************
    
    // Return Single Preset
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
        
        // Synth VC
        holdToggled = dictionary["holdToggled"] as? Bool ?? holdToggled
        monoToggled = dictionary["monoToggled"] as? Bool ?? monoToggled
        arpToggled = dictionary["arpToggled"] as? Bool ?? arpToggled
        octavePosition = dictionary["octavePosition"] as? Int ?? octavePosition
        
        // Controls VC
        masterVolume = dictionary["masterVolume"] as? Double ?? masterVolume
        
        seqPatternNote = dictionary["seqPatternNote"] as? [Int] ?? seqPatternNote
        
        seqNoteOn = dictionary["seqNoteOn"] as? [Bool] ?? seqNoteOn
        vco1Semitone = dictionary["vco1Semitone"] as? Double ?? vco1Semitone
        vco2Semitone = dictionary["vco2Semitone"] as? Double ?? vco2Semitone
        vco2Detuning = dictionary["vco2Detuning"] as? Double ?? vco2Detuning
        vcoBalance = dictionary["vcoBalance"] as? Double ?? vcoBalance
        subVolume = dictionary["subVolume"] as? Double ?? subVolume
        fmVolume = dictionary["fmVolume"] as? Double ?? fmVolume
        fmMod = dictionary["fmMod"] as? Double ?? fmMod
        noiseVolume = dictionary["noiseVolume"] as? Double ?? noiseVolume
        lfoAmplitude = dictionary["lfoAmplitude"] as? Double ?? lfoAmplitude
        lfoRate = dictionary["lfoRate"] as? Double ?? lfoRate
        cutoff = dictionary["cutoff"] as? Double ?? cutoff
        rez = dictionary["rez"] as? Double ?? rez
        delayTime = dictionary["delayTime"] as? Double ?? delayTime
        delayMix = dictionary["delayMix"] as? Double ?? delayMix
        reverbFeedback = dictionary["reverbFeedback"] as? Double ?? reverbFeedback
        reverbMix = dictionary["reverbMix"] as? Double ?? reverbMix
        midiBendRange = dictionary["midiBendRange"] as? Double ?? midiBendRange
        crushAmt = dictionary["crushAmt"] as? Double ?? crushAmt
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
        delayToggled = dictionary["delayToggled"] as? Bool ?? delayToggled
        reverbToggled = dictionary["reverbToggled"] as? Bool ?? reverbToggled
        autoPanToggled = dictionary["autoPanToggled"] as? Bool ?? autoPanToggled
        subOsc24Toggled = dictionary["subOsc24Toggled"] as? Bool ?? subOsc24Toggled
        subOscSquareToggled = dictionary["subOscSquareToggled"] as? Bool ?? subOscSquareToggled
        verbHighPassToggled = dictionary["verbHighPassToggled"] as? Bool ?? subOsc24Toggled
        
        // Waveforms
        waveform1 = dictionary["waveform1"] as? Double ?? waveform1
        waveform2 = dictionary["waveform2"] as? Double ?? waveform2
        lfoWaveform = dictionary["lfoWaveform"] as? Double ?? lfoWaveform
        
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
        
        // *** ToDo ***
        // DCO Volumes
        // LFO 2
        // LFO Routings
        // Tempo Sync
    }
    
   
}
