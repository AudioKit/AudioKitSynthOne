//
//  PresetsViewController.swift
//  AudioKit Synth One
//
//  Created by Matthew Fecher on 7/24/17.
//  Copyright © 2017 Matthew Fecher. All rights reserved.
//

import AudioKit
import UIKit
import MobileCoreServices
import Disk
import CloudKit
import GameplayKit

protocol PresetsDelegate {
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
        get {
           var newIndex = categoryIndex - PresetCategory.bankStartingIndex
           if newIndex < 0 { newIndex = 0 }
           return newIndex
        }
    }
    
    let conductor = Conductor.sharedInstance
    let userBankIndex = PresetCategory.bankStartingIndex + 1
    let userBankName = "User"
    
    var randomNumbers: GKRandomDistribution!
    
    var presetsDelegate: PresetsDelegate?
    
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
            let bank = conductor.banks.filter{ $0.position == bankIndex }.first
            sortedPresets = presets.filter { $0.bank == bank!.name }
                .sorted { $0.position < $1.position }
            
        default:
            // Display BankA
            sortedPresets = presets.filter { $0.bank == "BankA" }.sorted { $0.position < $1.position }
        }
    }
    
    func randomizePresets() {
        // Generate random presets 🎲
        randomNumbers = GKShuffledDistribution(lowestValue: 0, highestValue: presets.count-1)
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
        if let filePath = Bundle.main.path(forResource: bank, ofType:"json") {
            let data = try? NSData(contentsOfFile: filePath, options: NSData.ReadingOptions.uncached) as Data
            parsePresetsFromData(data: data!)
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
            presets.insert(activePreset, at: activePreset.position+1)
        }
        
        activePreset.isUser = true
        currentPreset = activePreset
        saveAllPresetsIn(currentPreset.bank)
        
        // Create new active preset
        createActivePreset()
    }
    
    func selectCategory(_ newIndex: Int) {
        guard let categoriesVC = self.childViewControllers.first as? PresetsCategoriesController else { return }
        categoriesVC.categoryTableView.selectRow(at: IndexPath(row: newIndex, section: 0), animated: false, scrollPosition: .top)
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
        if let index = sortedPresets.index(where: {$0 === currentPreset}) {
            tableView.selectRow(at: IndexPath(row: index, section: 0), animated: true, scrollPosition: .middle)
        } else {
            tableView.setContentOffset(CGPoint.zero, animated: false)
        }
        
        // Update all UI
        Conductor.sharedInstance.updateAllUI()
    }
    
    func deselectCurrentRow() {
        if let index = sortedPresets.index(where: {$0 === currentPreset}) {
            tableView.deselectRow(at: IndexPath(row: index, section: 0), animated: false)
        }
    }
    
    func upgradePresets() {
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
            self.addNewBank(newBankName:  newBankName, newBankIndex: newBankIndex)
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
                self.reorderButton.backgroundColor = UIColor(red: 230/255, green: 136/255, blue: 2/255, alpha: 1.0)
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
        let presetBank = presets.filter{ $0.bank == currentPreset.bank }.sorted { $0.position < $1.position }
        
        if currentPreset.position < presetBank.count - 1 {
            currentPreset = presetBank[currentPreset.position + 1]
        } else {
            currentPreset = presetBank[0]
        }
        
        selectCurrentPreset()
    }
    
    func prevPreset() {
        let presetBank = presets.filter{ $0.bank == currentPreset.bank }.sorted { $0.position < $1.position }
        
        if currentPreset.position > 0 {
            currentPreset = presetBank[currentPreset.position + -1 ]
            
        } else {
            currentPreset = presetBank.last!
        }
        
        selectCurrentPreset()
    }
    
    // Used for Selecting Presets from Program Change
    func didSelectPreset(index: Int) {
        deselectCurrentRow()
        
        // Get current Bank
        let currentBank = conductor.banks.filter{ $0.position == bankIndex }.first
        let presetsInBank = presets.filter{ $0.bank == currentBank!.name }.sorted { $0.position < $1.position }
        
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
            let popOverController = segue.destination as! PopUpPresetEdit
            popOverController.delegate = self
            popOverController.preset = currentPreset
            popOverController.preferredContentSize = CGSize(width: 550, height: 316)
            if let presentation = popOverController.popoverPresentationController {
                presentation.backgroundColor = #colorLiteral(red: 0.1333333333, green: 0.1333333333, blue: 0.1333333333, alpha: 0)
            }
        }
        
        if segue.identifier == "SegueToBankEdit" {
            let popOverController = segue.destination as! PopUpBankEdit
            popOverController.delegate = self
            let bank = conductor.banks.filter{ $0.position == bankIndex }.first
            popOverController.bankName = bank!.name
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
        self.view.endEditing(true)
    }
    
    @IBAction func doneEditingPressed(_ sender: UIButton) {
        self.view.endEditing(true)
        self.savePreset(currentPreset)
    }
    
}

