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
        mixerViewController.masterVolume.midiCC = MIDIByte(appSettings.masterVolume_CC)
        mixerViewController.morph1SemitoneOffset.midiCC = MIDIByte(appSettings.morph1SemitoneOffset_CC)
        mixerViewController.morph2SemitoneOffset.midiCC = MIDIByte(appSettings.morph2SemitoneOffset_CC)
        mixerViewController.morph2Detuning.midiCC = MIDIByte(appSettings.morph2Detuning_CC)
        mixerViewController.morphBalance.midiCC = MIDIByte(appSettings.morphBalance_CC)
        mixerViewController.morph1Volume.midiCC = MIDIByte(appSettings.morph1Volume_CC)
        mixerViewController.morph2Volume.midiCC = MIDIByte(appSettings.morph2Volume_CC)
        mixerViewController.subVolume.midiCC = MIDIByte(appSettings.subVolume_CC)
        mixerViewController.fmVolume.midiCC = MIDIByte(appSettings.fmVolume_CC)
        mixerViewController.fmAmount.midiCC = MIDIByte(appSettings.fmAmount_CC)
        mixerViewController.noiseVolume.midiCC = MIDIByte(appSettings.noiseVolume_CC)
        mixerViewController.glideKnob.midiCC = MIDIByte(appSettings.glideKnob_CC)
        mixerViewController.cutoff.midiCC = MIDIByte(appSettings.cutoff_CC)
        mixerViewController.resonance.midiCC = MIDIByte(appSettings.rez_CC)
        
        seqViewController.arpInterval.midiCC = MIDIByte(appSettings.arpInterval_CC)
        
        adsrViewController.attackKnob.midiCC = MIDIByte(appSettings.attackKnob_CC)
        adsrViewController.decayKnob.midiCC = MIDIByte(appSettings.decayKnob_CC)
        adsrViewController.sustainKnob.midiCC = MIDIByte(appSettings.sustainKnob_CC)
        adsrViewController.releaseKnob.midiCC = MIDIByte(appSettings.releaseKnob_CC)
        adsrViewController.filterAttackKnob.midiCC = MIDIByte(appSettings.filterAttackKnob_CC)
        adsrViewController.filterDecayKnob.midiCC = MIDIByte(appSettings.filterDecayKnob_CC)
        adsrViewController.filterSustainKnob.midiCC = MIDIByte(appSettings.filterSustainKnob_CC)
        adsrViewController.filterReleaseKnob.midiCC = MIDIByte(appSettings.filterReleaseKnob_CC)
        adsrViewController.filterADSRMixKnob.midiCC = MIDIByte(appSettings.filterADSRMixKnob_CC)
        
        fxViewController.sampleRate.midiCC = MIDIByte(appSettings.sampleRate_CC)
        fxViewController.autoPanRate.midiCC = MIDIByte(appSettings.autoPanRate_CC)
        fxViewController.reverbSize.midiCC = MIDIByte(appSettings.reverbSize_CC)
        fxViewController.reverbLowCut.midiCC = MIDIByte(appSettings.reverbLowCut_CC)
        fxViewController.reverbMix.midiCC = MIDIByte(appSettings.reverbMix_CC)
        fxViewController.delayTime.midiCC = MIDIByte(appSettings.delayTime_CC)
        fxViewController.delayFeedback.midiCC = MIDIByte(appSettings.delayFeedback_CC)
        fxViewController.delayMix.midiCC = MIDIByte(appSettings.delayMix_CC)
        fxViewController.lfo1Amp.midiCC = MIDIByte(appSettings.lfo1Amp_CC)
        fxViewController.lfo2Amp.midiCC = MIDIByte(appSettings.lfo2Amp_CC)
        fxViewController.lfo1Rate.midiCC = MIDIByte(appSettings.lfo1Rate_CC)
        fxViewController.lfo2Rate.midiCC = MIDIByte(appSettings.lfo2Rate_CC)
        fxViewController.phaserMix.midiCC = MIDIByte(appSettings.phaserMix_CC)
        fxViewController.phaserRate.midiCC = MIDIByte(appSettings.phaserRate_CC)
        fxViewController.phaserFeedback.midiCC = MIDIByte(appSettings.phaserFeedback_CC)
        fxViewController.phaserNotchWidth.midiCC = MIDIByte(appSettings.phaserNotchWidth_CC)
        
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
        appSettings.masterVolume_CC = Int(mixerViewController.masterVolume.midiCC)
        appSettings.morph1SemitoneOffset_CC = Int(mixerViewController.morph1SemitoneOffset.midiCC)
        appSettings.morph2SemitoneOffset_CC = Int(mixerViewController.morph2SemitoneOffset.midiCC)
        appSettings.morph2Detuning_CC = Int(mixerViewController.morph2Detuning.midiCC)
        appSettings.morphBalance_CC = Int(mixerViewController.morphBalance.midiCC)
        appSettings.morph1Volume_CC = Int(mixerViewController.morph1Volume.midiCC)
        appSettings.morph2Volume_CC = Int(mixerViewController.morph2Volume.midiCC)
        appSettings.subVolume_CC = Int(mixerViewController.subVolume.midiCC)
        appSettings.fmVolume_CC = Int(mixerViewController.fmVolume.midiCC)
        appSettings.fmAmount_CC = Int(mixerViewController.fmAmount.midiCC)
        appSettings.noiseVolume_CC = Int(mixerViewController.noiseVolume.midiCC)
        appSettings.glideKnob_CC = Int(mixerViewController.glideKnob.midiCC)
        appSettings.cutoff_CC = Int(mixerViewController.cutoff.midiCC)
        appSettings.rez_CC = Int(mixerViewController.resonance.midiCC)
        
        appSettings.arpInterval_CC = Int(seqViewController.arpInterval.midiCC)
        
        appSettings.attackKnob_CC = Int(adsrViewController.attackKnob.midiCC)
        appSettings.decayKnob_CC = Int(adsrViewController.decayKnob.midiCC)
        appSettings.sustainKnob_CC = Int(adsrViewController.sustainKnob.midiCC)
        appSettings.releaseKnob_CC = Int(adsrViewController.releaseKnob.midiCC)
        appSettings.filterAttackKnob_CC = Int(adsrViewController.filterAttackKnob.midiCC)
        appSettings.filterDecayKnob_CC = Int(adsrViewController.filterDecayKnob.midiCC)
        appSettings.filterSustainKnob_CC = Int(adsrViewController.filterSustainKnob.midiCC)
        appSettings.filterReleaseKnob_CC = Int(adsrViewController.filterReleaseKnob.midiCC)
        appSettings.filterADSRMixKnob_CC = Int(adsrViewController.filterADSRMixKnob.midiCC)
        
        appSettings.sampleRate_CC = Int(fxViewController.sampleRate.midiCC)
        appSettings.autoPanRate_CC = Int(fxViewController.autoPanRate.midiCC)
        appSettings.reverbSize_CC = Int(fxViewController.reverbSize.midiCC)
        appSettings.reverbLowCut_CC = Int(fxViewController.reverbLowCut.midiCC)
        appSettings.reverbMix_CC = Int(fxViewController.reverbMix.midiCC)
        appSettings.delayTime_CC = Int(fxViewController.delayTime.midiCC)
        appSettings.delayFeedback_CC = Int(fxViewController.delayFeedback.midiCC)
        appSettings.delayMix_CC = Int(fxViewController.delayMix.midiCC)
        appSettings.lfo1Amp_CC = Int(fxViewController.lfo1Amp.midiCC)
        appSettings.lfo2Amp_CC = Int(fxViewController.lfo2Amp.midiCC)
        appSettings.lfo1Rate_CC = Int(fxViewController.lfo1Rate.midiCC)
        appSettings.lfo2Rate_CC = Int(fxViewController.lfo2Rate.midiCC)
        appSettings.phaserMix_CC = Int(fxViewController.phaserMix.midiCC)
        appSettings.phaserRate_CC = Int(fxViewController.phaserRate.midiCC)
        appSettings.phaserFeedback_CC = Int(fxViewController.phaserFeedback.midiCC)
        appSettings.phaserNotchWidth_CC = Int(fxViewController.phaserNotchWidth.midiCC)
       
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
