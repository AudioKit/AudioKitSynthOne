//
//  PresetCell.swift
//  AudioKitSynthOne
//
//  Created by AudioKit Contributors on 7/28/16.
//  Copyright © 2016 AudioKit. All rights reserved.
//

import UIKit

protocol PresetCellDelegate: AnyObject {
    func editPressed()
    func duplicatePressed()
    func sharePressed()
    func favoritePressed()
}

class PresetCell: UITableViewCell {

    // MARK: - Properties / Outlets

    @IBOutlet weak var presetNameLabel: UILabel!
    @IBOutlet weak var renameButton: UIButton!
    @IBOutlet weak var shareButton: UIButton!
    @IBOutlet weak var duplicateButton: UIButton!
    @IBOutlet weak var favoriteButton: UIButton!
    @IBOutlet weak var labelTrailingConstraint: NSLayoutConstraint!
    
    weak var delegate: PresetCellDelegate?
    var currentPreset: Preset?
    let conductor = Conductor.sharedInstance

    // MARK: - Lifecycle

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code

        // set cell selection color
        let selectedView = UIView(frame: CGRect.zero)
        selectedView.backgroundColor = UIColor.clear
        selectedBackgroundView = selectedView
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        let color = duplicateButton.backgroundColor
        super.setSelected(selected, animated: animated)

        duplicateButton.backgroundColor = color
        renameButton.backgroundColor = color
        shareButton.backgroundColor = color

        // Configure the view for the selected state
        if selected {
            labelTrailingConstraint?.constant = 132
            presetNameLabel.textColor = UIColor.white
            backgroundColor = #colorLiteral(red: 0.2431372549, green: 0.2431372549, blue: 0.262745098, alpha: 1)

            duplicateButton.isHidden = false
            renameButton.isHidden = false
            shareButton.isHidden = false
            favoriteButton.isHidden = false

        } else {
            labelTrailingConstraint?.constant = 5
            presetNameLabel.textColor = #colorLiteral(red: 0.7333333333, green: 0.7333333333, blue: 0.7333333333, alpha: 1)
            backgroundColor = #colorLiteral(red: 0.2549019754, green: 0.2745098174, blue: 0.3019607961, alpha: 0)

            duplicateButton.isHidden = true
            renameButton.isHidden = true
            shareButton.isHidden = true
            favoriteButton.isHidden = true
        }
    }

    func configureCell(preset: Preset, alpha: Bool) {
        currentPreset = preset

        guard let bank = conductor.banks.first(where: { $0.name == preset.bank }) else { return }
        
        if conductor.device == .phone {
            presetNameLabel.font = UIFont(name: "Avenir Next", size: 14)
        }
        
        if alpha {
            presetNameLabel.text = "\(preset.name) (#\(preset.position))"
        } else {
            if preset.bank != "BankA" {
                presetNameLabel.text = "[\(bank.position)] \(preset.position): \(preset.name)"
            } else {
                presetNameLabel.text = "\(preset.position): \(preset.name)"
            }
        }

        if preset.isFavorite {
            favoriteButton.setImage(#imageLiteral(resourceName: "ak_favfilled"), for: .normal)
        } else {
            favoriteButton.setImage(#imageLiteral(resourceName: "ak_fav"), for: .normal)
        }

    }

    @IBAction func duplicatePressed(_ sender: UIButton) {
        delegate?.duplicatePressed()
    }

    @IBAction func editPressed(_ sender: UIButton) {
        delegate?.editPressed()
    }

    @IBAction func sharePressed(_ sender: UIButton) {
        delegate?.sharePressed()
    }

    @IBAction func favoritePressed(_ sender: UIButton) {
        delegate?.favoritePressed()
    }
}
