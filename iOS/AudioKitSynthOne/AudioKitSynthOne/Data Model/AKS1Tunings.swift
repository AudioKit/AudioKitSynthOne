//
//  AKS1Tunings.swift
//  AudioKitSynthOne
//
//  Created by Marcus W. Hobbs on 5/12/18.
//  Copyright © 2018 AudioKit. All rights reserved.
//

import UIKit
import AudioKit

class AKS1Tunings {

    var tuningsDelegate: TuningsPitchWheelViewTuningDidChange?

    public typealias AKS1TuningCallback = () -> Void
    public typealias Frequency = Double

    //TODO: determine encoding, match with local tuning list, add if not there, select row
    public func setTuning(withMasterArray master: [Double]) -> Int? {
        if master.count == 0 { return nil }
        _ = AKPolyphonicNode.tuningTable.tuningTable(fromFrequencies: master)
        tuningsDelegate?.tuningDidChange()
        return tunings.count - 1
    }

    public func resetTuning() -> Int {
        let i = 0
        let tuning = tunings[i]
        tuning.1()
        let f = Conductor.sharedInstance.synth!.getDefault(.frequencyA4)
        Conductor.sharedInstance.synth!.setSynthParameter(.frequencyA4, f)
        tuningsDelegate?.tuningDidChange()
        return i
    }

    public func randomTuning() -> Int {
        let ri = Int(arc4random() % UInt32(tunings.count))
        let tuning = tunings[ri]
        tuning.1()
        tuningsDelegate?.tuningDidChange()
        return ri
    }

    private static let tuningHelper = { (_ input: [Frequency]) -> Void in
        _ = AKPolyphonicNode.tuningTable.tuningTable(fromFrequencies: input)
    }

