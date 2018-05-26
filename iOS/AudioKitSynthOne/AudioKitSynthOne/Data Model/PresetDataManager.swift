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

        guard let s = conductor.synth else {
            print("ERROR:can't read presets if synth is not initialized")
            return
        }

        s.setSynthParameter(.tempoSyncToArpRate, activePreset.tempoSyncToArpRate)
        if !appSettings.freezeArpRate {
            s.setSynthParameter(.arpRate, activePreset.arpRate)
        }
        if !appSettings.freezeDelay {
            s.setAK1Parameter(.delayOn, activePreset.delayToggled)
            s.setAK1Parameter(.delayFeedback, activePreset.delayFeedback)
            s.setAK1Parameter(.delayMix, activePreset.delayMix)
            s.setAK1Parameter(.delayTime, activePreset.delayTime)
            s.setAK1Parameter(.delayInputCutoffTrackingRatio, activePreset.delayInputCutoffTrackingRatio)
            s.setAK1Parameter(.delayInputResonance, activePreset.delayInputResonance)
        }
        if !appSettings.freezeReverb {
            s.setAK1Parameter(.reverbOn, activePreset.reverbToggled)
            s.setAK1Parameter(.reverbFeedback, activePreset.reverbFeedback)
            s.setAK1Parameter(.reverbHighPass, activePreset.reverbHighPass)
            s.setAK1Parameter(.reverbMix, activePreset.reverbMix)
        }
        s.setAK1Parameter(.tempoSyncToArpRate,  activePreset.tempoSyncToArpRate)
        s.setAK1Parameter(.lfo1Rate, activePreset.lfoRate)
        s.setAK1Parameter(.lfo2Rate, activePreset.lfo2Rate)
        s.setAK1Parameter(.autoPanFrequency, activePreset.autoPanFrequency)
        s.setAK1Parameter(.masterVolume, activePreset.masterVolume)
        s.setAK1Parameter(.isMono, activePreset.isMono)
        s.setAK1Parameter(.glide, activePreset.glide)
        s.setAK1Parameter(.widen, activePreset.widen)
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
        s.setAK1Parameter(.fmAmount, activePreset.fmAmount)
        s.setAK1Parameter(.noiseVolume, activePreset.noiseVolume)
        s.setAK1Parameter(.cutoff, activePreset.cutoff)
        s.setAK1Parameter(.resonance, activePreset.resonance)
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
        s.setAK1Parameter(.lfo1Index, activePreset.lfoWaveform)
        s.setAK1Parameter(.lfo1Amplitude, activePreset.lfoAmplitude)
        s.setAK1Parameter(.lfo2Index, activePreset.lfo2Waveform)
        s.setAK1Parameter(.lfo2Amplitude, activePreset.lfo2Amplitude)
        s.setAK1Parameter(.cutoffLFO, activePreset.cutoffLFO)
        s.setAK1Parameter(.resonanceLFO, activePreset.resonanceLFO)
        s.setAK1Parameter(.oscMixLFO, activePreset.oscMixLFO)
        s.setAK1Parameter(.reverbMixLFO, activePreset.reverbMixLFO)
        s.setAK1Parameter(.decayLFO, activePreset.decayLFO)
        s.setAK1Parameter(.noiseLFO, activePreset.noiseLFO)
        s.setAK1Parameter(.fmLFO, activePreset.fmLFO)
        s.setAK1Parameter(.detuneLFO, activePreset.detuneLFO)
        s.setAK1Parameter(.filterEnvLFO, activePreset.filterEnvLFO)
        s.setAK1Parameter(.pitchLFO, activePreset.pitchLFO)
        s.setAK1Parameter(.bitcrushLFO, activePreset.bitcrushLFO)
        s.setAK1Parameter(.tremoloLFO, activePreset.tremoloLFO)
        s.setAK1Parameter(.arpDirection, activePreset.arpDirection)
        s.setAK1Parameter(.arpInterval, activePreset.arpInterval)
        s.setAK1Parameter(.arpIsOn, activePreset.isArpMode)
        s.setAK1Parameter(.arpOctave, activePreset.arpOctave)
        s.setAK1Parameter(.arpIsSequencer, activePreset.arpIsSequencer ? 1 : 0 )
        s.setAK1Parameter(.arpTotalSteps, activePreset.arpTotalSteps )
        s.setAK1Parameter(.monoIsLegato, activePreset.isLegato )
        s.setAK1Parameter(.phaserMix, activePreset.phaserMix)
        s.setAK1Parameter(.phaserRate, activePreset.phaserRate)
        s.setAK1Parameter(.phaserFeedback, activePreset.phaserFeedback)
        s.setAK1Parameter(.phaserNotchWidth, activePreset.phaserNotchWidth)
        for i in 0..<16 {
            s.setPattern(forIndex: i, activePreset.seqPatternNote[i])
            s.setOctaveBoost(forIndex: i, activePreset.seqOctBoost[i] ? 1 : 0)
            s.setNoteOn(forIndex: i, activePreset.seqNoteOn[i])
        }
        s.setSynthParameter(.filterType, activePreset.filterType)
        s.setSynthParameter(.compressorMasterRatio, activePreset.compressorMasterRatio)
        s.setSynthParameter(.compressorReverbInputRatio, activePreset.compressorReverbInputRatio)
        s.setSynthParameter(.compressorReverbWetRatio, activePreset.compressorReverbWetRatio)
        s.setSynthParameter(.compressorMasterThreshold, activePreset.compressorMasterThreshold)
        s.setSynthParameter(.compressorReverbInputThreshold, activePreset.compressorReverbInputThreshold)
        s.setSynthParameter(.compressorReverbWetThreshold, activePreset.compressorReverbWetThreshold)
        s.setSynthParameter(.compressorMasterAttack, activePreset.compressorMasterAttack)
        s.setSynthParameter(.compressorReverbInputAttack, activePreset.compressorReverbInputAttack)
        s.setSynthParameter(.compressorReverbWetAttack, activePreset.compressorReverbWetAttack)
        s.setSynthParameter(.compressorMasterRelease, activePreset.compressorMasterRelease)
        s.setSynthParameter(.compressorReverbInputRelease, activePreset.compressorReverbInputRelease)
        s.setSynthParameter(.compressorReverbWetRelease, activePreset.compressorReverbWetRelease)
        s.setSynthParameter(.compressorMasterMakeupGain, activePreset.compressorMasterMakeupGain)
        s.setSynthParameter(.compressorReverbInputMakeupGain, activePreset.compressorReverbInputMakeupGain)
        s.setSynthParameter(.compressorReverbWetMakeupGain, activePreset.compressorReverbWetMakeupGain)
        s.setSynthParameter(.delayInputCutoffTrackingRatio, activePreset.delayInputCutoffTrackingRatio)
        s.setSynthParameter(.delayInputResonance, activePreset.delayInputResonance)
        s.setSynthParameter(.pitchbendMinSemitones, activePreset.pitchbendMinSemitones)
        s.setSynthParameter(.pitchbendMaxSemitones, activePreset.pitchbendMaxSemitones)

        s.setSynthParameter(.frequencyA4, activePreset.frequencyA4)
        if appSettings.saveTuningWithPreset {
            if let m = activePreset.tuningMasterSet {
                tuningsViewController.setTuning(withMasterArray: m)
            } else {
                tuningsViewController.setDefaultTuning()
            }
        }

        //
        s.resetSequencer()
    }

    func saveValuesToPreset() {
        let s = conductor.synth!
        if !appSettings.freezeArpRate {
            activePreset.arpRate = s.getAK1Parameter(.arpRate)
        }
        if !appSettings.freezeDelay {
            activePreset.delayToggled = s.getAK1Parameter(.delayOn)
            activePreset.delayFeedback = s.getAK1Parameter(.delayFeedback)
            activePreset.delayTime = s.getAK1Parameter(.delayTime)
            activePreset.delayMix = s.getAK1Parameter(.delayMix)
        }
        if !appSettings.freezeReverb {
            activePreset.reverbToggled = s.getAK1Parameter(.reverbOn)
            activePreset.reverbFeedback = s.getAK1Parameter(.reverbFeedback)
            activePreset.reverbHighPass = s.getAK1Parameter(.reverbHighPass)
            activePreset.reverbMix = s.getAK1Parameter(.reverbMix)
        }
        activePreset.tempoSyncToArpRate = s.getAK1Parameter(.tempoSyncToArpRate)
        activePreset.masterVolume = s.getAK1Parameter(.masterVolume)
        activePreset.isMono = s.getAK1Parameter(.isMono)
        activePreset.isLegato = s.getAK1Parameter(.monoIsLegato)
        activePreset.glide = s.getAK1Parameter(.glide)
        activePreset.widen = s.getAK1Parameter(.widen) < 1 ? 0 : 1 // widen is smoothed but want to store only 0 or 1
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
        activePreset.fmAmount = s.getAK1Parameter(.fmAmount)
        activePreset.noiseVolume = s.getAK1Parameter(.noiseVolume)
        activePreset.cutoff = s.getAK1Parameter(.cutoff)
        activePreset.resonance = s.getAK1Parameter(.resonance)
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
        activePreset.autoPanFrequency = s.getAK1Parameter(.autoPanFrequency)
        activePreset.lfoWaveform = s.getAK1Parameter(.lfo1Index)
        activePreset.lfoAmplitude = s.getAK1Parameter(.lfo1Amplitude)
        activePreset.lfoRate = s.getAK1Parameter(.lfo1Rate)
        activePreset.lfo2Waveform = s.getAK1Parameter(.lfo2Index)
        activePreset.lfo2Amplitude = s.getAK1Parameter(.lfo2Amplitude)
        activePreset.lfo2Rate = s.getAK1Parameter(.lfo2Rate)
        activePreset.cutoffLFO = s.getAK1Parameter(.cutoffLFO)
        activePreset.resonanceLFO = s.getAK1Parameter(.resonanceLFO)
        activePreset.oscMixLFO = s.getAK1Parameter(.oscMixLFO)
        activePreset.reverbMixLFO = s.getAK1Parameter(.reverbMixLFO)
        activePreset.decayLFO = s.getAK1Parameter(.decayLFO)
        activePreset.noiseLFO = s.getAK1Parameter(.noiseLFO)
        activePreset.fmLFO = s.getAK1Parameter(.fmLFO)
        activePreset.detuneLFO = s.getAK1Parameter(.detuneLFO)
        activePreset.filterEnvLFO = s.getAK1Parameter(.filterEnvLFO)
        activePreset.pitchLFO = s.getAK1Parameter(.pitchLFO)
        activePreset.bitcrushLFO = s.getAK1Parameter(.bitcrushLFO)
        activePreset.tremoloLFO = s.getAK1Parameter(.tremoloLFO)
        activePreset.arpDirection = s.getAK1Parameter(.arpDirection)
        activePreset.arpInterval = s.getAK1Parameter(.arpInterval)
        activePreset.arpOctave = s.getAK1Parameter(.arpOctave)
        activePreset.arpIsSequencer = s.getAK1Parameter(.arpIsSequencer) > 0 ? true : false
        activePreset.arpTotalSteps = s.getAK1Parameter(.arpTotalSteps)
        activePreset.isArpMode = s.getAK1Parameter(.arpIsOn)
        activePreset.phaserMix = s.getAK1Parameter(.phaserMix)
        activePreset.phaserRate = s.getAK1Parameter(.phaserRate)
        activePreset.phaserFeedback = s.getAK1Parameter(.phaserFeedback)
        activePreset.phaserNotchWidth = s.getAK1Parameter(.phaserNotchWidth)
        for i in 0..<16 {
            activePreset.seqPatternNote[i] = s.getPattern(forIndex: i)
            activePreset.seqOctBoost[i] = s.getOctaveBoost(forIndex: i)
            activePreset.seqNoteOn[i] = s.isNoteOn(forIndex: i)
        }
        activePreset.filterType = s.getSynthParameter(.filterType)
        activePreset.compressorMasterRatio = s.getSynthParameter(.compressorMasterRatio)
        activePreset.compressorReverbInputRatio = s.getSynthParameter(.compressorReverbInputRatio)
        activePreset.compressorReverbWetRatio = s.getSynthParameter(.compressorReverbWetRatio)
        activePreset.compressorMasterThreshold = s.getSynthParameter(.compressorMasterThreshold)
        activePreset.compressorReverbInputThreshold = s.getSynthParameter(.compressorReverbInputThreshold)
        activePreset.compressorReverbWetThreshold = s.getSynthParameter(.compressorReverbWetThreshold)
        activePreset.compressorMasterAttack = s.getSynthParameter(.compressorMasterAttack)
        activePreset.compressorReverbInputAttack = s.getSynthParameter(.compressorReverbInputAttack)
        activePreset.compressorReverbWetAttack = s.getSynthParameter(.compressorReverbWetAttack)
        activePreset.compressorMasterRelease = s.getSynthParameter(.compressorMasterRelease)
        activePreset.compressorReverbInputRelease = s.getSynthParameter(.compressorReverbInputRelease)
        activePreset.compressorReverbWetRelease = s.getSynthParameter(.compressorReverbWetRelease)
        activePreset.compressorMasterMakeupGain = s.getSynthParameter(.compressorMasterMakeupGain)
        activePreset.compressorReverbInputMakeupGain = s.getSynthParameter(.compressorReverbInputMakeupGain)
        activePreset.compressorReverbWetMakeupGain = s.getSynthParameter(.compressorReverbWetMakeupGain)
        activePreset.delayInputCutoffTrackingRatio = s.getSynthParameter(.delayInputCutoffTrackingRatio)
        activePreset.delayInputResonance = s.getSynthParameter(.delayInputResonance)
        activePreset.pitchbendMinSemitones = s.getSynthParameter(.pitchbendMinSemitones)
        activePreset.pitchbendMaxSemitones = s.getSynthParameter(.pitchbendMaxSemitones)

        // tuning
        activePreset.frequencyA4 = s.getSynthParameter(.frequencyA4)
        if appSettings.saveTuningWithPreset {
            activePreset.tuningMasterSet = tuningsViewController.getTuning()
        } else {
            activePreset.tuningMasterSet = nil
        }

        // octave position
        activePreset.octavePosition = keyboardView.firstOctave - 2

        // metadata
        activePreset.userText = presetsViewController.currentPreset.userText

        presetsViewController.savePreset(activePreset)
    }
}
