//
//  TuningCell.swift
//  AudioKitSynthOne
//
//  Created by AudioKit Contributors on 6/3/18.
//  Copyright © 2018 AudioKit. All rights reserved.
//

import UIKit

class TuningCell: UITableViewCell {

    // MARK: - Lifecycle

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
        if selected {
            textLabel?.textColor = UIColor.white
            backgroundColor = #colorLiteral(red: 0.2431372549, green: 0.2431372549, blue: 0.262745098, alpha: 1)
        } else {
            textLabel?.textColor = #colorLiteral(red: 0.7333333333, green: 0.7333333333, blue: 0.7333333333, alpha: 1)
            //backgroundColor = #colorLiteral(red: 0.2549019754, green: 0.2745098174, blue: 0.3019607961, alpha: 0)
            backgroundColor = #colorLiteral(red: 0.1215686275, green: 0.1294117647, blue: 0.1411764706, alpha: 1)
        }
    }

    // MARK: - Configure Cell

    func configureCell() {
        //isOpaque = false
        isOpaque = true
        backgroundColor = UIColor.clear
        textLabel?.textColor = #colorLiteral(red: 0.694699347, green: 0.6895567775, blue: 0.6986362338, alpha: 1)
        selectionStyle = .gray
        textLabel?.font = UIFont(name: "Avenir Next", size: 16)!
    }
}
