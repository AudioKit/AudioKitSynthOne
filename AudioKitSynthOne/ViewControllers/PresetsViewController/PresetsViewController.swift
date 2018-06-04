//
//  PresetsViewController.swift
//  AudioKit Synth One
//
//  Created by AudioKit Contributors on 7/24/17.
//  Copyright © 2017 Matthew Fecher. All rights reserved.
//

import AudioKit
import UIKit
import MobileCoreServices
import Disk
import CloudKit
import GameplayKit

protocol PresetsDelegate: AnyObject {
    func presetDidChange(_ activePreset: Preset)
    func saveEditedPreset(name: String, category: Int, bank: String)
    func banksDidUpdate()
}

class PresetsViewController: UIViewController {

    @IBOutlet weak var newButton: SynthUIButton!
    @IBOutlet weak var importButton: SynthUIButton!
    @IBOutlet weak var reorderButton: SynthUIButton!
    @IBOutlet weak var importBankButton: PresetUIButton!
    @IBOutlet weak var newBankButton: PresetUIButton!

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var categoryEmbeddedView: UIView!
    @IBOutlet weak var presetDescriptionField: UITextView!
    @IBOutlet weak var categoryLabel: UILabel!
    @IBOutlet weak var doneEditingButton: UIButton!

    var presets = [Preset]() {
        didSet {
            randomizePresets()
        }
    }

    var sortedPresets = [Preset]() {
        didSet {
            tableView.reloadData()
            selectCurrentPreset()
        }
    }

