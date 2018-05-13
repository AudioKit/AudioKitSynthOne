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
    
    private let aks1Tunings = AKS1Tunings()
    
    override func viewDidLoad() {
        super.viewDidLoad()        
        viewType = .tuningsView
        tuningTableView.dataSource = aks1Tunings
        tuningTableView.delegate = aks1Tunings
        tuningTableView.backgroundColor = #colorLiteral(red: 0.2549019754, green: 0.2745098174, blue: 0.3019607961, alpha: 1)
        aks1Tunings.tuningsDelegate = self
        tuningDidChange()
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

