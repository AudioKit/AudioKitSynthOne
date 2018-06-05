//
//  Tunings+UITableViewDelegate.swift
//  AudioKitSynthOne
//
//  Created by AudioKit Contributors on 6/3/18.
//  Copyright © 2018 AudioKit. All rights reserved.
//

// MARK: - TableViewDelegate

extension TuningsViewController: UITableViewDelegate {

    public func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if cell.isSelected {
            cell.contentView.backgroundColor = #colorLiteral(red: 0.2, green: 0.2, blue: 0.2, alpha: 1)
        }
    }

    public func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tuningIndex = (indexPath as NSIndexPath).row
        tuningModel.selectTuning(atRow: tuningIndex)
        if let selectedCell = tableView.cellForRow(at: indexPath) {
            selectedCell.contentView.backgroundColor = #colorLiteral(red: 0.2, green: 0.2, blue: 0.2, alpha: 1)
        }
        tuningDidChange()
    }
}
