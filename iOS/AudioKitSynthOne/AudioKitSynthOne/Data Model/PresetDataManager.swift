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
        conductor.synth.setAK1Parameter(.arpSeqPattern00, Double(activePreset.seqPatternNote[0]) )
        conductor.synth.setAK1Parameter(.arpSeqPattern01, Double(activePreset.seqPatternNote[1]) )
        conductor.synth.setAK1Parameter(.arpSeqPattern02, Double(activePreset.seqPatternNote[2]) )
        conductor.synth.setAK1Parameter(.arpSeqPattern03, Double(activePreset.seqPatternNote[3]) )
        conductor.synth.setAK1Parameter(.arpSeqPattern04, Double(activePreset.seqPatternNote[4]) )
        conductor.synth.setAK1Parameter(.arpSeqPattern05, Double(activePreset.seqPatternNote[5]) )
        conductor.synth.setAK1Parameter(.arpSeqPattern06, Double(activePreset.seqPatternNote[6]) )
        conductor.synth.setAK1Parameter(.arpSeqPattern07, Double(activePreset.seqPatternNote[7]) )
        conductor.synth.setAK1Parameter(.arpSeqPattern08, Double(activePreset.seqPatternNote[8]) )
        conductor.synth.setAK1Parameter(.arpSeqPattern09, Double(activePreset.seqPatternNote[9]) )
        conductor.synth.setAK1Parameter(.arpSeqPattern10, Double(activePreset.seqPatternNote[10]) )
        conductor.synth.setAK1Parameter(.arpSeqPattern11, Double(activePreset.seqPatternNote[11]) )
        conductor.synth.setAK1Parameter(.arpSeqPattern12, Double(activePreset.seqPatternNote[12]) )
        conductor.synth.setAK1Parameter(.arpSeqPattern13, Double(activePreset.seqPatternNote[13]) )
        conductor.synth.setAK1Parameter(.arpSeqPattern14, Double(activePreset.seqPatternNote[14]) )
        conductor.synth.setAK1Parameter(.arpSeqPattern15, Double(activePreset.seqPatternNote[15]) )
        conductor.synth.setAK1Parameter(.arpSeqOctBoost00, activePreset.seqOctBoost[0] ? 1 : 0 )
        conductor.synth.setAK1Parameter(.arpSeqOctBoost01, activePreset.seqOctBoost[1] ? 1 : 0 )
        conductor.synth.setAK1Parameter(.arpSeqOctBoost02, activePreset.seqOctBoost[2] ? 1 : 0 )
        conductor.synth.setAK1Parameter(.arpSeqOctBoost03, activePreset.seqOctBoost[3] ? 1 : 0 )
        conductor.synth.setAK1Parameter(.arpSeqOctBoost04, activePreset.seqOctBoost[4] ? 1 : 0 )
        conductor.synth.setAK1Parameter(.arpSeqOctBoost05, activePreset.seqOctBoost[5] ? 1 : 0 )
        conductor.synth.setAK1Parameter(.arpSeqOctBoost06, activePreset.seqOctBoost[6] ? 1 : 0 )
        conductor.synth.setAK1Parameter(.arpSeqOctBoost07, activePreset.seqOctBoost[7] ? 1 : 0 )
        conductor.synth.setAK1Parameter(.arpSeqOctBoost08, activePreset.seqOctBoost[8] ? 1 : 0 )
        conductor.synth.setAK1Parameter(.arpSeqOctBoost09, activePreset.seqOctBoost[9] ? 1 : 0 )
        conductor.synth.setAK1Parameter(.arpSeqOctBoost10, activePreset.seqOctBoost[10] ? 1 : 0 )
        conductor.synth.setAK1Parameter(.arpSeqOctBoost11, activePreset.seqOctBoost[11] ? 1 : 0 )
        conductor.synth.setAK1Parameter(.arpSeqOctBoost12, activePreset.seqOctBoost[12] ? 1 : 0 )
        conductor.synth.setAK1Parameter(.arpSeqOctBoost13, activePreset.seqOctBoost[13] ? 1 : 0 )
        conductor.synth.setAK1Parameter(.arpSeqOctBoost14, activePreset.seqOctBoost[14] ? 1 : 0 )
        conductor.synth.setAK1Parameter(.arpSeqOctBoost15, activePreset.seqOctBoost[15] ? 1 : 0 )
        conductor.synth.setAK1Parameter(.arpSeqNoteOn00, activePreset.seqNoteOn[0] ? 1 : 0 )
        conductor.synth.setAK1Parameter(.arpSeqNoteOn01, activePreset.seqNoteOn[1] ? 1 : 0 )
        conductor.synth.setAK1Parameter(.arpSeqNoteOn02, activePreset.seqNoteOn[2] ? 1 : 0 )
        conductor.synth.setAK1Parameter(.arpSeqNoteOn03, activePreset.seqNoteOn[3] ? 1 : 0 )
        conductor.synth.setAK1Parameter(.arpSeqNoteOn04, activePreset.seqNoteOn[4] ? 1 : 0 )
        conductor.synth.setAK1Parameter(.arpSeqNoteOn05, activePreset.seqNoteOn[5] ? 1 : 0 )
        conductor.synth.setAK1Parameter(.arpSeqNoteOn06, activePreset.seqNoteOn[6] ? 1 : 0 )
        conductor.synth.setAK1Parameter(.arpSeqNoteOn07, activePreset.seqNoteOn[7] ? 1 : 0 )
        conductor.synth.setAK1Parameter(.arpSeqNoteOn08, activePreset.seqNoteOn[8] ? 1 : 0 )
        conductor.synth.setAK1Parameter(.arpSeqNoteOn09, activePreset.seqNoteOn[9] ? 1 : 0 )
        conductor.synth.setAK1Parameter(.arpSeqNoteOn10, activePreset.seqNoteOn[10] ? 1 : 0 )
        conductor.synth.setAK1Parameter(.arpSeqNoteOn11, activePreset.seqNoteOn[11] ? 1 : 0 )
        conductor.synth.setAK1Parameter(.arpSeqNoteOn12, activePreset.seqNoteOn[12] ? 1 : 0 )
        conductor.synth.setAK1Parameter(.arpSeqNoteOn13, activePreset.seqNoteOn[13] ? 1 : 0 )
        conductor.synth.setAK1Parameter(.arpSeqNoteOn14, activePreset.seqNoteOn[14] ? 1 : 0 )
        conductor.synth.setAK1Parameter(.arpSeqNoteOn15, activePreset.seqNoteOn[15] ? 1 : 0 )

        conductor.synth.resetSequencer()
        
        #if false
        ///TODO:REMOVE DEBUG LOGGING
        AKLog("----------------------------------------------------------------------")
        AKLog("Preset #\(activePreset.position) \(activePreset.name)")
        for i in 0..<AKSynthOneParameter.count {
            let param : AKSynthOneParameter = AKSynthOneParameter(rawValue: i)!
            let sd = param.simpleDescription()
            AKLog("\(i) = \(sd) = \(conductor.synth.getAK1Parameter(param))")
        }
        AKLog("END----------------------------------------------------------------------")
            #endif
        
        // Update arpVC AFTER DSP params are set
        seqViewController.setupControlValues()
    }
    
    
    func saveValuesToPreset() {
        activePreset.masterVolume = conductor.synth.parameters[AKSynthOneParameter.masterVolume.rawValue]
        activePreset.isMono = conductor.synth.parameters[AKSynthOneParameter.isMono.rawValue]
        activePreset.glide = conductor.synth.parameters[AKSynthOneParameter.glide.rawValue]
        activePreset.waveform1 = conductor.synth.parameters[AKSynthOneParameter.index1.rawValue]
        activePreset.waveform2 = conductor.synth.parameters[AKSynthOneParameter.index2.rawValue]
        activePreset.vco1Semitone = conductor.synth.parameters[AKSynthOneParameter.morph1SemitoneOffset.rawValue]
        activePreset.vco2Semitone = conductor.synth.parameters[AKSynthOneParameter.morph2SemitoneOffset.rawValue]
        activePreset.vco2Detuning = conductor.synth.parameters[AKSynthOneParameter.morph2Detuning.rawValue]
        activePreset.vco1Volume = conductor.synth.parameters[AKSynthOneParameter.morph1Volume.rawValue]
        activePreset.vco2Volume = conductor.synth.parameters[AKSynthOneParameter.morph2Volume.rawValue]
        activePreset.vcoBalance = conductor.synth.parameters[AKSynthOneParameter.morphBalance.rawValue]
        activePreset.subVolume = conductor.synth.parameters[AKSynthOneParameter.subVolume.rawValue]
        activePreset.subOsc24Toggled = conductor.synth.parameters[AKSynthOneParameter.subOctaveDown.rawValue]
        activePreset.subOscSquareToggled = conductor.synth.parameters[AKSynthOneParameter.subIsSquare.rawValue]
        activePreset.fmVolume = conductor.synth.parameters[AKSynthOneParameter.fmVolume.rawValue]
        activePreset.fmMod = conductor.synth.parameters[AKSynthOneParameter.fmAmount.rawValue]
        activePreset.noiseVolume = conductor.synth.parameters[AKSynthOneParameter.noiseVolume.rawValue]
        activePreset.cutoff = conductor.synth.parameters[AKSynthOneParameter.cutoff.rawValue]
        activePreset.rez = conductor.synth.parameters[AKSynthOneParameter.resonance.rawValue]
        activePreset.filterADSRMix = conductor.synth.parameters[AKSynthOneParameter.filterADSRMix.rawValue]
        activePreset.filterAttack = conductor.synth.parameters[AKSynthOneParameter.filterAttackDuration.rawValue]
        activePreset.filterDecay = conductor.synth.parameters[AKSynthOneParameter.filterDecayDuration.rawValue]
        activePreset.filterSustain = conductor.synth.parameters[AKSynthOneParameter.filterSustainLevel.rawValue]
        activePreset.filterRelease = conductor.synth.parameters[AKSynthOneParameter.filterReleaseDuration.rawValue]
        activePreset.attackDuration = conductor.synth.parameters[AKSynthOneParameter.attackDuration.rawValue]
        activePreset.decayDuration = conductor.synth.parameters[AKSynthOneParameter.decayDuration.rawValue]
        activePreset.sustainLevel = conductor.synth.parameters[AKSynthOneParameter.sustainLevel.rawValue]
        activePreset.releaseDuration = conductor.synth.parameters[AKSynthOneParameter.releaseDuration.rawValue]
        activePreset.crushFreq = conductor.synth.parameters[AKSynthOneParameter.bitCrushSampleRate.rawValue]
        activePreset.autoPanToggled = conductor.synth.parameters[AKSynthOneParameter.autoPanOn.rawValue]
        activePreset.autoPanRate = conductor.synth.parameters[AKSynthOneParameter.autoPanFrequency.rawValue]
        activePreset.reverbToggled = conductor.synth.parameters[AKSynthOneParameter.reverbOn.rawValue]
        activePreset.reverbFeedback = conductor.synth.parameters[AKSynthOneParameter.reverbFeedback.rawValue]
        activePreset.reverbHighPass = conductor.synth.parameters[AKSynthOneParameter.reverbHighPass.rawValue]
        activePreset.reverbMix = conductor.synth.parameters[AKSynthOneParameter.reverbMix.rawValue]
        activePreset.delayToggled = conductor.synth.parameters[AKSynthOneParameter.delayOn.rawValue]
        activePreset.delayFeedback = conductor.synth.parameters[AKSynthOneParameter.delayFeedback.rawValue]
        activePreset.delayTime = conductor.synth.parameters[AKSynthOneParameter.delayTime.rawValue]
        activePreset.delayMix = conductor.synth.parameters[AKSynthOneParameter.delayMix.rawValue]
        activePreset.lfoWaveform = conductor.synth.parameters[AKSynthOneParameter.lfo1Index.rawValue]
        activePreset.lfoAmplitude = conductor.synth.parameters[AKSynthOneParameter.lfo1Amplitude.rawValue]
        activePreset.lfoRate = conductor.synth.parameters[AKSynthOneParameter.lfo1Rate.rawValue]
        activePreset.lfo2Waveform = conductor.synth.parameters[AKSynthOneParameter.lfo2Index.rawValue]
        activePreset.lfo2Amplitude = conductor.synth.parameters[AKSynthOneParameter.lfo2Amplitude.rawValue]
        activePreset.lfo2Rate = conductor.synth.parameters[AKSynthOneParameter.lfo2Rate.rawValue]
        activePreset.cutoffLFO = conductor.synth.parameters[AKSynthOneParameter.cutoffLFO.rawValue]
        activePreset.resonanceLFO = conductor.synth.parameters[AKSynthOneParameter.resonanceLFO.rawValue]
        activePreset.oscMixLFO = conductor.synth.parameters[AKSynthOneParameter.oscMixLFO.rawValue]
        activePreset.sustainLFO = conductor.synth.parameters[AKSynthOneParameter.sustainLFO.rawValue]
        activePreset.index1LFO = conductor.synth.parameters[AKSynthOneParameter.index1LFO.rawValue]
        activePreset.index2LFO = conductor.synth.parameters[AKSynthOneParameter.index2LFO.rawValue]
        activePreset.fmLFO = conductor.synth.parameters[AKSynthOneParameter.fmLFO.rawValue]
        activePreset.detuneLFO = conductor.synth.parameters[AKSynthOneParameter.detuneLFO.rawValue]
        activePreset.filterEnvLFO = conductor.synth.parameters[AKSynthOneParameter.filterEnvLFO.rawValue]
        activePreset.pitchLFO = conductor.synth.parameters[AKSynthOneParameter.pitchLFO.rawValue]
        activePreset.bitcrushLFO = conductor.synth.parameters[AKSynthOneParameter.bitcrushLFO.rawValue]
        activePreset.autopanLFO = conductor.synth.parameters[AKSynthOneParameter.autopanLFO.rawValue]
        activePreset.arpDirection = conductor.synth.getAK1Parameter(.arpDirection)
        activePreset.arpInterval = conductor.synth.getAK1Parameter(.arpInterval)
        activePreset.arpOctave = conductor.synth.getAK1Parameter(.arpOctave)
        activePreset.arpRate = conductor.synth.getAK1Parameter(.arpRate)
        activePreset.arpIsSequencer = conductor.synth.getAK1Parameter(.arpIsSequencer) > 0 ? true : false
        activePreset.arpTotalSteps = conductor.synth.getAK1Parameter(.arpTotalSteps)
        activePreset.isArpMode = conductor.synth.getAK1Parameter(.arpIsOn)
        for i in 0..<16 {
            let aspi = AKSynthOneParameter.arpSeqPattern00.rawValue + i
            let aspp = AKSynthOneParameter(rawValue: aspi) ?? AKSynthOneParameter.arpSeqPattern00
            activePreset.seqPatternNote[i] = Int(conductor.synth.getAK1Parameter(aspp))
            
            let asni = AKSynthOneParameter.arpSeqOctBoost00.rawValue + i
            let asnp = AKSynthOneParameter(rawValue: asni) ?? AKSynthOneParameter.arpSeqOctBoost00
            activePreset.seqOctBoost[i] = conductor.synth.getAK1Parameter(asnp) > 0 ? true : false

            let asoi = AKSynthOneParameter.arpSeqNoteOn00.rawValue + i
            let asop = AKSynthOneParameter(rawValue: asoi) ?? AKSynthOneParameter.arpSeqNoteOn00
            activePreset.seqNoteOn[i] = conductor.synth.getAK1Parameter(asop) > 0 ? true : false
        }
        
        presetsViewController.savePreset(activePreset)
    }
}
