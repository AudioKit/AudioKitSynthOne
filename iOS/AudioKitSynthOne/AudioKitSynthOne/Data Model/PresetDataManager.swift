//
//  PresetDataManager.swift
//  AudioKitSynthOne
//
//  Created by Matthew Fecher on 10/23/17.
//  Copyright © 2017 AudioKit. All rights reserved.
//

import Foundation

extension ParentViewController {
    
    // **********************************************************
    // MARK: - Preset Load/Save
    // **********************************************************
    
    func loadPreset() {
        // Non-kernel parameters
        conductor.syncRateToTempo = (activePreset.syncRateToTempo == 1)
        fxViewController.tempoSyncToggle.value = activePreset.syncRateToTempo
        
        // Kernel Parameters
        let s = conductor.synth!
        s.setAK1Parameter(.masterVolume, activePreset.masterVolume)
        s.setAK1Parameter(.isMono, activePreset.isMono)
        s.setAK1Parameter(.glide, activePreset.glide)
        s.setAK1Parameter(.index1, activePreset.waveform1)
        s.setAK1Parameter(.index2, activePreset.waveform2)
        s.setAK1Parameter(.morph1SemitoneOffset, activePreset.vco1Semitone)
        s.setAK1Parameter(.morph2SemitoneOffset, activePreset.vco2Semitone)
        s.setAK1Parameter(.morph2Detuning, activePreset.vco2Detuning)
        s.setAK1Parameter(.morph1Volume, activePreset.vco1Volume)
        s.setAK1Parameter(.morph2Volume, activePreset.vco2Volume)
        s.setAK1Parameter(.morphBalance, activePreset.vcoBalance)
        s.setAK1Parameter(.subVolume, activePreset.subVolume)
        s.setAK1Parameter(.subOctaveDown, activePreset.subOsc24Toggled)
        s.setAK1Parameter(.subIsSquare, activePreset.subOscSquareToggled)
        s.setAK1Parameter(.fmVolume, activePreset.fmVolume)
        s.setAK1Parameter(.fmAmount, activePreset.fmMod)
        s.setAK1Parameter(.noiseVolume, activePreset.noiseVolume)
        s.setAK1Parameter(.cutoff, activePreset.cutoff)
        s.setAK1Parameter(.resonance, activePreset.rez)
        s.setAK1Parameter(.filterADSRMix, activePreset.filterADSRMix)
        s.setAK1Parameter(.filterAttackDuration, activePreset.filterAttack)
        s.setAK1Parameter(.filterDecayDuration, activePreset.filterDecay)
        s.setAK1Parameter(.filterSustainLevel, activePreset.filterSustain)
        s.setAK1Parameter(.filterReleaseDuration, activePreset.filterRelease)
        s.setAK1Parameter(.attackDuration, activePreset.attackDuration)
        s.setAK1Parameter(.decayDuration, activePreset.decayDuration)
        s.setAK1Parameter(.sustainLevel, activePreset.sustainLevel)
        s.setAK1Parameter(.releaseDuration, activePreset.releaseDuration)
        s.setAK1Parameter(.bitCrushSampleRate, activePreset.crushFreq)
        s.setAK1Parameter(.autoPanAmount, activePreset.autoPanAmount)
        s.setAK1Parameter(.autoPanFrequency, activePreset.autoPanRate)
        s.setAK1Parameter(.reverbOn, activePreset.reverbToggled)
        s.setAK1Parameter(.reverbFeedback, activePreset.reverbFeedback)
        s.setAK1Parameter(.reverbHighPass, activePreset.reverbHighPass)
        s.setAK1Parameter(.reverbMix, activePreset.reverbMix)
        s.setAK1Parameter(.delayOn, activePreset.delayToggled)
        s.setAK1Parameter(.delayFeedback, activePreset.delayFeedback)
        s.setAK1Parameter(.delayTime, activePreset.delayTime)
        s.setAK1Parameter(.delayMix, activePreset.delayMix)
        s.setAK1Parameter(.lfo1Index, activePreset.lfoWaveform)
        s.setAK1Parameter(.lfo1Amplitude, activePreset.lfoAmplitude)
        s.setAK1Parameter(.lfo1Rate, activePreset.lfoRate)
        s.setAK1Parameter(.lfo2Index, activePreset.lfo2Waveform)
        s.setAK1Parameter(.lfo2Amplitude, activePreset.lfo2Amplitude)
        s.setAK1Parameter(.lfo2Rate, activePreset.lfo2Rate)
        s.setAK1Parameter(.cutoffLFO, activePreset.cutoffLFO)
        s.setAK1Parameter(.resonanceLFO, activePreset.resonanceLFO)
        s.setAK1Parameter(.oscMixLFO, activePreset.oscMixLFO)
        s.setAK1Parameter(.sustainLFO, activePreset.sustainLFO)
        s.setAK1Parameter(.decayLFO, activePreset.decayLFO)
        s.setAK1Parameter(.noiseLFO, activePreset.noiseLFO)
        s.setAK1Parameter(.fmLFO, activePreset.fmLFO)
        s.setAK1Parameter(.detuneLFO, activePreset.detuneLFO)
        s.setAK1Parameter(.filterEnvLFO, activePreset.filterEnvLFO)
        s.setAK1Parameter(.pitchLFO, activePreset.pitchLFO)
        s.setAK1Parameter(.bitcrushLFO, activePreset.bitcrushLFO)
        s.setAK1Parameter(.autopanLFO, activePreset.autopanLFO)
        s.setAK1Parameter(.arpDirection, activePreset.arpDirection)
        s.setAK1Parameter(.arpInterval, activePreset.arpInterval)
        s.setAK1Parameter(.arpIsOn, activePreset.isArpMode)
        s.setAK1Parameter(.arpOctave, activePreset.arpOctave)
        s.setAK1Parameter(.arpRate, activePreset.arpRate)
        s.setAK1Parameter(.arpIsSequencer, activePreset.arpIsSequencer ? 1 : 0 )
        s.setAK1Parameter(.arpTotalSteps, activePreset.arpTotalSteps )
        
        s.setAK1Parameter(.phaserMix, activePreset.phaserMix)
        s.setAK1Parameter(.phaserRate, activePreset.phaserRate)
        s.setAK1Parameter(.phaserFeedback, activePreset.phaserFeedback)
        s.setAK1Parameter(.phaserNotchWidth, activePreset.phaserNotchWidth)
        
        conductor.syncRateToTempo = (activePreset.syncRateToTempo == 1)
        
        for i in 0..<16 {
            s.setAK1ArpSeqPattern(forIndex: i, activePreset.seqPatternNote[i])
            s.setAK1SeqOctBoost(forIndex: i, activePreset.seqOctBoost[i] ? 1 : 0)
            s.setAK1ArpSeqNoteOn(forIndex: i, activePreset.seqNoteOn[i])
        }

        s.setAK1Parameter(.filterType, activePreset.filterType)

        s.resetSequencer()
        
        #if false
        AKLog("----------------------------------------------------------------------")
        AKLog("Preset #\(activePreset.position) \(activePreset.name)")
        for i in 0..<AKSynthOneParameter.count {
            let param : AKSynthOneParameter = AKSynthOneParameter(rawValue: i)!
            let sd = param.simpleDescription()
            AKLog("\(i) = \(sd) = \(s.getAK1Parameter(param))")
        }
        AKLog("END----------------------------------------------------------------------")
            #endif
        
      
    }
    
