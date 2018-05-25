//
//  Presets+CategoryDelegate.swift
//  AudioKitSynthOne
//
//  Created by Aurelius Prochazka on 5/25/18.
//  Copyright © 2018 AudioKit. All rights reserved.
//

import Disk

extension PresetsViewController: CategoryDelegate {

    func categoryDidChange(_ newCategoryIndex: Int) {
        categoryIndex = newCategoryIndex
    }

    func bankShare() {
        // Get Bank to Share
        let bank = conductor.banks.filter{ $0.position == bankIndex }.first
        let bankName = bank!.name
        let bankPresetsToShare = presets.filter { $0.bank == bankName }

        // Save bank presets to temp directory to be shared
        let bankLocation = "temp/\(bankName).json"
        try? Disk.save(bankPresetsToShare, to: .caches, as: bankLocation)
        let path: URL =  try! Disk.getURL(for: bankLocation, in: .caches)

        // Share
        let activityViewController = UIActivityViewController(
            activityItems: [path],
            applicationActivities: nil)
        activityViewController.excludedActivityTypes = [
            UIActivityType.copyToPasteboard
        ]

        if let popoverPresentationController = activityViewController.popoverPresentationController {
            popoverPresentationController.sourceView = self.view
            popoverPresentationController.sourceRect = CGRect(x: self.view.bounds.midX, y: self.view.bounds.midY, width: 0, height: 0)
            popoverPresentationController.permittedArrowDirections = []
        }

        self.present(activityViewController, animated: true, completion: nil)
    }

    func bankEdit() {
        self.performSegue(withIdentifier: "SegueToBankEdit", sender: self)
    }
}

