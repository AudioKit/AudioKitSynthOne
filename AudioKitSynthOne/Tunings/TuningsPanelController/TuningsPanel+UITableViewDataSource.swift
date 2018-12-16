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
        return 44
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
        
        let cell: TuningCell
        if let reusableCell = tableView.dequeueReusableCell(withIdentifier: "TuningCell") as? TuningCell {
            cell = reusableCell
        } else {
            cell = TuningCell()
        }
        cell.configureCell()

        let title: String
        if tableView == tuningBankTableView {
            title = tuningModel.tuningBank.name
        } else if tableView == tuningTableView {
            let tuning = tuningModel.tunings[(indexPath as NSIndexPath).row]
            title = tuning.name
        } else {
            title = "error"
        }

        cell.textLabel?.text = title
        return cell
    }
}
