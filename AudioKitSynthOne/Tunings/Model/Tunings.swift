//
//  Tunings.swift
//  AudioKitSynthOne
//
//  Created by Marcus Hobbs on 5/12/18.
//  Copyright © 2018 AudioKit. All rights reserved.
//

import UIKit
import AudioKit
import Disk

/// Tuning Model
class Tunings {

    let conductor = Conductor.sharedInstance

    // TuneUp BackButton
    private var redirectHost: String?
    private var redirectFriendlyName: String = "Back"

    enum TuningSortType {
        case npo
        case name
        case order // user order
        // eventually put tuning type here, i.e., mos, cps hexany, scala, unknown, etc.
    }
    private var tuningSortType = TuningSortType.npo

    public typealias S1TuningCallback = () -> [Double]
    public typealias Frequency = Double
    public typealias S1TuningLoadCallback = () -> (Void)

    var isTuningReady = false
    var tuningsDelegate: TuningsPitchWheelViewTuningDidChange?

    internal static let bundleBankIndex = 0
    internal static let userBankIndex = 1
    internal static let hexanyTriadIndex = 2
    private(set) var tuningBanks = [TuningBank]()
    private(set) var selectedBankIndex: Int = 0

    // convenience property: returns selected bank
    var tuningBank: TuningBank {
        get {
            return tuningBanks[selectedBankIndex]
        }
    }

    // convenience property: returns index of selected tuning in selected bank
    var selectedTuningIndex: Int {
        get {
            return tuningBank.selectedTuningIndex
        }
    }

    // convenience property: returns array of tunings of selected bank
    var tunings: [Tuning] {
        get {
            return tuningBank.tunings
        }
    }

    // exposed for sharing tunings with D1
    var tuningName = Tuning.defaultName
    var masterSet = Tuning.defaultMasterSet

    internal let tuningFilenameV0 = "tunings.json"
    internal let tuningFilenameV1 = "tunings_v1.json"
    internal static let hexanyTriadTuningsBankName = "Hexanies With Proportional Triads"


    // MARK: INIT
    init() {}

    // MARK: STORAGE

    ///
    func loadTunings(completionHandler: @escaping S1TuningLoadCallback) {
        DispatchQueue.global(qos: .userInitiated).async {
            // CLEAR
            self.tuningBanks.removeAll()

            // uncomment to test upgrade paths
            //self.testUpgradeV1Path()
            //self.testFreshInstallV1Path()

            // LOAD PATH
            if Disk.exists(self.tuningFilenameV1, in: .documents) {
                // tunings have been installed and/or upgraded
                self.loadTuningsFromDevice()
            } else if Disk.exists(self.tuningFilenameV0, in: .documents) {
                // tunings need to be upgraded
                self.upgradeTuningsFromV0ToV1()
            } else {
                // fresh install
                self.loadTuningFactoryPresets()
            }

            // SORT
            self.sortTunings(forBank: self.tuningBanks[Tunings.userBankIndex], sortType: self.tuningSortType)
            self.sortTunings(forBank: self.tuningBanks[Tunings.bundleBankIndex], sortType: .order)
            self.sortTunings(forBank: self.tuningBanks[Tunings.hexanyTriadIndex], sortType: .order)

            // SAVE
            self.saveTunings()

            // SELECT user bank if it's not empty
            if self.tuningBanks[Tunings.userBankIndex].tunings.count > 1 {
                self.selectedBankIndex = Tunings.userBankIndex
            } else {
                self.selectedBankIndex = Tunings.bundleBankIndex
            }

            // MODEL IS INITIALIZED
            self.isTuningReady = true
            self.tuningsDelegate?.tuningDidChange()

            // CALLBACK
            DispatchQueue.main.async {
                completionHandler()
            }
        }
    }


    /// reads array of banks, each of which has an array of tunings
    private func loadTuningsFromDevice() {
        do {
            let tuningBankData = try Disk.retrieve(tuningFilenameV1, from: .documents, as: Data.self)
            let jsonArray = try JSONDecoder().decode([TuningBank].self, from: tuningBankData)
            tuningBanks.append(contentsOf: jsonArray)
        } catch let error as NSError {
            AKLog("*** error loading tuning banks from device: \(error)")
        }
    }

    /// Fresh Install
    internal func loadTuningFactoryPresets() {
        tuningBanks.removeAll()
        tuningBanks.append(TuningBank())
        tuningBanks.append(TuningBank())
        tuningBanks.append(TuningBank())

        // bundled bank
        let bundledBank = tuningBanks[Tunings.bundleBankIndex]
        bundledBank.name = "Curated"
        bundledBank.isEditable = false
        bundledBank.order = Tunings.bundleBankIndex
        for (order, t) in Tunings.defaultTunings().enumerated() {
            let newTuning = Tuning()
            newTuning.name = t.0
            newTuning.masterSet = t.1()
            newTuning.order = order
            bundledBank.tunings.append(newTuning)
        }

        // user bank
        let userBank = tuningBanks[Tunings.userBankIndex]
        userBank.name = "User"
        userBank.isEditable = false // for now
        userBank.order = Tunings.userBankIndex

        // hexany triads bank
        let hexanyTriadsBank = tuningBanks[Tunings.hexanyTriadIndex]
        hexanyTriadsBank.name = Tunings.hexanyTriadTuningsBankName
        hexanyTriadsBank.isEditable = false
        hexanyTriadsBank.order = Tunings.hexanyTriadIndex
        for (order, t) in Tunings.hexanyTriadTunings().enumerated() {
            let hexanyTuning = Tuning()
            hexanyTuning.name = t.0
            hexanyTuning.masterSet = t.1()
            hexanyTuning.order = order
            hexanyTriadsBank.tunings.append(hexanyTuning)
        }
    }

