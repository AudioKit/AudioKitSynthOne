//
//  Presets+BankPopOverDelegate.swift
//  AudioKitSynthOne
//
//  Created by AudioKit Contributors on 5/25/18.
//  Copyright © 2018 AudioKit. All rights reserved.
//

import Disk

// PopUpBankEdit

extension PresetsViewController: BankPopOverDelegate {

    func didFinishEditing(oldName: String, newName: String) {
        // update presets
        let presetsInBank = presets.filter { $0.bank == oldName }
        for preset in presetsInBank { preset.bank = newName }

        // Update Conductor
        guard let bank = conductor.banks.first(where: { $0.name == oldName }) else { return }
        bank.name = newName

        // Update AppSettings
        presetsDelegate?.banksDidUpdate()

        // Update Category Table
        updateCategoryTable()
        selectCategory(PresetCategory.bankStartingIndex + bank.position)
        categoryIndex = PresetCategory.bankStartingIndex + bank.position

        // Save new bank file
        saveAllPresetsIn(newName)

        // Delete old bank json file
        try? Disk.remove(oldName + ".json", from: .documents)

    }

    func didDeleteBank(bankName: String) {

        // Remove presets from main list
        presets = presets.filter { $0.bank != bankName }

        // Remove from Conductor
        conductor.banks = conductor.banks.filter { $0.name != bankName }

        // Reorder Banks
        for (i, bank) in conductor.banks.enumerated() {
            bank.position = i
        }

        // Remove from AppSettings
        presetsDelegate?.banksDidUpdate()

        updateCategoryTable()
        selectCategory(PresetCategory.bankStartingIndex)
        categoryIndex = PresetCategory.bankStartingIndex
        selectCurrentPreset()

        // Delete bank json file
        try? Disk.remove(bankName + ".json", from: .documents)

    }
}
