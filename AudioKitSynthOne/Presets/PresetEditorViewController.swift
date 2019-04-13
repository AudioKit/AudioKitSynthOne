//
//  PresetEditorViewController.swift
//  AudioKitSynthOne
//
//  Created by AudioKit Contributors on 9/5/17.
//  Copyright © 2018 AudioKit. All rights reserved.
//

import UIKit

protocol PresetPopOverDelegate: AnyObject {
    func didFinishEditing(name: String, category: Int, newBank: String)
}

class PresetEditorViewController: UIViewController {
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var categoryTableView: UITableView!
    @IBOutlet weak var popupView: UIView!
    @IBOutlet weak var bankPicker: UIPickerView!
    @IBOutlet weak var saveButton: SynthButton!
    @IBOutlet weak var cancelButton: SynthButton!

    weak var delegate: PresetPopOverDelegate?

    var preset = Preset()
    var categories = [""]
    let cellReuseIdentifier = "PopUpCell"
    var categoryIndex = 0

    let conductor = Conductor.sharedInstance
    var pickerBankNames = [String]()
    var bankSelected = "BankA"

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()

        // Register the table view cell class and its reuse id
        categoryTableView.register(UITableViewCell.self, forCellReuseIdentifier: cellReuseIdentifier)

        popupView.layer.borderColor = #colorLiteral(red: 0.1333333333, green: 0.1333333333, blue: 0.1333333333, alpha: 1)
        popupView.layer.borderWidth = 4
        popupView.layer.cornerRadius = 6

        nameTextField.text = preset.name

        // Setup Picker
        //conductor.banks = conductor.banks.sorted { $0.position < $1.position }
        pickerBankNames = conductor.banks.map { $0.name }
        if let index = pickerBankNames.firstIndex(of: preset.bank) {
            bankPicker.selectRow(index, inComponent: 0, animated: true)
            bankSelected = preset.bank
        }
        
        // pull all preset categories
        categories.removeAll()
        for i in 0...PresetCategory.categoryCount {
            categories.append((PresetCategory(rawValue: i)?.description())!)
        }

        setupCallbacks()
		
		categoryTableView.accessibilityLabel = NSLocalizedString("Categories", comment: "Categories")
		categoryTableView.accessibilityHint = NSLocalizedString("Sets catagory for a preset.", comment: "Sets catagory for a preset.")
		
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        categoryTableView.reloadData()

        // Populate Preset current values
        categoryIndex = preset.category
        
        let indexPath = IndexPath(row: categoryIndex, section: 0)
        guard preset.category >= 0 && preset.category < PresetCategory.categoryCount else { return }
        categoryTableView.selectRow(at: indexPath, animated: true, scrollPosition: .middle)
    }

    // MARK: - IBActions

    func setupCallbacks() {

        cancelButton.callback = { _ in
            self.dismiss(animated: true, completion: nil)
        }

        saveButton.callback = { _ in
            self.delegate?.didFinishEditing(name: self.nameTextField.text ?? "Unnamed",
                                            category: self.categoryIndex,
                                            newBank: self.bankSelected)
            self.dismiss(animated: true, completion: nil)
        }

    }

}

// MARK: - TableViewDataSource

extension PresetEditorViewController: UITableViewDataSource {

    func numberOfSections(in categoryTableView: UITableView) -> Int {
        return 1
    }

    @objc(tableView:heightForRowAtIndexPath:) func tableView(_ tableView: UITableView,
                                                             heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 44
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if categories.isEmpty {
            return 1
        } else {
            return categories.count
        }
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let cell = tableView.dequeueReusableCell(withIdentifier: cellReuseIdentifier) as UITableViewCell? {
            cell.textLabel?.font = UIFont(name: "Avenir Next", size: 16)
            cell.textLabel?.text = categories[indexPath.row]
            return cell
        } else {
            let cell = UITableViewCell()
            cell.textLabel?.font = UIFont(name: "Avenir Next", size: 16)
            cell.textLabel?.text = categories[indexPath.row]
            return cell
        }
    }
}

// MARK: - TableViewDelegate

extension PresetEditorViewController: UITableViewDelegate {

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        categoryIndex = (indexPath as NSIndexPath).row
    }

}

// MARK: - PickerDataSource

extension PresetEditorViewController: UIPickerViewDataSource {

    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }

    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return pickerBankNames.count
    }

    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return pickerBankNames[row]
    }

    func pickerView(_ pickerView: UIPickerView,
                    viewForRow row: Int,
                    forComponent component: Int,
                    reusing view: UIView?) -> UIView {

        guard let pickerLabel = view as? UILabel else {
            let newLabel = UILabel()
            newLabel.font = UIFont(name: "Avenir Next Condensed", size: 18)
            newLabel.textAlignment = .center
            newLabel.text = pickerBankNames[row]
            newLabel.textColor = #colorLiteral(red: 0.7333333333, green: 0.7333333333, blue: 0.7333333333, alpha: 1)
            return newLabel
        }
        pickerLabel.text = pickerBankNames[row]
        pickerLabel.textColor = #colorLiteral(red: 0.7333333333, green: 0.7333333333, blue: 0.7333333333, alpha: 1)

        return pickerLabel
    }
}

// MARK: - PickerViewDelegate

extension PresetEditorViewController: UIPickerViewDelegate {

    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        bankSelected = pickerBankNames[row]
    }

}

// MARK: - UITextFieldDelegate

extension PresetEditorViewController: UITextFieldDelegate {
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        view.endEditing(true)
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        nameTextField.resignFirstResponder()
        return true
    }

}
