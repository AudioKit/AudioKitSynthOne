//
//  PopUpBankEdit.swift
//  AudioKitSynthOne
//
//  Created by Matthew Fecher on 1/27/18.
//  Copyright © 2018 AudioKit. All rights reserved.
//

import UIKit

protocol BankPopOverDelegate {
    func didFinishEditing(name: String)
    func didDeleteBank(name: String)
}

class PopUpBankEdit: UIViewController {
    
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var popupView: UIView!
    @IBOutlet weak var warningText: UILabel!
    
    @IBOutlet weak var cancelButton: SynthUIButton!
    @IBOutlet weak var saveButton: SynthUIButton!
    @IBOutlet weak var deleteButton: SynthUIButton!
    
    
    var delegate: BankPopOverDelegate?
    
    var bankName = "bank name"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        popupView.layer.borderColor = #colorLiteral(red: 0.1333333333, green: 0.1333333333, blue: 0.1333333333, alpha: 1)
        popupView.layer.borderWidth = 2
        popupView.layer.cornerRadius = 6
        
        nameTextField.text = bankName
        
        setupCallbacks()
    }
    
    func setupCallbacks() {
       
        cancelButton.callback = { _ in
            self.dismiss(animated: true, completion: nil)
        }
        
        saveButton.callback = { _ in
            self.delegate?.didFinishEditing(name: self.nameTextField.text!)
            self.dismiss(animated: true, completion: nil)
        }
        
        deleteButton.callback = { _ in
            self.delegate?.didDeleteBank(name: self.bankName)
        }
        
    }

}
