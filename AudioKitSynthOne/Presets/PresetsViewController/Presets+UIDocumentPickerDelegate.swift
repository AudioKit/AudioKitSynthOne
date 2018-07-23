//
//  Presets+UIDocumentPickerDelegate.swift
//  AudioKitSynthOne
//
//  Created by AudioKit Contributors on 5/25/18.
//  Copyright © 2018 AudioKit. All rights reserved.
//

// Import / UIDocumentPickerDelegate

extension PresetsViewController: UIDocumentPickerDelegate {

    func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentAt url: URL) {
        AKLog("**** url: \(url) ")

        let fileName = String(describing: url.lastPathComponent)

        // import presets
        do {
            // Parse Data to JSON
            let retrievedPresetData = try Data(contentsOf: url)
            if let presetJSON = try? JSONSerialization.jsonObject(with: retrievedPresetData, options: []) {

                // Check if it is a bank or single preset
                if fileName.hasSuffix("json") {
                    // import bank
                    guard let jsonArray = presetJSON as? [Any] else { return }
                    let importBank = Preset.parseDataToPresets(jsonArray: jsonArray)

                    // Update imported presets with bankName
                    var bankName = String(fileName.dropLast(5))

                    // check for duplicate bank name already in system
                    if conductor.banks.contains(where: { $0.name == bankName }) {
                        let title = NSLocalizedString("Notice", comment: "Alert Title: Duplicate Bank Name")
                        let message = NSLocalizedString("There is already a bank with the name '\(bankName)'. "  +
                            "Please rename one of them to keep things working smoothly.",
                                                        comment: "Alert Message: Duplicate Bank Name")
                        displayAlertController(title,
                                               message: message)
                        bankName += " [rename]"
                    }

                    // Update presets
                    for preset in importBank {
                        preset.uid = UUID().uuidString
                        preset.bank = bankName
                    }

                    // Add new bank to presets
                    presets += importBank

                    // Save to local disk
                    saveAllPresetsIn(bankName)

                    // Save to AppSettings
                    let newBankIndex = conductor.banks.count
                    self.addNewBank(newBankName: bankName, newBankIndex: newBankIndex)

                } else {
                    let importedPreset = Preset.parseDataToPreset(presetJSON: presetJSON)

                    // Import preset to User Bank
                    let userBank = presets.filter { $0.bank == userBankName }
                    importedPreset.position = userBank.count
                    importedPreset.isFavorite = false
                    importedPreset.isUser = true
                    presets.append(importedPreset)

                    currentPreset = importedPreset
                    currentPreset.bank = userBankName
                    saveAllPresetsIn(currentPreset.bank)

                    // Display the User Bank
                    selectCategory(userBankIndex)
                    categoryIndex = userBankIndex
                    selectCurrentPreset()

                    AKLog("*** preset loaded")
                }
            } else {
                AKLog("*** error parsing presets")
            }

        } catch {
            AKLog("*** error loading")
        }
    }

}
