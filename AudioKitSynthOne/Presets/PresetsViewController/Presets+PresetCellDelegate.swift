//
//  Presets+PresetCellDelegate.swift
//  AudioKitSynthOne
//
//  Created by AudioKit Contributors on 5/25/18.
//  Copyright © 2018 AudioKit. All rights reserved.
//

import Disk

extension PresetsViewController: PresetCellDelegate {

    func editPressed() {
        self.performSegue(withIdentifier: "SegueToEdit", sender: self)
    }

    func duplicatePressed() {

        do {
            // Make unique copy of preset
            try Disk.save(currentPreset, to: .caches, as: "tmp/presetcopy.json")
            guard let copy = try? Disk.retrieve("tmp/presetcopy.json", from: .caches, as: Preset.self) else { return }

            // Set duplicate preset properties
            copy.name += " [copy]"
            copy.uid = UUID().uuidString
            copy.isUser = true
            copy.bank = userBankName // User Bank

            // Append preset
            presets.append(copy)

            // Resave positions in User Bank
            let userBank = presets.filter { $0.bank == copy.bank }.sorted { $0.position < $1.position }
            for (i, preset) in userBank.enumerated() {
                preset.position = i
            }

            // Save the User Bank
            saveAllPresetsIn(copy.bank)

            // Select the new Preset
            currentPreset = copy

            // Display the User Bank
            selectCategory(userBankIndex)
            categoryIndex = userBankIndex
            selectCurrentPreset()

        } catch {
            AKLog("error duplicating")
        }
    }

    func favoritePressed() {
        // Toggle and save preset
        currentPreset.isFavorite = !currentPreset.isFavorite
        saveAllPresetsIn(currentPreset.bank)

        // Select current preset
        selectCurrentPreset()
    }

    func sharePressed() {

        // Save preset to temp directory to be shared
        let presetLocation = "temp/\(currentPreset.name).synth1"
        try? Disk.save(currentPreset, to: .caches, as: presetLocation)
        guard let path: URL = try? Disk.getURL(for: presetLocation, in: .caches) else { return }

        // Share
        let activityViewController = UIActivityViewController(
            activityItems: [path],
            applicationActivities: nil)
        activityViewController.excludedActivityTypes = [
            UIActivity.ActivityType.copyToPasteboard
        ]

        if let popoverPresentationController = activityViewController.popoverPresentationController {
            popoverPresentationController.sourceView = self.view
            popoverPresentationController.sourceRect = CGRect(x: self.view.bounds.midX,
                                                              y: self.view.bounds.midY,
                                                              width: 0, height: 0)
            popoverPresentationController.permittedArrowDirections = []
        }

        self.present(activityViewController, animated: true, completion: nil)
    }

    // To find the files in your machine, search for filename in your ~/Library/Developer/CoreSimulator/Devices/
}
