//
//  SearchViewController.swift
//  AudioKitSynthOne
//
//  Created by Matthew Fecher on 7/8/19.
//  Copyright © 2019 AudioKit. All rights reserved.
//

import UIKit

protocol SearchControllerDelegate: AnyObject {
   func didSelectPreset(_ newPreset: Preset)
}

class SearchViewController: UIViewController {
    
    @IBOutlet weak var popUpView: UIView!
    @IBOutlet weak var tableView: UITableView!
    weak var delegate: SearchControllerDelegate?
    
    var presets = [Preset]()
    var filteredPresets = [Preset]() {
        didSet {
            tableView.reloadData()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.separatorColor = #colorLiteral(red: 0.3058823529, green: 0.3058823529, blue: 0.3254901961, alpha: 1)
        
        popUpView.layer.borderColor = #colorLiteral(red: 0.1333333333, green: 0.1333333333, blue: 0.1333333333, alpha: 1)
        popUpView.layer.borderWidth = 4
        popUpView.layer.cornerRadius = 6
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        presets.forEach { $0.name.capitalizeFirstLetter() }
        presets.sort { $0.name < $1.name }
        tableView.reloadData()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
    }
    
    @IBAction func closeTapped(_ sender: UIButton) {
        self.dismiss(animated: true, completion: nil)
    }
    
    
}

// MARK: - TableViewDataSource

extension SearchViewController: UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    @objc(tableView:heightForRowAtIndexPath:) func tableView(_ tableView: UITableView,
                                                             heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 44
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if presets.isEmpty {
            return 0
        } else {
            return presets.count
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        // Get current preset
        
        if let cell = tableView.dequeueReusableCell(withIdentifier: "PresetCell") as? PresetCell {
            
            let preset = presets[(indexPath as NSIndexPath).row]
           
            // Cell updated in PresetCell.swift
            cell.configureCell(preset: preset, alpha: true)
            
            return cell
        } else {
            return PresetCell()
        }
    }
    
}

// MARK: - TableViewDelegate

extension SearchViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        // Get cell
        let cell = tableView.cellForRow(at: indexPath) as? PresetCell
        guard let newPreset = cell?.currentPreset else { return }
        delegate?.didSelectPreset(newPreset)
        dismiss(animated: true, completion: nil)
    }
}