    public let tunings: [(String, AKS1TuningCallback)] = [

        ("12 Tone Equal Temperament (default)", { _ = AKPolyphonicNode.tuningTable.defaultTuning() }),
        (" 7 Tone Equal Temperament", { _ = AKPolyphonicNode.tuningTable.equalTemperament(notesPerOctave: 7) }),
        //        ("13 Tone Equal Temperament", { _ = AKPolyphonicNode.tuningTable.equalTemperament(notesPerOctave: 13) } ),
        //        ("15 Tone Equal Temperament", { _ = AKPolyphonicNode.tuningTable.equalTemperament(notesPerOctave: 15) } ),
        //        ("16 Tone Equal Temperament", { _ = AKPolyphonicNode.tuningTable.equalTemperament(notesPerOctave: 16) } ),
        //        ("17 Tone Equal Temperament", { _ = AKPolyphonicNode.tuningTable.equalTemperament(notesPerOctave: 17) } ),
        //        ("19 Tone Equal Temperament", { _ = AKPolyphonicNode.tuningTable.equalTemperament(notesPerOctave: 19) } ),
        //        ("22 Tone Equal Temperament", { _ = AKPolyphonicNode.tuningTable.equalTemperament(notesPerOctave: 22) } ),
        ("31 Tone Equal Temperament", { _ = AKPolyphonicNode.tuningTable.equalTemperament(notesPerOctave: 31) }),
        ("41 Tone Equal Temperament", { _ = AKPolyphonicNode.tuningTable.equalTemperament(notesPerOctave: 41) }),

        ("12 Chain of pure fifths", { tuningHelper([1, 3, 9, 27, 81, 243, 729, 2_187, 6_561, 19_683, 59_049, 177_147] ) }),
        //        (" 2 Harmonic", { tuningHelper(harmonicSeries( 2) ) } ),
        //        (" 2 Subharmonic", { tuningHelper(subHarmonicSeries( 2) ) } ),
        (" 2 Harmonic+Sub", { tuningHelper( harmonicSubharmonicSeries(2) ) }),
        (" 3 Harmonic+Sub", { tuningHelper( harmonicSubharmonicSeries(3) ) }),
        (" 4 Harmonic+Sub", { tuningHelper( harmonicSubharmonicSeries(4) ) }),
        //        (" 5 Harmonic+Sub", { tuningHelper( harmonicSubharmonicSeries(5) ) } ),

        (" 3 Harmonic", { tuningHelper(harmonicSeries( 3) ) }),
        (" 4 Harmonic", { tuningHelper(harmonicSeries( 4) ) }),
        (" 5 Harmonic", { tuningHelper(harmonicSeries( 5) ) }),
        //        (" 6 Harmonic", { tuningHelper(harmonicSeries( 6) ) } ),
        //        (" 7 Harmonic", { tuningHelper(harmonicSeries( 7) ) } ),
        //        (" 9 Harmonic", { tuningHelper(harmonicSeries( 9) ) } ),
        ("12 Harmonic", { tuningHelper(harmonicSeries(12) ) }),

        (" 3 Subharmonic", { tuningHelper(subHarmonicSeries( 3) ) }),
        (" 4 Subharmonic", { tuningHelper(subHarmonicSeries( 4) ) }),
        (" 5 Subharmonic", { tuningHelper(subHarmonicSeries( 5) ) }),
        //        (" 6 Subharmonic", { tuningHelper(subHarmonicSeries( 6) ) } ),
        //        (" 7 Subharmonic", { tuningHelper(subHarmonicSeries( 7) ) } ),
        //        ("16 Subharmonic", { tuningHelper(subHarmonicSeries(16) ) } ),

        /// Scales designed by Erv Wilson.  See http://anaphoria.com/genus.pdf
        (" 6 Wilson Hexany(1, 3, 5, 7)", { tuningHelper(AKS1Tunings.hexany( [1, 3, 5, 7] ) ) }),
        (" 6 Wilson Hexany(1, 3, 5, 45)", { tuningHelper(AKS1Tunings.hexany( [1, 3, 5, 45] ) ) }),
        (" 6 Wilson Hexany(1, 3, 5, 9)", { tuningHelper(AKS1Tunings.hexany( [1, 3, 5, 9] ) ) }),
        (" 6 Wilson Hexany(1, 3, 5, 15)", { tuningHelper(AKS1Tunings.hexany( [1, 3, 5, 15] ) ) }),
        (" 6 Wilson Hexany(1, 3, 5, 81)", { tuningHelper(AKS1Tunings.hexany( [1, 3, 5, 81] ) ) }),
        ("10 Wilson Dekany(1, 3, 5, 9, 81)", { tuningHelper(AKS1Tunings.dekany( [1, 3, 5, 9, 81] ) ) }),
        (" 6 Wilson Hexany(1, 3, 5, 121)", { tuningHelper(AKS1Tunings.hexany( [1, 3, 5, 121] ) ) }),
        (" 6 Wilson Hexany(1, 15, 45, 75)", { tuningHelper(AKS1Tunings.hexany( [1, 15, 45, 75] ) ) }),
        (" 6 Wilson Hexany(1, 17, 19, 23)", { tuningHelper(AKS1Tunings.hexany( [1, 17, 19, 23] ) ) }),
        (" 6 Wilson Hexany(1, 45, 135, 225)", { tuningHelper(AKS1Tunings.hexany( [1, 45, 135, 225] ) ) }),
        (" 6 Wilson Hexany(3, 2.111, 5.111, 8.111)", { tuningHelper(AKS1Tunings.hexany( [3, 2.111, 5.111, 8.111] ) ) }),
        (" 6 Wilson Hexany(3, 1.346, 4.346, 7.346)", { tuningHelper(AKS1Tunings.hexany( [3, 1.346, 4.346, 7.346] ) ) }),
        (" 6 Wilson Hexany(3, 5, 7, 9)", { tuningHelper(AKS1Tunings.hexany( [3, 5, 7, 9] ) ) }),
        (" 6 Wilson Hexany(3, 5, 15, 19)", { tuningHelper(AKS1Tunings.hexany( [3, 5, 15, 19] ) ) }),
        (" 6 Wilson Hexany(5, 7, 21, 35)", { tuningHelper(AKS1Tunings.hexany( [5, 7, 21, 35] ) ) }),
        (" 7 Wilson Highland Bagpipes", { _ = AKPolyphonicNode.tuningTable.presetHighlandBagPipes() }),
        (" 7 Wilson MOS G:0.2641", { _ = AKPolyphonicNode.tuningTable.momentOfSymmetry(generator: 0.264_1, level: 5, murchana: 0) }),
        (" 9 Wilson MOS G:0.238186", { _ = AKPolyphonicNode.tuningTable.momentOfSymmetry(generator: 0.238_186, level: 6, murchana: 0) }),
        ("10 Wilson MOS G:0.292", { _ = AKPolyphonicNode.tuningTable.momentOfSymmetry(generator: 0.292, level: 6, murchana: 0) }),
        (" 7 Wilson MOS G:0.4057", { _ = AKPolyphonicNode.tuningTable.momentOfSymmetry(generator: 0.405_7, level: 5, murchana: 0) }),
        (" 7 Wilson MOS G:0.415226", { _ = AKPolyphonicNode.tuningTable.momentOfSymmetry(generator: 0.415_226, level: 5, murchana: 0) }),
        (" 7 Wilson MOS G:0.436385", { _ = AKPolyphonicNode.tuningTable.momentOfSymmetry(generator: 0.436_385, level: 5, murchana: 0) }),
        ("22 Wilson Evangelina", { tuningHelper( [1 / 1, 135 / 128, 13 / 12, 10 / 9, 9 / 8, 7 / 6, 11 / 9, 5 / 4, 81 / 64, 4 / 3, 11 / 8, 45 / 32, 17 / 12, 3 / 2, 19 / 12, 13 / 8, 5 / 3, 27 / 16, 7 / 4, 11 / 6, 15 / 8, 243 / 128] ) }),
        //        (" 7 Wilson North Indian:Kalyan", {_ = AKPolyphonicNode.tuningTable.presetPersian17NorthIndian01Kalyan() } ),
        //        (" 7 Wilson North Indian:Bilawal", {_ = AKPolyphonicNode.tuningTable.presetPersian17NorthIndian02Bilawal() } ),
        //        (" 7 Wilson North Indian:Khamaj", {_ = AKPolyphonicNode.tuningTable.presetPersian17NorthIndian03Khamaj() } ),
        //        (" 7 Wilson North Indian:KafiOld", {_ = AKPolyphonicNode.tuningTable.presetPersian17NorthIndian04KafiOld() } ),
        (" 7 Wilson North Indian:Kafi", { _ = AKPolyphonicNode.tuningTable.presetPersian17NorthIndian05Kafi() }),
        //        (" 7 Wilson North Indian:Asawari", {_ = AKPolyphonicNode.tuningTable.presetPersian17NorthIndian06Asawari() } ),
        (" 7 Wilson North Indian:Bhairavi", { _ = AKPolyphonicNode.tuningTable.presetPersian17NorthIndian07Bhairavi() }),
        (" 7 Wilson North Indian:Bhairav", { _ = AKPolyphonicNode.tuningTable.presetPersian17NorthIndian15Bhairav() }),
        (" 7 Wilson North Indian:Marwa", { _ = AKPolyphonicNode.tuningTable.presetPersian17NorthIndian08Marwa() }),
        (" 7 Wilson North Indian:Purvi", { _ = AKPolyphonicNode.tuningTable.presetPersian17NorthIndian09Purvi() }),
        //        (" 7 Wilson North Indian:Lalit2", {_ = AKPolyphonicNode.tuningTable.presetPersian17NorthIndian10Lalit2() } ),
        (" 7 Wilson North Indian:Todi", { _ = AKPolyphonicNode.tuningTable.presetPersian17NorthIndian11Todi() }),
        //        (" 7 Wilson North Indian:Lalit", {_ = AKPolyphonicNode.tuningTable.presetPersian17NorthIndian12Lalit() } ),
        //        (" 7 Wilson North Indian:NoName", {_ = AKPolyphonicNode.tuningTable.presetPersian17NorthIndian13NoName() } ),
        //        (" 7 Wilson North Indian:AnandBhairav", {_ = AKPolyphonicNode.tuningTable.presetPersian17NorthIndian14AnandBhairav() } ),
        (" 7 Wilson North Indian:Bhairav", { _ = AKPolyphonicNode.tuningTable.presetPersian17NorthIndian15Bhairav() }),
        //        (" 7 Wilson North Indian:JogiyaTodi", {_ = AKPolyphonicNode.tuningTable.presetPersian17NorthIndian16JogiyaTodi() } ),
        (" 7 Wilson North Indian:Madhubanti", { _ = AKPolyphonicNode.tuningTable.presetPersian17NorthIndian17Madhubanti() }),
        //        (" 7 Wilson North Indian:NatBhairav", {_ = AKPolyphonicNode.tuningTable.presetPersian17NorthIndian18NatBhairav() } ),
        (" 7 Wilson North Indian:AhirBhairav", { _ = AKPolyphonicNode.tuningTable.presetPersian17NorthIndian19AhirBhairav() }),
        (" 7 Wilson North Indian:ChandraKanada", { _ = AKPolyphonicNode.tuningTable.presetPersian17NorthIndian20ChandraKanada() }),
        (" 7 Wilson North Indian:BasantMukhair", { _ = AKPolyphonicNode.tuningTable.presetPersian17NorthIndian21BasantMukhari() }),
        (" 7 Wilson North Indian:Champakali", { _ = AKPolyphonicNode.tuningTable.presetPersian17NorthIndian22Champakali() }),
        (" 7 Wilson North Indian:Patdeep", { _ = AKPolyphonicNode.tuningTable.presetPersian17NorthIndian23Patdeep() }),
        (" 7 Wilson North Indian:MohanKauns", { _ = AKPolyphonicNode.tuningTable.presetPersian17NorthIndian24MohanKauns() }),
        //        (" 7 Wilson North Indian:Parameswari", {_ = AKPolyphonicNode.tuningTable.presetPersian17NorthIndian25Parameswari() } ),
        ("17 Wilson North Indian:17", { _ = AKPolyphonicNode.tuningTable.presetPersian17NorthIndian00_17() }),

        /// Scales designed by Jose Garcia
        ("22 Garcia: Wilson 7-limit marimba", { tuningHelper( [1 / 1, 28 / 27, 16 / 15, 10 / 9, 9 / 8, 7 / 6, 6 / 5, 5 / 4, 35 / 27, 4 / 3, 27 / 20, 45 / 32, 35 / 24, 3 / 2, 14 / 9, 8 / 5, 5 / 3, 27 / 16, 7 / 4, 9 / 5, 15 / 8, 35 / 18] ) }),
        ("29 Garcia: linear 15/13-52/45 alternating", { tuningHelper( [1 / 1, 40 / 39, 27 / 26, 16 / 15, 128 / 117, 9 / 8, 15 / 13, 32 / 27, 6 / 5, 16 / 13, 81 / 64, 135 / 104, 4 / 3, 160 / 117, 18 / 13, 64 / 45, 512 / 351, 3 / 2, 20 / 13, 81 / 52, 8 / 5, 64 / 39, 27 / 16, 45 / 26, 16 / 9, 9 / 5, 24 / 13, 405 / 208] ) }),

        /// scales designed by Kraig Grady
        (" 5 Grady: S 7-limit Pentatonic", { tuningHelper( [1 / 1, 7 / 6, 4 / 3, 3 / 2, 7 / 4] ) }),
        (" 5 Grady: S Pentatonic 11-limit Scale 1", { tuningHelper( [1 / 1, 9 / 8, 11 / 8, 3 / 2, 7 / 4] ) }),
        (" 5 Grady: S Pentatonic 11-limit Scale 2", { tuningHelper( [1 / 1, 5 / 4, 11 / 8, 3 / 2, 7 / 4] ) }),
        (" 7 Grady: S Centaur 7-limit Minor", { tuningHelper( [1 / 1, 9 / 8, 7 / 6, 4 / 3, 3 / 2, 14 / 9, 7 / 4] ) }),
        (" 7 Grady: S Centaur Soft Major on E", { tuningHelper( [1 / 1, 28 / 25, 56 / 46, 4 / 3, 3 / 2, 42 / 25, 28 / 15] ) }),
        //        ("10 Grady: A Centaur 10-Tone", { tuningHelper( [1/1, 21/20, 9/8, 7/6, 4/3, 7/5, 3/2, 5/3, 7/4, 15/8] ) } ),
        ("12 Grady: A Centaur", { tuningHelper( [1 / 1, 21 / 20, 9 / 8, 7 / 6, 5 / 4, 4 / 3, 7 / 5, 3 / 2, 14 / 9, 5 / 3, 7 / 4, 15 / 8] ) }),
        //        ("14 Grady: 14-tone 7-limit", { tuningHelper( [1/1, 21/20, 9/8, 7/6, 5/4, 21/16, 4/3, 7/5, 3/2, 63/40, 27/16, 7/4, 15/8, 63/32] ) } ),
        ("14 Grady: Double Dekany 14-tone", { tuningHelper( [1 / 1, 35 / 32, 9 / 8, 7 / 6, 5 / 4, 21 / 16, 45 / 32, 35 / 24, 3 / 2, 105 / 64, 5 / 3, 7 / 4, 15 / 8, 63 / 32] ) }),
        ("19 Grady: A-Narushima 19-tone 7-limit", { tuningHelper( [1 / 1, 21 / 20, 35 / 32, 9 / 8, 7 / 6, 6 / 5, 5 / 4, 21 / 16, 4 / 3, 7 / 5, 35 / 24, 3 / 2, 14 / 9, 8 / 5, 5 / 3, 7 / 4, 9 / 5, 15 / 8, 63 / 32] ) }),
        ("12 Grady: Sisiutl 12-tone", { tuningHelper( [ 1 / 1, 28 / 27, 9 / 8, 7 / 6, 14 / 11, 4 / 3, 11 / 8, 3 / 2, 14 / 9, 56 / 33, 7 / 4, 11 / 6 ] ) }),
        ("14 Grady: Wilson pre-Sisiutl 17", { tuningHelper( [ 1 / 1, 28 / 27, 9 / 8, 7 / 6, 14 / 11, 4 / 3, 11 / 8, 3 / 2, 14 / 9, 3 / 2, 14 / 9, 56 / 33, 7 / 4, 11 / 6 ] ) }),
        //        ("12 Grady: Dakota Monarda 17-limit", {tuningHelper( [ 1/1, 17/16, 10/9, 7/6, 5/4, 4/3, 17/12, 3/2, 14/9, 5/3, 7/4, 17/9] ) } ),
        ("12 Grady: Beebalm 7-limit", { tuningHelper( [ 1 / 1, 17 / 16, 9 / 8, 7 / 6, 5 / 4, 4 / 3, 17 / 12, 3 / 2, 14 / 9, 5 / 3, 16 / 9, 17 / 9] ) }),
        ("12 Grady: Schulter Zeta Centauri 12 tone", { tuningHelper( [ 1 / 1, 13 / 12, 9 / 8, 7 / 6, 11 / 9, 4 / 3, 13 / 9, 3 / 2, 14 / 9, 13 / 8, 7 / 4, 11 / 6] ) }),
        ("10 Grady: Shulter Shur", { tuningHelper( [ 1 / 1, 27 / 26, 9 / 8, 27 / 22, 4 / 3, 18 / 13, 3 / 2, 18 / 11, 16 / 9, 24 / 13] ) }),
        ("17 Grady: Poole 17", { tuningHelper( [ 1 / 1, 33 / 32, 13 / 12, 9 / 8, 7 / 6, 11 / 9, 14 / 11, 4 / 3, 11 / 8, 13 / 9, 3 / 2, 14 / 9, 44 / 27, 27 / 16, 7 / 4, 11 / 6, 21 / 11] ) }),
        ("10 Grady: 11-limit Helix Song", { tuningHelper( [ 1 / 1, 9 / 8, 7 / 6, 5 / 4, 4 / 3, 11 / 8, 3 / 2, 5 / 3, 7 / 4, 11 / 6] ) }),
        //        ("14 Grady: 17-limit Helix Song", {tuningHelper( [ 1/1, 13/12, 9/8, 7/6, 5/4, 4/3, 11/8, 17/12, 3/2, 13/8, 5/3, 7/4, 11/6, 15/16] ) } ),
        ("12 Grady: Gary David Double 1-3-5-7 Hexany 12-Tone", { tuningHelper( [ 1 / 1, 16 / 15, 35 / 32, 7 / 6, 5 / 4, 4 / 3, 7 / 5, 35 / 24, 8 / 5, 5 / 3, 7 / 4, 28 / 15] ) }),
        ("12 Grady: Wilson Double Hexany+ 12 tone", { tuningHelper( [ 1 / 1, 49 / 48, 8 / 7, 7 / 6, 5 / 4, 4 / 3, 10 / 7, 35 / 24, 80 / 49, 5 / 3, 7 / 4, 40 / 21] ) }),
        ("12 Grady: Wilson Triple Hexany +", { tuningHelper( [ 1 / 1, 15 / 14, 9 / 8, 7 / 6, 5 / 4, 21 / 16, 10 / 7, 3 / 2, 45 / 28, 5 / 3, 7 / 4, 15 / 8] ) }),
        ("12 Grady: Wilson Super 7", { tuningHelper( [ 1 / 1, 35 / 32, 8 / 7, 5 / 4, 245 / 192, 10 / 7, 35 / 24, 3 / 2, 49 / 32, 12 / 7, 7 / 4, 245 / 128] ) }),
        ("12 Grady: Gary David Dual Harmonic Subharmonic", { tuningHelper( [ 1 / 1, 16 / 15, 9 / 8, 6 / 5, 9 / 7, 4 / 3, 7 / 5, 3 / 2, 8 / 5, 12 / 7, 9 / 5, 28 / 15] ) }),
        ("12 Grady: Wilson/David Enharmonics", { tuningHelper( [ 1 / 1, 28 / 27, 9 / 8, 7 / 6, 6 / 5, 4 / 3, 35 / 24, 3 / 2, 14 / 9, 8 / 5, 7 / 4, 25 / 18] ) }),
        ("Grady: ****Wilson Meta Meantone (might need to check if it seems off)", { tuningHelper( [ 1 / 1, 67 / 64, 558 / 512, 9 / 8, 75 / 64, 39 / 32, 5 / 4, 167 / 128, 87 / 64, 45 / 32, 187 / 128, 3 / 2, 25 / 16, 417 / 256, 27 / 16, 7 / 4, 233 / 128, 15 / 8, 125 / 64] ) }),
        (" 9 Grady: Wilson First Pelog", { tuningHelper( [ 1 / 1, 16 / 15, 64 / 55, 5 / 4, 4 / 3, 16 / 11, 8 / 5, 128 / 75, 20 / 11] ) }),
        (" 9 Grady: Wilson Meta-Pelog 1", { tuningHelper( [ 1 / 1, 571 / 512, 153 / 128, 41 / 32, 4 / 3, 11 / 8, 209 / 128, 7 / 4, 15 / 8] ) }),
        (" 9 Grady: Wilson Meta-Pelog 2", { tuningHelper( [ 1 / 1, 9 / 8, 19 / 16, 41 / 32, 11 / 8, 3 / 2, 13 / 8, 7 / 4, 15 / 8] ) }),
        ("10 Grady: Wilson Meta-Ptolemy 10", { tuningHelper( [ 1 / 1, 33 / 32, 9 / 8, 73 / 64, 5 / 4, 11 / 8, 3 / 2, 49 / 32, 27 / 16, 15 / 8] ) }),

        // Scales designed by Marcus Hobbs using Wilsonic
        (" 6 Hobbs Hexany(9, 25, 49, 81)", { tuningHelper(AKS1Tunings.hexany( [9, 25, 49, 81] ) ) }),
        //        (" 6 Hobbs Hexany(1,  9, 25, 49)", { tuningHelper(AKS1Tunings.hexany( [1, 9, 25, 49] ) ) } ),
        (" 5 Hobbs Recurrence Relation", { _ = AKPolyphonicNode.tuningTable.tuningTable(fromFrequencies: [1, 19, 5, 3, 15]) }),
        //        (" 5 Hobbs Recurrence Relation", { _ = AKPolyphonicNode.tuningTable.tuningTable(fromFrequencies: [35, 20, 46, 26, 15]) }),
        //        (" 5 Hobbs Recurrence Relation", { _ = AKPolyphonicNode.tuningTable.tuningTable(fromFrequencies: [1, 37, 21, 49, 28]) }),
        (" 5 Hobbs Recurrence Relation", { _ = AKPolyphonicNode.tuningTable.tuningTable(fromFrequencies: [35, 74, 23, 51, 61]) }),
        (" 6 Hobbs Recurrence Relation", { _ = AKPolyphonicNode.tuningTable.tuningTable(fromFrequencies: [74, 150, 85, 106, 120, 61]) }),
        (" 6 Hobbs Recurrence Relation", { _ = AKPolyphonicNode.tuningTable.tuningTable(fromFrequencies: [1, 9, 5, 23, 48, 7]) }),
        (" 6 Hobbs Recurrence Relation", { _ = AKPolyphonicNode.tuningTable.tuningTable(fromFrequencies: [1, 9, 21, 3, 25, 15]) }),
        (" 6 Hobbs Recurrence Relation", { _ = AKPolyphonicNode.tuningTable.tuningTable(fromFrequencies: [1, 75, 19, 5, 3, 15]) }),
        (" 7 Hobbs Recurrence Relation", { _ = AKPolyphonicNode.tuningTable.tuningTable(fromFrequencies: [1, 17, 10, 47, 3, 13, 7]) }),
        (" 7 Hobbs Recurrence Relation", { _ = AKPolyphonicNode.tuningTable.tuningTable(fromFrequencies: [1, 9, 5, 21, 3, 27, 7]) }),
        (" 7 Hobbs Recurrence Relation", { _ = AKPolyphonicNode.tuningTable.tuningTable(fromFrequencies: [1, 9, 21, 3, 25, 15, 31]) }),
        (" 7 Hobbs Recurrence Relation", { _ = AKPolyphonicNode.tuningTable.tuningTable(fromFrequencies: [1, 75, 19, 5, 94, 3, 15]) }),
        (" 7 Hobbs Recurrence Relation", { _ = AKPolyphonicNode.tuningTable.tuningTable(fromFrequencies: [9, 40, 21, 25, 52, 15, 31]) }),
        (" 7 Hobbs Recurrence Relation", { _ = AKPolyphonicNode.tuningTable.tuningTable(fromFrequencies: [1, 18, 5, 21, 3, 25, 15]) }),
        ("12 Hobbs Recurrence Relation", { _ = AKPolyphonicNode.tuningTable.tuningTable(fromFrequencies: [1, 65, 9, 37, 151, 21, 86, 12, 49, 200, 28, 114]) }),

        /// scales designed by Stephen Taylor
        (" 6 SJT MOS G: 0.855088", { _ = AKPolyphonicNode.tuningTable.momentOfSymmetry(generator: 0.855_088, level: 6, murchana: 0 ) }),
        //("13 SJT MOS G: 0.855088", {_ = AKPolyphonicNode.tuningTable.momentOfSymmetry(generator: 0.855088, level: 10, murchana: 0 ) } ),
        (" 6 SJT MOS G: 0.791400", { _ = AKPolyphonicNode.tuningTable.momentOfSymmetry(generator: 0.791_400, level: 5, murchana: 0 ) }),
        (" 5 SJT MOS G: 0.78207964", { _ = AKPolyphonicNode.tuningTable.momentOfSymmetry(generator: 0.782_079_64, level: 5, murchana: 0 ) }),
        (" 5 SJT MOS G: 0.618033", { _ = AKPolyphonicNode.tuningTable.momentOfSymmetry(generator: 0.618_033, level: 4, murchana: 0 ) }),
        (" 5 SJT MOS G: 0.232587", { _ = AKPolyphonicNode.tuningTable.momentOfSymmetry(generator: 0.232_587, level: 5, murchana: 0 ) }),
        ("27 Taylor Pasadena JI 27", { tuningHelper( [ 1 / 1, 81 / 80, 17 / 16, 16 / 15, 10 / 9, 9 / 8, 8 / 7, 7 / 6, 19 / 16, 6 / 5, 11 / 9, 5 / 4, 9 / 7, 21 / 16, 4 / 3, 11 / 8, 7 / 5, 3 / 2, 11 / 7, 8 / 5, 5 / 3, 13 / 8, 27 / 16, 7 / 4, 9 / 5, 11 / 6, 15 / 8 ] ) }),

        (" - Tuning From Preset", { _ = 0 })
    ]
}

