//
//  Presets+UITableViewDelegate.swift
//  AudioKitSynthOne
//
//  Created by AudioKit Contributors on 5/25/18.
//  Copyright © 2018 AudioKit. All rights reserved.
//

extension PresetsViewController: UITableViewDelegate {

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.view.endEditing(true)

        // Get cell
        let cell = tableView.cellForRow(at: indexPath) as? PresetCell
        guard let newPreset = cell?.currentPreset else { return }
        currentPreset = newPreset
    }

    // Editing the table view.
    @objc(tableView:commitEditingStyle:forRowAtIndexPath:)
    func tableView(_ tableView: UITableView,
                   commit editingStyle: UITableViewCell.EditingStyle,
                   forRowAt indexPath: IndexPath) {

        if editingStyle == .delete {

            guard presets.count > 1 else { return }

            // Get cell
            let cell = tableView.cellForRow(at: indexPath) as? PresetCell
            guard let presetToDelete = cell?.currentPreset else { return }

            // Delete the preset from the data source
            presets = presets.filter { $0.uid != presetToDelete.uid }

            // Resave Preset Positions in Bank
            let presetBank = presets.filter { $0.bank == presetToDelete.bank }.sorted { $0.position < $1.position }
            for (i, preset) in presetBank.enumerated() {
                preset.position = i
            }

            // Move to preset above deleted preset
            if indexPath.row > 0 && presetToDelete.position > 0 {
                currentPreset = sortedPresets[indexPath.row - 1]
            }

            // Save presets
            saveAllPresetsIn(currentPreset.bank)
            selectCurrentPreset()
        }
    }

    @objc(tableView:canFocusRowAtIndexPath:) func tableView(_ tableView: UITableView,
                                                            canFocusRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }

    // Override to support rearranging the table view.
    @objc(tableView:moveRowAtIndexPath:toIndexPath:) func tableView(_ tableView: UITableView,
                                                                    moveRowAt fromIndexPath: IndexPath,
                                                                    to toIndexPath: IndexPath) {

        // Get preset
        let presetToMove = sortedPresets[Int(fromIndexPath.row)]

        // Update new position in sortedPresets array
        // Rearranging is only allowed in "banks" views, so we can use sortedPresets
        sortedPresets.remove(at: (fromIndexPath as NSIndexPath).row)
        sortedPresets.insert(presetToMove, at: (toIndexPath as NSIndexPath).row)

        // Resave positions
        for (i, preset) in sortedPresets.enumerated() {
            preset.position = i
        }
        saveAllPresetsIn(presetToMove.bank)
    }

    // Override to support conditional rearranging of the table view.
    @objc(tableView:canMoveRowAtIndexPath:) func tableView(_ tableView: UITableView,
                                                           canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }

}
