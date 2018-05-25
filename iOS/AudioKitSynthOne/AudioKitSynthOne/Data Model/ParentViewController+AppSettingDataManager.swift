//
//  AppSettingDataManager.swift
//  AK1
//
//  Created by Matthew Fecher on 10/31/17.
//  Copyright © 2017 Matthew Fecher. All rights reserved.
//

import AudioKit
import UIKit
import Disk

extension ParentViewController {

    // **********************************************************
    // MARK: - Convert App Settings to Controls and vice-versa
    // **********************************************************

    func setDefaultsFromAppSettings() {

        // MIDI
        //conductor.backgroundAudioOn = appSettings.backgroundAudioOn
        midiChannelIn = MIDIByte(appSettings.midiChannel)
        omniMode = appSettings.omniMode
        devViewController.freezeArpRate.value = (appSettings.freezeArpRate == true ? 1 : 0)

        // MIDI Learn
        mixerViewController.masterVolume.midiCC = MIDIByte(appSettings.masterVolumeCC)
        mixerViewController.morph1SemitoneOffset.midiCC = MIDIByte(appSettings.morph1SemitoneOffsetCC)
        mixerViewController.morph2SemitoneOffset.midiCC = MIDIByte(appSettings.morph2SemitoneOffsetCC)
        mixerViewController.morph2Detuning.midiCC = MIDIByte(appSettings.morph2DetuningCC)
        mixerViewController.morphBalance.midiCC = MIDIByte(appSettings.morphBalanceCC)
        mixerViewController.morph1Volume.midiCC = MIDIByte(appSettings.morph1VolumeCC)
        mixerViewController.morph2Volume.midiCC = MIDIByte(appSettings.morph2VolumeCC)
        mixerViewController.subVolume.midiCC = MIDIByte(appSettings.subVolumeCC)
        mixerViewController.fmVolume.midiCC = MIDIByte(appSettings.fmVolumeCC)
        mixerViewController.fmAmount.midiCC = MIDIByte(appSettings.fmAmountCC)
        mixerViewController.noiseVolume.midiCC = MIDIByte(appSettings.noiseVolumeCC)
        mixerViewController.glideKnob.midiCC = MIDIByte(appSettings.glideKnobCC)
        mixerViewController.cutoff.midiCC = MIDIByte(appSettings.cutoffCC)
        mixerViewController.resonance.midiCC = MIDIByte(appSettings.rezCC)

        seqViewController.arpInterval.midiCC = MIDIByte(appSettings.arpIntervalCC)

        adsrViewController.attackKnob.midiCC = MIDIByte(appSettings.attackKnobCC)
        adsrViewController.decayKnob.midiCC = MIDIByte(appSettings.decayKnobCC)
        adsrViewController.sustainKnob.midiCC = MIDIByte(appSettings.sustainKnobCC)
        adsrViewController.releaseKnob.midiCC = MIDIByte(appSettings.releaseKnobCC)
        adsrViewController.filterAttackKnob.midiCC = MIDIByte(appSettings.filterAttackKnobCC)
        adsrViewController.filterDecayKnob.midiCC = MIDIByte(appSettings.filterDecayKnobCC)
        adsrViewController.filterSustainKnob.midiCC = MIDIByte(appSettings.filterSustainKnobCC)
        adsrViewController.filterReleaseKnob.midiCC = MIDIByte(appSettings.filterReleaseKnobCC)
        adsrViewController.filterADSRMixKnob.midiCC = MIDIByte(appSettings.filterADSRMixKnobCC)

        fxViewController.sampleRate.midiCC = MIDIByte(appSettings.sampleRateCC)
        fxViewController.autoPanRate.midiCC = MIDIByte(appSettings.autoPanRateCC)
        fxViewController.reverbSize.midiCC = MIDIByte(appSettings.reverbSizeCC)
        fxViewController.reverbLowCut.midiCC = MIDIByte(appSettings.reverbLowCutCC)
        fxViewController.reverbMix.midiCC = MIDIByte(appSettings.reverbMixCC)
        fxViewController.delayTime.midiCC = MIDIByte(appSettings.delayTimeCC)
        fxViewController.delayFeedback.midiCC = MIDIByte(appSettings.delayFeedbackCC)
        fxViewController.delayMix.midiCC = MIDIByte(appSettings.delayMixCC)
        fxViewController.lfo1Amp.midiCC = MIDIByte(appSettings.lfo1AmpCC)
        fxViewController.lfo2Amp.midiCC = MIDIByte(appSettings.lfo2AmpCC)
        fxViewController.lfo1Rate.midiCC = MIDIByte(appSettings.lfo1RateCC)
        fxViewController.lfo2Rate.midiCC = MIDIByte(appSettings.lfo2RateCC)
        fxViewController.phaserMix.midiCC = MIDIByte(appSettings.phaserMixCC)
        fxViewController.phaserRate.midiCC = MIDIByte(appSettings.phaserRateCC)
        fxViewController.phaserFeedback.midiCC = MIDIByte(appSettings.phaserFeedbackCC)
        fxViewController.phaserNotchWidth.midiCC = MIDIByte(appSettings.phaserNotchWidthCC)

        // keyboard
        keyboardView.labelMode = appSettings.labelMode
        keyboardView.octaveCount = appSettings.octaveRange
        keyboardView.darkMode = appSettings.darkMode

        //TODO: Persist AudioPlot fill?
    }