// **********************************************************
// MARK: - Helpers
// **********************************************************

//TODO: change to extension of AKTuningTable
extension AKS1Tunings {

    /// return tuple of ([master set of frequencies], [master set of pitches]) both arrays of length npo, normalized by middleCFrequency
    class func masterFrequenciesFromGlobalTuningTable() -> ([Frequency], [Frequency]) {
        // no access to the master set so recreate it from midi note numbers [60, 60 + npo]
        var mf: [Frequency] = [1]
        var mp: [Frequency] = [0]
        let mc = AKPolyphonicNode.tuningTable.middleCFrequency
        if mc < 1 { return (mf, mp) }
        let npo = AKPolyphonicNode.tuningTable.npo
        if npo < 1 { return (mf, mp) }
        mf.removeAll()
        mp.removeAll()
        for i: Int in 0..<npo {
            let nn = Int(AKPolyphonicNode.tuningTable.middleCNoteNumber) + i
            let f = AKPolyphonicNode.tuningTable.frequency(forNoteNumber: MIDINoteNumber(nn)) / mc
            mf.append(f)
            let p = log2(f)
            mp.append(p)
        }
        return (mf, mp)
    }

    // Harmonic Series from n...2n
    class func harmonicSeries( _ root: Int ) -> [Frequency] {
        var retVal: [Frequency] = [1] // octave-based tuning with default root 1/1
        if root < 1 { return retVal }
        let octave = 2 * root
        for n in root..<octave where n != root {
            let f = Frequency(n) / Frequency(root)
            retVal.append(f)
        }
        return retVal
    }

