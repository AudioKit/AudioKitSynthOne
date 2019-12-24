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

// MARK: - TuningScaleDegreeDescription

public enum TuningScaleDegreeDescription {
    case frequency, pitch, cents, harmonic
    
    func simpleDescription() -> String {
        switch self {
        case .frequency:
            return "Frequency"
        case .pitch:
            return "Pitch"
        case .cents:
            return "Cents"
        case .harmonic:
            return "Harmonic"
        }
    }
}

// MARK: - Tunings

final class Tunings {

    // MARK: - INIT

    init() {}

    // MARK: - Types

    public typealias S1TuningCallback = () -> [Double]
    public typealias Frequency = Double
    public typealias Pitch = Double
    public typealias S1TuningLoadCallback = () -> (Void)
    public enum TuningSortType {
        case npo
        case name
        case userOrder
    }

    // MARK: - Properties

    let conductor = Conductor.sharedInstance
    private var tuningSortType = TuningSortType.userOrder
    var isInitialized = false
    internal let bundleBankIndex = 0
    internal let userBankIndex = 1
    internal let hexanyTriadIndex = 2
    private(set) var tuningBanks = [TuningBank]()
    private(set) var selectedBankIndex: Int = 0

    /// convenience property: returns selected bank
    var tuningBank: TuningBank {
        get {
            return tuningBanks[selectedBankIndex]
        }
    }

    /// convenience property: returns index of selected tuning in selected bank
    var selectedTuningIndex: Int {
        get {
            return tuningBank.selectedTuningIndex
        }
    }

    /// convenience property: returns array of tunings of selected bank
    var tunings: [Tuning] {
        get {
            return tuningBank.tunings
        }
    }

    var selectedBankTuningIsEditable: Bool {
        get {
            return selectedBankIndex == userBankIndex
        }
    }

    var selectedBankName: String {
        get {
            return tuningBanks[selectedBankIndex].name
        }
    }

    // MARK: - TuneUp Properties

    var tuningName = Tuning.defaultName
    var tuningFileBaseName: String {
        get {
            // tuningName is always a valid String
            let underScore = "_"
            let convertToUnderscore = CharacterSet(charactersIn: " ()[],:=+/!@#$%^&*+")
            var retVal = tuningName.components(separatedBy: convertToUnderscore).joined(separator: underScore)
            retVal += underScore
            let tempo = Conductor.sharedInstance.synth.getSynthParameter(.arpRate)
            let tempoFormat = String(format: "%03d", Int32(tempo))
            retVal += tempoFormat
            retVal += underScore
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "yyyyMMdd_HHmmss"
            let dateSuffix = dateFormatter.string(from:Date())
            retVal += dateSuffix
            return retVal
        }
    }
    var masterSet = Tuning.defaultMasterSet
    internal let tuningFilenameV0 = "tunings.json"
    internal let tuningFilenameV1 = "tunings_v1.json"
    internal static let hexanyTriadTuningsBankName = "Hexanies With Proportional Triads"

    // MARK: - TuneUp BackButton Properties

    internal var redirectHost: String?
    internal var redirectFriendlyName: String = "TuneUp"
    public weak var tuneUpDelegate: TuneUpDelegate?
    static let tuneUpBackButtonUrlArgs = "&redirect=synth1&redirectFriendlyName=Synth One"

    // MARK: - STORAGE

