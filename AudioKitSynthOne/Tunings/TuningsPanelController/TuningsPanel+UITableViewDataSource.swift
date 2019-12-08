//
//  TuningsPanel+UITableViewDataSource.swift
//  AudioKitSynthOne
//
//  Created by Marcus Hobbs on 6/3/18.
//  Copyright © 2018 AudioKit. All rights reserved.
//

import UIKit

extension TuningsPanelController: UITableViewDataSource {
    public func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    @objc(tableView:heightForRowAtIndexPath:) public func tableView(_ tableView: UITableView,
                                                                    heightForRowAt indexPath: IndexPath) -> CGFloat {
        var cellHeight: CGFloat = 12
        let isIpad = Conductor.sharedInstance.device == .pad
        let isBankCell = (tableView === tuningBankTableView)
        switch (isIpad, isBankCell) {

        ///iPhone
        case (false, false): cellHeight = 36 /// tuning
        case (false, true): cellHeight = 48 /// bank

        ///iPad
        case (true, false): cellHeight = 48 /// tuning
        case (true, true): cellHeight = 64 /// bank
        }
        return cellHeight
    }

    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if tableView == tuningBankTableView {
            return tuningModel.tuningBanks.count
        } else if tableView == tuningTableView {
            return tuningModel.tunings.count
        }
        return 0
    }

    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        tableView.separatorColor = #colorLiteral(red: 0.368627451, green: 0.368627451, blue: 0.3882352941, alpha: 1)
        let row = (indexPath as NSIndexPath).row
        let reuseID: String
        if tableView == tuningBankTableView {
            reuseID = "TuningBankCell"
        } else {
            reuseID = "TuningCell"
        }
        let cell: TuningCell
        if let reusableCell = tableView.dequeueReusableCell(withIdentifier: reuseID) as? TuningCell {
            cell = reusableCell
        } else {
            cell = TuningCell()
        }
        let cellDelta: CGFloat = 8 + 8 + 8
        var fontSize: CGFloat = cellDelta * 2
        let isIpad = Conductor.sharedInstance.device == .pad
        let isBankCell = (tableView === tuningBankTableView)
        switch (isIpad, isBankCell) {

        ///iPhone
        case (false, false): fontSize = 32 + 4 - cellDelta /// tuning
        case (false, true): fontSize = 48 - 8 - cellDelta /// bank

        ///iPad
        case (true, false): fontSize = 36 - 16 - 8 + 4 /// tuning
        case (true, true): fontSize = 48 - 16 - 8 /// bank
        }
        cell.configureCell(fontSize: Int(fontSize))
        if tableView == tuningBankTableView {
            cell.textLabel?.numberOfLines = 3
            let bg0 = UIImageView(image: UIImage(named: "right-arrow"), highlightedImage: nil)
            bg0.backgroundColor = .clear
            cell.accessoryView = bg0
        } else {
            cell.textLabel?.numberOfLines = 3
            cell.accessoryView = nil
            cell.accessoryType = .none
        }
        let title: String
        if tableView == tuningBankTableView {
            let bank = tuningModel.tuningBanks[row]
            title = bank.name
        } else if tableView == tuningTableView {
            let tuning = tuningModel.tunings[row]
            title = tuning.nameForCell
        } else {
            title = "error"
        }
        cell.textLabel?.text = title
        return cell
    }
}
