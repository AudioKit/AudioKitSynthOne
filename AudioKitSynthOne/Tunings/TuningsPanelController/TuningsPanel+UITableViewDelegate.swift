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
        let selectedRow = (indexPath as NSIndexPath).row
        if tableView == tuningTableView {
            tuningModel.selectTuning(atRow: selectedRow)
            tuningTableView.selectRow(at: indexPath, animated: true, scrollPosition: .middle)
        } else if tableView == tuningBankTableView {
            tuningModel.selectBank(atRow: selectedRow)
            tuningBankTableView.selectRow(at: indexPath, animated: true, scrollPosition: .top)
            tuningTableView.reloadData()
            let tuningPath = IndexPath(row: tuningModel.selectedTuningIndex, section: 0)
            tuningTableView.selectRow(at: tuningPath, animated: false, scrollPosition: .middle)
        } else {
            AKLog("error: no such tableview")
        }
    }
}
