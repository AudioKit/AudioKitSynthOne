//
//  PresetDataManager.swift
//  AudioKitSynthOne
//
//  Created by Matthew Fecher on 10/23/17.
//  Copyright © 2017 AudioKit. All rights reserved.
//

import Foundation
import AudioKit

extension ParentViewController {
    // **********************************************************
    // MARK: - Preset Load/Save
    // **********************************************************
    
    func loadPreset() {
        conductor.synth.parameters[AKSynthOneParameter.masterVolume.rawValue] = activePreset.masterVolume
        conductor.synth.parameters[AKSynthOneParameter.isMono.rawValue] = activePreset.isMono
        conductor.synth.parameters[AKSynthOneParameter.glide.rawValue] = activePreset.glide
        
        conductor.synth.parameters[AKSynthOneParameter.index1.rawValue] = activePreset.waveform1
        conductor.synth.parameters[AKSynthOneParameter.index2.rawValue] = activePreset.waveform2
        
        conductor.synth.parameters[AKSynthOneParameter.morph1SemitoneOffset.rawValue] = activePreset.vco1Semitone
        conductor.synth.parameters[AKSynthOneParameter.morph2SemitoneOffset.rawValue] = activePreset.vco2Semitone
        conductor.synth.parameters[AKSynthOneParameter.morph2Detuning.rawValue] = activePreset.vco2Detuning
        conductor.synth.parameters[AKSynthOneParameter.morph1Volume.rawValue] = activePreset.vco1Volume
        conductor.synth.parameters[AKSynthOneParameter.morph2Volume.rawValue] = activePreset.vco2Volume
        conductor.synth.parameters[AKSynthOneParameter.morphBalance.rawValue] = activePreset.vcoBalance
        
        conductor.synth.parameters[AKSynthOneParameter.subVolume.rawValue] = activePreset.subVolume
        conductor.synth.parameters[AKSynthOneParameter.subOctaveDown.rawValue] = activePreset.subOsc24Toggled
        conductor.synth.parameters[AKSynthOneParameter.subIsSquare.rawValue] = activePreset.subOscSquareToggled
        
        conductor.synth.parameters[AKSynthOneParameter.fmVolume.rawValue] = activePreset.fmVolume
        conductor.synth.parameters[AKSynthOneParameter.fmAmount.rawValue] = activePreset.fmMod
        conductor.synth.parameters[AKSynthOneParameter.noiseVolume.rawValue] = activePreset.noiseVolume
        
        conductor.synth.parameters[AKSynthOneParameter.cutoff.rawValue] = activePreset.cutoff
        conductor.synth.parameters[AKSynthOneParameter.resonance.rawValue] = activePreset.rez
        
        conductor.synth.parameters[AKSynthOneParameter.filterADSRMix.rawValue] = activePreset.filterADSRMix
        conductor.synth.parameters[AKSynthOneParameter.filterAttackDuration.rawValue] = activePreset.filterAttack
        conductor.synth.parameters[AKSynthOneParameter.filterDecayDuration.rawValue] = activePreset.filterDecay
        conductor.synth.parameters[AKSynthOneParameter.filterSustainLevel.rawValue] = activePreset.filterSustain
        conductor.synth.parameters[AKSynthOneParameter.filterReleaseDuration.rawValue] = activePreset.filterRelease
        
        conductor.synth.parameters[AKSynthOneParameter.attackDuration.rawValue] = activePreset.attackDuration
        conductor.synth.parameters[AKSynthOneParameter.decayDuration.rawValue] = activePreset.decayDuration
        conductor.synth.parameters[AKSynthOneParameter.sustainLevel.rawValue] = activePreset.sustainLevel
        conductor.synth.parameters[AKSynthOneParameter.releaseDuration.rawValue] = activePreset.releaseDuration
        
        conductor.synth.parameters[AKSynthOneParameter.bitCrushSampleRate.rawValue] = activePreset.crushFreq
        
        conductor.synth.parameters[AKSynthOneParameter.autoPanOn.rawValue] = activePreset.autoPanToggled
        conductor.synth.parameters[AKSynthOneParameter.autoPanFrequency.rawValue] = activePreset.autoPanRate
        
        conductor.synth.parameters[AKSynthOneParameter.reverbOn.rawValue] = activePreset.reverbToggled
        conductor.synth.parameters[AKSynthOneParameter.reverbFeedback.rawValue] = activePreset.reverbFeedback
        
        conductor.synth.parameters[AKSynthOneParameter.reverbHighPass.rawValue] = activePreset.reverbHighPass
        
        conductor.synth.parameters[AKSynthOneParameter.reverbMix.rawValue] = activePreset.reverbMix
        
        conductor.synth.parameters[AKSynthOneParameter.delayOn.rawValue] = activePreset.delayToggled
        conductor.synth.parameters[AKSynthOneParameter.delayFeedback.rawValue] = activePreset.delayFeedback
        conductor.synth.parameters[AKSynthOneParameter.delayTime.rawValue] = activePreset.delayTime
        conductor.synth.parameters[AKSynthOneParameter.delayMix.rawValue] = activePreset.delayMix
        
        conductor.synth.parameters[AKSynthOneParameter.lfo1Index.rawValue] = activePreset.lfoWaveform
        conductor.synth.parameters[AKSynthOneParameter.lfo1Amplitude.rawValue] = activePreset.lfoAmplitude
        conductor.synth.parameters[AKSynthOneParameter.lfo1Rate.rawValue] = activePreset.lfoRate
        conductor.synth.parameters[AKSynthOneParameter.lfo2Index.rawValue] = activePreset.lfo2Waveform
        conductor.synth.parameters[AKSynthOneParameter.lfo2Amplitude.rawValue] = activePreset.lfo2Amplitude
        conductor.synth.parameters[AKSynthOneParameter.lfo2Rate.rawValue] = activePreset.lfo2Rate
        
        // LFO Routings
        conductor.synth.parameters[AKSynthOneParameter.cutoffLFO.rawValue] = activePreset.cutoffLFO
        conductor.synth.parameters[AKSynthOneParameter.resonanceLFO.rawValue] = activePreset.resonanceLFO
        conductor.synth.parameters[AKSynthOneParameter.oscMixLFO.rawValue] = activePreset.oscMixLFO
        conductor.synth.parameters[AKSynthOneParameter.sustainLFO.rawValue] = activePreset.sustainLFO
        conductor.synth.parameters[AKSynthOneParameter.index1LFO.rawValue] = activePreset.index1LFO
        conductor.synth.parameters[AKSynthOneParameter.index2LFO.rawValue] = activePreset.index2LFO
        conductor.synth.parameters[AKSynthOneParameter.fmLFO.rawValue] = activePreset.fmLFO
        conductor.synth.parameters[AKSynthOneParameter.detuneLFO.rawValue] = activePreset.detuneLFO
        conductor.synth.parameters[AKSynthOneParameter.filterEnvLFO.rawValue] = activePreset.filterEnvLFO
        conductor.synth.parameters[AKSynthOneParameter.pitchLFO.rawValue] = activePreset.pitchLFO
        conductor.synth.parameters[AKSynthOneParameter.bitcrushLFO.rawValue] = activePreset.bitcrushLFO
        conductor.synth.parameters[AKSynthOneParameter.autopanLFO.rawValue] = activePreset.autopanLFO
        
        ///TODO:Remove this logging after validating Preset
        AKLog("----------------------------------------------------------------------")
        AKLog("Preset #\(activePreset.position) \(activePreset.name)")
        for i in 0..<60 {
            let sd = AKSynthOneParameter(rawValue: i)?.simpleDescription() ?? ""
            AKLog("conductor.synth.parameters[\(i)] = \(sd) = \(conductor.synth.parameters[i])")
        }
        
        // Arp
        activeArp.beatCounter = 0
        activeArp.direction = activePreset.arpDirection
        activeArp.interval = activePreset.arpInterval
        activeArp.octave = activePreset.arpOctave
        activeArp.rate = activePreset.arpRate
        activeArp.isSequencer = activePreset.arpIsSequencer
        activeArp.totalSteps = activePreset.arpTotalSteps
        activeArp.seqPattern = activePreset.seqPatternNote
        activeArp.seqNoteOn = activePreset.seqNoteOn
        activeArp.seqOctBoost = activePreset.seqOctBoost
        activeArp.isOn = activePreset.isArpMode
        
        // Update arpVC
        //seqViewController.arpeggiator = activeArp
        //seqViewController.setupControlValues()
        
        // Arp Toggle
        //arpToggle.isSelected = !preset.arpToggled
        
        // filterMix = 18,
        // tempoSync
        // octave position
    }
    
    func saveValuesToPreset() {
        activePreset.vcoBalance = conductor.synth.parameters[AKSynthOneParameter.morphBalance.rawValue]
        activePreset.rez = conductor.synth.parameters[AKSynthOneParameter.resonance.rawValue]
        activePreset.cutoff = conductor.synth.parameters[AKSynthOneParameter.cutoff.rawValue]
        ///TODO:Why is savePreset commented out?  Because this method is not fleshed out?
        //presetsViewController.savePreset(activePreset)
    }
}


// **************************************************
// MARK: - Presets Delegate
// **************************************************

extension ParentViewController: PresetsDelegate {
    
    func presetDidChange(_ newActivePreset: Preset) {
        activePreset = newActivePreset
        updateDisplay("")
        // Set parameters from preset
        loadPreset()
    }
    
    func updateDisplay(_ message: String) {
        if let headerVC = self.childViewControllers.first as? HeaderViewController {
            headerVC.displayLabel.text = "\(activePreset.position): \(activePreset.name)"
        }
    }
    
    func saveEditedPreset(name: String, category: Int) {
        activePreset.name = name
        activePreset.category = category
        activePreset.isUser = true
        saveValuesToPreset()
    }
}

