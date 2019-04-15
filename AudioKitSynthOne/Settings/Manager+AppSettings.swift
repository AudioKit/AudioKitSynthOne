//
//  Manager+AppSettingsDataManager.swift
//  AudioKitSynthOne
//
//  Created by AudioKit Contributors on 10/31/17.
//  Copyright © 2018 AudioKit. All rights reserved.
//

import AudioKit
import UIKit
import Disk

extension Manager {

    // MARK: - Map App Settings to Controls

    func setDefaultsFromAppSettings() {

        // MIDI
        conductor.backgroundAudio = appSettings.backgroundAudio
        conductor.neverSleep = appSettings.neverSleep 
        midiChannelIn = MIDIByte(appSettings.midiChannel)
        omniMode = appSettings.omniMode
        AKSettings.bufferLength = AKSettings.BufferLength(rawValue:appSettings.bufferLengthRawValue) ?? .short

        do {
            try AKTry {
                try AVAudioSession.sharedInstance().setPreferredIOBufferDuration(AKSettings.bufferLength.duration)
            }
        } catch let error as NSError {
            AKLog("AKSettings Error: Cannot set Preferred IOBufferDuration to " +
                "\(AKSettings.bufferLength.duration) ( = \(AKSettings.bufferLength.samplesCount) samples)")
            AKLog("AKSettings Error: \(error))")
        }

        // DEV PANEL
        devViewController.freezeArpRate.value = (appSettings.freezeArpRate == true ? 1 : 0)
        devViewController.freezeDelay.value = (appSettings.freezeDelay == true ? 1 : 0)
        devViewController.freezeReverb.value = (appSettings.freezeReverb == true ? 1 : 0)
        devViewController.freezeArpSeq.value = (appSettings.freezeArpSeq == true ? 1 : 0)
        devViewController.whiteKeysOnly.value = (appSettings.whiteKeysOnly == true ? 1 : 0)

        // DSP parameter stored in app settings
        conductor.synth.setSynthParameter(.portamentoHalfTime, appSettings.portamentoHalfTime)
        devViewController.portamento.value = conductor.synth.getSynthParameter(.portamentoHalfTime)

        // keyboard
        keyboardView.labelMode = appSettings.labelMode
        keyboardView.octaveCount = appSettings.octaveRange
        keyboardView.darkMode = appSettings.darkMode

        // MIDI Learn Generators
        generatorsPanel.masterVolume.midiCC = MIDIByte(appSettings.masterVolumeCC)
        generatorsPanel.morph1SemitoneOffset.midiCC = MIDIByte(appSettings.morph1SemitoneOffsetCC)
        generatorsPanel.morph2SemitoneOffset.midiCC = MIDIByte(appSettings.morph2SemitoneOffsetCC)
        generatorsPanel.morph2Detuning.midiCC = MIDIByte(appSettings.morph2DetuningCC)
        generatorsPanel.morphBalance.midiCC = MIDIByte(appSettings.morphBalanceCC)
        generatorsPanel.morph1Volume.midiCC = MIDIByte(appSettings.morph1VolumeCC)
        generatorsPanel.morph2Volume.midiCC = MIDIByte(appSettings.morph2VolumeCC)
        generatorsPanel.subVolume.midiCC = MIDIByte(appSettings.subVolumeCC)
        generatorsPanel.fmVolume.midiCC = MIDIByte(appSettings.fmVolumeCC)
        generatorsPanel.fmAmount.midiCC = MIDIByte(appSettings.fmAmountCC)
        generatorsPanel.noiseVolume.midiCC = MIDIByte(appSettings.noiseVolumeCC)
        generatorsPanel.glideKnob.midiCC = MIDIByte(appSettings.glideKnobCC)
        generatorsPanel.cutoff.midiCC = MIDIByte(appSettings.cutoffCC)
        generatorsPanel.resonance.midiCC = MIDIByte(appSettings.resonanceCC)

        // MIDI Learn ADSR
        envelopesPanel.attackKnob.midiCC = MIDIByte(appSettings.attackKnobCC)
        envelopesPanel.decayKnob.midiCC = MIDIByte(appSettings.decayKnobCC)
        envelopesPanel.sustainKnob.midiCC = MIDIByte(appSettings.sustainKnobCC)
        envelopesPanel.releaseKnob.midiCC = MIDIByte(appSettings.releaseKnobCC)
        envelopesPanel.filterAttackKnob.midiCC = MIDIByte(appSettings.filterAttackKnobCC)
        envelopesPanel.filterDecayKnob.midiCC = MIDIByte(appSettings.filterDecayKnobCC)
        envelopesPanel.filterSustainKnob.midiCC = MIDIByte(appSettings.filterSustainKnobCC)
        envelopesPanel.filterReleaseKnob.midiCC = MIDIByte(appSettings.filterReleaseKnobCC)
        envelopesPanel.filterADSRMixKnob.midiCC = MIDIByte(appSettings.filterADSRMixKnobCC)
        envelopesPanel.adsrPitchTrackingKnob.midiCC = MIDIByte(appSettings.adsrPitchTrackingKnobCC)

        // MIDI Learn FX
        fxPanel.sampleRateKnob.midiCC = MIDIByte(appSettings.sampleRateCC)
        fxPanel.autoPanRateKnob.midiCC = MIDIByte(appSettings.autoPanRateCC)
        fxPanel.autoPanAmountKnob.midiCC = MIDIByte(appSettings.autoPanAmountCC)
        fxPanel.reverbSizeKnob.midiCC = MIDIByte(appSettings.reverbSizeCC)
        fxPanel.reverbLowCutKnob.midiCC = MIDIByte(appSettings.reverbLowCutCC)
        fxPanel.reverbMixKnob.midiCC = MIDIByte(appSettings.reverbMixCC)
        fxPanel.delayTimeKnob.midiCC = MIDIByte(appSettings.delayTimeCC)
        fxPanel.delayFeedbackKnob.midiCC = MIDIByte(appSettings.delayFeedbackCC)
        fxPanel.delayMixKnob.midiCC = MIDIByte(appSettings.delayMixCC)
        fxPanel.lfo1AmpKnob.midiCC = MIDIByte(appSettings.lfo1AmpCC)
        fxPanel.lfo2AmpKnob.midiCC = MIDIByte(appSettings.lfo2AmpCC)
        fxPanel.lfo1RateKnob.midiCC = MIDIByte(appSettings.lfo1RateCC)
        fxPanel.lfo2RateKnob.midiCC = MIDIByte(appSettings.lfo2RateCC)
        fxPanel.phaserMixKnob.midiCC = MIDIByte(appSettings.phaserMixCC)
        fxPanel.phaserRateKnob.midiCC = MIDIByte(appSettings.phaserRateCC)
        fxPanel.phaserFeedbackKnob.midiCC = MIDIByte(appSettings.phaserFeedbackCC)
        fxPanel.phaserNotchWidthKnob.midiCC = MIDIByte(appSettings.phaserNotchWidthCC)

        // MIDI Learn Arp/Seq
        sequencerPanel.sequencerToggle.midiCC = MIDIByte(appSettings.sequencerToggleCC)
        sequencerPanel.arpSeqTempoMultiplier.midiCC = MIDIByte(appSettings.arpSeqTempoMultiplierCC)
        sequencerPanel.arpInterval.midiCC = MIDIByte(appSettings.arpIntervalCC)
        sequencerPanel.arpToggle.midiCC = MIDIByte(appSettings.arpToggleCC)
        sequencerPanel.octaveStepper.midiCC = MIDIByte(appSettings.octaveStepperCC)
        sequencerPanel.arpDirectionButton.midiCC = MIDIByte(appSettings.arpDirectionButtonCC)
        sequencerPanel.seqStepsStepper.midiCC = MIDIByte(appSettings.seqStepsStepperCC)

        // MIDI Learn Keyboard
        self.transposeStepper.midiCC = MIDIByte(appSettings.transposeStepperCC)
        self.holdButton.midiCC = MIDIByte(appSettings.holdButtonCC)
        self.monoButton.midiCC = MIDIByte(appSettings.monoButtonCC)
    }

