//
//  RadioButton.swift
//  SynthUISpike
//
//  Created by Matthew Fecher on 7/26/17.
//  Copyright © 2017 Matthew Fecher. All rights reserved.
//

import UIKit

class RadioButton: UIButton {
    var alternateButton:Array<RadioButton>?
    public var callback: (Bool)->Void = { _ in }
    
    override func awakeFromNib() {
        self.layer.cornerRadius = 5
        self.layer.borderWidth = 2.0
        self.layer.masksToBounds = true
    }
    
    func unselectAlternateButtons(){
        if let alternateButton = alternateButton {
            alternateButton.forEach {
                $0.isSelected = false
            }
        } 
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        unselectAlternateButtons()
        super.touchesBegan(touches, with: event)
        toggleButton()
    }
    
    func toggleButton(){
        self.isSelected = !isSelected
    }
    
    override var isSelected: Bool {
        didSet {
            if isSelected {
                self.backgroundColor = #colorLiteral(red: 0.4352941176, green: 0.4352941176, blue: 0.4588235294, alpha: 1)
            } else {
                self.titleLabel?.textColor = #colorLiteral(red: 0.7921568627, green: 0.7921568627, blue: 0.7921568627, alpha: 1)
                self.backgroundColor = #colorLiteral(red: 0.3098039216, green: 0.3098039216, blue: 0.3333333333, alpha: 1)
            }
            self.setNeedsDisplay()
            callback(isSelected)
        }
    }
}