    var currentPreset = Preset() {
        didSet {
            createActivePreset()
            presetDescriptionField.text = currentPreset.userText
            categoryLabel.text = PresetCategory(rawValue: currentPreset.category)?.description()
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

    // *****************************************************************
    // MARK: - Lifecycle
    // *****************************************************************

    override func viewDidLoad() {
        super.viewDidLoad()

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

    // *****************************************************************
    // MARK: - Load/Save/Manipulate Presets
    // *****************************************************************

    func loadBanks() {
        presets.removeAll()

        conductor.banks.forEach { bank in
            let fileName = bank.name + ".json"

            // Load presets
            if Disk.exists(fileName, in: .documents) {
                loadPresetsFromDevice(fileName)
            } else {
                loadFactoryPresets(bank.name)
            }

            saveAllPresetsIn(bank.name)
        }

        updateCategoryTable()
    }

    func sortPresets() {

        switch categoryIndex {

        // Display Categories
        case 0:
            // All Presets, by Bank
            sortedPresets.removeAll()
            conductor.banks.forEach { bank in
                sortedPresets += presets.filter { $0.bank == bank.name }.sorted { $0.position < $1.position }
            }

        // Sort by Categories
        case 1...PresetCategory.categoryCount:
            sortedPresets.removeAll()
            let categoryPresets = presets.filter { $0.category == categoryIndex }
            conductor.banks.forEach { bank in
                sortedPresets += categoryPresets.filter { $0.bank == bank.name }.sorted { $0.position < $1.position }
            }

        // Sort by Favorites
        case PresetCategory.categoryCount + 1:
            sortedPresets = presets.filter { $0.isFavorite }

        // Display Banks
        case PresetCategory.bankStartingIndex ... PresetCategory.bankStartingIndex + conductor.banks.count:
            guard let bank = conductor.banks.first(where: { $0.position == bankIndex }) else { return }
            sortedPresets = presets.filter { $0.bank == bank.name }
                .sorted { $0.position < $1.position }

        default:
            // Display BankA
            sortedPresets = presets.filter { $0.bank == "BankA" }.sorted { $0.position < $1.position }
        }
    }

    func randomizePresets() {
        // Generate random presets 🎲
        randomNumbers = GKShuffledDistribution(lowestValue: 0, highestValue: presets.count - 1)
    }

    func loadPresetsFromDevice(_ fileName: String) {
        do {
            let retrievedPresetData = try Disk.retrieve(fileName, from: .documents, as: Data.self)
            parsePresetsFromData(data: retrievedPresetData)
        } catch {
            AKLog("*** error loading")
        }
    }

    func loadFactoryPresets(_ bank: String) {
        if let filePath = Bundle.main.path(forResource: bank, ofType: "json") {
            guard let data = try? NSData(contentsOfFile: filePath, options: NSData.ReadingOptions.uncached) as Data
                else { return }
            parsePresetsFromData(data: data)
        }
    }

    func parsePresetsFromData(data: Data) {
        let presetsJSON = try? JSONSerialization.jsonObject(with: data, options: [])
        guard let jsonArray = presetsJSON as? [Any] else { return }

        presets += Preset.parseDataToPresets(jsonArray: jsonArray)
        sortPresets()
    }

    func saveAllPresetsIn(_ bank: String) {
        let presetsToSave = presets.filter { $0.bank == bank }.sorted { $0.position < $1.position }
        for (i, preset) in presetsToSave.enumerated() {
            preset.position = i
        }

        do {
            try Disk.save(presetsToSave, to: .documents, as: bank + ".json")
            sortPresets()
        } catch {
            AKLog("error saving")
        }
    }

    // Save activePreset
    func savePreset(_ activePreset: Preset) {

        activePreset.userText = presetDescriptionField.text

        var updateExistingPreset = false

        // Check if preset name exists
        if presets.contains(where: { $0.name == activePreset.name }) {
            updateExistingPreset = true
        }

        if updateExistingPreset {
            // Remove currentPreset and replace it with activePreset
            if let position = presets.index(where: { $0.uid == currentPreset.uid }) {
                presets.remove(at: position)
                presets.insert(activePreset, at: activePreset.position)
            }
        } else {
            // create new preset
            activePreset.uid = UUID().uuidString
            presets.insert(activePreset, at: activePreset.position + 1)
        }

        activePreset.isUser = true
        currentPreset = activePreset
        saveAllPresetsIn(currentPreset.bank)

        // Create new active preset
        createActivePreset()
    }

    func selectCategory(_ newIndex: Int) {
        guard let categoriesVC = self.childViewControllers.first as? PresetsCategoriesController else { return }
        categoriesVC.categoryTableView.selectRow(at: IndexPath(row: newIndex, section: 0),
                                                 animated: false,
                                                 scrollPosition: .top)
    }

    func updateCategoryTable() {
        guard let categoriesVC = self.childViewControllers.first as? PresetsCategoriesController else { return }
        categoriesVC.updateChoices()
    }

    func createActivePreset() {
        do {
            try Disk.save(currentPreset, to: .caches, as: "currentPreset.json")
            if let activePreset = try? Disk.retrieve("currentPreset.json", from: .caches, as: Preset.self) {
                presetsDelegate?.presetDidChange(activePreset)
            }
        } catch {
            AKLog("error saving")
        }
    }

    func selectCurrentPreset() {
        // Find the preset in the current view
        if let index = sortedPresets.index(where: { $0 === currentPreset }) {
            tableView.selectRow(at: IndexPath(row: index, section: 0), animated: true, scrollPosition: .middle)
        } else {
            tableView.setContentOffset(CGPoint.zero, animated: false)
        }

        // Update all UI
        Conductor.sharedInstance.updateAllUI()
    }

    func deselectCurrentRow() {
        if let index = sortedPresets.index(where: { $0 === currentPreset }) {
            tableView.deselectRow(at: IndexPath(row: index, section: 0), animated: false)
        }
    }

    func upgradePresets() {

        // Remove existing presets
       // let banksToUpdate = ["BankA", "Brice Beasley", "DJ Puzzle", "Red Sky Lullaby"]
        let banksToUpdate = ["BankA", "Red Sky Lullaby"]
        banksToUpdate.forEach { bankName in
            presets = presets.filter { $0.bank != bankName }
            loadFactoryPresets(bankName)
            saveAllPresetsIn(bankName)
        }

        // If the bankName is not in conductorBanks, add bank to conductor banks
        for bankName in initBanks {
            if !conductor.banks.contains(where: { $0.name == bankName }) {
                // Add bank to conductor banks
                let bank = Bank(name: bankName, position: conductor.banks.count)
                conductor.banks.append(bank)
                presetsDelegate?.banksDidUpdate()
            }
        }
    }

    func addBonusPresets() {
      let bankName = "BankA"
      presets = presets.filter { $0.bank != bankName }
      loadFactoryPresets("Bonus")
      saveAllPresetsIn(bankName)
    }

    // *****************************************************************
    // MARK: - IBActions / Callbacks
    // *****************************************************************

    func setupCallbacks() {

        newButton.callback = { _ in
            let userBankCount = self.presets.filter { $0.bank == self.userBankName }.count
            let initPreset = Preset(position: userBankCount)
            self.presets.append(initPreset)
            self.currentPreset = initPreset

            // Show User Category
            self.selectCategory(self.userBankIndex)
            self.categoryIndex = self.userBankIndex

            // Save new preset in User Bank
            self.saveAllPresetsIn(self.currentPreset.bank)
        }

        newBankButton.callback = { _ in

            // New Bank Name
            let newBankIndex = self.conductor.banks.count
            let newBankName = "Bank\(newBankIndex)"

            // Add a preset to the new Bank
            let initPreset = Preset(position: 0)
            initPreset.bank = newBankName
            self.presets.append(initPreset)
            self.saveAllPresetsIn(newBankName)

            // Add new bank to App settings
            self.addNewBank(newBankName: newBankName, newBankIndex: newBankIndex)
        }

        importButton.callback = { _ in
            let documentPicker = UIDocumentPickerViewController(documentTypes: [(kUTTypeText as String)], in: .import)
            documentPicker.delegate = self
            self.present(documentPicker, animated: true, completion: nil)
        }

        importBankButton.callback = { _ in
            let documentPicker = UIDocumentPickerViewController(documentTypes: [String(kUTTypeText)], in: .import)
            documentPicker.delegate = self
            self.present(documentPicker, animated: true, completion: nil)
        }

        reorderButton.callback = { _ in
            self.tableView.isEditing = !self.tableView.isEditing

            // Set Categories table to a specific bank
            if self.categoryIndex < PresetCategory.bankStartingIndex {
                self.categoryIndex = PresetCategory.bankStartingIndex
            }

            self.selectCategory(self.categoryIndex) // select category in category table

            if self.tableView.isEditing {
                self.reorderButton.setTitle("I'M DONE!", for: UIControlState())
                self.reorderButton.setTitleColor(#colorLiteral(red: 0, green: 0, blue: 0, alpha: 1), for: .normal)
                self.reorderButton.backgroundColor = #colorLiteral(red: 0.9019607843, green: 0.5333333333, blue: 0.007843137255, alpha: 1)
                self.categoryEmbeddedView.isUserInteractionEnabled = false

            } else {
                self.reorderButton.setTitle("Reorder", for: UIControlState())
                self.reorderButton.setTitleColor(#colorLiteral(red: 0.7333333333, green: 0.7333333333, blue: 0.7333333333, alpha: 1), for: .normal)
                self.reorderButton.backgroundColor = #colorLiteral(red: 0.1764705882, green: 0.1764705882, blue: 0.1764705882, alpha: 1)
                self.categoryEmbeddedView.isUserInteractionEnabled = true
                self.selectCurrentPreset()
            }
        }

    }

    func nextPreset() {
        let presetBank = presets.filter { $0.bank == currentPreset.bank }.sorted { $0.position < $1.position }

        if currentPreset.position < presetBank.count - 1 {
            currentPreset = presetBank[currentPreset.position + 1]

        } else {
            currentPreset = presetBank[0]
        }

        selectCurrentPreset()
    }

    func prevPreset() {
        let presetBank = presets.filter { $0.bank == currentPreset.bank }.sorted { $0.position < $1.position }

        if currentPreset.position > 0 {
            currentPreset = presetBank[currentPreset.position + -1 ]

        } else {
            guard let lastPreset = presetBank.last else { return }
            currentPreset = lastPreset
        }

        selectCurrentPreset()
    }

    // Used for Selecting Presets from Program Change
    func didSelectPreset(index: Int) {
        deselectCurrentRow()

        // Get current Bank
        guard let currentBank = conductor.banks.first(where: { $0.position == bankIndex }) else { return }
        let presetsInBank = presets.filter { $0.bank == currentBank.name }.sorted { $0.position < $1.position }

        // Smoothly cycle through presets if MIDI input is greater than preset count
        let currentPresetIndex = index % (presetsInBank.count)

        AKLog ("currentPresetIndex \(currentPresetIndex)")

        currentPreset = presetsInBank[currentPresetIndex]
        selectCurrentPreset()
    }

    // Used for Selecting Bank from MIDI msb (cc0)
    func didSelectBank(index: Int) {

        var newBankIndex = index
        if newBankIndex < 0 {
            newBankIndex = 0
        }
        if newBankIndex > conductor.banks.count - 1 {
            newBankIndex = conductor.banks.count - 1
        }

        // Update Category Table
        selectCategory(PresetCategory.bankStartingIndex + newBankIndex)
        categoryIndex = PresetCategory.bankStartingIndex + newBankIndex
    }

    func randomPreset() {
        deselectCurrentRow()

        // Pick random Preset
        var newIndex = randomNumbers.nextInt()
        if newIndex == currentPreset.position { newIndex = randomNumbers.nextInt() }
        currentPreset = presets[newIndex]
        selectCurrentPreset()
    }

    func addNewBank(newBankName: String, newBankIndex: Int) {
        // Add new bank to App settings
        let newBank = Bank(name: newBankName, position: newBankIndex)
        self.conductor.banks.append(newBank)

        self.presetsDelegate?.banksDidUpdate()

        // Add Bank to left category listing
        self.updateCategoryTable()
        self.selectCategory(PresetCategory.bankStartingIndex + newBankIndex)
        self.self.categoryIndex = PresetCategory.bankStartingIndex + newBankIndex

        self.sortPresets()
    }

    // *****************************************************************
    // MARK: - Segue
    // *****************************************************************

    override public func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "SegueToEdit" {
            guard let popOverController = segue.destination as? PopUpPresetEdit else { return }
            popOverController.delegate = self
            popOverController.preset = currentPreset
            popOverController.preferredContentSize = CGSize(width: 550, height: 316)
            if let presentation = popOverController.popoverPresentationController {
                presentation.backgroundColor = #colorLiteral(red: 0.1333333333, green: 0.1333333333, blue: 0.1333333333, alpha: 0)
            }
        }

        if segue.identifier == "SegueToBankEdit" {
            guard let popOverController = segue.destination as? PopUpBankEdit else { return }
            popOverController.delegate = self
            let bank = conductor.banks.first(where: { $0.position == bankIndex })
            popOverController.bankName = bank?.name ?? "Unnamed Bank"
            popOverController.preferredContentSize = CGSize(width: 300, height: 320)
            if let presentation = popOverController.popoverPresentationController {
                presentation.backgroundColor = #colorLiteral(red: 0.2, green: 0.2, blue: 0.2, alpha: 1)
            }
        }
    }

    // *****************************************************************
    // MARK: - TextView
    // *****************************************************************

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        view.endEditing(true)
    }

    @IBAction func doneEditingPressed(_ sender: UIButton) {
        view.endEditing(true)
        presetsDelegate?.saveEditedPreset(name: currentPreset.name,
                                          category: currentPreset.category,
                                          bank: currentPreset.bank)
    }

}

// *****************************************************************
// MARK: - TextView Delegate
// *****************************************************************

extension PresetsViewController: UITextViewDelegate {
    func textViewDidEndEditing(_ textView: UITextView) {
        doneEditingButton.isHidden = true
    }

    func textViewDidBeginEditing(_ textView: UITextView) {
        doneEditingButton.isHidden = false
    }
}
