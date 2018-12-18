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

    enum TuningSortType {
        case npo
        case name
        case order // user order
        // eventually put tuning type here, i.e., mos, cps hexany, scala, unknown, etc.
    }

    public typealias S1TuningCallback = () -> [Double]
    public typealias Frequency = Double
    public typealias S1TuningLoadCallback = () -> (Void)

    var isTuningReady = false
    var tuningsDelegate: TuningsPitchWheelViewTuningDidChange?

    private static let bundleBankIndex = 0
    private static let userBankIndex = 1
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

    private var tuningSortType = TuningSortType.npo
    private let tuningFilenameV0 = "tunings.json"
    private let tuningFilenameV1 = "tunings_v1.json"

    init() {}

    ///
    func loadTunings(completionHandler: @escaping S1TuningLoadCallback) {
        DispatchQueue.global(qos: .userInitiated).async {
            self.tuningBanks.removeAll()

            //TODO:remove test code
            self.testUpgradeV1Path()
            //self.testFreshInstallV1Path()

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
            self.sortTunings(forBank: self.tuningBanks[Tunings.bundleBankIndex])
            self.sortTunings(forBank: self.tuningBanks[Tunings.userBankIndex])
            self.saveTunings()

            // select user bank if it's not empty
            if self.tuningBanks[Tunings.userBankIndex].tunings.count > 1 {
                self.selectedBankIndex = Tunings.userBankIndex
            } else {
                self.selectedBankIndex = Tunings.bundleBankIndex
            }

            self.isTuningReady = true
            self.tuningsDelegate?.tuningDidChange()

            DispatchQueue.main.async {
                completionHandler()
            }
        }
    }

    // for testing...resets file system state with bundled+user v0 tunings
    private func testUpgradeV1Path() {
        // copy test v0 file from bundle to documents
        if let pathStr = Bundle.main.path(forResource: "tunings_v0_upgrade_path_test", ofType: "json") {
            let fromUrl = URL(fileURLWithPath: pathStr)
            try? Disk.remove(tuningFilenameV0, from: .documents)
            let docUrl = try? FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create:false)
            if let toUrl = docUrl?.appendingPathComponent(tuningFilenameV0) {
                try? FileManager.default.copyItem(at: fromUrl, to: toUrl)
            }
        }
        // remove v1 file
        try? Disk.remove(tuningFilenameV1, from: .documents)
    }

    // for testing...tests case new v1 user
    private func testFreshInstallV1Path() {
        try? Disk.remove(tuningFilenameV0, from: .documents)
        try? Disk.remove(tuningFilenameV1, from: .documents)
    }

    /// reads array of banks, each of which has an array of tunings
    private func loadTuningsFromDevice() {
        do {
            let tuningBankData = try Disk.retrieve(tuningFilenameV1, from: .documents, as: Data.self)
            let jsonArray = try JSONDecoder().decode([TuningBank].self, from: tuningBankData)
            tuningBanks.append(contentsOf: jsonArray)
            tuningBanks.sort { $0.order < $1.order }
        } catch let error as NSError {
            AKLog("*** error loading tuning banks from device: \(error)")
        }
    }

    /// Upgrade path from Tunings v0 to v1
    private func upgradeTuningsFromV0ToV1() {
        // create bundled bank, and an empty user bank
        loadTuningFactoryPresets()

        do {
            // read v0 file
            let retrievedTuningData = try Disk.retrieve(tuningFilenameV0, from: .documents, as: Data.self)
            let tuningsJSON = try? JSONSerialization.jsonObject(with: retrievedTuningData, options: [])
            guard let jsonArray = tuningsJSON as? [Any] else {
                AKLog("*** error parsing v0 tuning array from JSON while upgrading to v1")
                return
            }
            var tuningsV0 = [Tuning]()
            for tuningJSON in jsonArray {
                if let tuningDictionary = tuningJSON as? [String: Any] {
                    let retrievedTuning = Tuning(dictionary: tuningDictionary)
                    tuningsV0.append(retrievedTuning)
                }
            }

            // uniquify encodings of v0 tunings
            var v1BundledTuningEncodings = [String:String]()
            for t in Tunings.defaultTunings() {
                let tt = Tuning()
                tt.masterSet = t.1()
                let e = tt.encoding
                v1BundledTuningEncodings[e] = e
            }
            // filter 12ET
            let t = Tuning()
            v1BundledTuningEncodings[t.encoding] = t.encoding

            // compare v0 tuning encodings to bundled v1 tuning encodings
            for t in tuningsV0 {
                if v1BundledTuningEncodings[t.encoding] == nil {
                    // t is a v0 custom tuning not in v1 bundled tunings
                    tuningBanks[Tunings.userBankIndex].tunings.append(t)
                }
            }

            // remove v0 file so next launch will skip this upgrade path
            try? Disk.remove(tuningFilenameV0, from: .documents)
        } catch let error as NSError {
            AKLog("*** error upgrading from V0 to V1:\(error)")
        }
    }

    // Fresh Install: create bundled bank, and an empty user bank
    private func loadTuningFactoryPresets() {
        tuningBanks.removeAll()
        tuningBanks.append(TuningBank())
        tuningBanks.append(TuningBank())

        let bundledBank = tuningBanks[Tunings.bundleBankIndex]
        bundledBank.name = "Curated"
        bundledBank.isEditable = false
        bundledBank.order = Tunings.bundleBankIndex
        for t in Tunings.defaultTunings() {
            let newTuning = Tuning()
            newTuning.name = t.0
            newTuning.masterSet = t.1()
            bundledBank.tunings.append(newTuning)
        }

        let userBank = tuningBanks[Tunings.userBankIndex]
        userBank.name = "User"
        userBank.isEditable = false // for now
        userBank.order = Tunings.userBankIndex
    }

    private func saveTunings() {
        do {
            try Disk.save(tuningBanks, to: .documents, as: tuningFilenameV1)
        } catch {
            AKLog("*** error saving tuning banks")
        }
    }

    ///TODO: do you want user bank to have 12et on top?
    private func sortTunings(forBank tuningBank: TuningBank) {
        let twelve = Tuning()
        // remove 12ET, then sort
        var t = tuningBank.tunings.filter { $0.name + $0.encoding != twelve.name + twelve.encoding }
        switch tuningSortType {
        case .npo:
            //t.sort { String($0.npo) + $0.name + $0.encoding < String($1.npo) + $1.name + $1.encoding }
            t.sort { $0.nameForCell + $0.encoding < $1.nameForCell + $1.encoding }
        case .name:
            t.sort { $0.name + $0.nameForCell + $0.encoding < $1.name + $1.nameForCell + $1.encoding }
        case .order:
            t.sort { $0.order < $1.order }
        }
        // Insert 12ET at top
        t.insert(twelve, at: 0)
        tuningBank.tunings = t
    }

    // adds tuning to user bank if it does not exist
    public func setTuning(name: String?, masterArray master: [Double]?) -> Bool {
        guard let name = name, let masterFrequencies = master else { return false }
        if masterFrequencies.count == 0 { return false }
        let t = Tuning()
        t.name = name
        tuningName = name
        t.masterSet = masterFrequencies
        masterSet = masterFrequencies

        var refreshDatasource = false
        let b = tuningBanks[Tunings.userBankIndex]
        let matchingIndices = b.tunings.indices.filter { b.tunings[$0].name + b.tunings[$0].encoding == t.name + t.encoding }
        if matchingIndices.count == 0 {
            // If this is a new tuning: add, sort, save
            b.tunings.append(t)
            sortTunings(forBank: b)
            let sortedIndices = b.tunings.indices.filter { b.tunings[$0].name + b.tunings[$0].encoding == t.name + t.encoding }
            if sortedIndices.count > 0 {
                selectedBankIndex = Tunings.userBankIndex
                b.selectedTuningIndex = sortedIndices[0]
                refreshDatasource = true
                _ = AKPolyphonicNode.tuningTable.tuningTable(fromFrequencies: masterFrequencies)
                tuningsDelegate?.tuningDidChange()
                saveTunings()
            } else {
                AKLog("error inserting/sorting new tuning")
            }
        } else {
            // existing tuning...do nothing.  Or, if you want to alert user this is the place
        }

        return refreshDatasource
    }

    /// select the tuning at row for selected bank
    public func selectTuning(atRow row: Int) {
        let b = tuningBank
        b.selectedTuningIndex = Int((0 ... b.tunings.count).clamp(row))
        let tuning = b.tunings[b.selectedTuningIndex]
        AKPolyphonicNode.tuningTable.tuningTable(fromFrequencies: tuning.masterSet)
        tuningsDelegate?.tuningDidChange()
    }

    /// select the bank at row
    public func selectBank(atRow row: Int) {
        let c = tuningBanks.count
        selectedBankIndex = Int((0 ... c).clamp(row))
        let b = tuningBank
        let tuning = b.tunings[b.selectedTuningIndex]
        AKPolyphonicNode.tuningTable.tuningTable(fromFrequencies: tuning.masterSet)
        tuningsDelegate?.tuningDidChange()
    }

    // Assumes tuning[0] is twelve et for all tuningBanks
    public func resetTuning() {
        selectedBankIndex = Tunings.bundleBankIndex
        let b = tuningBank
        let tuning = b.tunings[b.selectedTuningIndex]
        _ = AKPolyphonicNode.tuningTable.tuningTable(fromFrequencies: tuning.masterSet)
        let f = Conductor.sharedInstance.synth!.getDefault(.frequencyA4)
        Conductor.sharedInstance.synth!.setSynthParameter(.frequencyA4, f)
        tuningsDelegate?.tuningDidChange()
    }

    public func randomTuning() {
        let b = tuningBanks[selectedBankIndex]
        b.selectedTuningIndex = Int(arc4random() % UInt32(b.tunings.count))
        let tuning = b.tunings[b.selectedTuningIndex]
        _ = AKPolyphonicNode.tuningTable.tuningTable(fromFrequencies: tuning.masterSet)
        tuningsDelegate?.tuningDidChange()
    }

    public func getTuning() -> (String, [Double]) {
        let b = tuningBank
        let tuning = b.tunings[b.selectedTuningIndex]
        return (tuning.name, tuning.masterSet)
    }
}
