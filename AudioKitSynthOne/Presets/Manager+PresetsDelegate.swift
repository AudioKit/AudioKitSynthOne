//
//  Manager+PresetsDelegate.swift
//  AudioKitSynthOne
//
//  Created by AudioKit Contributors on 5/25/18.
//  Copyright © 2018 AudioKit. All rights reserved.
//

// Presets Delegate

extension Manager: PresetsDelegate {

    func presetDidChange(_ newActivePreset: Preset) {
        conductor.synth.reset()

        activePreset = newActivePreset

        if let headerVC = self.childViewControllers.first as? HeaderViewController {
            headerVC.activePreset = activePreset
        }

        // Set parameters from preset
        self.loadPreset()

        DispatchQueue.main.async {
            self.conductor.updateAllUI()
        }

        // Display new preset name in header
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
            let message = "\(self.activePreset.position): \(self.activePreset.name)"
            self.updateDisplay(message)
        }

        // UI Updates for non-bound controls
        DispatchQueue.main.async {
            // Octave position
            self.keyboardView.firstOctave = self.activePreset.octavePosition + 2
            self.octaveStepper.value = Double(self.activePreset.octavePosition)
        }

        // Save Current Preset
        saveAppSettingValues()
    }

    func updateDisplay(_ message: String) {
        if let headerVC = self.childViewControllers.first as? HeaderViewController {
            headerVC.displayLabel.text = message
        }
    }

    func saveEditedPreset(name: String, category: Int, bank: String) {
        activePreset.name = name
        activePreset.category = category
        activePreset.bank = bank
        // activePreset.isUser = true
        saveValuesToPreset()
    }

    func banksDidUpdate() {
        saveBankSettings()
    }
}
