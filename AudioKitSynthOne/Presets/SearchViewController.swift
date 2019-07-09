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
    
    let resultSearchController = UISearchController(searchResultsController: nil)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.separatorColor = #colorLiteral(red: 0.3058823529, green: 0.3058823529, blue: 0.3254901961, alpha: 1)
        
        popUpView.layer.borderColor = #colorLiteral(red: 0.1333333333, green: 0.1333333333, blue: 0.1333333333, alpha: 1)
        popUpView.layer.borderWidth = 4
        popUpView.layer.cornerRadius = 6
        
        // Configure Search Controller
        resultSearchController.searchResultsUpdater = self
        resultSearchController.searchBar.delegate = self
        resultSearchController.dimsBackgroundDuringPresentation = false
        resultSearchController.hidesNavigationBarDuringPresentation = false
        resultSearchController.searchBar.barStyle = UIBarStyle.black
        resultSearchController.searchBar.showsCancelButton = true
        resultSearchController.searchBar.keyboardAppearance = UIKeyboardAppearance.dark
        resultSearchController.searchBar.sizeToFit()
        resultSearchController.definesPresentationContext = true
        resultSearchController.isActive = true
        view.addSubview(resultSearchController.searchBar)
       
        //tableView.backgroundView = UIView() // removes white background when pulling down search at top of list
        //tableView.tableHeaderView = resultSearchController.searchBar
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // Sort Presets Alphabetically and Display Them
        presets.forEach { $0.name.capitalizeFirstLetter() }
        presets.sort { $0.name < $1.name }
        filteredPresets = presets
        tableView.reloadData()
    }
    
}

// MARK: - SearchBar Delegate

extension SearchViewController: UISearchBarDelegate, UISearchResultsUpdating {
  
    func updateSearchResults(for searchController: UISearchController) {
        
        // Filter Results by Name & Description
        if let searchText = searchController.searchBar.text {
            if !searchText.isEmpty {
                filteredPresets.removeAll()
                let compareText = searchText.lowercased();
                for index in 0..<presets.count {
                    if presets[index].name.lowercased().contains(
                        compareText) ||
                        presets[index].userText.lowercased().contains(
                            compareText) {
                        filteredPresets.append(presets[index])
                    }
                }
            } else {
                filteredPresets = presets
            }
          
            filteredPresets.sort { $0.name < $1.name }
            tableView.reloadData()
        }
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
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
        if filteredPresets.isEmpty {
            return 0
        } else {
            return filteredPresets.count
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        // Get current preset
        
        if let cell = tableView.dequeueReusableCell(withIdentifier: "PresetCell") as? PresetCell {
            
            let preset = filteredPresets[(indexPath as NSIndexPath).row]
           
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
        resultSearchController.dismiss(animated: true, completion: nil)
        
        // Get cell
        let cell = tableView.cellForRow(at: indexPath) as? PresetCell
        guard let newPreset = cell?.currentPreset else { return }
        delegate?.didSelectPreset(newPreset)
        
        dismiss(animated: true, completion: nil)
    }
}
