//
//  AppSettingDataManager.swift
//  AK1
//
//  Created by Matthew Fecher on 10/31/17.
//  Copyright © 2017 Matthew Fecher. All rights reserved.
//

import UIKit
import AudioKit
import Disk

extension ParentViewController {
 
    // **********************************************************
    // MARK: - Convert App Settings to Controls and vice-versa
    // **********************************************************
    
    func setDefaultsFromAppSettings() {
        
        // MIDI Learn
        /*
        auMainController.vol1Knob.midiCC = MIDIByte(appSettings.vol1_CC)
        auMainController.masterVolume.midiCC = MIDIByte(appSettings.masterVolume_CC)
        
        auMainController.autoPanRateKnob.midiCC = MIDIByte(appSettings.autoPanRate_CC)
        
        auMainController.reverbAmtKnob.midiCC = MIDIByte(appSettings.reverbAmt_CC)
        auMainController.reverbMixKnob.midiCC = MIDIByte(appSettings.reverbMix_CC)
        
        auMainController.crushKnob.midiCC = MIDIByte(appSettings.crush_CC)
        auMainController.tremoloKnob.midiCC = MIDIByte(appSettings.tremolo_CC)
        
        auMainController.delayTimeKnob.midiCC = MIDIByte(appSettings.delayTime_CC)
        auMainController.delayFeedbackKnob.midiCC = MIDIByte(appSettings.delayFeedback_CC)
        auMainController.delayMixKnob.midiCC = MIDIByte(appSettings.delayMix_CC)
        
        auMainController.freqKnob.midiCC = MIDIByte(appSettings.cutoff_CC)
        auMainController.rezKnob.midiCC = MIDIByte(appSettings.rez_CC)
        auMainController.lfoAmtKnob.midiCC = MIDIByte(appSettings.lfoAmt_CC)
        auMainController.lfoRateKnob.midiCC = MIDIByte(appSettings.lfoRate_CC)
        */
        
        // keyboard
        keyboardView.labelMode = appSettings.labelMode
        keyboardView.octaveCount = appSettings.octaveRange
        keyboardView.darkMode = appSettings.darkMode
        //keyboardView.currentVelocity = MIDIVelocity(appSettings.velocity)
    }
    
    func saveAppSettingValues() {
        
        // MIDI Learn
        /*
        appSettings.vol1_CC = Int(auMainController.vol1Knob.midiCC)
        appSettings.masterVolume_CC = Int(auMainController.masterVolume.midiCC)
        
        appSettings.autoPanRate_CC = Int(auMainController.autoPanRateKnob.midiCC)
        
        appSettings.reverbAmt_CC = Int(auMainController.reverbAmtKnob.midiCC)
        appSettings.reverbMix_CC = Int(auMainController.reverbMixKnob.midiCC)
        
        appSettings.crush_CC = Int(auMainController.crushKnob.midiCC)
        appSettings.tremolo_CC = Int(auMainController.tremoloKnob.midiCC)
        
        appSettings.delayTime_CC = Int(auMainController.delayTimeKnob.midiCC)
        appSettings.delayFeedback_CC = Int(auMainController.delayFeedbackKnob.midiCC)
        appSettings.delayMix_CC = Int(auMainController.delayMixKnob.midiCC)
        
        appSettings.cutoff_CC = Int(auMainController.freqKnob.midiCC)
        appSettings.rez_CC = Int(auMainController.rezKnob.midiCC)
        appSettings.lfoAmt_CC = Int(auMainController.lfoAmtKnob.midiCC)
        appSettings.lfoRate_CC = Int(auMainController.lfoRateKnob.midiCC)
        */
        
        // keyboard
        appSettings.labelMode = keyboardView.labelMode
        appSettings.octaveRange = keyboardView.octaveCount
        appSettings.darkMode = keyboardView.darkMode
        
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
            print("*** error loading")
        }
    }
    
    func saveAppSettings() {
        do {
            try Disk.save(appSettings, to: .documents, as: "settings.json")
        } catch {
            print("error saving")
        }
    }
    
}