    func saveAppSettingValues() {

        // MIDI
        appSettings.backgroundAudio = conductor.backgroundAudio
        appSettings.neverSleep = conductor.neverSleep
        appSettings.midiChannel = Int(midiChannelIn)
        appSettings.omniMode = omniMode
        appSettings.bufferLengthRawValue = AKSettings.bufferLength.rawValue
        appSettings.midiSources = midiInputs.filter { $0.isOpen }.compactMap { $0.name }

        // HAQ Panel
        appSettings.freezeArpRate = (devViewController.freezeArpRate.value == 1 ? true : false)
        appSettings.freezeDelay = (devViewController.freezeDelay.value == 1 ? true : false)
        appSettings.freezeReverb = (devViewController.freezeReverb.value == 1 ? true : false)
        appSettings.whiteKeysOnly = (devViewController.whiteKeysOnly.value == 1 ? true : false)
        appSettings.portamentoHalfTime = conductor.synth.getSynthParameter(.portamentoHalfTime)

        // MIDI Learn Generators
        appSettings.masterVolumeCC = Int(generatorsPanel.masterVolume.midiCC)
        appSettings.morph1SemitoneOffsetCC = Int(generatorsPanel.morph1SemitoneOffset.midiCC)
        appSettings.morph2SemitoneOffsetCC = Int(generatorsPanel.morph2SemitoneOffset.midiCC)
        appSettings.morph2DetuningCC = Int(generatorsPanel.morph2Detuning.midiCC)
        appSettings.morphBalanceCC = Int(generatorsPanel.morphBalance.midiCC)
        appSettings.morph1VolumeCC = Int(generatorsPanel.morph1Volume.midiCC)
        appSettings.morph2VolumeCC = Int(generatorsPanel.morph2Volume.midiCC)
        appSettings.subVolumeCC = Int(generatorsPanel.subVolume.midiCC)
        appSettings.fmVolumeCC = Int(generatorsPanel.fmVolume.midiCC)
        appSettings.fmAmountCC = Int(generatorsPanel.fmAmount.midiCC)
        appSettings.noiseVolumeCC = Int(generatorsPanel.noiseVolume.midiCC)
        appSettings.glideKnobCC = Int(generatorsPanel.glideKnob.midiCC)
        appSettings.cutoffCC = Int(generatorsPanel.cutoff.midiCC)
        appSettings.resonanceCC = Int(generatorsPanel.resonance.midiCC)

        // MIDI Learn Sequencer
        appSettings.arpToggleCC = Int(sequencerPanel.arpToggle.midiCC)
        appSettings.arpIntervalCC = Int(sequencerPanel.arpInterval.midiCC)
        appSettings.octaveStepperCC = Int(sequencerPanel.octaveStepper.midiCC)
        appSettings.arpDirectionButtonCC = Int(sequencerPanel.arpDirectionButton.midiCC)
        appSettings.sequencerToggleCC = Int(sequencerPanel.sequencerToggle.midiCC)
        appSettings.seqStepsStepperCC = Int(sequencerPanel.seqStepsStepper.midiCC)
        appSettings.arpSeqTempoMultiplierCC = Int(sequencerPanel.arpSeqTempoMultiplier.midiCC)

        // MIDI Learn Keyboard
        appSettings.transposeStepperCC = Int(self.transposeStepper.midiCC)
        appSettings.holdButtonCC = Int(self.holdButton.midiCC)
        appSettings.monoButtonCC = Int(self.monoButton.midiCC)

        // MIDI Learn ADSR
        appSettings.attackKnobCC = Int(envelopesPanel.attackKnob.midiCC)
        appSettings.decayKnobCC = Int(envelopesPanel.decayKnob.midiCC)
        appSettings.sustainKnobCC = Int(envelopesPanel.sustainKnob.midiCC)
        appSettings.releaseKnobCC = Int(envelopesPanel.releaseKnob.midiCC)
        appSettings.filterAttackKnobCC = Int(envelopesPanel.filterAttackKnob.midiCC)
        appSettings.filterDecayKnobCC = Int(envelopesPanel.filterDecayKnob.midiCC)
        appSettings.filterSustainKnobCC = Int(envelopesPanel.filterSustainKnob.midiCC)
        appSettings.filterReleaseKnobCC = Int(envelopesPanel.filterReleaseKnob.midiCC)
        appSettings.filterADSRMixKnobCC = Int(envelopesPanel.filterADSRMixKnob.midiCC)
        appSettings.adsrPitchTrackingKnobCC = Int(envelopesPanel.adsrPitchTrackingKnob.midiCC)

        // MIDI Learn FX
        appSettings.sampleRateCC = Int(fxPanel.sampleRateKnob.midiCC)
        appSettings.autoPanRateCC = Int(fxPanel.autoPanRateKnob.midiCC)
        appSettings.autoPanAmountCC = Int(fxPanel.autoPanAmountKnob.midiCC)
        appSettings.reverbSizeCC = Int(fxPanel.reverbSizeKnob.midiCC)
        appSettings.reverbLowCutCC = Int(fxPanel.reverbLowCutKnob.midiCC)
        appSettings.reverbMixCC = Int(fxPanel.reverbMixKnob.midiCC)
        appSettings.delayTimeCC = Int(fxPanel.delayTimeKnob.midiCC)
        appSettings.delayFeedbackCC = Int(fxPanel.delayFeedbackKnob.midiCC)
        appSettings.delayMixCC = Int(fxPanel.delayMixKnob.midiCC)
        appSettings.lfo1AmpCC = Int(fxPanel.lfo1AmpKnob.midiCC)
        appSettings.lfo2AmpCC = Int(fxPanel.lfo2AmpKnob.midiCC)
        appSettings.lfo1RateCC = Int(fxPanel.lfo1RateKnob.midiCC)
        appSettings.lfo2RateCC = Int(fxPanel.lfo2RateKnob.midiCC)
        appSettings.phaserMixCC = Int(fxPanel.phaserMixKnob.midiCC)
        appSettings.phaserRateCC = Int(fxPanel.phaserRateKnob.midiCC)
        appSettings.phaserFeedbackCC = Int(fxPanel.phaserFeedbackKnob.midiCC)
        appSettings.phaserNotchWidthCC = Int(fxPanel.phaserNotchWidthKnob.midiCC)

        // keyboard
        appSettings.labelMode = keyboardView.labelMode
        appSettings.octaveRange = keyboardView.octaveCount
        appSettings.darkMode = keyboardView.darkMode

        // State
        appSettings.currentBankIndex = presetsViewController.bankIndex
        appSettings.currentPresetIndex = activePreset.position
        appSettings.plotFilled = generatorsPanel.isAudioPlotFilled

        // Save
        saveAppSettings()
    }

