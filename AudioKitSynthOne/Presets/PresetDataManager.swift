//
//  PresetDataManager.swift
//  AudioKitSynthOne
//
//  Created by AudioKit Contributors on 10/23/17.
//  Copyright © 2017 AudioKit. All rights reserved.
//

import Foundation

extension Manager {

    // MARK: - Preset Load/Save

    func loadPreset() {

        guard let s = conductor.synth else {
            print("ERROR:can't load preset if synth is not initialized")
            return
        }

        // The DEV panel has toggles (stored in settings) that impact loading of subsets of parameters of a Preset

        if !appSettings.freezeDelay {
            s.setSynthParameter(.delayOn, activePreset.delayToggled)
            s.setSynthParameter(.delayFeedback, activePreset.delayFeedback)
            s.setSynthParameter(.delayMix, activePreset.delayMix)
            s.setSynthParameter(.delayTime, activePreset.delayTime)
            s.setSynthParameter(.delayInputCutoffTrackingRatio, activePreset.delayInputCutoffTrackingRatio)
            s.setSynthParameter(.delayInputResonance, activePreset.delayInputResonance)
        }

        if !appSettings.freezeReverb {
            s.setSynthParameter(.reverbOn, activePreset.reverbToggled)
            s.setSynthParameter(.reverbFeedback, activePreset.reverbFeedback)
            s.setSynthParameter(.reverbHighPass, activePreset.reverbHighPass)
            s.setSynthParameter(.reverbMix, activePreset.reverbMix)
            s.setSynthParameter(.compressorReverbInputRatio, activePreset.compressorReverbInputRatio)
            s.setSynthParameter(.compressorReverbWetRatio, activePreset.compressorReverbWetRatio)
            s.setSynthParameter(.compressorReverbInputThreshold, activePreset.compressorReverbInputThreshold)
            s.setSynthParameter(.compressorReverbWetThreshold, activePreset.compressorReverbWetThreshold)
            s.setSynthParameter(.compressorReverbInputAttack, activePreset.compressorReverbInputAttack)
            s.setSynthParameter(.compressorReverbWetAttack, activePreset.compressorReverbWetAttack)
            s.setSynthParameter(.compressorReverbInputRelease, activePreset.compressorReverbInputRelease)
            s.setSynthParameter(.compressorReverbWetRelease, activePreset.compressorReverbWetRelease)
            s.setSynthParameter(.compressorReverbInputMakeupGain, activePreset.compressorReverbInputMakeupGain)
            s.setSynthParameter(.compressorReverbWetMakeupGain, activePreset.compressorReverbWetMakeupGain)
        }

        if !appSettings.freezeArpRate {
            s.setSynthParameter(.arpRate, activePreset.arpRate)
        }

        if !appSettings.freezeArpSeq {
            s.setSynthParameter(.arpIsOn, activePreset.isArpMode)
            s.setSynthParameter(.arpIsSequencer, activePreset.arpIsSequencer ? 1 : 0 )
            s.setSynthParameter(.arpDirection, activePreset.arpDirection)
            s.setSynthParameter(.arpInterval, activePreset.arpInterval)
            s.setSynthParameter(.arpOctave, activePreset.arpOctave)
            s.setSynthParameter(.arpTotalSteps, activePreset.arpTotalSteps )
            s.setSynthParameter(.arpSeqTempoMultiplier, activePreset.arpSeqTempoMultiplier)
            for i in 0..<16 {
                s.setPattern(forIndex: i, activePreset.seqPatternNote[i])
                s.setOctaveBoost(forIndex: i, activePreset.seqOctBoost[i] ? 1 : 0)
                s.setNoteOn(forIndex: i, activePreset.seqNoteOn[i])
            }
        }

        if appSettings.saveTuningWithPreset {
            if let m = activePreset.tuningMasterSet {
                tuningsPanel.setTuning(name: activePreset.tuningName, masterArray: m)
            } else {
                tuningsPanel.setDefaultTuning()
            }
        }

        s.setSynthParameter(.tempoSyncToArpRate, activePreset.tempoSyncToArpRate)
        s.setSynthParameter(.lfo1Rate, activePreset.lfoRate)
        s.setSynthParameter(.lfo2Rate, activePreset.lfo2Rate)
        s.setSynthParameter(.autoPanFrequency, activePreset.autoPanFrequency)
        s.setSynthParameter(.masterVolume, activePreset.masterVolume)
        s.setSynthParameter(.isMono, activePreset.isMono)
        s.setSynthParameter(.glide, activePreset.glide)
        s.setSynthParameter(.widen, activePreset.widen)
        s.setSynthParameter(.index1, activePreset.waveform1)
        s.setSynthParameter(.index2, activePreset.waveform2)
        s.setSynthParameter(.morph1SemitoneOffset, activePreset.vco1Semitone)
        s.setSynthParameter(.morph2SemitoneOffset, activePreset.vco2Semitone)
        s.setSynthParameter(.morph2Detuning, activePreset.vco2Detuning)
        s.setSynthParameter(.morph1Volume, activePreset.vco1Volume)
        s.setSynthParameter(.morph2Volume, activePreset.vco2Volume)
        s.setSynthParameter(.morphBalance, activePreset.vcoBalance)
        s.setSynthParameter(.subVolume, activePreset.subVolume)
        s.setSynthParameter(.subOctaveDown, activePreset.subOsc24Toggled)
        s.setSynthParameter(.subIsSquare, activePreset.subOscSquareToggled)
        s.setSynthParameter(.fmVolume, activePreset.fmVolume)
        s.setSynthParameter(.fmAmount, activePreset.fmAmount)
        s.setSynthParameter(.noiseVolume, activePreset.noiseVolume)
        s.setSynthParameter(.cutoff, activePreset.cutoff)
        s.setSynthParameter(.resonance, activePreset.resonance)
        s.setSynthParameter(.filterADSRMix, activePreset.filterADSRMix)
        s.setSynthParameter(.filterAttackDuration, activePreset.filterAttack)
        s.setSynthParameter(.filterDecayDuration, activePreset.filterDecay)
        s.setSynthParameter(.filterSustainLevel, activePreset.filterSustain)
        s.setSynthParameter(.filterReleaseDuration, activePreset.filterRelease)
        s.setSynthParameter(.attackDuration, activePreset.attackDuration)
        s.setSynthParameter(.decayDuration, activePreset.decayDuration)
        s.setSynthParameter(.sustainLevel, activePreset.sustainLevel)
        s.setSynthParameter(.releaseDuration, activePreset.releaseDuration)
        s.setSynthParameter(.bitCrushSampleRate, activePreset.crushFreq)
        s.setSynthParameter(.autoPanAmount, activePreset.autoPanAmount)
        s.setSynthParameter(.lfo1Index, activePreset.lfoWaveform)
        s.setSynthParameter(.lfo1Amplitude, activePreset.lfoAmplitude)
        s.setSynthParameter(.lfo2Index, activePreset.lfo2Waveform)
        s.setSynthParameter(.lfo2Amplitude, activePreset.lfo2Amplitude)
        s.setSynthParameter(.cutoffLFO, activePreset.cutoffLFO)
        s.setSynthParameter(.resonanceLFO, activePreset.resonanceLFO)
        s.setSynthParameter(.oscMixLFO, activePreset.oscMixLFO)
        s.setSynthParameter(.reverbMixLFO, activePreset.reverbMixLFO)
        s.setSynthParameter(.decayLFO, activePreset.decayLFO)
        s.setSynthParameter(.noiseLFO, activePreset.noiseLFO)
        s.setSynthParameter(.fmLFO, activePreset.fmLFO)
        s.setSynthParameter(.detuneLFO, activePreset.detuneLFO)
        s.setSynthParameter(.filterEnvLFO, activePreset.filterEnvLFO)
        s.setSynthParameter(.pitchLFO, activePreset.pitchLFO)
        s.setSynthParameter(.bitcrushLFO, activePreset.bitcrushLFO)
        s.setSynthParameter(.tremoloLFO, activePreset.tremoloLFO)
        s.setSynthParameter(.monoIsLegato, activePreset.isLegato )
        s.setSynthParameter(.phaserMix, activePreset.phaserMix)
        s.setSynthParameter(.phaserRate, activePreset.phaserRate)
        s.setSynthParameter(.phaserFeedback, activePreset.phaserFeedback)
        s.setSynthParameter(.phaserNotchWidth, activePreset.phaserNotchWidth)
        s.setSynthParameter(.filterType, activePreset.filterType)
        s.setSynthParameter(.compressorMasterThreshold, activePreset.compressorMasterThreshold)
        s.setSynthParameter(.compressorMasterRatio, activePreset.compressorMasterRatio)
        s.setSynthParameter(.compressorMasterAttack, activePreset.compressorMasterAttack)
        s.setSynthParameter(.compressorMasterRelease, activePreset.compressorMasterRelease)
        s.setSynthParameter(.compressorMasterMakeupGain, activePreset.compressorMasterMakeupGain)
        s.setSynthParameter(.pitchbendMinSemitones, activePreset.pitchbendMinSemitones)
        s.setSynthParameter(.pitchbendMaxSemitones, activePreset.pitchbendMaxSemitones)
        s.setSynthParameter(.frequencyA4, activePreset.frequencyA4)
        s.setSynthParameter(.oscBandlimitEnable, activePreset.oscBandlimitEnable)
        s.setSynthParameter(.transpose, Double(activePreset.transpose))
        s.setSynthParameter(.adsrPitchTracking, activePreset.adsrPitchTracking)

        s.resetSequencer()
        conductor.updateDefaultValues()
    }

