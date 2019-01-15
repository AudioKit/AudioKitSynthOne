//
//  TuningsPanelController.swift
//  AudioKitSynthOne
//
//  Created by Marcus Hobbs on 5/6/18.
//  Copyright © 2018 AudioKit. All rights reserved.
//

import UIKit
import CloudKit
import MobileCoreServices

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
    @IBOutlet weak var importButton: SynthButton!
    @IBOutlet weak var tuneUpBackButtonButton: SynthButton!

    ///Model
    let tuningModel = Tunings()
    var getStoreTuningWithPresetValue = false

    override func viewDidLoad() {
        super.viewDidLoad()
        view.accessibilityElements = [
            tuningBankTableView,
            tuningTableView,
            masterTuningKnob,
            diceButton,
            resetTuningsButton,
            importButton,
            d1LaunchButton,
            leftNavButton,
            rightNavButton
        ]

        currentPanel = .tunings

        tuningTableView.backgroundColor = UIColor.clear
        tuningTableView.isOpaque = true
        tuningTableView.allowsSelection = true
        tuningTableView.allowsMultipleSelection = false
        tuningTableView.dataSource = self
        tuningTableView.delegate = self
        tuningTableView.accessibilityLabel = "Tunings Table"

        tuningBankTableView.backgroundColor = UIColor.clear
        tuningBankTableView.isOpaque = true
        tuningBankTableView.allowsSelection = true
        tuningBankTableView.allowsMultipleSelection = false
        tuningBankTableView.dataSource = self
        tuningBankTableView.delegate = self
        tuningBankTableView.accessibilityLabel = "Tuning Banks Table"

        if let synth = Conductor.sharedInstance.synth {
            masterTuningKnob.range = synth.getRange(.frequencyA4)
            masterTuningKnob.value = synth.getSynthParameter(.frequencyA4)
            Conductor.sharedInstance.bind(masterTuningKnob, to: .frequencyA4)

            resetTuningsButton.callback = { value in
                if value == 1 {
                    self.tuningModel.resetTuning()
                    self.masterTuningKnob.value = synth.getSynthParameter(.frequencyA4)
                    self.selectRow()
                    self.resetTuningsButton.value = 0
                }
            }
            
            importButton.callback = { _ in
                let documentPicker = UIDocumentPickerViewController(documentTypes: [(kUTTypeText as String)], in: .import)
                documentPicker.delegate = self
                self.present(documentPicker, animated: true, completion: nil)
            }
        } else {
            AKLog("race condition: synth not yet created")
        }

        d1LaunchButton.callback = { value in
            self.launchD1()
            self.d1LaunchButton.value = 0
        }

        // tuneUpBackButton
        tuneUpBackButtonButton.callback = { value in
            if let app = UIApplication.shared.delegate as? AppDelegate {
                app.tuneUpBackButton()
            } else {
                AKLog("ERROR: can not assign callback to TuneUp BackButton")
            }
        }

        // model
        tuningModel.tuningsDelegate = self
        tuningModel.loadTunings {
            // callback called on main thread
            self.tuningBankTableView.reloadData()
            self.tuningTableView.reloadData()
            self.selectRow()
        }
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
        selectRow()
        UIView.animate(withDuration: 0.4, animations: {
            for _ in 0 ... 1 {
                self.diceButton.transform = self.diceButton.transform.rotated(by: CGFloat(Double.pi))
            }
        })
    }

    internal func selectRow() {
        guard tuningModel.isTuningReady else { return }

        let bankPath = IndexPath(row: tuningModel.selectedBankIndex, section: 0)
        tableView(tuningBankTableView, didSelectRowAt: bankPath)

        let tuningPath = IndexPath(row: tuningModel.selectedTuningIndex, section: 0)
        tableView(tuningTableView, didSelectRowAt: tuningPath)
    }

    public func setTuning(name: String?, masterArray master: [Double]?) {
        guard tuningModel.isTuningReady else { return }
        let reload = tuningModel.setTuning(name: name, masterArray: master)
        if reload {
            tuningTableView.reloadData()
        }
        selectRow()
    }

    public func setDefaultTuning() {
        guard tuningModel.isTuningReady else { return }
        tuningModel.resetTuning()
        selectRow()
    }

    public func getTuning() -> (String, [Double]) {
        guard tuningModel.isTuningReady else { return ("", [1]) }
        return tuningModel.getTuning()
    }

    /// redirect to redirectURL provided by last TuneUp ( "back button" )
    func tuneUpBackButton() {
        tuningModel.tuneUpBackButton()
    }

    /// openURL
    public func openUrl(url: URL) -> Bool {
        return tuningModel.openUrl(url: url)
    }
}




// MARK: - TuningsPitchWheelViewTuningDidChange

extension TuningsPanelController: TuningsPitchWheelViewTuningDidChange {
    func tuningDidChange() {
        tuningsPitchWheelView.updateFromGlobalTuningTable()
    }
}

// MARK: - Import Scala File

extension TuningsPanelController: UIDocumentPickerDelegate {
    
    func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentAt url: URL) {
        AKLog("**** url: \(url) ")
        
        let fileName = String(describing: url.lastPathComponent)

        // Marcus: Run load procedure with "fileName" here
        
        // OR, add the logic right here
//        do {
//            //
//
//        } catch {
//            AKLog("*** error loading")
//        }
        
    }
    
}
