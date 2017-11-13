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
        
        ///TODO: NEED TO VALIDATE RANGE OF index1, index2 VS. waveform1, waveform2
        ///TODO: index1 is on [0,1], waveform1 is on [0,4).
        conductor.synth.parameters[AKSynthOneParameter.index1.rawValue] = activePreset.waveform1/4.0
        conductor.synth.parameters[AKSynthOneParameter.index2.rawValue] = activePreset.waveform2/4.0
        ///////////////////
        
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
        
        // Arp/Sequencer
        //conductor.synth.arpBeatCounter = 0 // synth arp is reset after all the following parameters are set
        conductor.synth.parameters[AKSynthOneParameter.arpDirection.rawValue] = activePreset.arpDirection
        conductor.synth.parameters[AKSynthOneParameter.arpInterval.rawValue] = activePreset.arpInterval
        conductor.synth.parameters[AKSynthOneParameter.arpIsOn.rawValue] = activePreset.isArpMode
        conductor.synth.parameters[AKSynthOneParameter.arpOctave.rawValue] = activePreset.arpOctave
        conductor.synth.parameters[AKSynthOneParameter.arpRate.rawValue] = activePreset.arpRate
        conductor.synth.parameters[AKSynthOneParameter.arpIsSequencer.rawValue] = activePreset.arpIsSequencer ? 1 : 0
        conductor.synth.parameters[AKSynthOneParameter.arpTotalSteps.rawValue] = activePreset.arpTotalSteps
        conductor.synth.parameters[AKSynthOneParameter.arpSeqPattern00.rawValue] = Double(activePreset.seqPatternNote[0])
        conductor.synth.parameters[AKSynthOneParameter.arpSeqPattern01.rawValue] = Double(activePreset.seqPatternNote[1])
        conductor.synth.parameters[AKSynthOneParameter.arpSeqPattern02.rawValue] = Double(activePreset.seqPatternNote[2])
        conductor.synth.parameters[AKSynthOneParameter.arpSeqPattern03.rawValue] = Double(activePreset.seqPatternNote[3])
        conductor.synth.parameters[AKSynthOneParameter.arpSeqPattern04.rawValue] = Double(activePreset.seqPatternNote[4])
        conductor.synth.parameters[AKSynthOneParameter.arpSeqPattern05.rawValue] = Double(activePreset.seqPatternNote[5])
        conductor.synth.parameters[AKSynthOneParameter.arpSeqPattern06.rawValue] = Double(activePreset.seqPatternNote[6])
        conductor.synth.parameters[AKSynthOneParameter.arpSeqPattern07.rawValue] = Double(activePreset.seqPatternNote[7])
        conductor.synth.parameters[AKSynthOneParameter.arpSeqPattern08.rawValue] = Double(activePreset.seqPatternNote[8])
        conductor.synth.parameters[AKSynthOneParameter.arpSeqPattern09.rawValue] = Double(activePreset.seqPatternNote[9])
        conductor.synth.parameters[AKSynthOneParameter.arpSeqPattern10.rawValue] = Double(activePreset.seqPatternNote[10])
        conductor.synth.parameters[AKSynthOneParameter.arpSeqPattern11.rawValue] = Double(activePreset.seqPatternNote[11])
        conductor.synth.parameters[AKSynthOneParameter.arpSeqPattern12.rawValue] = Double(activePreset.seqPatternNote[12])
        conductor.synth.parameters[AKSynthOneParameter.arpSeqPattern13.rawValue] = Double(activePreset.seqPatternNote[13])
        conductor.synth.parameters[AKSynthOneParameter.arpSeqPattern14.rawValue] = Double(activePreset.seqPatternNote[14])
        conductor.synth.parameters[AKSynthOneParameter.arpSeqPattern15.rawValue] = Double(activePreset.seqPatternNote[15])
        conductor.synth.parameters[AKSynthOneParameter.arpSeqOctBoost00.rawValue] = activePreset.seqOctBoost[0] ? 1 : 0
        conductor.synth.parameters[AKSynthOneParameter.arpSeqOctBoost01.rawValue] = activePreset.seqOctBoost[1] ? 1 : 0
        conductor.synth.parameters[AKSynthOneParameter.arpSeqOctBoost02.rawValue] = activePreset.seqOctBoost[2] ? 1 : 0
        conductor.synth.parameters[AKSynthOneParameter.arpSeqOctBoost03.rawValue] = activePreset.seqOctBoost[3] ? 1 : 0
        conductor.synth.parameters[AKSynthOneParameter.arpSeqOctBoost04.rawValue] = activePreset.seqOctBoost[4] ? 1 : 0
        conductor.synth.parameters[AKSynthOneParameter.arpSeqOctBoost05.rawValue] = activePreset.seqOctBoost[5] ? 1 : 0
        conductor.synth.parameters[AKSynthOneParameter.arpSeqOctBoost06.rawValue] = activePreset.seqOctBoost[6] ? 1 : 0
        conductor.synth.parameters[AKSynthOneParameter.arpSeqOctBoost07.rawValue] = activePreset.seqOctBoost[7] ? 1 : 0
        conductor.synth.parameters[AKSynthOneParameter.arpSeqOctBoost08.rawValue] = activePreset.seqOctBoost[8] ? 1 : 0
        conductor.synth.parameters[AKSynthOneParameter.arpSeqOctBoost09.rawValue] = activePreset.seqOctBoost[9] ? 1 : 0
        conductor.synth.parameters[AKSynthOneParameter.arpSeqOctBoost10.rawValue] = activePreset.seqOctBoost[10] ? 1 : 0
        conductor.synth.parameters[AKSynthOneParameter.arpSeqOctBoost11.rawValue] = activePreset.seqOctBoost[11] ? 1 : 0
        conductor.synth.parameters[AKSynthOneParameter.arpSeqOctBoost12.rawValue] = activePreset.seqOctBoost[12] ? 1 : 0
        conductor.synth.parameters[AKSynthOneParameter.arpSeqOctBoost13.rawValue] = activePreset.seqOctBoost[13] ? 1 : 0
        conductor.synth.parameters[AKSynthOneParameter.arpSeqOctBoost14.rawValue] = activePreset.seqOctBoost[14] ? 1 : 0
        conductor.synth.parameters[AKSynthOneParameter.arpSeqOctBoost15.rawValue] = activePreset.seqOctBoost[15] ? 1 : 0
        conductor.synth.parameters[AKSynthOneParameter.arpSeqNoteOn00.rawValue] = activePreset.seqNoteOn[0] ? 1 : 0
        conductor.synth.parameters[AKSynthOneParameter.arpSeqNoteOn01.rawValue] = activePreset.seqNoteOn[1] ? 1 : 0
        conductor.synth.parameters[AKSynthOneParameter.arpSeqNoteOn02.rawValue] = activePreset.seqNoteOn[2] ? 1 : 0
        conductor.synth.parameters[AKSynthOneParameter.arpSeqNoteOn03.rawValue] = activePreset.seqNoteOn[3] ? 1 : 0
        conductor.synth.parameters[AKSynthOneParameter.arpSeqNoteOn04.rawValue] = activePreset.seqNoteOn[4] ? 1 : 0
        conductor.synth.parameters[AKSynthOneParameter.arpSeqNoteOn05.rawValue] = activePreset.seqNoteOn[5] ? 1 : 0
        conductor.synth.parameters[AKSynthOneParameter.arpSeqNoteOn06.rawValue] = activePreset.seqNoteOn[6] ? 1 : 0
        conductor.synth.parameters[AKSynthOneParameter.arpSeqNoteOn07.rawValue] = activePreset.seqNoteOn[7] ? 1 : 0
        conductor.synth.parameters[AKSynthOneParameter.arpSeqNoteOn08.rawValue] = activePreset.seqNoteOn[8] ? 1 : 0
        conductor.synth.parameters[AKSynthOneParameter.arpSeqNoteOn09.rawValue] = activePreset.seqNoteOn[9] ? 1 : 0
        conductor.synth.parameters[AKSynthOneParameter.arpSeqNoteOn10.rawValue] = activePreset.seqNoteOn[10] ? 1 : 0
        conductor.synth.parameters[AKSynthOneParameter.arpSeqNoteOn11.rawValue] = activePreset.seqNoteOn[11] ? 1 : 0
        conductor.synth.parameters[AKSynthOneParameter.arpSeqNoteOn12.rawValue] = activePreset.seqNoteOn[12] ? 1 : 0
        conductor.synth.parameters[AKSynthOneParameter.arpSeqNoteOn13.rawValue] = activePreset.seqNoteOn[13] ? 1 : 0
        conductor.synth.parameters[AKSynthOneParameter.arpSeqNoteOn14.rawValue] = activePreset.seqNoteOn[14] ? 1 : 0
        conductor.synth.parameters[AKSynthOneParameter.arpSeqNoteOn15.rawValue] = activePreset.seqNoteOn[15] ? 1 : 0

        ///TODO:remove activeArp when conversion is complete
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
        ///////////
        
        conductor.synth.resetSequencer()
        
        AKLog("----------------------------------------------------------------------")
        AKLog("Preset #\(activePreset.position) \(activePreset.name)")
        for i in 0..<AKSynthOneParameter.count {
            let sd = AKSynthOneParameter(rawValue: i)?.simpleDescription() ?? ""
            AKLog("conductor.synth.parameters[\(i)] = \(sd) = \(conductor.synth.parameters[i])")
        }
        AKLog("END----------------------------------------------------------------------")

        // Update arpVC
        //seqViewController.arpeggiator = activeArp
        //seqViewController.setupControlValues()
        
        // Arp Toggle
        //arpToggle.isSelected = !preset.arpToggled
        
        // filterMix = 18,
        // tempoSync
        // octave position
        
        // Display new preset name in header
        let message = "\(activePreset.position): \(activePreset.name)"
        updateDisplay(message)
        
    }
    
    func saveValuesToPreset() {
        activePreset.vcoBalance = conductor.synth.parameters[AKSynthOneParameter.morphBalance.rawValue]
        activePreset.rez = conductor.synth.parameters[AKSynthOneParameter.resonance.rawValue]
        activePreset.cutoff = conductor.synth.parameters[AKSynthOneParameter.cutoff.rawValue]
        ///TODO:Why is savePreset commented out?  Because this method is not fleshed out?
        //presetsViewController.savePreset(activePreset)
    }
}