    func loadTunings(completionHandler: @escaping S1TuningLoadCallback) {
        DispatchQueue.global(qos: .userInitiated).async {
            /// CLEAR
            self.tuningBanks.removeAll()

            /// uncomment to test upgrade paths
            ///self.testUpgradeV1Path()
            ///self.testFreshInstallV1Path()

            /// LOAD PATH
            if Disk.exists(self.tuningFilenameV1, in: .documents) {

                /// tunings have been installed and/or upgraded
                self.loadTuningsFromDevice()
            } else if Disk.exists(self.tuningFilenameV0, in: .documents) {

                /// tunings need to be upgraded
                self.upgradeTuningsFromV0ToV1()
            } else {

                /// fresh install
                self.loadTuningFactoryPresets()
            }

            /// SORT
            self.sortTunings(forBank: self.tuningBanks[self.userBankIndex], sortType: self.tuningSortType)
            self.sortTunings(forBank: self.tuningBanks[self.bundleBankIndex], sortType: .userOrder)
            self.sortTunings(forBank: self.tuningBanks[self.hexanyTriadIndex], sortType: .userOrder)

            /// SAVE
            self.saveTunings()

            /// SELECT user bank if it's not empty
            if self.tuningBanks[self.userBankIndex].tunings.count > 1 {
                self.selectedBankIndex = self.userBankIndex
            } else {
                self.selectedBankIndex = self.bundleBankIndex
            }

            /// MODEL IS INITIALIZED
            self.isInitialized = true
            self.tuningDidChange()

            /// CALLBACK
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

        /// bundled bank
        let bundledBank = tuningBanks[bundleBankIndex]
        bundledBank.name = "Curated"
        bundledBank.isEditable = false
        bundledBank.order = bundleBankIndex
        for (order, t) in Tunings.defaultTunings().enumerated() {
            let newTuning = Tuning()
            newTuning.name = t.0
            newTuning.masterSet = t.1()
            newTuning.order = order
            bundledBank.tunings.append(newTuning)
        }

        /// user bank
        let userBank = tuningBanks[userBankIndex]
        userBank.name = "User"
        userBank.isEditable = false // for now
        userBank.order = userBankIndex

        /// hexany triads bank
        let hexanyTriadsBank = tuningBanks[hexanyTriadIndex]
        hexanyTriadsBank.name = Tunings.hexanyTriadTuningsBankName
        hexanyTriadsBank.isEditable = false
        hexanyTriadsBank.order = hexanyTriadIndex
        for (order, t) in Tunings.hexanyTriadTunings().enumerated() {
            let hexanyTuning = Tuning()
            hexanyTuning.name = t.0
            hexanyTuning.masterSet = t.1()
            hexanyTuning.order = order
            hexanyTriadsBank.tunings.append(hexanyTuning)
        }
    }

    /// saveTunings: For the cases where selectedTuningIndex changes
    private func saveTunings() {
        DispatchQueue.global(qos: .userInitiated).async {
            do {
                try Disk.save(self.tuningBanks, to: .documents, as: self.tuningFilenameV1)
            } catch {
                AKLog("*** error saving tuning banks")
            }
        }
    }

    // MARK: - SORT

    public func reorderUserBank(tuningFromIndex: Int, tuningToIndex: Int) -> Bool {
        let bank = tuningBanks[userBankIndex]
        var tunings = bank.tunings
        guard tunings.count > 1 else { return false }
        guard 0 ..< tunings.count ~= tuningFromIndex else { return false }
        guard 0 ..< tunings.count ~= tuningToIndex else { return false }
        let tuningToMove = tunings[tuningFromIndex]
        tunings.remove(at: tuningFromIndex)
        tunings.insert(tuningToMove, at: tuningToIndex)
        for (index, tuning) in tunings.enumerated() {
            tuning.userOrder = index
        }
        sortTunings(forBank: bank, sortType: .userOrder)
        selectTuning(atRow: tuningToIndex) // saves to disk
        return true
    }

    private func sortTunings(forBank tuningBank: TuningBank, sortType: TuningSortType) {
        var t = tuningBank.tunings

        /// remove 12ET
        let twelveET = Tuning()
        let insertTwelveET = tuningBank === tuningBanks[bundleBankIndex] || tuningBank === tuningBanks[userBankIndex]
        if insertTwelveET {
            t = tuningBank.tunings.filter { $0.name + $0.encoding != twelveET.name + twelveET.encoding }
            t = t.filter {$0.name != "Twelve Tone Equal Temperament" }
        }

        /// SORT BY TYPE
        switch sortType {
        case .npo:
            t.sort { $0.nameForCell + $0.encoding < $1.nameForCell + $1.encoding }
        case .name:
            t.sort { $0.name + $0.nameForCell + $0.encoding < $1.name + $1.nameForCell + $1.encoding }
        case .userOrder:
            t.sort { $0.userOrder < $1.userOrder }
        }

        /// If no userOrder (== -1) set a default
        let defaultUserOrder = t.filter { $0.userOrder == -1 }
        if defaultUserOrder.count > 0 {
            for (index, tuning) in t.enumerated() {
                tuning.userOrder = index + 10
            }
        }

        /// insert 12ET
        if insertTwelveET {
            twelveET.userOrder = 0
            t.insert(twelveET, at: 0)
        }

        /// IN-PLACE
        tuningBank.tunings = t
    }

    // MARK: - SELECTION (PERSISTENT)

    /// select the tuning at row for selected bank
    public func selectTuning(atRow row: Int) {
        let b = tuningBank
        b.selectedTuningIndex = Int((0 ... b.tunings.count).clamp(row))
        let tuning = b.tunings[b.selectedTuningIndex]
        tuningName = tuning.name
        masterSet = tuning.masterSet
        AKPolyphonicNode.tuningTable.tuningTable(fromFrequencies: tuning.masterSet)
        tuningDidChange()
        saveTunings()
    }

    /// select the bank at row
    public func selectBank(atRow row: Int) {
        let c = tuningBanks.count
        selectedBankIndex = Int((0 ... c).clamp(row))
        let b = tuningBank
        let tuning = b.tunings[b.selectedTuningIndex]
        tuningName = tuning.name
        masterSet = tuning.masterSet
        AKPolyphonicNode.tuningTable.tuningTable(fromFrequencies: tuning.masterSet)
        tuningDidChange()
        saveTunings()
    }

    // MARK: - GLOBAL STATE

    public var frequencyA4: Double {
        get {
            return conductor.synth!.getSynthParameter(.frequencyA4)
        }
        set(frequency) {
            conductor.synth!.setSynthParameter(.frequencyA4, frequency)
            tuningDidChange()
        }
    }

    public func resetTuning() {

        /// Assumes 12ET is bundled at index 0
        selectedBankIndex = bundleBankIndex
        selectBank(atRow: selectedBankIndex)
        let b = tuningBank
        selectTuning(atRow: 0)
        let tuning = b.tunings[b.selectedTuningIndex]
        tuningName = tuning.name
        masterSet = tuning.masterSet
        _ = AKPolyphonicNode.tuningTable.tuningTable(fromFrequencies: tuning.masterSet)
        let f = conductor.synth!.getDefault(.frequencyA4)
        conductor.synth!.setSynthParameter(.frequencyA4, f)
        tuningDidChange()
        saveTunings()
    }

    public func randomTuning() {
        let b = tuningBanks[selectedBankIndex]
        b.selectedTuningIndex = Int(arc4random() % UInt32(b.tunings.count))
        let tuning = b.tunings[b.selectedTuningIndex]
        tuningName = tuning.name
        masterSet = tuning.masterSet
        _ = AKPolyphonicNode.tuningTable.tuningTable(fromFrequencies: tuning.masterSet)
        tuningDidChange()
        saveTunings()
    }

    public func getTuning() -> (String, [Double]) {
        let b = tuningBank
        let tuning = b.tunings[b.selectedTuningIndex]
        return (tuning.name, tuning.masterSet)
    }

    /// Add tuning to user bank if it does not exist
    public func setTuning(name: String?, masterArray master: [Double]?) -> Bool {
        guard let name = name, let masterFrequencies = master, masterFrequencies.count > 0 else { return false }

        /// NEW TUNING
        let t = Tuning()
        t.name = name
        tuningName = name
        t.masterSet = masterFrequencies
        masterSet = masterFrequencies

        /// SEARCH TUNING BANK
        let ubi = userBankIndex
        let ub = tuningBanks[ubi]
        let matchingIndices = ub.tunings.indices.filter { ub.tunings[$0].name + ub.tunings[$0].encoding == t.name + t.encoding }

        /// EXISTING TUNING
        if matchingIndices.count > 0 {
            selectedBankIndex = ubi
            ub.selectedTuningIndex = matchingIndices[0]
        } else {
            // NEW TUNING: add to user bank, sort, save
            ub.tunings.append(t)
            sortTunings(forBank: ub, sortType: tuningSortType)
            let sortedIndices = ub.tunings.indices.filter { ub.tunings[$0].name + ub.tunings[$0].encoding == t.name + t.encoding } // do not optimize
            if sortedIndices.count > 0 {
                selectedBankIndex = ubi
                ub.selectedTuningIndex = sortedIndices[0]
            }
        }

        /// Update global tuning table no matter what
        _ = AKPolyphonicNode.tuningTable.tuningTable(fromFrequencies: masterFrequencies)
        tuningDidChange()

        /// save
        saveTunings()
        return true
    }

    public func removeUserTuning(atIndex index: Int) -> Bool {

        /// can only delete from user bank
        guard selectedBankIndex == userBankIndex else { return false }
        let b = tuningBanks[userBankIndex]

        /// never empty; 12 ET is always item 0
        guard b.tunings.count > 1 && index != 0 else { return false }

        /// remove and set new selected index
        b.tunings.remove(at: index)
        let newIndex = Int( (0 ... b.tunings.count).clamp(index - 1) )
        selectTuning(atRow: newIndex) // saves tunings
        return true
    }

    // MARK: - Notification

    private func tuningDidChange() {

        /// udpate dsp with global tuning table
        /// NOTE: There is NO need to block dsp while the update is happening from a non-realtime  thread
        let a4 = conductor.synth!.getSynthParameter(.frequencyA4)
        AKPolyphonicNode.tuningTable.middleCFrequency = a4 * exp2((60 - 69) / 12)
        for i in 0..<127 {
            let f = AKPolyphonicNode.tuningTable.frequency(forNoteNumber: MIDINoteNumber(i))
            conductor.synth.setTuningTable(f, index: i)
        }
        NotificationCenter.default.post(name: .tuningDidChange, object: nil)
    }
}

extension Notification.Name {
    static let tuningDidChange = Notification.Name("tuningDidChange")
}
