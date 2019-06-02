//
//  TuningsPanel+UITableViewDelegate.swift
//  AudioKitSynthOne
//
//  Created by Marcus Hobbs on 6/3/18.
//  Copyright © 2018 AudioKit. All rights reserved.
//

// MARK: - TableViewDelegate

extension TuningsPanelController: UITableViewDelegate {

    public func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {

        self.view.endEditing(true)
        
        let selectedRow = (indexPath as NSIndexPath).row
        if tableView == tuningTableView {
            tuningModel.selectTuning(atRow: selectedRow)
            tuningTableView.selectRow(at: indexPath, animated: true, scrollPosition: .middle)
        } else if tableView == tuningBankTableView {
            tuningModel.selectBank(atRow: selectedRow)
            updateAppSettingsTuningsBank(for: tuningModel.selectedBankIndex)
            tuningTableView.reloadData()
            let tuningPath = IndexPath(row: tuningModel.selectedTuningIndex, section: 0)
            tuningTableView.selectRow(at: tuningPath, animated: true, scrollPosition: .middle)
            tuningViewController.navigationItem.rightBarButtonItem = tuningModel.selectedBankTuningIsEditable ? tuningTableEditButton : nil
            tuningNavController.pushViewController(tuningViewController, animated: true)
            tuningBankTableView.selectRow(at: indexPath, animated: true, scrollPosition: .top)
        } else {
            AKLog("error: no such tableview")
        }
    }

    // Edit the table view
    @objc(tableView:commitEditingStyle:forRowAtIndexPath:)
    func tableView(_ tableView: UITableView,
                   commit editingStyle: UITableViewCell.EditingStyle,
                   forRowAt indexPath: IndexPath) {

        guard tableView === tuningTableView && tuningModel.selectedBankIndex == tuningModel.userBankIndex else { return }

        if editingStyle == .delete {
            if tuningModel.removeUserTuning(atIndex: indexPath.row) {
                tuningTableView.reloadData()
                let ip = IndexPath(row: tuningModel.selectedTuningIndex, section: 0)
                tuningTableView.selectRow(at: ip, animated: true, scrollPosition: .middle)
            }
        }
    }

    @objc(tableView:canFocusRowAtIndexPath:) func tableView(_ tableView: UITableView,
                                                            canFocusRowAt indexPath: IndexPath) -> Bool {

        // Only edit items in user bank
        return tableView === tuningTableView && tuningModel.selectedBankIndex == tuningModel.userBankIndex
    }

    @objc(tableView:canEditRowAtIndexPath:) func tableView(_ tableView: UITableView,
                                                            canEditRowAt indexPath: IndexPath) -> Bool {
        
        // Only edit items in user bank
        return tableView === tuningTableView && tuningModel.selectedBankIndex == tuningModel.userBankIndex
    }


    @objc(tableView:canMoveRowAtIndexPath:) func tableView(_ tableView: UITableView,
                                                           canMoveRowAt indexPath: IndexPath) -> Bool {

        return true
    }

    // Override to support rearranging the table view.
    @objc(tableView:moveRowAtIndexPath:toIndexPath:) func tableView(_ tableView: UITableView,
                                                                    moveRowAt fromIndexPath: IndexPath,
                                                                    to toIndexPath: IndexPath) {

        guard tableView === tuningTableView else { return }

        let fromIndex = Int(fromIndexPath.row)
        let toIndex = Int(toIndexPath.row)
        if tuningModel.reorderUserBank(tuningFromIndex: fromIndex, tuningToIndex: toIndex) {
            tuningTableView.reloadData()
            let ip = IndexPath(row: tuningModel.selectedTuningIndex, section: 0)
            tuningTableView.selectRow(at: ip, animated: true, scrollPosition: .middle)
        }
    }
}