extension PresetsViewController: UITextViewDelegate {
    func textViewDidEndEditing(_ textView: UITextView) {
        doneEditingButton.isHidden = true
    }
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        doneEditingButton.isHidden = false
    }
}

// *****************************************************************
// MARK: - TableViewDataSource
// *****************************************************************

extension PresetsViewController: UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    @objc(tableView:heightForRowAtIndexPath:) func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 44
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if sortedPresets.isEmpty {
            return 0
        } else {
            return sortedPresets.count
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        // Get current preset
        let preset = sortedPresets[(indexPath as NSIndexPath).row]
        
        if let cell = tableView.dequeueReusableCell(withIdentifier: "PresetCell") as? PresetCell {
            
            cell.delegate = self
            
            // Cell updated in PresetCell.swift
            cell.configureCell(preset: preset)
            
            return cell
            
        } else {
            return PresetCell()
        }
    }
}

//*****************************************************************
// MARK: - TableViewDelegate
//*****************************************************************

extension PresetsViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.view.endEditing(true)
        
        // Get cell
        let cell = tableView.cellForRow(at: indexPath) as? PresetCell
        guard let newPreset = cell?.currentPreset else { return }
        currentPreset = newPreset
    }
    
    // Editing the table view.
    @objc(tableView:commitEditingStyle:forRowAtIndexPath:) func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        
        if editingStyle == .delete {
            
            guard presets.count > 1 else { return }
            
            // Get cell
            let cell = tableView.cellForRow(at: indexPath) as? PresetCell
            guard let presetToDelete = cell?.currentPreset else { return }
            
            // Delete the preset from the data source
            presets = presets.filter{$0.uid != presetToDelete.uid}
            
            // Resave Preset Positions in Bank
            let presetBank = presets.filter{ $0.bank == presetToDelete.bank }.sorted { $0.position < $1.position }
            for (i, preset) in presetBank.enumerated() {
                preset.position = i
            }
            
            // Move to preset above deleted preset
            if indexPath.row > 0 && presetToDelete.position > 0 {
                currentPreset = sortedPresets[indexPath.row - 1]
            }
            
            // Save presets
            saveAllPresetsIn(currentPreset.bank)
        }
    }
    
    @objc(tableView:canFocusRowAtIndexPath:) func tableView(_ tableView: UITableView, canFocusRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    
    // Override to support rearranging the table view.
    @objc(tableView:moveRowAtIndexPath:toIndexPath:) func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to toIndexPath: IndexPath) {
        
        // Get preset
        let presetToMove = sortedPresets[Int(fromIndexPath.row)]
        
        // Update new position in sortedPresets array
        // Rearranging is only allowed in "banks" views, so we can use sortedPresets
        sortedPresets.remove(at: (fromIndexPath as NSIndexPath).row)
        sortedPresets.insert(presetToMove, at: (toIndexPath as NSIndexPath).row)
        
        // Resave positions
        for (i, preset) in sortedPresets.enumerated() {
            preset.position = i
        }
        saveAllPresetsIn(presetToMove.bank)
    }
    
    // Override to support conditional rearranging of the table view.
    @objc(tableView:canMoveRowAtIndexPath:) func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    
}

//*****************************************************************
// MARK: - PresetCell Delegate
//*****************************************************************

extension PresetsViewController: PresetCellDelegate {
    
    func editPressed() {
        self.performSegue(withIdentifier: "SegueToEdit", sender: self)
    }
    
