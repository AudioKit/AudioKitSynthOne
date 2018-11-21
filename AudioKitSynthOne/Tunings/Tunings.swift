//
//  Tunings.swift
//  AudioKitSynthOne
//
//  Created by AudioKit Contributors on 5/12/18.
//  Copyright © 2018 AudioKit. All rights reserved.
//

import UIKit
import AudioKit
import Disk

class Tunings {

    var isTuningReady = false
    var tunings = [Tuning]()
    var tuningsDelegate: TuningsPitchWheelViewTuningDidChange?
    var tuningName = ""
    var masterSet: [Double] = [1]
    private let tuningFilename = "tunings.json"
    public typealias S1TuningCallback = () -> [Double]
    public typealias Frequency = Double
    public typealias S1TuningLoadCallback = () -> (Void)

    init() {}

    //
    func loadTunings(completionHandler: @escaping S1TuningLoadCallback) {
        DispatchQueue.global(qos: .userInitiated).async {
            self.tunings.removeAll()

            if Disk.exists(self.tuningFilename, in: .documents) {
                self.loadTuningsFromDevice()
            } else {
                self.loadTuningFactoryPresets()
            }
            
            self.sortTunings()
            self.saveTunings()

            self.isTuningReady = true
            DispatchQueue.main.async {
                completionHandler()
            }
        }
    }

    private func loadTuningsFromDevice() {
        do {
            let retrievedTuningData = try Disk.retrieve(tuningFilename, from: .documents, as: Data.self)
            parseTuningsFromData(data: retrievedTuningData)
        } catch {
            AKLog("*** error loading tunings")
        }
    }

    private func loadTuningFactoryPresets() {
        for t in Tunings.defaultTunings() {
            let newTuning = Tuning()
            newTuning.name = t.0
            newTuning.masterSet = t.1()
            tunings.append(newTuning)
        }
    }

    private func saveTunings() {
        do {
            try Disk.save(tunings, to: .documents, as: tuningFilename)
        } catch {
            AKLog("error saving tunings")
        }
    }

    func parseTuningsFromData(data: Data) {
        let tuningsJSON = try? JSONSerialization.jsonObject(with: data, options: [])
        guard let jsonArray = tuningsJSON as? [Any] else { return }
        tunings += Tunings.parseDataToTunings(jsonArray: jsonArray)
    }

    // Return Array of Tunings
    class public func parseDataToTunings(jsonArray: [Any]) -> [Tuning] {
        var retVal = [Tuning]()
        for tuningJSON in jsonArray {
            if let tuningDictionary = tuningJSON as? [String: Any] {
                let retrievedTuning = Tuning(dictionary: tuningDictionary)
                retVal.append(retrievedTuning)
            }
        }
        return retVal
    }

    func sortTunings() {
        let twelve = Tuning()

        // remove 12ET, then sort
        var t = tunings.filter { $0.name + $0.encoding != twelve.name + twelve.encoding }
        t.sort { $0.name + $0.encoding < $1.name + $1.encoding }

        // Insert 12ET at top
        t.insert(twelve, at: 0)
        tunings = t
    }

    public func setTuning(name: String?, masterArray master: [Double]?) -> (Int?, Bool) {
        guard let name = name, let masterFrequencies = master else { return (nil, false) }
        if masterFrequencies.count == 0 { return (nil, false) }
        let t = Tuning()
        t.name = name
        tuningName = name
        t.masterSet = masterFrequencies
        masterSet = masterFrequencies

        var index: Int?
        var refreshDatasource: Bool = false

        let matchingIndices = tunings.indices.filter { tunings[$0].name + tunings[$0].encoding == t.name + t.encoding }
        if matchingIndices.count == 0 {
            tunings.append(t)
            sortTunings()
            let sortedIndices = tunings.indices.filter { tunings[$0].name + tunings[$0].encoding == t.name + t.encoding }
            if sortedIndices.count > 0 {
                index = sortedIndices[0]
                refreshDatasource = true
                saveTunings()
            } else {
                AKLog("error inserting/sorting new tuning")
            }
        } else {
            //TODO:Marcus: Add new tunings to database.
            index = matchingIndices[0]
        }

        _ = AKPolyphonicNode.tuningTable.tuningTable(fromFrequencies: masterFrequencies)
        tuningsDelegate?.tuningDidChange()
        return (index, refreshDatasource)
    }

