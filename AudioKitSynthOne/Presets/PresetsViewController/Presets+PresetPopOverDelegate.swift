//
//  Presets+PresetPopOverDelegate.swift
//  AudioKitSynthOne
//
//  Created by AudioKit Contributors on 5/25/18.
//  Copyright © 2018 AudioKit. All rights reserved.
//

// PopUpPresetEdit

extension PresetsViewController: PresetPopOverDelegate {
    func didFinishEditing(name: String, category: Int, newBank: String) {
        
        // Check for bank change
        if currentPreset.bank != newBank {
         
            // Check if preset name exists
            if  name == currentPreset.name {
                // remove preset from its previous bank if preset not renamed
                let oldBank = currentPreset.bank
                currentPreset.bank = newBank
                saveAllPresetsIn(oldBank)

                guard let currentBank = conductor.banks.first(where: { $0.name == newBank }) else { return }
                selectCategory(PresetCategory.bankStartingIndex + currentBank.position )
                categoryIndex = PresetCategory.bankStartingIndex + currentBank.position
            }
        }

        // save preset
        presetsDelegate?.saveEditedPreset(name: name, category: category, bank: newBank)
    }
}