    func saveValuesToPreset() {
        let s = conductor.synth!
        activePreset.masterVolume = s.getAK1Parameter(.masterVolume)
        activePreset.isMono = s.getAK1Parameter(.isMono)
        activePreset.glide = s.getAK1Parameter(.glide)
        activePreset.waveform1 = s.getAK1Parameter(.index1)
        activePreset.waveform2 = s.getAK1Parameter(.index2)
        activePreset.vco1Semitone = s.getAK1Parameter(.morph1SemitoneOffset)
        activePreset.vco2Semitone = s.getAK1Parameter(.morph2SemitoneOffset)
        activePreset.vco2Detuning = s.getAK1Parameter(.morph2Detuning)
        activePreset.vco1Volume = s.getAK1Parameter(.morph1Volume)
        activePreset.vco2Volume = s.getAK1Parameter(.morph2Volume)
        activePreset.vcoBalance = s.getAK1Parameter(.morphBalance)
        activePreset.subVolume = s.getAK1Parameter(.subVolume)
        activePreset.subOsc24Toggled = s.getAK1Parameter(.subOctaveDown)
        activePreset.subOscSquareToggled = s.getAK1Parameter(.subIsSquare)
        activePreset.fmVolume = s.getAK1Parameter(.fmVolume)
        activePreset.fmMod = s.getAK1Parameter(.fmAmount)
        activePreset.noiseVolume = s.getAK1Parameter(.noiseVolume)
        activePreset.cutoff = s.getAK1Parameter(.cutoff)
        activePreset.rez = s.getAK1Parameter(.resonance)
        activePreset.filterADSRMix = s.getAK1Parameter(.filterADSRMix)
        activePreset.filterAttack = s.getAK1Parameter(.filterAttackDuration)
        activePreset.filterDecay = s.getAK1Parameter(.filterDecayDuration)
        activePreset.filterSustain = s.getAK1Parameter(.filterSustainLevel)
        activePreset.filterRelease = s.getAK1Parameter(.filterReleaseDuration)
        activePreset.attackDuration = s.getAK1Parameter(.attackDuration)
        activePreset.decayDuration = s.getAK1Parameter(.decayDuration)
        activePreset.sustainLevel = s.getAK1Parameter(.sustainLevel)
        activePreset.releaseDuration = s.getAK1Parameter(.releaseDuration)
        activePreset.crushFreq = s.getAK1Parameter(.bitCrushSampleRate)
        activePreset.autoPanAmount = s.getAK1Parameter(.autoPanAmount)
        activePreset.autoPanRate = s.getAK1Parameter(.autoPanFrequency)
        activePreset.reverbToggled = s.getAK1Parameter(.reverbOn)
        activePreset.reverbFeedback = s.getAK1Parameter(.reverbFeedback)
        activePreset.reverbHighPass = s.getAK1Parameter(.reverbHighPass)
        activePreset.reverbMix = s.getAK1Parameter(.reverbMix)
        activePreset.delayToggled = s.getAK1Parameter(.delayOn)
        activePreset.delayFeedback = s.getAK1Parameter(.delayFeedback)
        activePreset.delayTime = s.getAK1Parameter(.delayTime)
        activePreset.delayMix = s.getAK1Parameter(.delayMix)
        activePreset.lfoWaveform = s.getAK1Parameter(.lfo1Index)
        activePreset.lfoAmplitude = s.getAK1Parameter(.lfo1Amplitude)
        activePreset.lfoRate = s.getAK1Parameter(.lfo1Rate)
        activePreset.lfo2Waveform = s.getAK1Parameter(.lfo2Index)
        activePreset.lfo2Amplitude = s.getAK1Parameter(.lfo2Amplitude)
        activePreset.lfo2Rate = s.getAK1Parameter(.lfo2Rate)
        activePreset.cutoffLFO = s.getAK1Parameter(.cutoffLFO)
        activePreset.resonanceLFO = s.getAK1Parameter(.resonanceLFO)
        activePreset.oscMixLFO = s.getAK1Parameter(.oscMixLFO)
        activePreset.sustainLFO = s.getAK1Parameter(.sustainLFO)
        activePreset.decayLFO = s.getAK1Parameter(.decayLFO)
        activePreset.noiseLFO = s.getAK1Parameter(.noiseLFO)
        activePreset.fmLFO = s.getAK1Parameter(.fmLFO)
        activePreset.detuneLFO = s.getAK1Parameter(.detuneLFO)
        activePreset.filterEnvLFO = s.getAK1Parameter(.filterEnvLFO)
        activePreset.pitchLFO = s.getAK1Parameter(.pitchLFO)
        activePreset.bitcrushLFO = s.getAK1Parameter(.bitcrushLFO)
        activePreset.autopanLFO = s.getAK1Parameter(.autopanLFO)
        activePreset.arpDirection = s.getAK1Parameter(.arpDirection)
        activePreset.arpInterval = s.getAK1Parameter(.arpInterval)
        activePreset.arpOctave = s.getAK1Parameter(.arpOctave)
        activePreset.arpRate = s.getAK1Parameter(.arpRate)
        activePreset.arpIsSequencer = s.getAK1Parameter(.arpIsSequencer) > 0 ? true : false
        activePreset.arpTotalSteps = s.getAK1Parameter(.arpTotalSteps)
        activePreset.isArpMode = s.getAK1Parameter(.arpIsOn)
        
        activePreset.phaserMix = s.getAK1Parameter(.phaserMix)
        activePreset.phaserRate = s.getAK1Parameter(.phaserRate)
        activePreset.phaserFeedback = s.getAK1Parameter(.phaserFeedback)
        activePreset.phaserNotchWidth = s.getAK1Parameter(.phaserNotchWidth)
        
        activePreset.syncRateToTempo = conductor.syncRateToTempo ? 1:0
        
        for i in 0..<16 {
            activePreset.seqPatternNote[i] = s.getAK1ArpSeqPattern(forIndex: i)
            activePreset.seqOctBoost[i] = s.getAK1SeqOctBoost(forIndex: i) > 0 ? true : false
            activePreset.seqNoteOn[i] = s.getAK1ArpSeqNoteOn(forIndex: i)
        }

        activePreset.filterType = s.getAK1Parameter(.filterType)
        
        // octave position
        activePreset.octavePosition = keyboardView.firstOctave - 2
        
        // metadata
        activePreset.userText = presetsViewController.currentPreset.userText
        
        presetsViewController.savePreset(activePreset)
    }
}
