//
//  DevViewController.swift
//  AudioKitSynthOne
//
//  Created by Matthew Fecher on 12/2/17.
//  Copyright © 2017 AudioKit. All rights reserved.
//

import AudioKit
import UIKit

class DevViewController: UpdatableViewController {
    
    @IBOutlet weak var tuningTableView: UITableView!
    
    let devTunings = DevTunings()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tuningTableView.dataSource = devTunings
        tuningTableView.delegate = devTunings
    }
    
}


//@MATT: temporarily adding this inside DevViewController so that no new files are in source control
@objc open class DevTunings: NSObject, UITableViewDataSource, UITableViewDelegate {
    
    public typealias DevTuningCallback = () -> (Void)
    
    private let tunings: [(String, DevTuningCallback)] = [
        ("12ET", {_ = AKPolyphonicNode.tuningTable.defaultTuning() } ),
        ("12 Pythagorean 12", {_ = AKPolyphonicNode.tuningTable.tuningTable(fromFrequencies: [1,3,9,27,81,243,729,2187,6561,19683,59049,177147]) } ),
        ("6 hexany(1, 17, 19, 23)", {_ = AKPolyphonicNode.tuningTable.hexany(1, 17, 19, 23) } ),
        ("6 hexany(1, 3, 5, 7) ", {_ = AKPolyphonicNode.tuningTable.hexany(1, 3, 5, 7)  } ),
        ("6 hexany(1, 3, 5, 45) ", {_ = AKPolyphonicNode.tuningTable.hexany(1, 3, 5, 45)  } ),// 071
        ("6 hexany(1, 3, 5, 81)", {_ = AKPolyphonicNode.tuningTable.hexany(1, 3, 5, 81) } ),
        ("6 hexany(1, 3, 5, 121)", {_ = AKPolyphonicNode.tuningTable.hexany(1, 3, 5, 121) } ),
        ("6 hexany(1, 15, 45, 75)", {_ = AKPolyphonicNode.tuningTable.hexany(1, 15, 45, 75) } ),
        ("6 hexany(1, 45, 135, 225)", {_ = AKPolyphonicNode.tuningTable.hexany(1, 45, 135, 225) } ),
        ("6 hexany(3, 2.111, 5.111, 8.111)", {_ = AKPolyphonicNode.tuningTable.hexany(3, 2.111, 5.111, 8.111) } ),
        ("6 hexany(3, 5, 7, 9)", {_ = AKPolyphonicNode.tuningTable.hexany(3, 5, 7, 9) } ),
        ("6 hexany(3, 5, 15, 19)", {_ = AKPolyphonicNode.tuningTable.hexany(3, 5, 15, 19) } ),
        ("7 North Indian:Bhairav", {_ = AKPolyphonicNode.tuningTable.presetPersian17NorthIndian15Bhairav() } ),
        ("7 Highland Bagpipes", {_ = AKPolyphonicNode.tuningTable.presetHighlandBagPipes() } ),
        ("7 MOS G:0.2641", {_ = AKPolyphonicNode.tuningTable.momentOfSymmetry(generator: 0.2641, level: 5, murchana: 0)})
    ]
    
    ///UITableViewDataSource
    public func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    @objc(tableView:heightForRowAtIndexPath:) public func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 44
    }

    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tunings.count
    }
    
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let tuning = tunings[(indexPath as NSIndexPath).row]
        let title = tuning.0 // title
        if let cell = tableView.dequeueReusableCell(withIdentifier: "DevTunings") as UITableViewCell! {
            configureCell(cell)
            cell.textLabel?.text = title
            return cell
        } else {
            let cell = UITableViewCell()
            configureCell(cell)
            cell.textLabel?.text = title
            return cell
        }
    }
    
    private func configureCell(_ cell: UITableViewCell) {
        cell.backgroundColor = #colorLiteral(red: 0.2549019754, green: 0.2745098174, blue: 0.3019607961, alpha: 1)
        cell.textLabel?.textColor = #colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0)
    }
    
    ///UITableViewDelegate
    public func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let tuning = tunings[(indexPath as NSIndexPath).row]
        tuning.1()
    }
}