    // Subharmonic series from n...2n
    class func subHarmonicSeries( _ root: Int ) -> [Frequency] {
        var retVal: [Frequency] = [1] // octave-based tuning with default root 1/1
        if root < 1 { return retVal }
        let octave = 2 * root
        for n in root..<octave where n != root {
            let f = Frequency(root) / Frequency(n)
            retVal.append(f)
        }
        return retVal
    }

    // Combine harmonic and subharmonic series from n...2n
    class func harmonicSubharmonicSeries( _ root: Int) -> [Frequency] {
        var retVal: [Frequency] = [1] // octave-based tuning with default root 1/1
        if root < 1 { return retVal }
        let harmonic = harmonicSeries(root)
        let subHarmonic = subHarmonicSeries(root)
        retVal = Array( Set(harmonic + subHarmonic) )
        retVal.sort()
        return retVal
    }

    //Combination Product Sets/Binomial Theorem
    // 4 choose 2
    // swiftlint:disable identifier_name
    class func hexany(_ masterSet: [Frequency]) -> [Frequency] {
        let A = masterSet[0]
        let B = masterSet[1]
        let C = masterSet[2]
        let D = masterSet[3]
        return [A * B, A * C, A * D, B * C, B * D, C * D]
    }

    // 5 choose 2
    class func dekany(_ masterSet: [Frequency]) -> [Frequency] {
        let A = masterSet[0]
        let B = masterSet[1]
        let C = masterSet[2]
        let D = masterSet[3]
        let E = masterSet[4]
        return [A * B, A * C, A * D, A * E, B * C, B * D, B * E, C * D, C * E, D * E]
    }

    // 6 choose 2
    class func pentadekany(_ masterSet: [Frequency]) -> [Frequency] {
        let A = masterSet[0]
        let B = masterSet[1]
        let C = masterSet[2]
        let D = masterSet[3]
        let E = masterSet[4]
        let F = masterSet[5]
        return [A * B, A * C, A * D, A * E, A * F, B * C, B * D, B * E, B * F, C * D, C * E, C * F, D * E, D * F, E * F]
    }

}
