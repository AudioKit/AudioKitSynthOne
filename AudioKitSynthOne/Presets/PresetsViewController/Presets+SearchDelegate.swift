//
//  Presets+SearchDelegate.swift
//  AudioKitSynthOne
//
//  Created by Matthew Fecher on 7/8/19.
//  Copyright © 2019 AudioKit. All rights reserved.
//

import Foundation

extension PresetsViewController: SearchControllerDelegate {
    
    func didSelectPreset(_ newPreset: Preset) {
        deselectCurrentRow()
        
        // Select Current Bank
        guard let currentBank = conductor.banks.first(where: { $0.name == newPreset.bank }) else { return }
        selectCategory(PresetCategory.bankStartingIndex + currentBank.position )
        categoryIndex = PresetCategory.bankStartingIndex + currentBank.position
        currentPreset = newPreset
        selectCurrentPreset()
    }
}
