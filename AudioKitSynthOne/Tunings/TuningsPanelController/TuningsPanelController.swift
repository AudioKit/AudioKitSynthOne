//
//  TuningsPanelController.swift
//  AudioKitSynthOne
//
//  Created by AudioKit Contributors on 5/6/18.
//  Copyright © 2018 AudioKit. All rights reserved.
//

import UIKit

public protocol TuningsPitchWheelViewTuningDidChange {
    func tuningDidChange()
}

/// View controller for the Tunings Panel
///
/// Erv Wilson is the man [website](http://anaphoria.com/wilson.html)
class TuningsPanelController: PanelController {

    @IBOutlet weak var tuningTableView: UITableView!
    @IBOutlet weak var tuningsPitchWheelView: TuningsPitchWheelView!
    @IBOutlet weak var masterTuningKnob: MIDIKnob!
    @IBOutlet weak var resetTuningsButton: SynthButton!
    @IBOutlet weak var d1LaunchButton: SynthButton!
    @IBOutlet weak var diceButton: UIButton!

    let tuningModel = Tunings()
    var getStoreTuningWithPresetValue = false
    internal var tuningIndex = 0

    override func viewDidLoad() {
        super.viewDidLoad()

        guard let synth = Conductor.sharedInstance.synth else { return }
        currentPanel = .tunings
        tuningTableView.backgroundColor = UIColor.clear
        tuningTableView.isOpaque = false
        tuningTableView.allowsSelection = true
        tuningTableView.allowsMultipleSelection = false
        tuningTableView.dataSource = self
        tuningTableView.delegate = self
        tuningModel.tuningsDelegate = self

        masterTuningKnob.range = synth.getRange(.frequencyA4)
        masterTuningKnob.value = synth.getSynthParameter(.frequencyA4)
        Conductor.sharedInstance.bind(masterTuningKnob, to: .frequencyA4)

        resetTuningsButton.callback = { value in
            if value == 1 {
                let i = self.tuningModel.resetTuning()
                self.masterTuningKnob.value = synth.getSynthParameter(.frequencyA4)
                self.selectRow(i)
                self.resetTuningsButton.value = 0
            }
        }

        d1LaunchButton.callback = { value in
            self.launchD1()
            self.d1LaunchButton.value = 0
        }

        // callback called on main thread
        tuningModel.loadTunings {
            self.tuningTableView.reloadData()
            self.selectRow(0)
            self.tuningDidChange()
        }

		tuningTableView.accessibilityLabel = "Tunings Table"

		view.accessibilityElements = [
			tuningTableView,
			masterTuningKnob,
			diceButton,
			resetTuningsButton,
			leftNavButton,
			rightNavButton
		]

    }

    func launchD1() {
        let host = "digitald1://tune?"
        let masterSet = AKPolyphonicNode.tuningTable.masterSet
        let npo = masterSet.count
        let tuningName = tuningTableView.cellForRow(at: tuningTableView.indexPathForSelectedRow!)?.textLabel?.text ?? "None"
        var urlStr = "\(host)tuningName=\(tuningName)&npo=\(npo)"
        for f in masterSet {
            urlStr += "&f=\(f)"
        }

        if let urlStr = urlStr.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) {
            if let url = URL(string: urlStr) {
                // is D1 installed on device?
                if UIApplication.shared.canOpenURL(url) {
                    UIApplication.shared.open(url, options: [:], completionHandler: nil)
                } else {
                    // Redirect to app store
                    if let appStoreURL = URL.init(string: "https://itunes.apple.com/us/app/audiokit-digital-d1-synth/id1436905540?mt=8") {
                        UIApplication.shared.open(appStoreURL, options: [:], completionHandler: nil)
                    }
                }
            }
        }
    }

    public override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }

    func dependentParameterDidChange(_ parameter: DependentParameter) {}

    /// Notification of a change in notes played
    ///
    /// - Parameter playingNotes: An array of playing notes
    func playingNotesDidChange(_ playingNotes: PlayingNotes) {
        tuningsPitchWheelView.playingNotesDidChange(playingNotes)
    }

    @IBAction func randomPressed(_ sender: UIButton) {
        guard tuningModel.isTuningReady else { return }
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
        guard tuningModel.isTuningReady else { return }
        tuningIndex = index
        let path = IndexPath(row: index, section: 0)
        tuningTableView.selectRow(at: path, animated: true, scrollPosition: .middle)
        tableView(tuningTableView, didSelectRowAt: path)
    }

    public func setTuning(name: String?, masterArray master: [Double]?) {
        guard tuningModel.isTuningReady else { return }
        let i = tuningModel.setTuning(name: name, masterArray: master)
        if i.1 {
            tuningTableView.reloadData()
        }
        if let row = i.0 {
            selectRow(row)
        }
    }

    public func setDefaultTuning() {
        guard tuningModel.isTuningReady else { return }
        tuningIndex = tuningModel.resetTuning()
        selectRow(tuningIndex)
    }

    public func getTuning() -> (String, [Double]) {
        guard tuningModel.isTuningReady else { return ("", [1]) }
        let t = tuningModel.getTuning(index: tuningIndex)
        return t
    }
}

// MARK: - TuningsPitchWheelViewTuningDidChange

extension TuningsPanelController: TuningsPitchWheelViewTuningDidChange {
    func tuningDidChange() {
        tuningsPitchWheelView.updateFromGlobalTuningTable()
    }
}
