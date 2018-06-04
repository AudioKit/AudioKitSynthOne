//
//  TuningsViewController.swift
//  AudioKitSynthOne
//
//  Created by AudioKit Contributors on 5/6/18.
//  Copyright © 2018 AudioKit. All rights reserved.
//

import UIKit

public protocol TuningsPitchWheelViewTuningDidChange {
    func tuningDidChange()
}

class TuningsViewController: PanelViewController {

    @IBOutlet weak var tuningTableView: UITableView!
    @IBOutlet weak var tuningsPitchWheelView: TuningsPitchWheelView!
    @IBOutlet weak var masterTuning: MIDIKnob!
    @IBOutlet weak var resetTunings: SynthUIButton!
    @IBOutlet weak var diceButton: UIButton!

    let tuningModel = S1Tunings()
    var getStoreTuningWithPresetValue = false
    internal var tuningIndex = 0

    override func viewDidLoad() {
        super.viewDidLoad()

        guard let synth = Conductor.sharedInstance.synth else { return }
        viewType = .tuningsView
        tuningModel.loadTunings()
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

        selectRow(0)
        tuningDidChange()
    }

    public override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }

    func dependentParameterDidChange(_ parameter: DependentParameter) {}

    func playingNotesDidChange(_ playingNotes: PlayingNotes) {
        tuningsPitchWheelView.playingNotesDidChange(playingNotes)
    }

    @IBAction func randomPressed(_ sender: UIButton) {
        tuningIndex = tuningModel.randomTuning()
        selectRow(tuningIndex)
        tuningDidChange()
        UIView.animate(withDuration: 0.4, animations: {
            for _ in 0 ... 1 {
                self.diceButton.transform = self.diceButton.transform.rotated(by: CGFloat(Double.pi))
            }
        })
    }

    internal func selectRow(_ index: Int) {
        tuningIndex = index
        let path = IndexPath(row: index, section: 0)
        tuningTableView.selectRow(at: path, animated: true, scrollPosition: .middle)
        tableView(tuningTableView, didSelectRowAt: path)
    }

    public func setTuning(name: String?, masterArray master: [Double]?) {
        let i = tuningModel.setTuning(name: name, masterArray: master)

        if i.1 {
            tuningTableView.reloadData()
        }
        if let row = i.0 {
            selectRow(row)
        }
    }

    public func setDefaultTuning() {
        tuningIndex = tuningModel.resetTuning()
        selectRow(tuningIndex)
    }

    public func getTuning() -> (String, [Double]) {
        let t = tuningModel.getTuning(index: tuningIndex)
        return t
    }
}

//*****************************************************************
// MARK: - TuningsPitchWheelViewTuningDidChange
//*****************************************************************

extension TuningsViewController: TuningsPitchWheelViewTuningDidChange {
    func tuningDidChange() {
        tuningsPitchWheelView.updateFromGlobalTuningTable()
    }
}