    func duplicatePressed() {
        
        do {
            // Make unique copy of preset
            try Disk.save(currentPreset, to: .caches, as: "tmp/presetcopy.json")
            guard let copy = try? Disk.retrieve("tmp/presetcopy.json", from: .caches, as: Preset.self) else { return }
            
            // Set duplicate preset properties
            copy.name = copy.name + " [copy]"
            copy.uid = UUID().uuidString
            copy.isUser = true
            copy.bank = userBankName // User Bank
            
            // Append preset
            presets.append(copy)
            
            // Resave positions in User Bank
            let userBank = presets.filter{ $0.bank == copy.bank }.sorted { $0.position < $1.position }
            for (i, preset) in userBank.enumerated() {
                preset.position = i
            }
            
            // Save the User Bank
            saveAllPresetsIn(copy.bank)
            
            // Select the new Preset
            currentPreset = copy
            
            // Display the User Bank
            selectCategory(userBankIndex)
            categoryIndex = userBankIndex
            selectCurrentPreset()
            
        } catch {
            AKLog("error duplicating")
        }
    }
    
    func favoritePressed() {
        // Toggle and save preset
        currentPreset.isFavorite = !currentPreset.isFavorite
        saveAllPresetsIn(currentPreset.bank)
        
        // Select current preset
        selectCurrentPreset()
    }
    
    func sharePressed() {
        
        // Save preset to temp directory to be shared
        let presetLocation = "temp/\(currentPreset.name).synth1"
        try? Disk.save(currentPreset, to: .caches, as: presetLocation)
        let path: URL =  try! Disk.getURL(for: presetLocation, in: .caches)
        
        // Share
        let activityViewController = UIActivityViewController(
            activityItems: [path],
            applicationActivities: nil)
        activityViewController.excludedActivityTypes = [
            UIActivityType.copyToPasteboard
        ]
        
        if let popoverPresentationController = activityViewController.popoverPresentationController {
            popoverPresentationController.sourceView = self.view
            popoverPresentationController.sourceRect = CGRect(x: self.view.bounds.midX, y: self.view.bounds.midY, width: 0, height: 0)
            popoverPresentationController.permittedArrowDirections = []
        }
        
        self.present(activityViewController, animated: true, completion: nil)
    }
    
    // To find the files in your machine, search for filename in your ~/Library/Developer/CoreSimulator/Devices/ directories
}

//*****************************************************************
// MARK: - CategoryDelegate
//*****************************************************************

extension PresetsViewController: CategoryDelegate {
    
    func categoryDidChange(_ newCategoryIndex: Int) {
        categoryIndex = newCategoryIndex
    }
    
    func bankShare() {
        // Get Bank to Share
        let bank = conductor.banks.filter{ $0.position == bankIndex }.first
        let bankName = bank!.name
        let bankPresetsToShare = presets.filter { $0.bank == bankName }
        
        // Save bank presets to temp directory to be shared
        let bankLocation = "temp/\(bankName).json"
        try? Disk.save(bankPresetsToShare, to: .caches, as: bankLocation)
        let path: URL =  try! Disk.getURL(for: bankLocation, in: .caches)
        
        // Share
        let activityViewController = UIActivityViewController(
            activityItems: [path],
            applicationActivities: nil)
        activityViewController.excludedActivityTypes = [
            UIActivityType.copyToPasteboard
        ]
        
        if let popoverPresentationController = activityViewController.popoverPresentationController {
            popoverPresentationController.sourceView = self.view
            popoverPresentationController.sourceRect = CGRect(x: self.view.bounds.midX, y: self.view.bounds.midY, width: 0, height: 0)
            popoverPresentationController.permittedArrowDirections = []
        }
        
        self.present(activityViewController, animated: true, completion: nil)
    }
    
    func bankEdit() {
        self.performSegue(withIdentifier: "SegueToBankEdit", sender: self)
    }
}

//*****************************************************************
// MARK: - PopUpPresetEdit
//*****************************************************************

extension PresetsViewController: PresetPopOverDelegate {
    func didFinishEditing(name: String, category: Int, newBank: String) {
        
        // Check for bank change
        if currentPreset.bank != newBank {
            // Check if preset name exists
            if  name == currentPreset.name {
                // remove preset from its previous bank if preset not renamed
                let oldBank = currentPreset.bank
                currentPreset.bank = newBank
                saveAllPresetsIn(oldBank)
                
                let currentBank = conductor.banks.filter{ $0.name == newBank }.first
                selectCategory(PresetCategory.bankStartingIndex + currentBank!.position )
                categoryIndex = PresetCategory.bankStartingIndex + currentBank!.position
            }
        }
       
        // save preset
        presetsDelegate?.saveEditedPreset(name: name, category: category, bank: newBank)
    }
}

