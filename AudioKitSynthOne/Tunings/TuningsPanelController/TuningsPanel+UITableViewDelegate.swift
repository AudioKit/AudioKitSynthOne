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

        selectedIndexPath = indexPath
        let selectedRow = indexPath.row
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
            tuningBankTableView.selectRow(at: indexPath, animated: true, scrollPosition: .top)

            // don't push if tuningViewController is on the stack
            let tuningVCOnStack = tuningNavController.viewControllers.contains { vc in
                return vc === tuningViewController ? true : false
            }
            if !tuningVCOnStack {
                tuningNavController.pushViewController(tuningViewController, animated: true)
            }
        } else {
            AKLog("error: no such tableview")
        }
    }

    // don't move 12ET
    @objc(tableView:canMoveRowAtIndexPath:)
    func tableView(_ tableView: UITableView,
                   canMoveRowAt indexPath: IndexPath) -> Bool {

        guard tableView === tuningTableView && tuningModel.selectedBankIndex == tuningModel.userBankIndex else { return false}

        return indexPath.row == 0 ? false : true
    }

    // don't edit 12ET
    @objc(tableView:canEditRowAtIndexPath:)
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {

        guard tableView === tuningTableView && tuningModel.selectedBankIndex == tuningModel.userBankIndex else { return false}

        return indexPath.row == 0 ? false : true
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

    @objc(tableView:willBeginEditingRowAtIndexPath:)
    func tableView(_ tableView: UITableView, willBeginEditingRowAt indexPath: IndexPath) {

        swipeGestureStarted = true;
    }

    @objc(tableView:didEndEditingRowAtIndexPath:)
    func tableView(_ tableView: UITableView, didEndEditingRowAt indexPath: IndexPath?) {

        if(swipeGestureStarted) {
            swipeGestureStarted = false
            tuningTableView.selectRow(at: selectedIndexPath, animated: true, scrollPosition: .none)
        }
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