    /// saveTunings
    /// Save for the cases where selectedTuningIndex changes
    /// Need to extend TuningBanks from array to dictionary with selectedBankIndex value
    private func saveTunings() {
        DispatchQueue.global(qos: .userInitiated).async {
            do {
                try Disk.save(self.tuningBanks, to: .documents, as: self.tuningFilenameV1)
            } catch {
                AKLog("*** error saving tuning banks")
            }
        }
    }

    // MARK: SORT, FILTER

    ///
    private func sortTunings(forBank tuningBank: TuningBank, sortType: TuningSortType) {
        var t = tuningBank.tunings
        let twelveET = Tuning()
        let insertTwelveET = tuningBank === tuningBanks[Tunings.bundleBankIndex] || tuningBank === tuningBanks[Tunings.userBankIndex]

        if insertTwelveET {
            t = tuningBank.tunings.filter { $0.name + $0.encoding != twelveET.name + twelveET.encoding }
            t = t.filter {$0.name != "Twelve Tone Equal Temperament" }
        }

        // SORT TYPE
        switch sortType {
        case .npo:
            t.sort { $0.nameForCell + $0.encoding < $1.nameForCell + $1.encoding }
        case .name:
            t.sort { $0.name + $0.nameForCell + $0.encoding < $1.name + $1.nameForCell + $1.encoding }
        case .order:
            t.sort { $0.order < $1.order }
        }

        if insertTwelveET {
            t.insert(twelveET, at: 0)
        }

        // IN-PLACE
        tuningBank.tunings = t

        // No need to save reordering of tunings
    }

    /// adds tuning to user bank if it does not exist
    public func setTuning(name: String?, masterArray master: [Double]?) -> Bool {
        guard let name = name, let masterFrequencies = master else { return false }
        if masterFrequencies.count == 0 { return false }
        var refreshDatasource = false

        // NEW TUNING
        let t = Tuning()
        t.name = name
        tuningName = name
        t.masterSet = masterFrequencies
        masterSet = masterFrequencies

        // SEARCH EACH TUNING BANK
        let bankIndices = [Tunings.bundleBankIndex, Tunings.hexanyTriadIndex, Tunings.userBankIndex]
        for bi in bankIndices {
            let b = tuningBanks[bi]
            let matchingIndices = b.tunings.indices.filter { b.tunings[$0].name + b.tunings[$0].encoding == t.name + t.encoding }

            // EXISTING TUNING
            if matchingIndices.count > 0 {
                selectedBankIndex = bi
                b.selectedTuningIndex = matchingIndices[0]
                refreshDatasource = true
                break
            } else {
                // NEW TUNING FOR USER BANK: add to user bank, sort, save
                if bi == Tunings.userBankIndex {
                    b.tunings.append(t)
                    sortTunings(forBank: b, sortType: tuningSortType)
                    let sortedIndices = b.tunings.indices.filter { b.tunings[$0].name + b.tunings[$0].encoding == t.name + t.encoding } // do not optimize
                    if sortedIndices.count > 0 {
                        selectedBankIndex = bi
                        b.selectedTuningIndex = sortedIndices[0]
                        refreshDatasource = true
                    }
                } else {
                    // New Tuning for a bundled bank.
                    // This is an option for an upgrade path: add new tuning to bundled bank.
                }
            }
        }

        // Update global tuning table no matter what
        _ = AKPolyphonicNode.tuningTable.tuningTable(fromFrequencies: masterFrequencies)
        tuningsDelegate?.tuningDidChange()
        saveTunings()

        return refreshDatasource
    }

    // MARK: SELECTION (PERSISTENT)

    /// select the tuning at row for selected bank
    public func selectTuning(atRow row: Int) {
        let b = tuningBank
        b.selectedTuningIndex = Int((0 ... b.tunings.count).clamp(row))
        let tuning = b.tunings[b.selectedTuningIndex]
        AKPolyphonicNode.tuningTable.tuningTable(fromFrequencies: tuning.masterSet)
        tuningsDelegate?.tuningDidChange()
        saveTunings()
    }

    /// select the bank at row
    public func selectBank(atRow row: Int) {
        let c = tuningBanks.count
        selectedBankIndex = Int((0 ... c).clamp(row))
        let b = tuningBank
        let tuning = b.tunings[b.selectedTuningIndex]
        AKPolyphonicNode.tuningTable.tuningTable(fromFrequencies: tuning.masterSet)
        tuningsDelegate?.tuningDidChange()
        saveTunings()
    }

