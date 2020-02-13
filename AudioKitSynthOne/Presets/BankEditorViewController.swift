//
//  BankEditorViewController.swift
//  AudioKitSynthOne
//
//  Created by AudioKit Contributors on 1/27/18.
//  Copyright © 2018 AudioKit. All rights reserved.
//

import UIKit

protocol BankPopOverDelegate: AnyObject {
    func didFinishEditing(oldName: String, newName: String)
    func didDeleteBank(bankName: String)
}

class BankEditorViewController: UIViewController {
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var popupView: UIView!
    @IBOutlet weak var cancelButton: SynthButton!
    @IBOutlet weak var saveButton: SynthButton!
    @IBOutlet weak var deleteButton: SynthButton!
    weak var delegate: BankPopOverDelegate?
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

        // cancel button
        cancelButton.setValueCallback = { _ in
            self.dismiss(animated: true, completion: nil)
        }

        // save button
        saveButton.setValueCallback = { _ in
            self.delegate?.didFinishEditing(oldName: self.bankName, newName: self.nameTextField.text ?? "Unnamed")
            self.dismiss(animated: true, completion: nil)
        }

        // delete button
        deleteButton.setValueCallback = { _ in
            self.delegate?.didDeleteBank(bankName: self.bankName)
            self.dismiss(animated: true, completion: nil)
        }
    }
}