//*****************************************************************
// MARK: - PopUpBankEdit
//*****************************************************************

extension PresetsViewController: BankPopOverDelegate {
    
    func didFinishEditing(oldName: String, newName: String) {
        // update presets
        let presetsInBank = presets.filter { $0.bank == oldName}
        presetsInBank.forEach {
            $0.bank = newName
        }
        
        // Update Conductor
        let bank = conductor.banks.filter { $0.name == oldName}.first
        bank?.name = newName
        
        // Update AppSettings
        presetsDelegate?.banksDidUpdate()
        
        // Update Category Table
        updateCategoryTable()
        selectCategory(PresetCategory.bankStartingIndex + bank!.position)
        categoryIndex = PresetCategory.bankStartingIndex + bank!.position
        
        // Save new bank file
        saveAllPresetsIn(newName)
        
        // Delete old bank json file
        try? Disk.remove(oldName + ".json", from: .documents)
    
    }
    
    func didDeleteBank(bankName: String) {
        
        // Remove presets from main list
        presets = presets.filter { $0.bank != bankName}
        
        // Remove from Conductor
        conductor.banks = conductor.banks.filter{ $0.name != bankName }
        
        // Reorder Banks
        for (i, bank) in conductor.banks.enumerated() {
            bank.position = i
        }
        
        // Remove from AppSettings
        presetsDelegate?.banksDidUpdate()
        
        updateCategoryTable()
        selectCategory(PresetCategory.bankStartingIndex)
        categoryIndex = PresetCategory.bankStartingIndex
        selectCurrentPreset()
        
        // Delete bank json file
        try? Disk.remove(bankName + ".json", from: .documents)
        
    }
}


//*****************************************************************
// MARK: - Import / UIDocumentPickerDelegate
//*****************************************************************

extension PresetsViewController: UIDocumentPickerDelegate {
    
    func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentAt url: URL) {
        AKLog("**** url: \(url) ")
        
        let fileName = String(describing: url.lastPathComponent)
        
        // import presets
        do {
            // Parse Data to JSON
            let retrievedPresetData = try Data(contentsOf: url)
            if let presetJSON = try? JSONSerialization.jsonObject(with: retrievedPresetData, options: []) {
                
                // Check if it is a bank or single preset
                if fileName.hasSuffix("json") {
                    // import bank
                    guard let jsonArray = presetJSON as? [Any] else { return }
                    let importBank = Preset.parseDataToPresets(jsonArray: jsonArray)
                    
                    // Update imported presets with bankName
                    var bankName = String(fileName.dropLast(5))
                    
                    // check for duplicate bank name already in system
                    if conductor.banks.contains(where: { $0.name == bankName }) {
                        displayAlertController("Oh my!", message: "There is already a bank with the name '\(bankName)'. Please rename one of them to keep things working smoothly.")
                        bankName += " [rename]"
                    }
                    
                    // Update presets
                    importBank.forEach { preset in
                        preset.uid = UUID().uuidString
                        preset.bank = bankName
                    }
                    
                    // Add new bank to presets
                    presets += importBank
                    
                    // Save to local disk
                    saveAllPresetsIn(bankName)
                    
                    // Save to AppSettings
                    let newBankIndex = conductor.banks.count
                    self.addNewBank(newBankName:  bankName, newBankIndex: newBankIndex)
                    
                } else {
                    let importedPreset = Preset.parseDataToPreset(presetJSON: presetJSON)
                    
                    // Import preset to User Bank
                    let userBank = presets.filter { $0.bank == userBankName }
                    importedPreset.position = userBank.count
                    importedPreset.isFavorite = false
                    importedPreset.isUser = true
                    presets.append(importedPreset)
                    
                    currentPreset = importedPreset
                    currentPreset.bank = userBankName
                    saveAllPresetsIn(currentPreset.bank)
                    
                    // Display the User Bank
                    selectCategory(userBankIndex)
                    categoryIndex = userBankIndex
                    selectCurrentPreset()
                    
                    AKLog("*** preset loaded")
                }
            } else {
                AKLog("*** error parsing presets")
            }
            
        } catch {
            AKLog("*** error loading")
        }
    }
    
}