    // MARK: - Load / Save App Settings

    // Load App Settings from Device
    func loadSettingsFromDevice() {
        do {
            let retrievedSettingData = try Disk.retrieve("settings.json", from: .documents, as: Data.self)
            let settingsJSON = try? JSONSerialization.jsonObject(with: retrievedSettingData, options: [])

            if let settingDictionary = settingsJSON as? [String: Any] {
                appSettings = AppSettings(dictionary: settingDictionary)
            }

            setDefaultsFromAppSettings()

        } catch {
            AKLog("*** error loading")
        }
    }

    func saveAppSettings() {
        do {
            try Disk.save(appSettings, to: .documents, as: "settings.json")
        } catch {
            AKLog("error saving")
        }
    }

    // MARK: - Load / Save Bank Settings

    func saveBankSettings() {
        do {
            try Disk.save(conductor.banks, to: .documents, as: "banks.json")
        } catch {
            AKLog("error saving")
        }
    }

    func loadBankSettings() {
        do {
            let retrievedSettingData = try Disk.retrieve("banks.json", from: .documents, as: Data.self)
            let banksJSON = try? JSONSerialization.jsonObject(with: retrievedSettingData, options: [])

            guard let jsonArray = banksJSON as? [Any] else { return }
            var banks = [Bank]()
            for bankJSON in jsonArray {
                if let bankDictionary = bankJSON as? [String: Any] {
                    let retrievedBank = Bank(dictionary: bankDictionary)
                    banks.append(retrievedBank)
                }
            }
            conductor.banks = banks

        } catch {
            AKLog("*** error loading")
        }
    }

    func createInitBanks() {

        for (i, bankName) in initBanks.enumerated() {
            let bank = Bank(name: bankName, position: i)
            conductor.banks.append(bank)
        }
        saveBankSettings()
    }

}
