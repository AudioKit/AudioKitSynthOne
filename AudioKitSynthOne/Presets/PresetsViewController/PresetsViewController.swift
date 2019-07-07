//
//  PresetsViewController.swift
//  AudioKitSynthOne
//
//  Created by AudioKit Contributors on 7/24/17.
//  Copyright © 2018 AudioKit. All rights reserved.
//

import AudioKit
import UIKit
import Disk
import GameplayKit

protocol PresetsDelegate: AnyObject {
    func presetDidChange(_ activePreset: Preset)
    func saveEditedPreset(name: String, category: Int, bank: String)
    func banksDidUpdate()
}

extension UISearchBar {
    func change(textFont: UIFont!) {
        for view : UIView in (self.subviews[0]).subviews {
            if let textField = view as? UITextField {
                textField.font = textFont
            }
        }
    }
}

class PresetsViewController: UIViewController, UISearchBarDelegate, UISearchResultsUpdating {

    @IBOutlet weak var newButton: SynthButton!
    @IBOutlet weak var importButton: SynthButton!
    @IBOutlet weak var reorderButton: SynthButton!
    @IBOutlet weak var importBankButton: PresetUIButton!
    @IBOutlet weak var newBankButton: PresetUIButton!

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var categoryEmbeddedView: UIView!
    @IBOutlet weak var presetDescriptionField: UITextView!
    @IBOutlet weak var categoryLabel: UILabel!
    @IBOutlet weak var doneEditingButton: UIButton!
    @IBOutlet weak var searchtoolButton: SynthButton!
    
    var searchBar: UISearchBar! {
        didSet {
            searchBar.change(textFont: UIFont(name: "AvenirNext-Regular", size: UIFont.systemFontSize)!)
        }
    }
    
    var presets = [Preset]() {
        didSet {
            randomizePresets()
        }
    }

    var sortedPresets = [Preset]() {
        didSet {
            tableView.reloadData()
        }
    }

    var currentPreset = Preset() {
        didSet {
            createActivePreset()
            presetDescriptionField.text = currentPreset.userText
            categoryLabel.text = PresetCategory(rawValue: currentPreset.category)?.description()
            if resultSearchController.isActive {
                self.dismissSearch()
            }
        }
    }

    var filteredTableData = [Preset]()
    var resultSearchController = UISearchController(searchResultsController: nil)
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        // called when cancel button pressed
        self.dismissSearch()
    }
    
    func showSearch() {
        if !resultSearchController.isActive {
            resultSearchController.isActive = true
            tableView.tableHeaderView = searchBar
        }
    }
    
    func dismissSearch(){
        resultSearchController.isActive = false
        tableView.tableHeaderView = nil
        searchtoolButton.value = 0
        selectCurrentPreset()
    }

    func updateSearchResults(for searchController: UISearchController) {
        if let searchText = searchController.searchBar.text {
            if !searchText.isEmpty {
                filteredTableData.removeAll()
                let compareText = searchText.lowercased();
                for index in 0..<sortedPresets.count {
                    if sortedPresets[index].name.lowercased().contains(
                        compareText) ||
                        sortedPresets[index].userText.lowercased().contains(
                            compareText) {
                        filteredTableData.append(sortedPresets[index])
                    }
                }
            }
            else {
                filteredTableData = sortedPresets
            }
            tableView.reloadData()
            self.tableView.reloadData()
        }
    }

    var tempPreset = Preset()

    var categoryIndex: Int = 0 {
        didSet {
            sortPresets()
        }
    }

    var bankIndex: Int {
        var newIndex = categoryIndex - PresetCategory.bankStartingIndex
        if newIndex < 0 { newIndex = 0 }
        return newIndex
    }

    let conductor = Conductor.sharedInstance
    let userBankIndex = PresetCategory.bankStartingIndex + 1
    let userBankName = "User"

    var randomNumbers: GKRandomDistribution!

    weak var presetsDelegate: PresetsDelegate?


    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()

        resultSearchController = ({
            let controller = UISearchController(searchResultsController: nil)
            controller.searchResultsUpdater = self
            controller.searchBar.delegate = self
            controller.dimsBackgroundDuringPresentation = false
            controller.hidesNavigationBarDuringPresentation = false
            controller.searchBar.barStyle = UIBarStyle.black
            controller.searchBar.showsCancelButton = true
            controller.searchBar.keyboardAppearance = UIKeyboardAppearance.dark
            controller.searchBar.sizeToFit()
            searchBar = controller.searchBar
            tableView.backgroundView = UIView() // removes white background when pulling down search at top of list
            tableView.tableHeaderView = searchBar
            return controller
        })()

        definesPresentationContext = true
        // Reload the table
        tableView.reloadData()

        // Preset Description TextField
        presetDescriptionField.delegate = self
        presetDescriptionField.layer.cornerRadius = 4

        // set color for lines between rows
        tableView.separatorColor = #colorLiteral(red: 0.368627451, green: 0.368627451, blue: 0.3882352941, alpha: 1)

        // Set Initial Cateogry & Preset
        selectCategory(0)

        // Setup button callbacks
        setupCallbacks()

    }

    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        try? Disk.remove("temp", from: .caches)
    }

    // MARK: - Segue

    override public func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "SegueToEdit" {
            guard let popOverController = segue.destination as? PresetEditorViewController else { return }
            popOverController.delegate = self
            popOverController.preset = currentPreset
            popOverController.preferredContentSize = CGSize(width: 550, height: 316)
            if let presentation = popOverController.popoverPresentationController {
                presentation.backgroundColor = #colorLiteral(red: 0.1333333333, green: 0.1333333333, blue: 0.1333333333, alpha: 0)
            }
        }

        if segue.identifier == "SegueToBankEdit" {
            guard let popOverController = segue.destination as? BankEditorViewController else { return }
            popOverController.delegate = self
            let bank = conductor.banks.first(where: { $0.position == bankIndex })
            popOverController.bankName = bank?.name ?? "Unnamed Bank"
            popOverController.preferredContentSize = CGSize(width: 300, height: 320)
            if let presentation = popOverController.popoverPresentationController {
                presentation.backgroundColor = #colorLiteral(red: 0.2, green: 0.2, blue: 0.2, alpha: 1)
            }
        }
    }
}
