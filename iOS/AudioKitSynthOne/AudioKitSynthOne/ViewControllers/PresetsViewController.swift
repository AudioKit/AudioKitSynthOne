//
//  ADSRViewController.swift
//  SynthUISpike
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
    func updateDisplay(_ message: String)
    func saveEditedPreset(name: String, category: Int)
}

class PresetsViewController: UIViewController {
    
    @IBOutlet weak var newButton: SynthUIButton!
    @IBOutlet weak var importButton: SynthUIButton!
    @IBOutlet weak var reorderButton: SynthUIButton!
    @IBOutlet weak var resetButton: PresetUIButton!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var categoryEmbeddedView: UIView!
    @IBOutlet weak var presetDescriptionField: UITextView!
    @IBOutlet weak var categoryLabel: UILabel!
    
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
            
            print ("preset: \(currentPreset.name)")
        }
    }
    
    var tempPreset = Preset()
    
    var categoryIndex: Int = 0 {
        didSet {
            sortPresets()
        }
    }
    
    var randomNumbers: GKRandomDistribution!
    
    var presetsDelegate: PresetsDelegate?
    
    // *****************************************************************
    // MARK: - Lifecycle
    // *****************************************************************
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Preset Description TextField
        presetDescriptionField.delegate = self
        //presetDescriptionField.layer.borderWidth = 2
        // presetDescriptionField.layer.borderColor = #colorLiteral(red: 0.1333333333, green: 0.1333333333, blue: 0.1333333333, alpha: 1)
        presetDescriptionField.layer.cornerRadius = 4
        
        // set color for lines between rows
        tableView.separatorColor = #colorLiteral(red: 0.368627451, green: 0.368627451, blue: 0.3882352941, alpha: 1)
        
        // Load presets
        if Disk.exists("presets.json", in: .documents) {
            loadPresetsFromDevice()
            saveAllPresets()
          
        } else {
            loadDefaultPresets()
            saveAllPresets()
        }
        
        // Set Initial Cateogry & Preset
        resetCategoryToAll()
        
        // Setup button callbacks
        setupCallbacks()
        
      
      
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        try? Disk.remove("temp", from: .caches)
    }
    
    // *****************************************************************
    // MARK: - Load/Save/Manipulate Presets
    // *****************************************************************
    
    func sortPresets() {
        switch categoryIndex {
        
        // all presets, sort by preset #
        case 0:
            sortedPresets = presets.sorted { $0.position < $1.position }
        
        // Sort by Categories
        case 1...PresetCategory.numCategories:
            sortedPresets = presets.filter { $0.category == categoryIndex }
            
        // Sort by Favorites
        case PresetCategory.numCategories + 1:
            sortedPresets = presets.filter { $0.isFavorite }
        
        // Sorty by User created/modified presets
        case PresetCategory.numCategories + 2:
            sortedPresets = presets.filter { $0.isUser }
            
        default:
            sortedPresets = presets.sorted { $0.position < $1.position }
        }
    }
    
    func randomizePresets() {
        // Generate random presets 🎲
        randomNumbers = GKShuffledDistribution(lowestValue: 0, highestValue: presets.count-1)
    }
    
    func loadPresetsFromDevice() {
        do {
            // debug logging
            // "save" goes to this file.  You can copy this file back to the app bundle as defaults.
            //AKLog(NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true).last ?? "nil");
            ///Users/marcushobbs/Library/Developer/CoreSimulator/Devices/870E7755-75B7-4037-9B08-4C8A066057CD/data/Containers/Data/Application/5901161D-1A6E-407B-8137-5CF4B4864091/Documents/presets.json
            
            let retrievedPresetData = try Disk.retrieve("presets.json", from: .documents, as: Data.self)
            parsePresetsFromData(data: retrievedPresetData)
        } catch {
            AKLog("*** error loading")
        }
    }
    
    func loadDefaultPresets() {
        if let filePath = Bundle.main.path(forResource: "presets1", ofType:"json") {
            let data = try? NSData(contentsOfFile: filePath, options: NSData.ReadingOptions.uncached) as Data
            parsePresetsFromData(data: data!)
        }
    }
    
    
    func parsePresetsFromData(data: Data) {
        let presetsJSON = try? JSONSerialization.jsonObject(with: data, options: [])
        guard let jsonArray = presetsJSON as? [Any] else { return }
        
        presets = Preset.parseDataToPresets(jsonArray: jsonArray)
        sortPresets()
    }
    
    func saveAllPresets() {
        do {
            try Disk.save(presets, to: .documents, as: "presets.json")
            sortPresets()
        } catch {
            AKLog("error saving")
        }
    }
    
    func savePreset(_ activePreset: Preset) {
        // Save preset
        presets.remove(at: currentPreset.position)
        presets.insert(activePreset, at: activePreset.position)
        currentPreset = activePreset
        saveAllPresets()
        
        // Create new active preset
        createActivePreset()
    }
    
    func resetCategoryToAll() {
        guard let categoriesVC = self.childViewControllers.first as? PresetsCategoriesController else { return }
        categoriesVC.categoryTableView.selectRow(at: IndexPath(row: 0, section: 0), animated: false, scrollPosition: .top)
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
        // No preset is selected, select first one
        guard presets.index(where: {$0 === currentPreset}) != nil else {
            // currentPreset = presets[0]
            tableView.selectRow(at: IndexPath(row: 0, section: 0), animated: true, scrollPosition: .top)
            return
        }
        
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
    
    // *****************************************************************
    // MARK: - IBActions / Callbacks
    // *****************************************************************
    
    func setupCallbacks() {
        newButton.callback = { _ in
            let initPreset = Preset(position: self.presets.count)
            self.presets.append(initPreset)
            self.currentPreset = initPreset
            self.saveAllPresets()
        }
        
        importButton.callback = { _ in
            let documentPicker = UIDocumentPickerViewController(documentTypes: [(kUTTypeText as String)], in: .import)
            documentPicker.delegate = self
            self.present(documentPicker, animated: true, completion: nil)
        }
        
        reorderButton.callback = { _ in
            self.tableView.isEditing = !self.tableView.isEditing
            
            // Set Categories table to "all"
            self.resetCategoryToAll()
            
            if self.tableView.isEditing {
                self.reorderButton.setTitle("I'M DONE!", for: UIControlState())
                self.reorderButton.setTitleColor(#colorLiteral(red: 0, green: 0, blue: 0, alpha: 1), for: .normal)
                self.reorderButton.backgroundColor = UIColor(red: 230/255, green: 136/255, blue: 2/255, alpha: 1.0)
                self.categoryIndex = 0
                self.categoryEmbeddedView.isUserInteractionEnabled = false
                
            } else {
                self.reorderButton.setTitle("Reorder", for: UIControlState())
                self.reorderButton.setTitleColor(#colorLiteral(red: 0.7333333333, green: 0.7333333333, blue: 0.7333333333, alpha: 1), for: .normal)
                self.reorderButton.backgroundColor = #colorLiteral(red: 0.2745098039, green: 0.2745098039, blue: 0.2941176471, alpha: 1)
                self.categoryEmbeddedView.isUserInteractionEnabled = true
                self.selectCurrentPreset()
            }
        }
        
        resetButton.callback = { _ in
            // prompt user if they want to do it, suggest they export user presets first
            // reset to factory defaults
            self.loadDefaultPresets()
            self.saveAllPresets()
        }
    }
    
    func nextPreset() {
        if currentPreset.position < presets.count - 1 {
            deselectCurrentRow()
            currentPreset = presets[currentPreset.position + 1]
            selectCurrentPreset()
        }
    }
    
    func prevPreset() {
        if currentPreset.position > 0 {
            deselectCurrentRow()
            currentPreset = presets[currentPreset.position + -1 ]
            selectCurrentPreset()
         
        }
    }
    
    // Used for Selecting Presets from Program Change
    func didSelectPreset(index: Int) {
        deselectCurrentRow()
        
        // Smoothly cycle through presets if MIDI input is greater than preset count
        let currentPresetIndex = Int(index) % (presets.count-1)
        
        currentPreset = presets[currentPresetIndex]
        selectCurrentPreset()
    }
    
    func randomPreset() {
        deselectCurrentRow()
        
        // Pick random Preset
        var newIndex = randomNumbers.nextInt()
        if newIndex == currentPreset.position { newIndex = randomNumbers.nextInt() }
        currentPreset = presets[newIndex]
        selectCurrentPreset()
     
    }
    
    // *****************************************************************
    // MARK: - Segue
    // *****************************************************************
    
    override public func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "SegueToEdit" {
            let popOverController = segue.destination as! PopUpPresetEdit
            popOverController.delegate = self
            popOverController.preset = currentPreset
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
}

extension PresetsViewController: UITextViewDelegate {
    func textViewDidEndEditing(_ textView: UITextView) {
        currentPreset.userText = presetDescriptionField.text
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
            
            // Delete the row from the data source
            presets.remove(at: presetToDelete.position)
            
            // Resave positions
            for (i, preset) in presets.enumerated() {
                preset.position = i
            }
            
            // Move to preset above deleted preset
            if indexPath.row > 0 && presetToDelete.position > 0 {
                 currentPreset = sortedPresets[indexPath.row - 1]
            }
            
            // Save presets
            saveAllPresets()
        }
    }
    
    @objc(tableView:canFocusRowAtIndexPath:) func tableView(_ tableView: UITableView, canFocusRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    
    // Override to support rearranging the table view.
    @objc(tableView:moveRowAtIndexPath:toIndexPath:) func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to toIndexPath: IndexPath) {
        
        // Update new position in presets array
        let itemToMove = presets[(fromIndexPath as NSIndexPath).row]
        presets.remove(at: (fromIndexPath as NSIndexPath).row)
        presets.insert(itemToMove, at: (toIndexPath as NSIndexPath).row)
        
        // Resave positions
        for (i, preset) in presets.enumerated() {
            preset.position = i
        }
        saveAllPresets()
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
    
    func presetDidChange(preset: Preset) {
        // currentPreset = preset
    }
    
    func duplicatePressed() {
        
        do {
            try Disk.save(currentPreset, to: .caches, as: "tmp/presetcopy.json")
            guard let copy = try? Disk.retrieve("tmp/presetcopy.json", from: .caches, as: Preset.self) else { return }
            
            copy.name = copy.name + " [copy]"
            copy.isUser = true
            presets.insert(copy, at: copy.position + 1)
            
            // Resave positions
            for (i, preset) in presets.enumerated() {
                preset.position = i
            }
            saveAllPresets()
            
        } catch {
            AKLog("error duplicating")
        }
    }
    
    func favoritePressed() {
        // Toggle and save preset
        currentPreset.isFavorite = !currentPreset.isFavorite
        saveAllPresets()
        
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
    
    func userPresetsShare() {
        
        let userPresets = presets.filter { $0.isUser }
        
        // Save preset to temp directory to be shared
        let presetLocation = "temp/userpresets.bank"
        try? Disk.save(userPresets, to: .caches, as: presetLocation)
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
}

//*****************************************************************
// MARK: - PopUpPresetEdit
//*****************************************************************

extension PresetsViewController: PresetPopOverDelegate {
    func didFinishEditing(name: String, category: Int) {
        // save preset
        presetsDelegate?.saveEditedPreset(name: name, category: category)
    }
}

extension PresetsViewController: UIDocumentPickerDelegate {
    
    func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentAt url: URL) {
        AKLog("****")
        AKLog("\(url)")
        do {
            let retrievedPresetData = try Data(contentsOf: url)
            
            if let presetJSON = try? JSONSerialization.jsonObject(with: retrievedPresetData, options: []) {
                let importedPreset = Preset.parseDataToPreset(presetJSON: presetJSON)
                importedPreset.position = presets.count
                importedPreset.isFavorite = false
                presets.append(importedPreset)
                currentPreset = importedPreset
                saveAllPresets()
                AKLog("*** preset loaded")
            } else {
                AKLog("*** error parsing preset")
            }
            
        } catch {
            AKLog("*** error loading")
        }
    }
}
