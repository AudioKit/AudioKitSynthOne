//
//  Presets+UITableViewDataSource.swift
//  AudioKitSynthOne
//
//  Created by Aurelius Prochazka on 5/25/18.
//  Copyright © 2018 AudioKit. All rights reserved.
//

extension PresetsViewController: UITableViewDataSource {

    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    @objc(tableView:heightForRowAtIndexPath:) func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 44
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if sortedPresets.isEmpty {
            return 0
        } else {
            return sortedPresets.count
        }
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        // Get current preset
        let preset = sortedPresets[(indexPath as NSIndexPath).row]

        if let cell = tableView.dequeueReusableCell(withIdentifier: "PresetCell") as? PresetCell {

            cell.delegate = self

            // Cell updated in PresetCell.swift
            cell.configureCell(preset: preset)

            return cell

        } else {
            return PresetCell()
        }
    }
}