    func saveValuesToPreset() {
        guard let s = conductor.synth else {
            AKLog("Could not save synth state to preset because synth is not instantiated")
            return
        }

        activePreset.arpRate = s.getSynthParameter(.arpRate)
        activePreset.delayToggled = s.getSynthParameter(.delayOn)
        activePreset.delayFeedback = s.getSynthParameter(.delayFeedback)
        activePreset.delayTime = s.getSynthParameter(.delayTime)
        activePreset.delayMix = s.getSynthParameter(.delayMix)
        activePreset.reverbToggled = s.getSynthParameter(.reverbOn)
        activePreset.reverbFeedback = s.getSynthParameter(.reverbFeedback)
        activePreset.reverbHighPass = s.getSynthParameter(.reverbHighPass)
        activePreset.reverbMix = s.getSynthParameter(.reverbMix)
        activePreset.tempoSyncToArpRate = s.getSynthParameter(.tempoSyncToArpRate)
        activePreset.masterVolume = s.getSynthParameter(.masterVolume)
        activePreset.isMono = s.getSynthParameter(.isMono)
        activePreset.isLegato = s.getSynthParameter(.monoIsLegato)
        activePreset.glide = s.getSynthParameter(.glide)
        activePreset.widen = s.getSynthParameter(.widen) < 1 ? 0 : 1 // widen is smoothed but want to store only 0 or 1
        activePreset.waveform1 = s.getSynthParameter(.index1)
        activePreset.waveform2 = s.getSynthParameter(.index2)
        activePreset.vco1Semitone = s.getSynthParameter(.morph1SemitoneOffset)
        activePreset.vco2Semitone = s.getSynthParameter(.morph2SemitoneOffset)
        activePreset.vco2Detuning = s.getSynthParameter(.morph2Detuning)
        activePreset.vco1Volume = s.getSynthParameter(.morph1Volume)
        activePreset.vco2Volume = s.getSynthParameter(.morph2Volume)
        activePreset.vcoBalance = s.getSynthParameter(.morphBalance)
        activePreset.subVolume = s.getSynthParameter(.subVolume)
        activePreset.subOsc24Toggled = s.getSynthParameter(.subOctaveDown)
        activePreset.subOscSquareToggled = s.getSynthParameter(.subIsSquare)
        activePreset.fmVolume = s.getSynthParameter(.fmVolume)
        activePreset.fmAmount = s.getSynthParameter(.fmAmount)
        activePreset.noiseVolume = s.getSynthParameter(.noiseVolume)
        activePreset.cutoff = s.getSynthParameter(.cutoff)
        activePreset.resonance = s.getSynthParameter(.resonance)
        activePreset.filterADSRMix = s.getSynthParameter(.filterADSRMix)
        activePreset.filterAttack = s.getSynthParameter(.filterAttackDuration)
        activePreset.filterDecay = s.getSynthParameter(.filterDecayDuration)
        activePreset.filterSustain = s.getSynthParameter(.filterSustainLevel)
        activePreset.filterRelease = s.getSynthParameter(.filterReleaseDuration)
        activePreset.attackDuration = s.getSynthParameter(.attackDuration)
        activePreset.decayDuration = s.getSynthParameter(.decayDuration)
        activePreset.sustainLevel = s.getSynthParameter(.sustainLevel)
        activePreset.releaseDuration = s.getSynthParameter(.releaseDuration)
        activePreset.crushFreq = s.getSynthParameter(.bitCrushSampleRate)
        activePreset.autoPanAmount = s.getSynthParameter(.autoPanAmount)
        activePreset.autoPanFrequency = s.getSynthParameter(.autoPanFrequency)
        activePreset.reverbToggled = s.getSynthParameter(.reverbOn)
        activePreset.reverbFeedback = s.getSynthParameter(.reverbFeedback)
        activePreset.reverbHighPass = s.getSynthParameter(.reverbHighPass)
        activePreset.reverbMix = s.getSynthParameter(.reverbMix)
        activePreset.delayToggled = s.getSynthParameter(.delayOn)
        activePreset.delayFeedback = s.getSynthParameter(.delayFeedback)
        activePreset.delayTime = s.getSynthParameter(.delayTime)
        activePreset.delayMix = s.getSynthParameter(.delayMix)
        activePreset.lfoWaveform = s.getSynthParameter(.lfo1Index)
        activePreset.lfoAmplitude = s.getSynthParameter(.lfo1Amplitude)
        activePreset.lfoRate = s.getSynthParameter(.lfo1Rate)
        activePreset.lfo2Waveform = s.getSynthParameter(.lfo2Index)
        activePreset.lfo2Amplitude = s.getSynthParameter(.lfo2Amplitude)
        activePreset.lfo2Rate = s.getSynthParameter(.lfo2Rate)
        activePreset.cutoffLFO = s.getSynthParameter(.cutoffLFO)
        activePreset.resonanceLFO = s.getSynthParameter(.resonanceLFO)
        activePreset.oscMixLFO = s.getSynthParameter(.oscMixLFO)
        activePreset.reverbMixLFO = s.getSynthParameter(.reverbMixLFO)
        activePreset.decayLFO = s.getSynthParameter(.decayLFO)
        activePreset.noiseLFO = s.getSynthParameter(.noiseLFO)
        activePreset.fmLFO = s.getSynthParameter(.fmLFO)
        activePreset.detuneLFO = s.getSynthParameter(.detuneLFO)
        activePreset.filterEnvLFO = s.getSynthParameter(.filterEnvLFO)
        activePreset.pitchLFO = s.getSynthParameter(.pitchLFO)
        activePreset.bitcrushLFO = s.getSynthParameter(.bitcrushLFO)
        activePreset.tremoloLFO = s.getSynthParameter(.tremoloLFO)
        activePreset.arpDirection = s.getSynthParameter(.arpDirection)
        activePreset.arpInterval = s.getSynthParameter(.arpInterval)
        activePreset.arpOctave = s.getSynthParameter(.arpOctave)
        activePreset.arpIsSequencer = s.getSynthParameter(.arpIsSequencer) > 0 ? true : false
        activePreset.arpTotalSteps = s.getSynthParameter(.arpTotalSteps)
        activePreset.isArpMode = s.getSynthParameter(.arpIsOn)
        activePreset.phaserMix = s.getSynthParameter(.phaserMix)
        activePreset.phaserRate = s.getSynthParameter(.phaserRate)
        activePreset.phaserFeedback = s.getSynthParameter(.phaserFeedback)
        activePreset.phaserNotchWidth = s.getSynthParameter(.phaserNotchWidth)
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
        activePreset.oscBandlimitEnable = s.getSynthParameter(.oscBandlimitEnable)
        activePreset.arpSeqTempoMultiplier = s.getSynthParameter(.arpSeqTempoMultiplier)
        activePreset.transpose = Int(s.getSynthParameter(.transpose))
        activePreset.adsrPitchTracking = s.getSynthParameter(.adsrPitchTracking)

        // tuning
        activePreset.frequencyA4 = s.getSynthParameter(.frequencyA4)
        if appSettings.saveTuningWithPreset {
            let t = tuningsPanel.getTuning()
            activePreset.tuningName = t.0
            activePreset.tuningMasterSet = t.1
        } else {
            activePreset.tuningName = nil
            activePreset.tuningMasterSet = nil
        }

        // octave position
        activePreset.octavePosition = keyboardView.firstOctave - 2

        // metadata
        activePreset.userText = presetsViewController.currentPreset.userText

        presetsViewController.savePreset(activePreset)
        conductor.updateDefaultValues()
    }
}
