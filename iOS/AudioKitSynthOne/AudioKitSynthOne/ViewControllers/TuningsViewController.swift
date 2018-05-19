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
    
    private let aks1Tunings = AKS1Tunings()
    
    override func viewDidLoad() {
        super.viewDidLoad()        
        viewType = .tuningsView
        
        tuningTableView.backgroundColor = UIColor.clear
        tuningTableView.isOpaque = false
        tuningTableView.dataSource = aks1Tunings
        tuningTableView.delegate = aks1Tunings
        aks1Tunings.tuningsDelegate = self
        
        tuningDidChange()

        masterTuning.range = Conductor.sharedInstance.synth!.getParameterRange(.frequencyA4)
        masterTuning.value = Conductor.sharedInstance.synth!.getAK1Parameter(.frequencyA4)
        Conductor.sharedInstance.bind(masterTuning, to: .frequencyA4)
        
        resetTunings.callback = { value in
            if value == 1 {
                self.aks1Tunings.resetTuning()
                self.masterTuning.value = Conductor.sharedInstance.synth!.getAK1Parameter(.frequencyA4)
                self.deselectRow()
                self.resetTunings.value = 0
            }
        }
    }
    
    public override func viewDidAppear(_ animated: Bool) {
        tuningDidChange()
    }
    
    func dependentParamDidChange(_ param: DependentParam) {
        //NOP for Tunings panel
    }

    func playingNotesDidChange(_ playingNotes: PlayingNotes) {
        tuningsPitchWheelView.playingNotesDidChange(playingNotes)
    }
    
    @IBAction func randomPressed(_ sender: UIButton) {
        let index = aks1Tunings.randomTuning()
        selectRow(index)
        UIView.animate(withDuration: 0.4, animations: {
            for _ in 0 ... 1 {
                self.diceButton.transform = self.diceButton.transform.rotated(by: CGFloat(Double.pi))
            }
        })
    }
    
    internal func deselectRow() {
        if let index = tuningTableView.indexPathForSelectedRow{
            tuningTableView.deselectRow(at: index, animated: true)
        }
        
    
    }
    
    internal func selectRow(_ index: Int) {
        let path = IndexPath(row: index, section: 0)
        tuningTableView.selectRow(at: path, animated: true, scrollPosition: .middle)
    }
}

