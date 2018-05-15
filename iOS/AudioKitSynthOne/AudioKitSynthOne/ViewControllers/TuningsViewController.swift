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
    
    private let aks1Tunings = AKS1Tunings()
    
    override func viewDidLoad() {
        super.viewDidLoad()        
        viewType = .tuningsView
        tuningTableView.dataSource = aks1Tunings
        tuningTableView.delegate = aks1Tunings
        tuningTableView.backgroundColor = UIColor.clear
        tuningTableView.isOpaque = false
        aks1Tunings.tuningsDelegate = self
        tuningDidChange()
        masterTuning.range = Conductor.sharedInstance.synth!.getParameterRange(.frequencyA4)
        Conductor.sharedInstance.bind(masterTuning, to: .frequencyA4)
    }
    
    public override func viewDidAppear(_ animated: Bool) {
        tuningDidChange()
    }
    
    func dependentParamDidChange(_ param: DependentParam) {
        switch param.param {
        default:
            _ = 0
        }
    }

    func playingNotesDidChange(_ playingNotes: PlayingNotes) {
        tuningsPitchWheelView.playingNotesDidChange(playingNotes)
    }
}

