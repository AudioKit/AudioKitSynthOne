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
            contentView.backgroundColor = #colorLiteral(red: 0.2431372549, green: 0.2431372549, blue: 0.262745098, alpha: 0.7547865317)

        } else {
            textLabel?.textColor = #colorLiteral(red: 0.7333333333, green: 0.7333333333, blue: 0.7333333333, alpha: 1)
            contentView.backgroundColor = UIColor.clear
        }
    }

    // MARK: - Configure Cell

    func configureCell() {
        isOpaque = false
        backgroundColor = UIColor.clear
        selectionStyle = .none
        textLabel?.font = UIFont(name: "Avenir Next", size: 12)!
        textLabel?.isOpaque = false
        textLabel?.backgroundColor = UIColor.clear
        contentView.isOpaque = false
        contentView.backgroundColor = UIColor.clear
    }
}
