//
//  TuningsPanel+UITableViewDataSource.swift
//  AudioKitSynthOne
//
//  Created by AudioKit Contributors on 6/3/18.
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
        return tuningModel.tunings.count
    }

    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        tableView.separatorColor = #colorLiteral(red: 0.368627451, green: 0.368627451, blue: 0.3882352941, alpha: 1)
        let tuning = tuningModel.tunings[(indexPath as NSIndexPath).row]
        let title = tuning.name
        if let cell = tableView.dequeueReusableCell(withIdentifier: "TuningCell") as? TuningCell {
            cell.configureCell()
            cell.textLabel?.text = title
            return cell
        } else {
            let cell = TuningCell()
            cell.configureCell()
            cell.textLabel?.text = title
            return cell
        }
    }
}
