//
//  TuningsPanelController.swift
//  AudioKitSynthOne
//
//  Created by Marcus Hobbs on 5/6/18.
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
    @IBOutlet weak var tuningBankTableView: UITableView!
    @IBOutlet weak var tuningsPitchWheelView: TuningsPitchWheelView!
    @IBOutlet weak var masterTuningKnob: MIDIKnob!
    @IBOutlet weak var resetTuningsButton: SynthButton!
    @IBOutlet weak var d1LaunchButton: SynthButton!
    @IBOutlet weak var diceButton: UIButton!

    let tuningModel = Tunings()
    var getStoreTuningWithPresetValue = false

    override func viewDidLoad() {
        super.viewDidLoad()

        guard let synth = Conductor.sharedInstance.synth else { return }
        currentPanel = .tunings
        
        tuningTableView.backgroundColor = UIColor.clear
        //tuningTableView.isOpaque = false
        tuningTableView.isOpaque = true
        tuningTableView.allowsSelection = true
        tuningTableView.allowsMultipleSelection = false
        tuningTableView.dataSource = self
        tuningTableView.delegate = self

        tuningBankTableView.backgroundColor = UIColor.clear
        //tuningBankTableView.isOpaque = false
        tuningBankTableView.isOpaque = true
        tuningBankTableView.allowsSelection = true
        tuningBankTableView.allowsMultipleSelection = false
        tuningBankTableView.dataSource = self
        tuningBankTableView.delegate = self

        tuningModel.tuningsDelegate = self

        masterTuningKnob.range = synth.getRange(.frequencyA4)
        masterTuningKnob.value = synth.getSynthParameter(.frequencyA4)
        Conductor.sharedInstance.bind(masterTuningKnob, to: .frequencyA4)

        resetTuningsButton.callback = { value in
            if value == 1 {
                self.tuningModel.resetTuning()
                self.masterTuningKnob.value = synth.getSynthParameter(.frequencyA4)
                //self.selectRow()
                self.resetTuningsButton.value = 0
            }
        }

        d1LaunchButton.callback = { value in
            self.launchD1()
            self.d1LaunchButton.value = 0
        }

        // callback called on main thread
        tuningModel.loadTunings {
            AKLog("BEGIN: load tunings")
            self.tuningBankTableView.reloadData()
            self.tuningTableView.reloadData()
            //self.selectRow()
            AKLog("END  : load tunings")
            self.tuningDidChange()
        }

        tuningBankTableView.accessibilityLabel = "Tuning Banks Table"
		tuningTableView.accessibilityLabel = "Tunings Table"

		view.accessibilityElements = [
            tuningBankTableView,
			tuningTableView,
			masterTuningKnob,
			diceButton,
			resetTuningsButton,
            d1LaunchButton,
			leftNavButton,
			rightNavButton
		]

    }

    func launchD1() {
        let host = "digitald1://tune?"
        let masterSet = tuningModel.masterSet
        let npo = masterSet.count
        let tuningName = tuningModel.tuningName
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
                    if let appStoreURL = URL.init(string: "https://itunes.apple.com/us/app/audiokit-digital-d1-synth/id1436905540") {
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
        tuningModel.randomTuning()
        //selectRow()
        tuningDidChange()
        UIView.animate(withDuration: 0.4, animations: {
            for _ in 0 ... 1 {
                self.diceButton.transform = self.diceButton.transform.rotated(by: CGFloat(Double.pi))
            }
        })
    }

    internal func selectRow() {
        guard tuningModel.isTuningReady else { return }

        AKLog("BEGIN selectRow")

        let bankPath = IndexPath(row: tuningModel.selectedBankIndex, section: 0)
        AKLog("bankPath:\(bankPath)")
        tuningBankTableView.selectRow(at: bankPath, animated: true, scrollPosition: .top)
        tableView(tuningBankTableView, didSelectRowAt: bankPath)

        let tuningPath = IndexPath(row: tuningModel.selectedTuningIndex, section: 0)
        AKLog("tuningPath:\(tuningPath)")
        tuningTableView.selectRow(at: tuningPath, animated: true, scrollPosition: .middle)
        tableView(tuningTableView, didSelectRowAt: tuningPath)

        AKLog("END   selectRow")
    }

    public func setTuning(name: String?, masterArray master: [Double]?) {
        guard tuningModel.isTuningReady else { return }
        let reload = tuningModel.setTuning(name: name, masterArray: master)
        if reload {
            tuningTableView.reloadData()
        }
        //selectRow()
    }

    public func setDefaultTuning() {
        guard tuningModel.isTuningReady else { return }
        tuningModel.resetTuning()
        //selectRow()
    }

    public func getTuning() -> (String, [Double]) {
        guard tuningModel.isTuningReady else { return ("", [1]) }
        return tuningModel.getTuning()
    }
}

// MARK: - TuningsPitchWheelViewTuningDidChange

extension TuningsPanelController: TuningsPitchWheelViewTuningDidChange {
    func tuningDidChange() {
        AKLog("")
        tuningsPitchWheelView.updateFromGlobalTuningTable()
    }
}
