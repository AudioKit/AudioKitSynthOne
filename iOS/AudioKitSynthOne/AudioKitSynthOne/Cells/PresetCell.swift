//
//  PresetCell.swift
//  AudioKit Synth One
//
//  Created by Matthew Fecher on 7/28/16.
//  Copyright © 2016 AudioKit. All rights reserved.
//

import UIKit

protocol PresetCellDelegate {
    func renamePressed(preset: Preset)
    func duplicatePressed(preset: Preset)
    func sharePressed(preset: Preset)
}

class PresetCell: UITableViewCell {
    
    // *********************************************************
    // MARK: - Properties / Outlets
    // *********************************************************

    @IBOutlet weak var presetNameLabel: UILabel!
    @IBOutlet weak var renameButton: RoundedButton!
    @IBOutlet weak var shareButton: RoundedButton!
    @IBOutlet weak var duplicateButton: RoundedButton!
    
    var delegate: PresetCellDelegate?
    var currentPreset: Preset?
    
    // *********************************************************
    // MARK: - Lifecycle
    // *********************************************************
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        // set cell selection color
        let selectedView = UIView(frame: CGRect.zero)
        selectedView.backgroundColor = UIColor.clear
        selectedBackgroundView  = selectedView
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        let color = duplicateButton.backgroundColor
        super.setSelected(selected, animated: animated)
        
        duplicateButton.backgroundColor = color
        renameButton.backgroundColor = color
        shareButton.backgroundColor = color

        // Configure the view for the selected state
        if selected {
            presetNameLabel.textColor = UIColor.green
        } else {
            presetNameLabel.textColor = UIColor.white
        }
    }
    
    // *********************************************************
    // MARK: - Configure Cell
    // *********************************************************
    
    func configureCell(preset: Preset) {
        currentPreset = preset
        presetNameLabel.text = "\(preset.position): \(preset.name)"
    }
    
    // *********************************************************
    // MARK: - IBAction
    // *********************************************************
    @IBAction func duplicatePressed(_ sender: RoundedButton) {
        if let preset = currentPreset {
            delegate?.duplicatePressed(preset: preset)
        }
    }
    
    @IBAction func renamePressed(_ sender: RoundedButton) {
        if let preset = currentPreset {
            delegate?.renamePressed(preset: preset)
        }
    }

    @IBAction func sharePressed(_ sender: RoundedButton) {
        if let preset = currentPreset {
            delegate?.sharePressed(preset: preset)
        }
    }
    
    
}
