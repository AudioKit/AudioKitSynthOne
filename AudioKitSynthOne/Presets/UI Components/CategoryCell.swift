//
//  CategoryCell.swift
//  AudioKitSynthOne
//
//  Created by AudioKit Contributors on 9/2/17.
//  Copyright © 2018 AudioKit. All rights reserved.
//

import UIKit

protocol CategoryCellDelegate: AnyObject {
    func bankShare()
    func bankEdit()
}

class CategoryCell: UITableViewCell {

    // MARK: - Properties / Outlets

    @IBOutlet weak var categoryLabel: UILabel!
    @IBOutlet weak var shareButton: UIButton!
    @IBOutlet weak var editButton: UIButton!
    @IBOutlet weak var labelTrailingConstraint: NSLayoutConstraint!
    
    var currentCategory: String = ""
    let conductor = Conductor.sharedInstance

    weak var delegate: CategoryCellDelegate?

    // MARK: - Lifecycle

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code

        // set cell selection color
        let selectedView = UIView(frame: CGRect.zero)
        selectedView.backgroundColor = UIColor.clear
        selectedBackgroundView = selectedView

        categoryLabel?.textColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
        shareButton.isHidden = true
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        // let color = editButton.backgroundColor
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
        if selected {
            categoryLabel?.textColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
            backgroundColor = #colorLiteral(red: 0.2431372549, green: 0.2431372549, blue: 0.262745098, alpha: 1)
            labelTrailingConstraint?.constant = 52
            
            // ⏣
            // Display Share & Edit Buttons
            if currentCategory.hasPrefix("⌾") {
                shareButton?.isHidden = false

                // Banks 0 & 1 can not be edited
                if currentCategory.hasPrefix("⌾ BankA") || currentCategory == ("⌾ User") {
                    editButton?.isHidden = true
                } else {
                    editButton?.isHidden = false
                }

            }
        } else {
             labelTrailingConstraint?.constant = 5
             categoryLabel?.textColor = #colorLiteral(red: 0.7333333333, green: 0.7333333333, blue: 0.7333333333, alpha: 1)
             backgroundColor = #colorLiteral(red: 0.2549019754, green: 0.2745098174, blue: 0.3019607961, alpha: 0)
             shareButton?.isHidden = true
             editButton?.isHidden = true
        }
    }

    // MARK: - Configure Cell

    func configureCell(category: String) {
        if conductor.device == .phone {
            categoryLabel.font = UIFont(name: "Avenir Next", size: 14)
        }
        currentCategory = category
        categoryLabel?.text = "\(category)"
    }

    // MARK: - IBAction

    @IBAction func sharePressed(_ sender: UIButton) {
        delegate?.bankShare()
    }

    @IBAction func editPressed(_ sender: UIButton) {
        delegate?.bankEdit()
    }
}
