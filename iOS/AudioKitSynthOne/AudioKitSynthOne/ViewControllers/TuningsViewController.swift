//
//  TuningsViewController.swift
//  AudioKitSynthOne
//
//  Created by Marcus W. Hobbs on 5/6/18.
//  Copyright © 2018 AudioKit. All rights reserved.
//

import UIKit

protocol TuningPanelDelegate {
    func storeTuningWithPresetDidChange(_ value: Bool)
    func getStoreTuningWithPresetValue() -> Bool
}

public protocol TuningsPitchWheelViewTuningDidChange {
    func tuningDidChange()
}

extension TuningsViewController: TuningsPitchWheelViewTuningDidChange {
    func tuningDidChange() {
        tuningsPitchWheelView.updateFromGlobalTuningTable()
    }
}

class TuningsViewController: SynthPanelController {
    
    @IBOutlet weak var tuningTableView: UITableView!
    @IBOutlet weak var tuningsPitchWheelView: TuningsPitchWheelView!
    @IBOutlet weak var masterTuning: MIDIKnob!
    @IBOutlet weak var resetTunings: SynthUIButton!
    @IBOutlet weak var diceButton: UIButton!
    @IBOutlet weak var saveTuningWithPreset: ToggleButton!
    
    var delegate: TuningPanelDelegate?
    private let aks1Tunings = AKS1Tunings()
    
    override func viewDidLoad() {
        super.viewDidLoad()        
        viewType = .tuningsView
        tuningTableView.backgroundColor = UIColor.clear
        tuningTableView.isOpaque = false
        tuningTableView.allowsSelection = true
        tuningTableView.allowsMultipleSelection = false
        tuningTableView.dataSource = aks1Tunings
        tuningTableView.delegate = aks1Tunings
        aks1Tunings.tuningsDelegate = self
        
        masterTuning.range = Conductor.sharedInstance.synth!.getParameterRange(.frequencyA4)
        masterTuning.value = Conductor.sharedInstance.synth!.getAK1Parameter(.frequencyA4)
        Conductor.sharedInstance.bind(masterTuning, to: .frequencyA4)
        
        resetTunings.callback = { value in
            if value == 1 {
                let i = self.aks1Tunings.resetTuning()
                self.masterTuning.value = Conductor.sharedInstance.synth!.getAK1Parameter(.frequencyA4)
                self.selectRow(i)
                self.resetTunings.value = 0
            }
        }
        
        if let v = delegate?.getStoreTuningWithPresetValue() {
            saveTuningWithPreset.value = v ? 1 : 0
        }
        
        saveTuningWithPreset.callback = { value in
            self.delegate?.storeTuningWithPresetDidChange(value == 1 ? true : false)
        }
        
        tuningDidChange()
    }
    
    public override func viewDidAppear(_ animated: Bool) {
        tuningDidChange()
    }
    
    func dependentParamDidChange(_ param: DependentParam) {
    }

    func playingNotesDidChange(_ playingNotes: PlayingNotes) {
        tuningsPitchWheelView.playingNotesDidChange(playingNotes)
    }
    
    @IBAction func randomPressed(_ sender: UIButton) {
        let i = aks1Tunings.randomTuning()
        selectRow(i)
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
    
    public func setTuning(withMasterArray master:[Double]) {
        if let i = aks1Tunings.setTuning(withMasterArray: master) {
            selectRow(i)
        }
    }
    
    public func setDefaultTuning() {
        let i = aks1Tunings.resetTuning()
        selectRow(i)
    }
    
    public func getTuning() -> [Double]? {
        return tuningsPitchWheelView.masterFrequency
    }
}