    func saveAppSettingValues() {

        // MIDI
        // appSettings.backgroundAudioOn = conductor.backgroundAudioOn
        appSettings.midiChannel = Int(midiChannelIn)
        appSettings.omniMode = omniMode
        appSettings.freezeArpRate = (devViewController.freezeArpRate.value == 1 ? true : false)

        // MIDI Learn
        appSettings.masterVolumeCC = Int(mixerViewController.masterVolume.midiCC)
        appSettings.morph1SemitoneOffsetCC = Int(mixerViewController.morph1SemitoneOffset.midiCC)
        appSettings.morph2SemitoneOffsetCC = Int(mixerViewController.morph2SemitoneOffset.midiCC)
        appSettings.morph2DetuningCC = Int(mixerViewController.morph2Detuning.midiCC)
        appSettings.morphBalanceCC = Int(mixerViewController.morphBalance.midiCC)
        appSettings.morph1VolumeCC = Int(mixerViewController.morph1Volume.midiCC)
        appSettings.morph2VolumeCC = Int(mixerViewController.morph2Volume.midiCC)
        appSettings.subVolumeCC = Int(mixerViewController.subVolume.midiCC)
        appSettings.fmVolumeCC = Int(mixerViewController.fmVolume.midiCC)
        appSettings.fmAmountCC = Int(mixerViewController.fmAmount.midiCC)
        appSettings.noiseVolumeCC = Int(mixerViewController.noiseVolume.midiCC)
        appSettings.glideKnobCC = Int(mixerViewController.glideKnob.midiCC)
        appSettings.cutoffCC = Int(mixerViewController.cutoff.midiCC)
        appSettings.rezCC = Int(mixerViewController.resonance.midiCC)

        appSettings.arpIntervalCC = Int(seqViewController.arpInterval.midiCC)

        appSettings.attackKnobCC = Int(adsrViewController.attackKnob.midiCC)
        appSettings.decayKnobCC = Int(adsrViewController.decayKnob.midiCC)
        appSettings.sustainKnobCC = Int(adsrViewController.sustainKnob.midiCC)
        appSettings.releaseKnobCC = Int(adsrViewController.releaseKnob.midiCC)
        appSettings.filterAttackKnobCC = Int(adsrViewController.filterAttackKnob.midiCC)
        appSettings.filterDecayKnobCC = Int(adsrViewController.filterDecayKnob.midiCC)
        appSettings.filterSustainKnobCC = Int(adsrViewController.filterSustainKnob.midiCC)
        appSettings.filterReleaseKnobCC = Int(adsrViewController.filterReleaseKnob.midiCC)
        appSettings.filterADSRMixKnobCC = Int(adsrViewController.filterADSRMixKnob.midiCC)

        appSettings.sampleRateCC = Int(fxViewController.sampleRate.midiCC)
        appSettings.autoPanRateCC = Int(fxViewController.autoPanRate.midiCC)
        appSettings.reverbSizeCC = Int(fxViewController.reverbSize.midiCC)
        appSettings.reverbLowCutCC = Int(fxViewController.reverbLowCut.midiCC)
        appSettings.reverbMixCC = Int(fxViewController.reverbMix.midiCC)
        appSettings.delayTimeCC = Int(fxViewController.delayTime.midiCC)
        appSettings.delayFeedbackCC = Int(fxViewController.delayFeedback.midiCC)
        appSettings.delayMixCC = Int(fxViewController.delayMix.midiCC)
        appSettings.lfo1AmpCC = Int(fxViewController.lfo1Amp.midiCC)
        appSettings.lfo2AmpCC = Int(fxViewController.lfo2Amp.midiCC)
        appSettings.lfo1RateCC = Int(fxViewController.lfo1Rate.midiCC)
        appSettings.lfo2RateCC = Int(fxViewController.lfo2Rate.midiCC)
        appSettings.phaserMixCC = Int(fxViewController.phaserMix.midiCC)
        appSettings.phaserRateCC = Int(fxViewController.phaserRate.midiCC)
        appSettings.phaserFeedbackCC = Int(fxViewController.phaserFeedback.midiCC)
        appSettings.phaserNotchWidthCC = Int(fxViewController.phaserNotchWidth.midiCC)

        // keyboard
        appSettings.labelMode = keyboardView.labelMode
        appSettings.octaveRange = keyboardView.octaveCount
        appSettings.darkMode = keyboardView.darkMode
        appSettings.showKeyboard = keyboardToggle.value

        appSettings.plotFilled = mixerViewController.isAudioPlotFilled
        saveAppSettings()
    }

    // **********************************************************
    // MARK: - Load / Save App Settings
    // **********************************************************

    // Load App Settings from Device
    func loadSettingsFromDevice() {
        do {
            let retrievedSettingData = try Disk.retrieve("settings.json", from: .documents, as: Data.self)
            let settingsJSON = try? JSONSerialization.jsonObject(with: retrievedSettingData, options: [])

            if let settingDictionary = settingsJSON as? [String: Any] {
                appSettings = AppSetting(dictionary: settingDictionary)
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

    // **********************************************************
    // MARK: - Load / Save Bank Settings
    // **********************************************************

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
