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

    @IBOutlet weak var tuningContainerView: UIView!

    @IBOutlet weak var tuningsPitchWheelView: TuningsPitchWheelView!

    @IBOutlet weak var masterTuningKnob: MIDIKnob!

    @IBOutlet weak var resetTuningsButton: SynthButton!

    @IBOutlet weak var diceButton: UIButton!

    @IBOutlet weak var importButton: SynthButton!

    @IBOutlet weak var tuneUpBackButtonButton: SynthButton!

    @IBOutlet weak var tuneUpButton: SynthButton!

    @IBOutlet weak var tuneUpBackLabel: UILabel!

    var tuningNavController = UINavigationController()

    var tuningBankTableView = UITableView()

    var tuningBankViewController = TuningsViewController()

    var tuningTableView = UITableView()

    var tuningViewController = TuningsViewController()

    var tuningTableEditButton: UIBarButtonItem?
    
    let tuningModel = Tunings()

    public override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {

        super.init(nibName: nibNameOrNil,bundle: nibBundleOrNil)
    }

    public required init?(coder aDecoder: NSCoder) {

        super.init(coder: aDecoder)
    }

    override func viewDidLoad() {

        super.viewDidLoad()

        currentPanel = .tunings

        let bg0 = UIImageView(image: UIImage(named: "iPhone_TouchPad_bg"), highlightedImage: nil)
        bg0.frame = tuningContainerView.bounds
        let bg1 = UIImageView(image: UIImage(named: "iPhone_TouchPad_bg"), highlightedImage: nil)
        bg1.frame = tuningContainerView.bounds

        tuningTableEditButton = UIBarButtonItem(title: "Edit", style: .plain, target: self, action: #selector(editTapped))

        // delegate and datasource are set when tuning model completes initialization
        tuningTableView.backgroundView = bg0
        tuningTableView.isOpaque = true
        tuningTableView.allowsSelection = true
        tuningTableView.allowsMultipleSelection = false
        tuningTableView.dataSource = self
        tuningTableView.delegate = self
        tuningTableView.accessibilityLabel = "Tunings"
        tuningTableView.separatorColor = #colorLiteral(red: 0.368627451, green: 0.368627451, blue: 0.3882352941, alpha: 1)
        tuningTableView.frame = tuningContainerView.bounds
        tuningViewController = TuningsViewController(tableView: tuningTableView)
        tuningViewController.title = "Tunings"
        tuningViewController.navigationItem.backBarButtonItem?.setTitleTextAttributes([NSAttributedString.Key.font: UIFont(name: "Avenir Next", size: 12)!], for: .normal)
        tuningViewController.navigationItem.rightBarButtonItem = tuningTableEditButton

        // delegate and datasource are set when tuning model completes initialization
        tuningBankTableView.backgroundView = bg1
        tuningBankTableView.isOpaque = true
        tuningBankTableView.allowsSelection = true
        tuningBankTableView.allowsMultipleSelection = false
        tuningBankTableView.dataSource = self
        tuningBankTableView.delegate = self
        tuningBankTableView.accessibilityLabel = "Tuning Banks"
        tuningBankTableView.separatorColor = #colorLiteral(red: 0.368627451, green: 0.368627451, blue: 0.3882352941, alpha: 1)
        tuningBankTableView.frame = tuningContainerView.bounds
        tuningBankViewController = TuningsViewController(tableView: tuningBankTableView)
        tuningBankViewController.title = "Banks"

        tuningNavController = UINavigationController(rootViewController: tuningBankViewController)
        tuningNavController.navigationBar.barStyle = .black
        tuningNavController.navigationBar.isTranslucent = true
        tuningNavController.navigationBar.titleTextAttributes = [NSAttributedString.Key.font: UIFont(name: "Avenir Next", size: 20)!]

        let backChevronImage = UIImage(named: "left-arrow")
        let barAppearance = UINavigationBar.appearance(whenContainedInInstancesOf: [UINavigationController.self])
        barAppearance.backIndicatorImage = backChevronImage
        barAppearance.backIndicatorTransitionMaskImage = backChevronImage
        barAppearance.tintColor = UIColor.white

        tuningNavController.view.frame = tuningContainerView.bounds
        tuningContainerView.addSubview(tuningNavController.view)

        view.accessibilityElements = [
            masterTuningKnob as Any,
            diceButton as Any,
            resetTuningsButton as Any,
            importButton as Any,
            leftNavButton as Any,
            rightNavButton as Any,
            tuneUpBackButtonButton as Any
        ]

        if let synth = Conductor.sharedInstance.synth {
            masterTuningKnob.range = synth.getRange(.frequencyA4)
            masterTuningKnob.value = synth.getSynthParameter(.frequencyA4)
            Conductor.sharedInstance.bind(masterTuningKnob, to: .frequencyA4)
            resetTuningsButton.setValueCallback = { value in
                if value == 1 {
                    self.tuningModel.resetTuning()
                    self.masterTuningKnob.value = synth.getSynthParameter(.frequencyA4)
                    self.selectRow()
                    self.resetTuningsButton.value = 0
                    self.conductor.updateDisplayLabel("Tuning Reset: 12ET/440")
                }
            }

            //TODO: implement sharing of tuning banks...see commented code at bottom of file
            importButton.setValueCallback = { _ in
                let documentPicker = UIDocumentPickerViewController(documentTypes: [(kUTTypeText as String)], in: .import)
                documentPicker.delegate = self
                self.present(documentPicker, animated: true, completion: nil)
            }
            importButton.isHidden = true
        } else {
            AKLog("race condition: synth not yet created")
        }

        // model
        tuningModel.pitchWheelDelegate = self
        tuningModel.tuneUpDelegate = self
        tuningModel.loadTunings {

            // callback called on main thread
            guard let manager = Conductor.sharedInstance.viewControllers.first(
                where: { $0 is Manager }) as? Manager else {
                    self.tuningModel.resetTuning()
                    return
            }

            if manager.appSettings.launchWithLastTuning {
                self.tuningModel.selectBank(atRow: self.getAppSettingsTuningsBank())
            } else {
                self.tuningModel.resetTuning()
            }

            self.tuningTableView.delegate = self
            self.tuningTableView.dataSource = self
            self.tuningBankTableView.delegate = self
            self.tuningBankTableView.dataSource = self
            self.tuningBankTableView.reloadData()
            self.tuningTableView.reloadData()
            self.selectRow()
            self.setTuneUpBackButton(enabled: false)
            self.setTuneUpBackButtonLabel(text: self.tuningModel.tuneUpBackButtonDefaultText)

            // If application was launched by url process it on next runloop
            DispatchQueue.main.async {
                if let appDelegate = UIApplication.shared.delegate as? AppDelegate {
                    if let url = appDelegate.applicationLaunchedWithURL() {
                        AKLog("launched with url:\(url)")
                        _ = self.openUrl(url: url)

                        // if url is a file in app Inbox remove it
                        AKLog("removing temporary file at \(url)")
                        do {
                            try FileManager.default.removeItem(at: url)
                        } catch let error as NSError {
                            AKLog("error removing temporary file at \(url): \(error)")
                        }
                    }
                }
            }
        }

        tuneUpBackButtonButton.setValueCallback = { value in
            self.tuningModel.tuneUpBackButton()
            self.tuneUpBackButtonButton.value = 0
        }

        tuneUpButton.setValueCallback = { value in
            self.performSegue(withIdentifier: "SegueToTuneUp", sender: nil)
            self.tuneUpButton.value = 0
        }
    }

    public override func viewDidAppear(_ animated: Bool) {

        super.viewDidAppear(animated)
    }

    @objc func editTapped() {
        
        self.tuningTableView.isEditing = !self.tuningTableView.isEditing

        UIView.animate(
            withDuration: 0.125,
            delay: 0.0,
            options: UIView.AnimationOptions(),
            animations: {
                if self.tuningTableView.isEditing {
                    self.tuningTableEditButton?.title = "Done"
                } else {
                    self.tuningTableEditButton?.title = "Edit"
                }
            }
        )
    }

    func dependentParameterDidChange(_ parameter: DependentParameter) {}

    /// Notification of a change in notes played
    ///
    /// - Parameter playingNotes: An array of playing notes
    func playingNotesDidChange(_ playingNotes: PlayingNotes) {

        tuningsPitchWheelView.playingNotesDidChange(playingNotes)
    }

    @IBAction func randomPressed(_ sender: UIButton) {

        guard tuningModel.isInitialized else { return }

        tuningModel.randomTuning()
        selectRow()
        UIView.animate(withDuration: 0.4, animations: {
            for _ in 0 ... 1 {
                self.diceButton.transform = self.diceButton.transform.rotated(by: CGFloat(Double.pi))
            }
        })
    }

    internal func selectRow() {

        guard tuningModel.isInitialized else { return }

        let bankPath = IndexPath(row: tuningModel.selectedBankIndex, section: 0)
        tableView(tuningBankTableView, didSelectRowAt: bankPath)

        let tuningPath = IndexPath(row: tuningModel.selectedTuningIndex, section: 0)
        tableView(tuningTableView, didSelectRowAt: tuningPath)
    }

    func updateAppSettingsTuningsBank(for index: Int) {

        guard let manager = Conductor.sharedInstance.viewControllers.first(
            where: { $0 is Manager }) as? Manager else { return }

        manager.appSettings.currentTuningBankIndex = index
        manager.saveAppSettingValues()
    }

    func getAppSettingsTuningsBank() -> Int {

        guard let manager = Conductor.sharedInstance.viewControllers.first(
            where: { $0 is Manager }) as? Manager else {
                return tuningModel.bundleBankIndex
        }

        let launchWithLastTuning = manager.appSettings.launchWithLastTuning
        let bankIndex = launchWithLastTuning ? manager.appSettings.currentTuningBankIndex : tuningModel.bundleBankIndex

        return bankIndex
    }

    public func setTuning(name: String?, masterArray master: [Double]?) {

        guard tuningModel.isInitialized else { return }

        let reload = tuningModel.setTuning(name: name, masterArray: master)
        if reload {
            tuningTableView.reloadData()
        }
        selectRow()
    }

    public func setDefaultTuning() {

        guard tuningModel.isInitialized else { return }

        tuningModel.resetTuning()
        selectRow()
    }

    public func getTuning() -> (String, [Double]) {

        guard tuningModel.isInitialized else { return ("", [1]) }

        return tuningModel.getTuning()
    }

    /// redirect to redirectURL provided by last TuneUp ( "back button" )
    func tuneUpBackButton() {

        tuningModel.tuneUpBackButton()
    }

    /// openURL
    public func openUrl(url: URL) -> Bool {

        let retVal = tuningModel.openUrl(url: url)
        if retVal {
            selectRow()
        }
        return retVal
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == "SegueToTuneUp" {
            guard let popOverController = segue.destination as? TuneUpPopUp else { return }
            popOverController.delegate = self
        }
    }
}

// MARK: - TuneUpPopUpDelegate

extension TuningsPanelController: TuneUpPopUpDelegate {

    func wilsonicPressed() {

        launchWilsonic()
    }
    
    func d1Pressed() {

        launchD1()
    }
}

// MARK: - TuningsPitchWheelViewTuningDidChange

extension TuningsPanelController: TuningsPitchWheelViewTuningDidChange {
    
    func tuningDidChange() {

        tuningsPitchWheelView.updateFromGlobalTuningTable()
    }
}



// MARK: - Launch applications that support TuneUp

extension TuningsPanelController {

    public func launchD1() {

        tuningModel.launchD1()
    }

    public func launchWilsonic() {

        tuningModel.launchWilsonic()
    }
}

// MARK: - import/export preset banks, tuning banks
extension TuningsPanelController: UIDocumentPickerDelegate {
    
    func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentAt url: URL) {
        AKLog("**** url: \(url) ")
        
        //let fileName = String(describing: url.lastPathComponent)

        //TODO: Add import/saving/sharing of TuningBanks
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
