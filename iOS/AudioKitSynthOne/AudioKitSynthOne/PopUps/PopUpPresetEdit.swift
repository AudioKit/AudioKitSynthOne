//
//  PopUpPresetEdit.swift
//  AudioKit Synth One
//
//  Created by Matthew Fecher on 9/5/17.
//  Copyright © 2017 Matthew Fecher. All rights reserved.
//

import UIKit

protocol PresetPopOverDelegate {
    func didFinishEditing(name: String, category: Int)
}

class PopUpPresetEdit: UIViewController {
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var categoryTableView: UITableView!
    @IBOutlet weak var popupView: UIView!
    
    var delegate: PresetPopOverDelegate?
    
    var preset = Preset()
    var categories = ["none","arp/seq","poly","pad","lead","bass","pluck"]
    let cellReuseIdentifier = "PopUpCell"
    var categoryIndex = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Register the table view cell class and its reuse id
        categoryTableView.register(UITableViewCell.self, forCellReuseIdentifier: cellReuseIdentifier)
        
        popupView.layer.borderColor = #colorLiteral(red: 0.1333333333, green: 0.1333333333, blue: 0.1333333333, alpha: 1)
        popupView.layer.borderWidth = 2
        popupView.layer.cornerRadius = 6
        
        nameTextField.text = preset.name
    }
    
    override func viewDidAppear(_ animated: Bool) {
        categoryTableView.reloadData()
        
        // Populate Preset current values
        categoryIndex = preset.category.hashValue
        let indexPath = IndexPath(row: categoryIndex, section: 0)
        categoryTableView.selectRow(at: indexPath, animated: true, scrollPosition: .middle)
    }
    
    @IBAction func closePressed(_ sender: UIButton) {
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func savePressed(_ sender: UIButton) {
        delegate?.didFinishEditing(name: nameTextField.text!, category: categoryIndex)
        dismiss(animated: true, completion: nil)
    }
}

// *****************************************************************
// MARK: - TableViewDataSource
// *****************************************************************

extension PopUpPresetEdit: UITableViewDataSource {
    
    func numberOfSections(in categoryTableView: UITableView) -> Int {
        return 1
    }
    
    @objc(tableView:heightForRowAtIndexPath:) func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
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
        
        let cell:UITableViewCell = tableView.dequeueReusableCell(withIdentifier: cellReuseIdentifier) as UITableViewCell!
        
        cell.textLabel?.font = UIFont.systemFont(ofSize: 15.0)
        cell.textLabel?.text = categories[indexPath.row]
        return cell
    }
}

//*****************************************************************
// MARK: - TableViewDelegate
//*****************************************************************

extension PopUpPresetEdit: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        categoryIndex = (indexPath as NSIndexPath).row
    }
    
}