    // MARK: STATE

    // Assumes tuning[0] is twelve et for all tuningBanks
    public func resetTuning() {
        selectedBankIndex = Tunings.bundleBankIndex
        let b = tuningBank
        b.selectedTuningIndex = 0
        let tuning = b.tunings[b.selectedTuningIndex]
        _ = AKPolyphonicNode.tuningTable.tuningTable(fromFrequencies: tuning.masterSet)
        let f = conductor.synth!.getDefault(.frequencyA4)
        conductor.synth!.setSynthParameter(.frequencyA4, f)
        tuningsDelegate?.tuningDidChange()
        saveTunings()
    }

    public func randomTuning() {
        let b = tuningBanks[selectedBankIndex]
        b.selectedTuningIndex = Int(arc4random() % UInt32(b.tunings.count))
        let tuning = b.tunings[b.selectedTuningIndex]
        _ = AKPolyphonicNode.tuningTable.tuningTable(fromFrequencies: tuning.masterSet)
        tuningsDelegate?.tuningDidChange()
        saveTunings()
    }

    public func getTuning() -> (String, [Double]) {
        let b = tuningBank
        let tuning = b.tunings[b.selectedTuningIndex]
        return (tuning.name, tuning.masterSet)
    }


    // MARK: TuneUp BackButton

    public func tuneUpBackButton() {

        // must have a host
        if let redirect = redirectHost {

            // open url
            let urlStr = "\(redirect)://tuneup?redirect=synth1&redirectFriendlyName=\"Synth One\""
            if let urlStr = urlStr.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) {
                if let url = URL(string: urlStr) {

                    // BackButton: Fast Switch to previous app
                    UIApplication.shared.open(url, options: [:], completionHandler: nil)
                }
            }
        } else {
            AKLog("Can't redirect because no previous host was given")
        }
    }

    public func openUrl(url: URL) -> Bool {
        
        // scala files
        if url.isFileURL {
            return openScala(atUrl: url)
        }

        // custom url
        let urlStr = url.absoluteString
        let host = URLComponents(string: urlStr)?.host

        // TuneUp
        if host == "tune" || host == "tuneup" {

            ///TuneUp implementation
            let queryItems = URLComponents(string: urlStr)?.queryItems
            if let fArray = queryItems?.filter({$0.name == "f"}).map({ Double($0.value ?? "1.0") ?? 1.0 }) {

                // only valid if non-zero length frequency array
                if fArray.count > 0 {

                    // set vc properties
                    let tuningName = queryItems?.filter({$0.name == "tuningName"}).first?.value ?? ""
                    _ = setTuning(name: tuningName, masterArray: fArray)

                    // set synth properties
                    if let frequencyMiddleCStr = queryItems?.filter({$0.name == "frequencyMiddleC"}).first?.value {
                        if let frequencyMiddleC = Double(frequencyMiddleCStr) {
                            if let s = conductor.synth {
                                let frequencyA4 = frequencyMiddleC * exp2((69-60)/12)
                                s.setSynthParameter(.frequencyA4, frequencyA4)
                            } else {
                                AKLog("TuneUp:can't set frequencyA4 because synth is not initialized")
                            }
                        }
                    }
                } else {

                    // if you want to alert the user that the tuning is invalid this is the place
                    AKLog("TuneUp: tuning is invalid")
                }

                // Store TuneUp BackButton properties even if there is an error
                if let redirect = queryItems?.filter({$0.name == "redirect"}).first?.value {
                    if redirect.count > 0 {

                        // store redirect url and friendly name...for when user wants to fast-switch back
                        redirectHost = redirect
                        if let redirectName = queryItems?.filter({$0.name == "redirectFriendlyName"}).first?.value {
                            if redirectName.count > 0 {
                                redirectFriendlyName = redirectName
                            } else {
                                redirectFriendlyName = "Back"
                            }
                        }
                    }
                }
            }
            return true
        } else if host == "open" {

            // simply Open
            return true
        } else {

            // can't handle this url scheme
            AKLog("unsupported custom url scheme: \(url)")
            return false
        }
    }

    private func openScala(atUrl url: URL) -> Bool {
        AKLog("opening scala file at full path:\(url.path)")

        let tt = AKTuningTable()
        guard tt.scalaFile(url.path) != nil else {
            AKLog("Scala file is invalid")
            return true // even if there is an error
        }

        let fArray = tt.masterSet
        if fArray.count > 0 {
            let tuningName = url.lastPathComponent
            let tuningsPanel = conductor.viewControllers.first(where: { $0 is TuningsPanelController })
                as? TuningsPanelController
            tuningsPanel?.setTuning(name: tuningName, masterArray: fArray)
            if let s = conductor.synth {
                let frequencyA4 = s.getDefault(.frequencyA4)
                s.setSynthParameter(.frequencyA4, frequencyA4)
            } else {
                AKLog("ERROR:can't set frequencyA4 because synth is not initialized")
            }
        } else {
            AKLog("Scala file is invalid: masterSet is zero-length")
        }

        return true
    }
}
