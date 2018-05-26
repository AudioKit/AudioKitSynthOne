//
//  TuningsViewController.swift
//  AudioKitSynthOne
//
//  Created by Marcus W. Hobbs on 5/6/18.
//  Copyright © 2018 AudioKit. All rights reserved.
//

import UIKit

public protocol TuningsPitchWheelViewTuningDidChange {
    func tuningDidChange()
}

class TuningsViewController: SynthPanelController {
    
    @IBOutlet weak var tuningTableView: UITableView!
    @IBOutlet weak var tuningsPitchWheelView: TuningsPitchWheelView!
    @IBOutlet weak var masterTuning: MIDIKnob!
    @IBOutlet weak var resetTunings: SynthUIButton!
    @IBOutlet weak var diceButton: UIButton!
    
    let tuningModel = AKS1Tunings()
    var getStoreTuningWithPresetValue = false
    
    override func viewDidLoad() {
        super.viewDidLoad()

        guard let synth = Conductor.sharedInstance.synth else { return }
        viewType = .tuningsView
        tuningTableView.backgroundColor = UIColor.clear
        tuningTableView.isOpaque = false
        tuningTableView.allowsSelection = true
        tuningTableView.allowsMultipleSelection = false
        tuningTableView.dataSource = self
        tuningTableView.delegate = self
        tuningModel.tuningsDelegate = self

        masterTuning.range = synth.getRange(.frequencyA4)
        masterTuning.value = synth.getSynthParameter(.frequencyA4)
        Conductor.sharedInstance.bind(masterTuning, to: .frequencyA4)
        
        resetTunings.callback = { value in
            if value == 1 {
                let i = self.tuningModel.resetTuning()
                self.masterTuning.value = synth.getSynthParameter(.frequencyA4)
                self.selectRow(i)
                self.resetTunings.value = 0
            }
        }
        
        tuningDidChange()
    }
    
    public override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        tuningDidChange()
    }
    
    func dependentParamDidChange(_ param: DependentParam) {
    }

    func playingNotesDidChange(_ playingNotes: PlayingNotes) {
        tuningsPitchWheelView.playingNotesDidChange(playingNotes)
    }
    
    @IBAction func randomPressed(_ sender: UIButton) {
        let i = tuningModel.randomTuning()
        selectRow(i)
        tuningDidChange()
        UIView.animate(withDuration: 0.4, animations: {
            for _ in 0 ... 1 {
                self.diceButton.transform = self.diceButton.transform.rotated(by: CGFloat(Double.pi))
            }
        })
    }
    
    internal func selectRow(_ index: Int) {
        let path = IndexPath(row: index, section: 0)
        tuningTableView.selectRow(at: path, animated: true, scrollPosition: .middle)
    }
    
    //TODO: determine encoding, match with local tuning list, add if not there, select row
    public func setTuning(withMasterArray master:[Double]) {
        if let i = tuningModel.setTuning(withMasterArray: master) {
            selectRow(i)
        }
    }
    
    public func setDefaultTuning() {
        let i = tuningModel.resetTuning()
        selectRow(i)
    }
    
    public func getTuning() -> [Double]? {
        return tuningsPitchWheelView.masterFrequency
    }
    
}


// *****************************************************************
// MARK: - TableViewDataSource
// *****************************************************************
extension TuningsViewController: UITableViewDataSource {
    
    public func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    @objc(tableView:heightForRowAtIndexPath:) public func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 44
    }
    
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tuningModel.tunings.count
    }
    
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        tableView.separatorColor = #colorLiteral(red: 0.368627451, green: 0.368627451, blue: 0.3882352941, alpha: 1)
        let tuning = tuningModel.tunings[(indexPath as NSIndexPath).row]
        let title = tuning.0
        if let cell = tableView.dequeueReusableCell(withIdentifier: "TuningsViewController") as UITableViewCell? {
            configureCell(cell)
            cell.textLabel?.text = title
            return cell
        } else {
            let cell = UITableViewCell()
            configureCell(cell)
            cell.textLabel?.text = title
            return cell
        }
    }
    
    private func configureCell(_ cell: UITableViewCell) {
        cell.isOpaque = false
        cell.backgroundColor = UIColor.clear
        cell.textLabel?.textColor = #colorLiteral(red: 0.694699347, green: 0.6895567775, blue: 0.6986362338, alpha: 1)
    }
}

//        func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
//
//            // Get current preset
//            let preset = sortedPresets[(indexPath as NSIndexPath).row]
//
//            if let cell = tableView.dequeueReusableCell(withIdentifier: "PresetCell") as? PresetCell {
//
//                cell.delegate = self
//
//                // Cell updated in PresetCell.swift
//                cell.configureCell(preset: preset)
//
//                return cell
//
//            } else {
//                return PresetCell()
//            }
//        }
//}

//*****************************************************************
// MARK: - TableViewDelegate
//*****************************************************************

extension TuningsViewController: UITableViewDelegate {
    
    public func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if cell.isSelected {
            cell.contentView.backgroundColor = #colorLiteral(red: 0.2, green: 0.2, blue: 0.2, alpha: 1)
        }
    }
    
    public func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let tuning = tuningModel.tunings[(indexPath as NSIndexPath).row]
        tuning.1()
        
        if let selectedCell = tableView.cellForRow(at: indexPath) {
            selectedCell.contentView.backgroundColor = #colorLiteral(red: 0.2, green: 0.2, blue: 0.2, alpha: 1)
        }
        tuningDidChange()
    }
    
    //        func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    //            self.view.endEditing(true)
    //
    //            // Get cell
    //            let cell = tableView.cellForRow(at: indexPath) as? PresetCell
    //            guard let newPreset = cell?.currentPreset else { return }
    //            currentPreset = newPreset
    //        }
}

//*****************************************************************
// MARK: - TuningsPitchWheelViewTuningDidChange
//*****************************************************************

extension TuningsViewController: TuningsPitchWheelViewTuningDidChange {
    func tuningDidChange() {
        tuningsPitchWheelView.updateFromGlobalTuningTable()
    }
}

