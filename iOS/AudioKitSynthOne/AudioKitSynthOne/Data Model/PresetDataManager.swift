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
        conductor.synth.setAK1Parameter(.masterVolume, activePreset.masterVolume)
        conductor.synth.setAK1Parameter(.isMono, activePreset.isMono)
        conductor.synth.setAK1Parameter(.glide, activePreset.glide)
        conductor.synth.setAK1Parameter(.index1, activePreset.waveform1)
        conductor.synth.setAK1Parameter(.index2, activePreset.waveform2)
        conductor.synth.setAK1Parameter(.morph1SemitoneOffset, activePreset.vco1Semitone)
        conductor.synth.setAK1Parameter(.morph2SemitoneOffset, activePreset.vco2Semitone)
        conductor.synth.setAK1Parameter(.morph2Detuning, activePreset.vco2Detuning)
        conductor.synth.setAK1Parameter(.morph1Volume, activePreset.vco1Volume)
        conductor.synth.setAK1Parameter(.morph2Volume, activePreset.vco2Volume)
        conductor.synth.setAK1Parameter(.morphBalance, activePreset.vcoBalance)
        conductor.synth.setAK1Parameter(.subVolume, activePreset.subVolume)
        conductor.synth.setAK1Parameter(.subOctaveDown, activePreset.subOsc24Toggled)
        conductor.synth.setAK1Parameter(.subIsSquare, activePreset.subOscSquareToggled)
        conductor.synth.setAK1Parameter(.fmVolume, activePreset.fmVolume)
        conductor.synth.setAK1Parameter(.fmAmount, activePreset.fmMod)
        conductor.synth.setAK1Parameter(.noiseVolume, activePreset.noiseVolume)
        conductor.synth.setAK1Parameter(.cutoff, activePreset.cutoff)
        conductor.synth.setAK1Parameter(.resonance, activePreset.rez)
        conductor.synth.setAK1Parameter(.filterType, activePreset.filterType)
        conductor.synth.setAK1Parameter(.filterADSRMix, activePreset.filterADSRMix)
        conductor.synth.setAK1Parameter(.filterAttackDuration, activePreset.filterAttack)
        conductor.synth.setAK1Parameter(.filterDecayDuration, activePreset.filterDecay)
        conductor.synth.setAK1Parameter(.filterSustainLevel, activePreset.filterSustain)
        conductor.synth.setAK1Parameter(.filterReleaseDuration, activePreset.filterRelease)
        conductor.synth.setAK1Parameter(.attackDuration, activePreset.attackDuration)
        conductor.synth.setAK1Parameter(.decayDuration, activePreset.decayDuration)
        conductor.synth.setAK1Parameter(.sustainLevel, activePreset.sustainLevel)
        conductor.synth.setAK1Parameter(.releaseDuration, activePreset.releaseDuration)
        conductor.synth.setAK1Parameter(.bitCrushSampleRate, activePreset.crushFreq)
        conductor.synth.setAK1Parameter(.autoPanOn, activePreset.autoPanToggled)
        conductor.synth.setAK1Parameter(.autoPanFrequency, activePreset.autoPanRate)
        conductor.synth.setAK1Parameter(.reverbOn, activePreset.reverbToggled)
        conductor.synth.setAK1Parameter(.reverbFeedback, activePreset.reverbFeedback)
        conductor.synth.setAK1Parameter(.reverbHighPass, activePreset.reverbHighPass)
        conductor.synth.setAK1Parameter(.reverbMix, activePreset.reverbMix)
        conductor.synth.setAK1Parameter(.delayOn, activePreset.delayToggled)
        conductor.synth.setAK1Parameter(.delayFeedback, activePreset.delayFeedback)
        conductor.synth.setAK1Parameter(.delayTime, activePreset.delayTime)
        conductor.synth.setAK1Parameter(.delayMix, activePreset.delayMix)
        conductor.synth.setAK1Parameter(.lfo1Index, activePreset.lfoWaveform)
        conductor.synth.setAK1Parameter(.lfo1Amplitude, activePreset.lfoAmplitude)
        conductor.synth.setAK1Parameter(.lfo1Rate, activePreset.lfoRate)
        conductor.synth.setAK1Parameter(.lfo2Index, activePreset.lfo2Waveform)
        conductor.synth.setAK1Parameter(.lfo2Amplitude, activePreset.lfo2Amplitude)
        conductor.synth.setAK1Parameter(.lfo2Rate, activePreset.lfo2Rate)
        conductor.synth.setAK1Parameter(.cutoffLFO, activePreset.cutoffLFO)
        conductor.synth.setAK1Parameter(.resonanceLFO, activePreset.resonanceLFO)
        conductor.synth.setAK1Parameter(.oscMixLFO, activePreset.oscMixLFO)
        conductor.synth.setAK1Parameter(.sustainLFO, activePreset.sustainLFO)
        conductor.synth.setAK1Parameter(.index1LFO, activePreset.index1LFO)
        conductor.synth.setAK1Parameter(.index2LFO, activePreset.index2LFO)
        conductor.synth.setAK1Parameter(.fmLFO, activePreset.fmLFO)
        conductor.synth.setAK1Parameter(.detuneLFO, activePreset.detuneLFO)
        conductor.synth.setAK1Parameter(.filterEnvLFO, activePreset.filterEnvLFO)
        conductor.synth.setAK1Parameter(.pitchLFO, activePreset.pitchLFO)
        conductor.synth.setAK1Parameter(.bitcrushLFO, activePreset.bitcrushLFO)
        conductor.synth.setAK1Parameter(.autopanLFO, activePreset.autopanLFO)
        conductor.synth.setAK1Parameter(.arpDirection, activePreset.arpDirection)
        conductor.synth.setAK1Parameter(.arpInterval, activePreset.arpInterval)
        conductor.synth.setAK1Parameter(.arpIsOn, activePreset.isArpMode)
        conductor.synth.setAK1Parameter(.arpOctave, activePreset.arpOctave)
        conductor.synth.setAK1Parameter(.arpRate, activePreset.arpRate)
        conductor.synth.setAK1Parameter(.arpIsSequencer, activePreset.arpIsSequencer ? 1 : 0 )
        conductor.synth.setAK1Parameter(.arpTotalSteps, activePreset.arpTotalSteps )
        
        for i in 0..<16 {
            conductor.synth.setAK1ArpSeqPattern(forIndex: i, activePreset.seqPatternNote[i])
            conductor.synth.setAK1SeqOctBoost(forIndex: i, activePreset.seqOctBoost[i])
            conductor.synth.setAK1ArpSeqNoteOn(forIndex: i, activePreset.seqNoteOn[i])
        }

        conductor.synth.resetSequencer()
        
        #if false
        AKLog("----------------------------------------------------------------------")
        AKLog("Preset #\(activePreset.position) \(activePreset.name)")
        for i in 0..<AKSynthOneParameter.count {
            let param : AKSynthOneParameter = AKSynthOneParameter(rawValue: i)!
            let sd = param.simpleDescription()
            AKLog("\(i) = \(sd) = \(conductor.synth.getAK1Parameter(param))")
        }
        AKLog("END----------------------------------------------------------------------")
            #endif        
    }
    
    
    func saveValuesToPreset() {
        activePreset.masterVolume = conductor.synth.getAK1Parameter(.masterVolume)
        activePreset.isMono = conductor.synth.getAK1Parameter(.isMono)
        activePreset.glide = conductor.synth.getAK1Parameter(.glide)
        activePreset.waveform1 = conductor.synth.getAK1Parameter(.index1)
        activePreset.waveform2 = conductor.synth.getAK1Parameter(.index2)
        activePreset.vco1Semitone = conductor.synth.getAK1Parameter(.morph1SemitoneOffset)
        activePreset.vco2Semitone = conductor.synth.getAK1Parameter(.morph2SemitoneOffset)
        activePreset.vco2Detuning = conductor.synth.getAK1Parameter(.morph2Detuning)
        activePreset.vco1Volume = conductor.synth.getAK1Parameter(.morph1Volume)
        activePreset.vco2Volume = conductor.synth.getAK1Parameter(.morph2Volume)
        activePreset.vcoBalance = conductor.synth.getAK1Parameter(.morphBalance)
        activePreset.subVolume = conductor.synth.getAK1Parameter(.subVolume)
        activePreset.subOsc24Toggled = conductor.synth.getAK1Parameter(.subOctaveDown)
        activePreset.subOscSquareToggled = conductor.synth.getAK1Parameter(.subIsSquare)
        activePreset.fmVolume = conductor.synth.getAK1Parameter(.fmVolume)
        activePreset.fmMod = conductor.synth.getAK1Parameter(.fmAmount)
        activePreset.noiseVolume = conductor.synth.getAK1Parameter(.noiseVolume)
        activePreset.cutoff = conductor.synth.getAK1Parameter(.cutoff)
        activePreset.rez = conductor.synth.getAK1Parameter(.resonance)
        activePreset.filterType = conductor.synth.getAK1Parameter(.filterType)
        activePreset.filterADSRMix = conductor.synth.getAK1Parameter(.filterADSRMix)
        activePreset.filterAttack = conductor.synth.getAK1Parameter(.filterAttackDuration)
        activePreset.filterDecay = conductor.synth.getAK1Parameter(.filterDecayDuration)
        activePreset.filterSustain = conductor.synth.getAK1Parameter(.filterSustainLevel)
        activePreset.filterRelease = conductor.synth.getAK1Parameter(.filterReleaseDuration)
        activePreset.attackDuration = conductor.synth.getAK1Parameter(.attackDuration)
        activePreset.decayDuration = conductor.synth.getAK1Parameter(.decayDuration)
        activePreset.sustainLevel = conductor.synth.getAK1Parameter(.sustainLevel)
        activePreset.releaseDuration = conductor.synth.getAK1Parameter(.releaseDuration)
        activePreset.crushFreq = conductor.synth.getAK1Parameter(.bitCrushSampleRate)
        activePreset.autoPanToggled = conductor.synth.getAK1Parameter(.autoPanOn)
        activePreset.autoPanRate = conductor.synth.getAK1Parameter(.autoPanFrequency)
        activePreset.reverbToggled = conductor.synth.getAK1Parameter(.reverbOn)
        activePreset.reverbFeedback = conductor.synth.getAK1Parameter(.reverbFeedback)
        activePreset.reverbHighPass = conductor.synth.getAK1Parameter(.reverbHighPass)
        activePreset.reverbMix = conductor.synth.getAK1Parameter(.reverbMix)
        activePreset.delayToggled = conductor.synth.getAK1Parameter(.delayOn)
        activePreset.delayFeedback = conductor.synth.getAK1Parameter(.delayFeedback)
        activePreset.delayTime = conductor.synth.getAK1Parameter(.delayTime)
        activePreset.delayMix = conductor.synth.getAK1Parameter(.delayMix)
        activePreset.lfoWaveform = conductor.synth.getAK1Parameter(.lfo1Index)
        activePreset.lfoAmplitude = conductor.synth.getAK1Parameter(.lfo1Amplitude)
        activePreset.lfoRate = conductor.synth.getAK1Parameter(.lfo1Rate)
        activePreset.lfo2Waveform = conductor.synth.getAK1Parameter(.lfo2Index)
        activePreset.lfo2Amplitude = conductor.synth.getAK1Parameter(.lfo2Amplitude)
        activePreset.lfo2Rate = conductor.synth.getAK1Parameter(.lfo2Rate)
        activePreset.cutoffLFO = conductor.synth.getAK1Parameter(.cutoffLFO)
        activePreset.resonanceLFO = conductor.synth.getAK1Parameter(.resonanceLFO)
        activePreset.oscMixLFO = conductor.synth.getAK1Parameter(.oscMixLFO)
        activePreset.sustainLFO = conductor.synth.getAK1Parameter(.sustainLFO)
        activePreset.index1LFO = conductor.synth.getAK1Parameter(.index1LFO)
        activePreset.index2LFO = conductor.synth.getAK1Parameter(.index2LFO)
        activePreset.fmLFO = conductor.synth.getAK1Parameter(.fmLFO)
        activePreset.detuneLFO = conductor.synth.getAK1Parameter(.detuneLFO)
        activePreset.filterEnvLFO = conductor.synth.getAK1Parameter(.filterEnvLFO)
        activePreset.pitchLFO = conductor.synth.getAK1Parameter(.pitchLFO)
        activePreset.bitcrushLFO = conductor.synth.getAK1Parameter(.bitcrushLFO)
        activePreset.autopanLFO = conductor.synth.getAK1Parameter(.autopanLFO)
        activePreset.arpDirection = conductor.synth.getAK1Parameter(.arpDirection)
        activePreset.arpInterval = conductor.synth.getAK1Parameter(.arpInterval)
        activePreset.arpOctave = conductor.synth.getAK1Parameter(.arpOctave)
        activePreset.arpRate = conductor.synth.getAK1Parameter(.arpRate)
        activePreset.arpIsSequencer = conductor.synth.getAK1Parameter(.arpIsSequencer) > 0 ? true : false
        activePreset.arpTotalSteps = conductor.synth.getAK1Parameter(.arpTotalSteps)
        activePreset.isArpMode = conductor.synth.getAK1Parameter(.arpIsOn)
        
        for i in 0..<16 {
            activePreset.seqPatternNote[i] = conductor.synth.getAK1ArpSeqPattern(forIndex: i)
            activePreset.seqOctBoost[i] = conductor.synth.getAK1SeqOctBoost(forIndex: i)
            activePreset.seqNoteOn[i] = conductor.synth.getAK1ArpSeqNoteOn(forIndex: i)
        }
        
        presetsViewController.savePreset(activePreset)
    }
}