    public func selectTuning(atRow row: Int) {
        let tuning = tunings[row]
        AKPolyphonicNode.tuningTable.tuningTable(fromFrequencies: tuning.masterSet)
    }

    public func resetTuning() -> Int {
        let i = 0
        let tuning = tunings[i]
        _ = AKPolyphonicNode.tuningTable.tuningTable(fromFrequencies: tuning.masterSet)
        let f = Conductor.sharedInstance.synth!.getDefault(.frequencyA4)
        Conductor.sharedInstance.synth!.setSynthParameter(.frequencyA4, f)
        tuningsDelegate?.tuningDidChange()
        return i
    }

    public func randomTuning() -> Int {
        let ri = Int(arc4random() % UInt32(tunings.count))
        let tuning = tunings[ri]
        _ = AKPolyphonicNode.tuningTable.tuningTable(fromFrequencies: tuning.masterSet)
        tuningsDelegate?.tuningDidChange()
        return ri
    }

    public func getTuning(index: Int) -> (String, [Double]) {
        let t = tunings[index]
        return (t.name, t.masterSet)
    }

    internal static func defaultTunings() -> [(String, S1TuningCallback)] {

        var retVal = [(String, S1TuningCallback)]()

        // do NOT include default tuning (12ET)

        retVal.append( ("12 Chain of pure fifths", { return [1, 3, 9, 27, 81, 243, 729, 2_187, 6_561, 19_683, 59_049, 177_147] }) )

        // See http://anaphoria.com/harm&Subharm.pdf
        retVal.append( (" 2 Harmonic Series: Dyad", { return harmonicSeries(2) }) )
        retVal.append( (" 2 Subharmonic Series: Dyad", { return subHarmonicSeries(2) }) )
        retVal.append( (" 2 Harmonic+Subharmonic Series: Dyad", { return harmonicSubharmonicSeries(2) }) )
        retVal.append( (" 3 Harmonic Series: Triad", { return harmonicSeries(3) }) )
        retVal.append( (" 3 Subharmonic Series: Triad", { return subHarmonicSeries(3) }) )
        retVal.append( (" 3 Harmonic+Subharmonic Series: Triad", { return harmonicSubharmonicSeries(3) }) )
        retVal.append( (" 4 Harmonic Series: Tetrad", { return harmonicSeries(4) }) )
        retVal.append( (" 4 Subharmonic Series: Tetrad", { return subHarmonicSeries(4) }) )
        retVal.append( (" 4 Harmonic+Subharmonic Series: Tetrad", { return harmonicSubharmonicSeries(4) }) )
        retVal.append( (" 5 Harmonic Series: Pentad", { return harmonicSeries(5) }) )
        retVal.append( (" 5 Subharmonic Series: Pentad", { return subHarmonicSeries(5) }) )
        retVal.append( ("12 Harmonic Series", { return harmonicSeries(12) }) )
        retVal.append( ("16 Harmonic Series", { return harmonicSeries(16) }) )
        retVal.append( ("16 Subharmonic Series", { return subHarmonicSeries(16) }) )
        retVal.append( ("16 Harmonic+Subharmonic Series", { return harmonicSubharmonicSeries(16) }) )

        /// Scales designed by Erv Wilson.  See http://anaphoria.com/genus.pdf
        retVal.append( (" 6 Wilson Hexany(1, 3, 5, 7)", { return Tunings.hexany( [1, 3, 5, 7] ) }) )
        retVal.append( (" 6 Wilson Hexany(1, 3, 5, 45)", { return Tunings.hexany( [1, 3, 5, 45] ) }) )
        retVal.append( (" 6 Wilson Hexany(1, 3, 5, 9)", { return Tunings.hexany( [1, 3, 5, 9] ) }) )
        retVal.append( (" 6 Wilson Hexany(1, 3, 5, 15)", { return Tunings.hexany( [1, 3, 5, 15] ) }) )
        retVal.append( (" 6 Wilson Hexany(1, 3, 5, 81)", { return Tunings.hexany( [1, 3, 5, 81] ) }) )
        retVal.append( ("10 Wilson Dekany(1, 3, 5, 9, 81)", { return Tunings.dekany( [1, 3, 5, 9, 81] ) }) )
        retVal.append( (" 6 Wilson Hexany(1, 3, 5, 121)", { return Tunings.hexany( [1, 3, 5, 121] ) }) )
        retVal.append( (" 6 Wilson Hexany(1, 15, 45, 75)", { return Tunings.hexany( [1, 15, 45, 75] ) }) )
        retVal.append( (" 6 Wilson Hexany(1, 17, 19, 23)", { return Tunings.hexany( [1, 17, 19, 23] ) }) )
        retVal.append( (" 6 Wilson Hexany(1, 45, 135, 225)", { return Tunings.hexany( [1, 45, 135, 225] ) }) )
        retVal.append( (" 6 Wilson Hexany(3, 5, 7, 9)", { return Tunings.hexany( [3, 5, 7, 9] ) }) )
        retVal.append( (" 6 Wilson Hexany(3, 5, 15, 19)", { return Tunings.hexany( [3, 5, 15, 19] ) }) )
        retVal.append( (" 7 Wilson Diaphonic", { let s: [Double] =  [1 / 1, 27 / 26, 9 / 8, 4 / 3, 18 / 13, 3 / 2, 27 / 16]; return s }) )
        retVal.append( (" 6 Wilson Hexany(3, 5, 15, 27)", { return Tunings.hexany( [3, 5, 15, 27] ) }) )
        retVal.append( (" 6 Wilson Hexany(5, 7, 21, 35)", { return Tunings.hexany( [5, 7, 21, 35] ) }) )
        retVal.append( (" 7 Wilson Highland Bagpipes", { let t = AKTuningTable(); _ = t.presetHighlandBagPipes(); return t.masterSet }) )
        retVal.append( (" 7 Wilson MOS G:0.2641", { let t = AKTuningTable(); _ = t.momentOfSymmetry(generator: 0.264_1, level: 5, murchana: 0); return t.masterSet }) )
        retVal.append( ("10 Wilson MOS G:0.292787", { let t = AKTuningTable(); _ = t.momentOfSymmetry(generator: 0.292_787, level: 6, murchana: 0); return t.masterSet }) )
        retVal.append( (" 7 Wilson MOS G:0.405699", { let t = AKTuningTable(); _ = t.momentOfSymmetry(generator: 0.405_699_700_117_111, level: 5, murchana: 0); return t.masterSet }) )
        retVal.append( (" 7 Wilson MOS G:0.415226", { let t = AKTuningTable(); _ = t.momentOfSymmetry(generator: 0.415_226, level: 5, murchana: 0); return t.masterSet }) )
        retVal.append( (" 7 Wilson MOS G:0.436385", { let t = AKTuningTable(); _ = t.momentOfSymmetry(generator: 0.436_385, level: 5, murchana: 0); return t.masterSet }) )
        retVal.append( ("31 Wilson MOS G:0.328173", { return [1.0, 1.139_858_796_310_911, 1.152_155_087_458_816_5, 1.164_584_025_542_011_2, 1.177_147_041_496_803_5, 1.189_845_581_695_805_6, 1.202_681_108_114_456_6, 1.215_655_098_499_338_2, 1.228_769_046_538_307_4, 1.242_024_462_032_462_8, 1.255_422_871_069_967_7, 1.431_004_802_679_001_4, 1.446_441_847_815_417_1, 1.462_045_420_948_172_4, 1.477_817_318_507_435_5, 1.493_759_356_302_464, 1.509_873_369_730_661_2, 1.526_161_213_988_883_4, 1.542_624_764_287_028_8, 1.559_265_916_063_926_6, 1.576_086_585_205_560_8, 1.796_516_157_894_184_6, 1.815_896_177_420_180_3, 1.835_485_260_001_455_1, 1.855_285_660_917_525_4, 1.875_299_659_776_866_1, 1.895_529_560_779_353_6, 1.915_977_692_981_552, 1.936_646_410_564_853_8, 1.957_538_093_106_518_3, 1.978_655_145_853_626_8] }) )
        retVal.append( ("22 Wilson Evangelina", { let s: [Double] =  [1 / 1, 135 / 128, 13 / 12, 10 / 9, 9 / 8, 7 / 6, 11 / 9, 5 / 4, 81 / 64, 4 / 3, 11 / 8, 45 / 32, 17 / 12, 3 / 2, 19 / 12, 13 / 8, 5 / 3, 27 / 16, 7 / 4, 11 / 6, 15 / 8, 243 / 128]; return s }) )
        retVal.append( (" 7 Wilson North Indian:Kafi", { let t = AKTuningTable(); _ = t.presetPersian17NorthIndian05Kafi(); return t.masterSet }) )
        retVal.append( (" 7 Wilson North Indian:Bhairavi", { let t = AKTuningTable(); _ = t.presetPersian17NorthIndian07Bhairavi(); return t.masterSet }) )
        retVal.append( (" 7 Wilson North Indian:Bhairav", { let t = AKTuningTable(); _ = t.presetPersian17NorthIndian15Bhairav(); return t.masterSet }) )
        retVal.append( (" 7 Wilson North Indian:Marwa", { let t = AKTuningTable(); _ = t.presetPersian17NorthIndian08Marwa(); return t.masterSet }) )
        retVal.append( (" 7 Wilson North Indian:Purvi", { let t = AKTuningTable(); _ = t.presetPersian17NorthIndian09Purvi(); return t.masterSet }) )
        retVal.append( (" 7 Wilson North Indian:Todi", { let t = AKTuningTable(); _ = t.presetPersian17NorthIndian11Todi(); return t.masterSet }) )
        retVal.append( (" 7 Wilson North Indian:Bhairav", { let t = AKTuningTable(); _ = t.presetPersian17NorthIndian15Bhairav(); return t.masterSet }) )
        retVal.append( (" 7 Wilson North Indian:Madhubanti", { let t = AKTuningTable(); _ = t.presetPersian17NorthIndian17Madhubanti(); return t.masterSet }) )
        retVal.append( (" 7 Wilson North Indian:AhirBhairav", { let t = AKTuningTable(); _ = t.presetPersian17NorthIndian19AhirBhairav(); return t.masterSet }) )
        retVal.append( (" 7 Wilson North Indian:ChandraKanada", { let t = AKTuningTable(); _ = t.presetPersian17NorthIndian20ChandraKanada(); return t.masterSet }) )
        retVal.append( (" 7 Wilson North Indian:BasantMukhair", { let t = AKTuningTable(); _ = t.presetPersian17NorthIndian21BasantMukhari(); return t.masterSet }) )
        retVal.append( (" 7 Wilson North Indian:Champakali", { let t = AKTuningTable(); _ = t.presetPersian17NorthIndian22Champakali(); return t.masterSet }) )
        retVal.append( (" 7 Wilson North Indian:Patdeep", { let t = AKTuningTable(); _ = t.presetPersian17NorthIndian23Patdeep(); return t.masterSet }) )
        retVal.append( (" 7 Wilson North Indian:MohanKauns", { let t = AKTuningTable(); _ = t.presetPersian17NorthIndian24MohanKauns(); return t.masterSet }) )
        retVal.append( ("17 Wilson North Indian:17", { let t = AKTuningTable(); _ = t.presetPersian17NorthIndian00_17(); return t.masterSet }) )

        /// Scales designed by Jose Garcia
        retVal.append( ("16 Garcia: Meta Mavila (37-50-67-91)", { let s: [Double] =  [ 1/1, 1027/1024, 67/64, 559/512, 37/32, 153/128,
            2539/2048, 167/128, 1389/1024, 91/64, 189/128, 25/16, 415/256, 225/128, 937/512, 31/16]; return s }) )
        retVal.append( ("22 Garcia: Wilson 7-limit marimba", { let s: [Double] =  [1 / 1, 28 / 27, 16 / 15, 10 / 9, 9 / 8, 7 / 6, 6 / 5, 5 / 4, 35 / 27, 4 / 3, 27 / 20, 45 / 32, 35 / 24, 3 / 2, 14 / 9, 8 / 5, 5 / 3, 27 / 16, 7 / 4, 9 / 5, 15 / 8, 35 / 18]; return s }) )
        retVal.append( ("29 Garcia: linear 15/13-52/45 alternating", { let s: [Double] =  [1 / 1,  40/39, 27/26, 16/15, 128/117, 9/8, 15/13, 32/27, 6/5, 16/13, 81/64, 135/104, 4/3, 160/117, 18/13, 64/45,  512/351,  3/2, 20/13, 81/52, 8/5,  64/39,  27/16,  45/26,  16/9,  9/5,  24/13,  256/135, 405/208]; return s }) )

        /// scales designed by Kraig Grady
        retVal.append( (" 5 Grady: S 7-limit Pentatonic", { let s: [Double] = [1 / 1, 7 / 6, 4 / 3, 3 / 2, 7 / 4]; return s }) )
        retVal.append( (" 5 Grady: S Pentatonic 11-limit Scale 1", { let s: [Double] = [1 / 1, 9 / 8, 11 / 8, 3 / 2, 7 / 4]; return s }) )
        retVal.append( (" 5 Grady: S Pentatonic 11-limit Scale 2", { let s: [Double] = [1 / 1, 5 / 4, 11 / 8, 3 / 2, 7 / 4]; return s }) )
        retVal.append( (" 7 Grady: S Centaur 7-limit Minor", { let s: [Double] = [1 / 1, 9 / 8, 7 / 6, 4 / 3, 3 / 2, 14 / 9, 7 / 4]; return s }) )
        retVal.append( (" 7 Grady: S Centaur Soft Major on E", { let s: [Double] = [1 / 1, 28 / 25, 56 / 46, 4 / 3, 3 / 2, 42 / 25, 28 / 15]; return s }) )
        retVal.append( ("12 Grady: A Centaur", { let s: [Double] = [1 / 1, 21 / 20, 9 / 8, 7 / 6, 5 / 4, 4 / 3, 7 / 5, 3 / 2, 14 / 9, 5 / 3, 7 / 4, 15 / 8]; return s }) )
        retVal.append( ("14 Grady: Double Dekany 14-tone", { let s: [Double] = [1.0 / 1, 35 / 32, 9 / 8, 7 / 6, 5 / 4, 21 / 16, 45 / 32, 35 / 24, 3 / 2, 105 / 64, 5 / 3, 7 / 4, 15 / 8, 63 / 32]; return s }) )
        retVal.append( ("19 Grady: A-Narushima 19-tone 7-limit", { let s: [Double] =  [1 / 1, 21 / 20, 35 / 32, 9 / 8, 7 / 6, 6 / 5, 5 / 4, 21 / 16, 4 / 3, 7 / 5, 35 / 24, 3 / 2, 14 / 9, 8 / 5, 5 / 3, 7 / 4, 9 / 5, 15 / 8, 63 / 32]; return s }) )
        retVal.append( ("12 Grady: Sisiutl 12-tone", { let s: [Double] = [ 1 / 1, 28 / 27, 9 / 8, 7 / 6, 14 / 11, 4 / 3, 11 / 8, 3 / 2, 14 / 9, 56 / 33, 7 / 4, 11 / 6]; return s }) )
        retVal.append( ("14 Grady: Wilson pre-Sisiutl 17", { let s: [Double] = [ 1 / 1, 28 / 27, 9 / 8, 7 / 6, 14 / 11, 4 / 3, 11 / 8, 3 / 2, 14 / 9, 3 / 2, 14 / 9, 56 / 33, 7 / 4, 11 / 6]; return s }) )
        retVal.append( ("12 Grady: Beebalm 7-limit", { let s: [Double] = [ 1 / 1, 17 / 16, 9 / 8, 7 / 6, 5 / 4, 4 / 3, 17 / 12, 3 / 2, 14 / 9, 5 / 3, 16 / 9, 17 / 9]; return s }) )
        retVal.append( ("12 Grady: Schulter Zeta Centauri 12 tone", { let s: [Double] = [ 1 / 1, 13 / 12, 9 / 8, 7 / 6, 11 / 9, 4 / 3, 13 / 9, 3 / 2, 14 / 9, 13 / 8, 7 / 4, 11 / 6]; return s }) )
        retVal.append( ("10 Grady: Schulter Shur", { let s: [Double] = [ 1 / 1, 27 / 26, 9 / 8, 27 / 22, 4 / 3, 18 / 13, 3 / 2, 18 / 11, 16 / 9, 24 / 13]; return s }) )
        retVal.append( ("17 Grady: Poole 17", { let s: [Double] = [ 1 / 1, 33 / 32, 13 / 12, 9 / 8, 7 / 6, 11 / 9, 14 / 11, 4 / 3, 11 / 8, 13 / 9, 3 / 2, 14 / 9, 44 / 27, 27 / 16, 7 / 4, 11 / 6, 21 / 11]; return s }) )
        retVal.append( ("10 Grady: 11-limit Helix Song", { let s: [Double] = [ 1 / 1, 9 / 8, 7 / 6, 5 / 4, 4 / 3, 11 / 8, 3 / 2, 5 / 3, 7 / 4, 11 / 6]; return s }) )
        retVal.append( ("12 David: Double 1-3-5-7 Hexany 12-Tone", { let s: [Double] = [ 1.0 / 1, 16 / 15, 35 / 32, 7 / 6, 5 / 4, 4 / 3, 7 / 5, 35 / 24, 8 / 5, 5 / 3, 7 / 4, 28 / 15]; return s }) )
        retVal.append( ("12 Wilson Double Hexany+ 12 tone", { let s: [Double] = [ 1 / 1, 49 / 48, 8 / 7, 7 / 6, 5 / 4, 4 / 3, 10 / 7, 35 / 24, 80 / 49, 5 / 3, 7 / 4, 40 / 21]; return s }) )
        retVal.append( ("12 Grady: Wilson Triple Hexany +", { let s: [Double] = [ 1 / 1, 15 / 14, 9 / 8, 7 / 6, 5 / 4, 21 / 16, 10 / 7, 3 / 2, 45 / 28, 5 / 3, 7 / 4, 15 / 8]; return s }) )
        retVal.append( ("12 Grady: Wilson Super 7", { let s: [Double] = [ 1 / 1, 35 / 32, 8 / 7, 5 / 4, 245 / 192, 10 / 7, 35 / 24, 3 / 2, 49 / 32, 12 / 7, 7 / 4, 245 / 128]; return s }) )
        retVal.append( ("12 David: Dual Harmonic Subharmonic", { let s: [Double] = [ 1 / 1, 16 / 15, 9 / 8, 6 / 5, 9 / 7, 4 / 3, 7 / 5, 3 / 2, 8 / 5, 12 / 7, 9 / 5, 28 / 15]; return s }) )
        retVal.append( ("12 Wilson/David: Enharmonics", { let s: [Double] = [ 1 / 1, 28 / 27, 9 / 8, 7 / 6, 6 / 5, 4 / 3, 35 / 24, 3 / 2, 14 / 9, 8 / 5, 7 / 4, 25 / 18]; return s }) )
        retVal.append( (" 9 Grady: Wilson First Pelog", { let s: [Double] = [ 1 / 1, 16 / 15, 64 / 55, 5 / 4, 4 / 3, 16 / 11, 8 / 5, 128 / 75, 20 / 11]; return s }) )
        retVal.append( (" 9 Grady: Wilson Meta-Pelog 1", { let s: [Double] = [ 1 / 1, 571 / 512, 153 / 128, 41 / 32, 4 / 3, 11 / 8, 209 / 128, 7 / 4, 15 / 8]; return s }) )
        retVal.append( (" 9 Grady: Wilson Meta-Pelog 2", { let s: [Double] = [ 1 / 1, 9 / 8, 19 / 16, 41 / 32, 11 / 8, 3 / 2, 13 / 8, 7 / 4, 15 / 8]; return s }) )
        retVal.append( ("10 Grady: Wilson Meta-Ptolemy 10", { let s: [Double] =  [ 1 / 1, 33 / 32, 9 / 8, 73 / 64, 5 / 4, 11 / 8, 3 / 2, 49 / 32, 27 / 16, 15 / 8]; return s }) )
        retVal.append( ("12 Grady: Olympos Staircase", { let s: [Double] = [1/1, 28/27, 9/8, 7/6, 9/7, 4/3, 49/36, 3/2, 14/9, 12/7, 7/4, 49/27]; return s } ) )

        // Scales designed by Marcus Hobbs using Wilsonic
        retVal.append( (" 9 Hobbs MOS G:0.238186", { let t = AKTuningTable(); _ = t.momentOfSymmetry(generator: 0.238_186, level: 6, murchana: 0); return t.masterSet }) )
        retVal.append( (" 6 Hobbs Hexany(9, 25, 49, 81)", { return Tunings.hexany( [9, 25, 49, 81] ) }) )
        
        //    •    Hexany Fibonacci Triplets (X-3, 3, X, X+3) where X=[3,6]
        retVal.append( (" 6 Hobbs Hexany(3, 2.111, 5.111, 8.111)", { return Tunings.hexany( [3, 2.111, 5.111, 8.111] ) }) )
        retVal.append( (" 6 Hobbs Hexany(3, 1.346, 4.346, 7.346)", { return Tunings.hexany( [3, 1.346, 4.346, 7.346] ) }) )

        retVal.append( (" 5 Hobbs Recurrence Relation 1", { let s: [Double] = [1, 19, 5, 3, 15]; return s }) )
        retVal.append( (" 5 Hobbs Recurrence Relation 2", { let s: [Double] = [35, 74, 23, 51, 61]; return s }) )
        retVal.append( (" 6 Hobbs Recurrence Relation 1", { let s: [Double] = [74, 150, 85, 106, 120, 61]; return s }) )
        retVal.append( (" 6 Hobbs Recurrence Relation 2", { let s: [Double] = [1, 9, 5, 23, 48, 7]; return s }) )
        retVal.append( (" 6 Hobbs Recurrence Relation 3", { let s: [Double] = [1, 9, 21, 3, 25, 15]; return s }) )
        retVal.append( (" 6 Hobbs Recurrence Relation 4", { let s: [Double] = [1, 75, 19, 5, 3, 15]; return s }) )
        retVal.append( (" 7 Hobbs Recurrence Relation 1", { let s: [Double] = [1, 17, 10, 47, 3, 13, 7]; return s }) )
        retVal.append( (" 7 Hobbs Recurrence Relation 2", { let s: [Double] = [1, 9, 5, 21, 3, 27, 7]; return s }) )
        retVal.append( (" 7 Hobbs Recurrence Relation 3", { let s: [Double] = [1, 9, 21, 3, 25, 15, 31]; return s }) )
        retVal.append( (" 7 Hobbs Recurrence Relation 4", { let s: [Double] = [1, 75, 19, 5, 94, 3, 15]; return s }) )
        retVal.append( (" 7 Hobbs Recurrence Relation 5", { let s: [Double] = [9, 40, 21, 25, 52, 15, 31]; return s }) )
        retVal.append( (" 7 Hobbs Recurrence Relation 6", { let s: [Double] = [1, 18, 5, 21, 3, 25, 15]; return s }) )
        retVal.append( ("12 Hobbs Recurrence Relation 1", { let s: [Double] = [1, 65, 9, 37, 151, 21, 86, 12, 49, 200, 28, 114]; return s }) )

        /// scales designed by Stephen Taylor
        retVal.append( (" 6 Taylor MOS G: 0.855088", { let t = AKTuningTable(); _ = t.momentOfSymmetry(generator: 0.855_088, level: 6, murchana: 0 ); return t.masterSet }) )
        retVal.append( ("13 Taylor MOS G: 0.855088", { return [1.0, 1.094_694_266_037_451, 1.198_355_536_095_273_3, 1.210_363_175_255_471_5, 1.324_977_627_775_046_9, 1.338_254_032_623_560_6, 1.464_979_016_014_507_3, 1.479_658_248_405_658_6, 1.619_773_400_224_692_8, 1.636_003_687_418_558_8, 1.790_923_855_833_222_1, 1.808_869_087_257_869_4, 1.980_158_617_833_586_4] }) )
        retVal.append( (" 6 Taylor MOS G: 0.791400", { let t = AKTuningTable(); _ = t.momentOfSymmetry(generator: 0.791_400, level: 5, murchana: 0 ); return t.masterSet }) )
        retVal.append( (" 5 Taylor MOS G: 0.78207964", { let t = AKTuningTable(); _ = t.momentOfSymmetry(generator: 0.782_079_64, level: 5, murchana: 0 ); return t.masterSet }) )
        retVal.append( (" 5 Taylor MOS G: 0.618033", { let t = AKTuningTable(); _ = t.momentOfSymmetry(generator: 0.618_033, level: 4, murchana: 0 ); return t.masterSet }) )
        retVal.append( (" 5 Taylor MOS G: 0.232587", { let t = AKTuningTable(); _ = t.momentOfSymmetry(generator: 0.232_587, level: 5, murchana: 0 ); return t.masterSet }) )
        retVal.append( ("12 Taylor MOS G: 0.5757381", { let t = AKTuningTable(); _ = t.momentOfSymmetry(generator: 0.575_738_1, level: 6, murchana: 0 ); return t.masterSet }) )
        retVal.append( ("27 Taylor Pasadena JI 27", { let s: [Double] = [ 1.0 / 1, 81 / 80, 17 / 16, 16 / 15, 10 / 9, 9 / 8, 8 / 7, 7 / 6, 19 / 16, 6 / 5, 11 / 9, 5 / 4, 9 / 7, 21 / 16, 4 / 3, 11 / 8, 7 / 5, 3 / 2, 11 / 7, 8 / 5, 5 / 3, 13 / 8, 27 / 16, 7 / 4, 9 / 5, 11 / 6, 15 / 8 ]; return s }) )

        // Harry Partch: PARTCH_43.scl Harry Partch's 43-tone pure scale
        retVal.append( ("43 Partch", { let s: [Double] = [1/1, 81/80, 33/32, 21/20, 16/15, 12/11, 11/10, 10/9, 9/8, 8/7, 7/6, 32/27, 6/5, 11/9, 5/4, 14/11, 9/7, 21/16, 4/3, 27/20, 11/8, 7/5, 10/7, 16/11, 40/27, 3/2, 32/21, 14/9, 11/7, 8/5, 18/11, 5/3, 27/16, 12/7, 7/4, 16/9, 9/5, 20/11, 11/6, 15/8, 40/21, 64/33, 160/81]; return s } ) )

        // ET
        retVal.append( (" 7 Tone Equal Temperament", { let t = AKTuningTable(); _ = t.equalTemperament(notesPerOctave: 7); return t.masterSet }) )
        retVal.append( ("31 Tone Equal Temperament", { let t = AKTuningTable(); _ = t.equalTemperament(notesPerOctave: 31); return t.masterSet }) )
        retVal.append( ("41 Tone Equal Temperament", { let t = AKTuningTable(); _ = t.equalTemperament(notesPerOctave: 41); return t.masterSet }) )
        retVal.append( ("53 Tone Equal Temperament", { let t = AKTuningTable(); _ = t.equalTemperament(notesPerOctave: 53); return t.masterSet }) )

        return retVal
    }
}
