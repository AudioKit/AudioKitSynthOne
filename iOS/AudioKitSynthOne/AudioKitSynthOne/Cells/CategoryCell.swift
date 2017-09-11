//
//  CategoryCell.swift
//  SynthUISpike
//
//  Created by Matthew Fecher on 9/2/17.
//  Copyright © 2017 Matthew Fecher. All rights reserved.
//

import Foundation
//
//  PresetCell.swift
//  AudioKit Synth One
//
//  Created by Matthew Fecher on 7/28/16.
//  Copyright © 2016 AudioKit. All rights reserved.
//

import UIKit

class CategoryCell: UITableViewCell {
    
    // *********************************************************
    // MARK: - Properties / Outlets
    // *********************************************************
    
    @IBOutlet weak var categoryLabel: UILabel!
    @IBOutlet weak var editButton: UIButton!
    
    // var delegate: CategoryCellDelegate?
    // var currentPreset: Preset?
    
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
        
        categoryLabel?.textColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
        editButton.isHidden = true
    }
    
 
    override func setSelected(_ selected: Bool, animated: Bool) {
        // let color = editButton.backgroundColor
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
        if selected {
            categoryLabel?.textColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
            backgroundColor = #colorLiteral(red: 0.2431372549, green: 0.2431372549, blue: 0.262745098, alpha: 1)
           
        } else {
             categoryLabel?.textColor = #colorLiteral(red: 0.7333333333, green: 0.7333333333, blue: 0.7333333333, alpha: 1)
             backgroundColor = #colorLiteral(red: 0.2549019754, green: 0.2745098174, blue: 0.3019607961, alpha: 0)
        }
    }
 
    
    // *********************************************************
    // MARK: - Configure Cell
    // *********************************************************
    
    func configureCell(category: String) {
        //currentPreset = preset
        categoryLabel.text = "\(category)"
    }
    
    // *********************************************************
    // MARK: - IBAction
    // *********************************************************
    @IBAction func editPressed(_ sender: UIButton) {
        /*
         if let preset = currentPreset {
         delegate?.duplicatePressed(preset: preset)
         }
         */
    }
    
}
