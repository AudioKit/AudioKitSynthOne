//
//  Preset.swift
//  AudioKit Synth One
//
//  Created by Matthew Fecher on 7/23/16.
//  Copyright © 2016 AudioKit. All rights reserved.
//

import Foundation
import RealmSwift

// NOTE: Update the schemaVersion in RealmConfig.swift
// Everytime you update the model

// ******************************************************
// MARK: - Classes for saving arrays w/ Realm
// ******************************************************

class SeqPatternNote: Object {
    dynamic var seqNote = 0
}

class SeqNoteOn: Object {
    dynamic var noteOn = true
}

// ******************************************************
// MARK: - Preset
// ******************************************************

class Preset: Object {
    
    // ******************************************************
    // MARK: - Properties
    // ******************************************************
    
    dynamic var uid = UUID().uuidString
    dynamic var position = 0 // Preset Number/Position
    dynamic var name = "Init"
    
    // Synth VC
    dynamic var holdToggled = false
    dynamic var monoToggled = false
    dynamic var arpToggled = false
    dynamic var octavePosition = 0
    
    // Controls VC
    dynamic var masterVolume = 0.5 // Master Volume
    dynamic var vco1Semitone = 0 // VCO1 Semitones
    dynamic var vco2Semitone = 0 // VCO2 Semitones
    dynamic var vco2Detuning = 0.0 // VCO2 Detune (Hz)
    dynamic var vcoBalance = 0.5 // VCO1/VCO2 Mix
    dynamic var subVolume = 0.0 // SubOsc Mix
    dynamic var fmVolume = 0.0 // FM Mix
    dynamic var fmMod = 0.0 // FM Modulation Amt
    dynamic var noiseVolume = 0.0 // Noise Mix
    dynamic var lfoAmplitude = 0.0 // LFO Amp (Hz)
    dynamic var lfoRate = 0.0 // LFO Rate
    dynamic var cutoff = 0.99 // Cutoff Knob Position
    dynamic var rez = 0.1 // Filter Q/Rez
    dynamic var delayTime = 0.5 // Delay (seconds)
    dynamic var delayMix = 0.5 // Dry/Wet
    dynamic var reverbFeedback = 0.5 // Amt
    dynamic var reverbMix = 0.5 // Dry/Wet
    dynamic var midiBendRange = 2.0 // MIDI bend range in +/- semitones
    dynamic var crushAmt = 0.0 // Crusher Knob Position
    dynamic var autoPanRate = 2.0 // AutoPan Rate
    dynamic var filterADSRMix = 0.0 // Filter Envelope depth
    dynamic var glide = 0.0 // Mono glide amount
    
    // ADSR
    dynamic var attackDuration = 0.05
    dynamic var decayDuration = 0.05
    dynamic var sustainLevel = 0.8
    dynamic var releaseDuration = 0.05
    
    dynamic var filterAttack = 0.05
    dynamic var filterDecay = 0.5
    dynamic var filterSustain = 1.0
    dynamic var filterRelease = 0.5
    
    // Toggle Presets
    dynamic var vco1Toggled = true
    dynamic var vco2Toggled = true
    dynamic var filterToggled = true
    dynamic var delayToggled = false
    dynamic var reverbToggled = false
    dynamic var crusherToggled = false
    dynamic var autoPanToggled = false
    dynamic var subOsc24Toggled = false
    dynamic var subOscSquareToggled = false
    dynamic var verbHighPassToggled = false
    
    // Waveforms
    dynamic var waveform1 = 0.0
    dynamic var waveform2 = 0.0
    dynamic var lfoWaveform = 0.0
    
    // Arp
    dynamic var arpDirection = 0
    dynamic var arpInterval = 12
    dynamic var arpOctave = 1
    dynamic var arpRate = 120.0
    dynamic var arpIsSequencer = false
    dynamic var arpTotalSteps = 7
    
    var seqPatterns = List<SeqPatternNote>()
    var seqNotesOn = List<SeqNoteOn>()
   
    // ******************************************************
    // MARK: - Realm
    // ******************************************************
    
    /*
    override class func primaryKey() -> String? {
        return "uid"
    }
    */
    
    override class func indexedProperties() -> [String] {
        return ["position"]
    }
    
    // ******************************************************
    // MARK: - Init
    // ******************************************************
    
    
    convenience init(position: Int) {
        self.init()
        
        // Preset Number/Position
        self.position = position
        
        // Populate Sequence pattern with 16 steps
        for _ in 0...15 {
            let seqPattern = SeqPatternNote()
            seqPattern.seqNote = 0
            seqPatterns.append(seqPattern)
            
            let seqNoteOn = SeqNoteOn()
            seqNoteOn.noteOn = true
            seqNotesOn.append(seqNoteOn)
        }
    }
    
}
