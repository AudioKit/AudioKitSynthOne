//
//  ADSRViewController.swift
//  SynthUISpike
//
//  Created by Matthew Fecher on 7/24/17.
//  Copyright © 2017 Matthew Fecher. All rights reserved.
//

import UIKit
import MobileCoreServices
import Disk
import CloudKit

protocol PresetsDelegate {
    func presetDidChange(_ position: Int)
    func updateDisplay(_ message: String)
}

class PresetsViewController: UIViewController {
    
    @IBOutlet weak var newButton: UIButton!
    @IBOutlet weak var importButton: UIButton!
    @IBOutlet weak var reorderButton: UIButton!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var categoryEmbeddedView: UIView!
    
    var presets = [Preset]()
    
    var sortedPresets = [Preset]() {
        didSet {
            tableView.reloadData()
            selectCurrentPreset()
        }
    }
    
    var currentPreset = Preset()
    
    var categoryIndex: Int = 0 {
        didSet {
            sortPresets()
        }
    }
    
    var presetsDelegate: PresetsDelegate?
    
    // *****************************************************************
    // MARK: - Lifecycle
    // *****************************************************************
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // set color for lines between rows
        tableView.separatorColor = #colorLiteral(red: 0.368627451, green: 0.368627451, blue: 0.3882352941, alpha: 1)
        
        // Load presets
        if Disk.exists("presets.json", in: .documents) {
            loadPresetsFromDevice()
        } else {
            loadDefaultPresets()
            saveAllPresets()
        }
        
        // Set Cateogry to all presets
        resetCategoryToAll()
        // presets.forEach { $0.isUser = false }
        
        // Make buttons pretty
        // newButton.layer.borderWidth = 1
        //newButton.layer.cornerRadius = 6
        //importButton.layer.borderWidth = 1
        //importButton.layer.cornerRadius = 6
        //reorderButton.layer.borderWidth = 1
        //reorderButton.layer.cornerRadius = 6
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        try? Disk.remove("temp", from: .caches)
    }
    
    // *****************************************************************
    // MARK: - Load/Save/Manipulate Presets
    // *****************************************************************
    
    func sortPresets() {
        switch categoryIndex {
        case 0:
            // all presets
            sortedPresets = presets.sorted { $0.position < $1.position }
            
        case 1...PresetCategory.numCategories:
            // Sort by category
            sortedPresets = presets.filter { $0.category == categoryIndex }
            
        case PresetCategory.numCategories + 1:
            // Favorites
            sortedPresets = presets.filter { $0.isFavorite }
            
        case PresetCategory.numCategories + 2:
            // User created/modified presets
            sortedPresets = presets.filter { $0.isUser }
            
        default:
            sortedPresets = presets.sorted { $0.position < $1.position }
        }
    }
    
    func loadPresetsFromDevice() {
        do {
            let retrievedPresetData = try Disk.retrieve("presets.json", from: .documents, as: Data.self)
            parsePresetsFromData(data: retrievedPresetData)
        } catch {
            print("*** error loading")
        }
    }
    
    func loadDefaultPresets() {
        if let filePath = Bundle.main.path(forResource: "presets1", ofType:"json") {
            let data = try? NSData(contentsOfFile:filePath, options: NSData.ReadingOptions.uncached) as Data
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
            print("error saving")
        }
    }
    
    func resetCategoryToAll() {
        guard let categoriesVC = self.childViewControllers.first as? PresetsCategoriesController else { return }
        categoriesVC.categoryTableView.selectRow(at: IndexPath(row: 0, section: 0), animated: false, scrollPosition: .top)
    }
    
    func selectCurrentPreset() {
        
        // No preset is selected
        guard presets.index(where: {$0 === currentPreset}) != nil else {
            currentPreset = presets[0]
            tableView.selectRow(at: IndexPath(row: 0, section: 0), animated: true, scrollPosition: .top)
            return
        }
        
        // Find the preset in the current view
        if let index = sortedPresets.index(where: {$0 === currentPreset}) {
            tableView.selectRow(at: IndexPath(row: index, section: 0), animated: true, scrollPosition: .middle)
        } else {
            tableView.setContentOffset(CGPoint.zero, animated: false)
        }
    }
    
    // *****************************************************************
    // MARK: - IBActions
    // *****************************************************************
    
    @IBAction func savePreset(_ sender: UIButton) {
        
        // save preset
        let preset = presets[0]
        do {
            try Disk.save(preset, to: .documents, as: "Factory/mypreset.json")
        } catch {
            print("error saving")
        }
        
    }
    
    @IBAction func newPresetPressed(_ sender: UIButton) {
        let initPreset = Preset(position: presets.count)
        presets.append(initPreset)
        currentPreset = initPreset
        saveAllPresets()
    }
    
    @IBAction func importPresetPressed(_ sender: UIButton) {
        let documentPicker = UIDocumentPickerViewController(documentTypes: [(kUTTypeText as String)], in: .import)
        documentPicker.delegate = self
        present(documentPicker, animated: true, completion: nil)
    }
    
    
    @IBAction func reorderPressed(_ sender: UIButton) {
        tableView.isEditing = !tableView.isEditing
        
        // Set Categories table to "all"
        resetCategoryToAll()
        
        if tableView.isEditing {
            sender.setTitle("I'M DONE!", for: UIControlState())
            sender.backgroundColor = UIColor(red: 230/255, green: 136/255, blue: 2/255, alpha: 1.0)
            categoryIndex = 0
            categoryEmbeddedView.isUserInteractionEnabled = false
            
        } else {
            sender.setTitle("Reorder Presets", for: UIControlState())
            sender.backgroundColor = #colorLiteral(red: 0.2431372549, green: 0.2431372549, blue: 0.262745098, alpha: 1)
            categoryEmbeddedView.isUserInteractionEnabled = true
            selectCurrentPreset()
        }
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
        
        // Update Cell
        let newPresetPosition = (indexPath as NSIndexPath).row
        
        // Update preset
        presetsDelegate?.presetDidChange(newPresetPosition)
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
            
            /*
             presetsDelegate?.presetDidChange(0)
             presetsDelegate?.updateDisplay("Preset deleted!")
             */
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
        
        /*
         presetsDelegate?.presetDidChange(0)
         presetsDelegate?.updateDisplay("Presets reordered!")
         */
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
        currentPreset = preset
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
            print("error duplicating")
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
    
}

//*****************************************************************
// MARK: - PopUpPresetEdit
//*****************************************************************

extension PresetsViewController: PresetPopOverDelegate {
    func didFinishEditing(name: String, category: Int) {
        // save preset
        currentPreset.name = name
        currentPreset.category = category
        currentPreset.isUser = true
        saveAllPresets()
    }
}

extension PresetsViewController: UIDocumentPickerDelegate {
    
    func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentAt url: URL) {
        print("****")
        print(url)
        do {
            let retrievedPresetData = try Data(contentsOf: url)
            
            if let presetJSON = try? JSONSerialization.jsonObject(with: retrievedPresetData, options: []) {
                let importedPreset = Preset.parseDataToPreset(presetJSON: presetJSON)
                importedPreset.position = presets.count
                importedPreset.isFavorite = false
                presets.append(importedPreset)
                currentPreset = importedPreset
                saveAllPresets()
                print("*** preset loaded")
            } else {
                print("*** error parsing preset")
            }
            
        } catch {
            print("*** error loading")
        }
    }
}


