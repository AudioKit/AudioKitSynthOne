//
//  Tunings+DefaultTunings.swift
//  AudioKitSynthOne
//
//  Created by Marcus W. Hobbs on 12/17/18.
//  Copyright © 2018 AudioKit. All rights reserved.
//

import Foundation

extension Tunings {

    internal static func defaultTunings() -> [(String, S1TuningCallback)] {
        var retVal = [(String, S1TuningCallback)]()

        retVal.append( ("Chain of pure fifths", { return [1, 3, 9, 27, 81, 243, 729, 2_187, 6_561, 19_683, 59_049, 177_147] }) )

        // See http://anaphoria.com/harm&Subharm.pdf
        retVal.append( ("Harmonic Series: Dyad", { return harmonicSeries(2) }) )
        retVal.append( ("Subharmonic Series: Dyad", { return subHarmonicSeries(2) }) )
        retVal.append( ("Harmonic+Subharmonic Series: Dyad", { return harmonicSubharmonicSeries(2) }) )
        retVal.append( ("Harmonic Series: Triad", { return harmonicSeries(3) }) )
        retVal.append( ("Subharmonic Series: Triad", { return subHarmonicSeries(3) }) )
        retVal.append( ("Harmonic+Subharmonic Series: Triad", { return harmonicSubharmonicSeries(3) }) )
        retVal.append( ("Harmonic Series: Tetrad", { return harmonicSeries(4) }) )
        retVal.append( ("Subharmonic Series: Tetrad", { return subHarmonicSeries(4) }) )
        retVal.append( ("Harmonic+Subharmonic Series: Tetrad", { return harmonicSubharmonicSeries(4) }) )
        retVal.append( ("Harmonic Series: Pentad", { return harmonicSeries(5) }) )
        retVal.append( ("Subharmonic Series: Pentad", { return subHarmonicSeries(5) }) )
        retVal.append( ("Harmonic Series", { return harmonicSeries(12) }) )
        retVal.append( ("Harmonic Series", { return harmonicSeries(16) }) )
        retVal.append( ("Subharmonic Series", { return subHarmonicSeries(16) }) )
        retVal.append( ("Harmonic+Subharmonic Series", { return harmonicSubharmonicSeries(16) }) )

        /// Scales designed by Erv Wilson.  See http://anaphoria.com/genus.pdf
        retVal.append( ("Wilson Hexany(1, 3, 5, 7)", { return Tunings.hexany( [1, 3, 5, 7] ) }) )
        retVal.append( ("Wilson Hexany(1, 3, 5, 45)", { return Tunings.hexany( [1, 3, 5, 45] ) }) )
        retVal.append( ("Wilson Hexany(1, 3, 5, 9)", { return Tunings.hexany( [1, 3, 5, 9] ) }) )
        retVal.append( ("Wilson Hexany(1, 3, 5, 15)", { return Tunings.hexany( [1, 3, 5, 15] ) }) )
        retVal.append( ("Wilson Hexany(1, 3, 5, 81)", { return Tunings.hexany( [1, 3, 5, 81] ) }) )
        retVal.append( ("Wilson Dekany(1, 3, 5, 9, 81)", { return Tunings.dekany( [1, 3, 5, 9, 81] ) }) )
        retVal.append( ("Wilson Hexany(1, 3, 5, 121)", { return Tunings.hexany( [1, 3, 5, 121] ) }) )
        retVal.append( ("Wilson Hexany(1, 15, 45, 75)", { return Tunings.hexany( [1, 15, 45, 75] ) }) )
        retVal.append( ("Wilson Hexany(1, 17, 19, 23)", { return Tunings.hexany( [1, 17, 19, 23] ) }) )
        retVal.append( ("Wilson Hexany(1, 45, 135, 225)", { return Tunings.hexany( [1, 45, 135, 225] ) }) )
        retVal.append( ("Wilson Hexany(3, 5, 7, 9)", { return Tunings.hexany( [3, 5, 7, 9] ) }) )
        retVal.append( ("Wilson Hexany(3, 5, 15, 19)", { return Tunings.hexany( [3, 5, 15, 19] ) }) )
        retVal.append( ("Wilson Diaphonic", { let s: [Double] =  [1 / 1, 27 / 26, 9 / 8, 4 / 3, 18 / 13, 3 / 2, 27 / 16]; return s }) )
        retVal.append( ("Wilson Hexany(3, 5, 15, 27)", { return Tunings.hexany( [3, 5, 15, 27] ) }) )
        retVal.append( ("Wilson Hexany(5, 7, 21, 35)", { return Tunings.hexany( [5, 7, 21, 35] ) }) )
        retVal.append( ("Wilson Highland Bagpipes", { let t = AKTuningTable(); _ = t.presetHighlandBagPipes(); return t.masterSet }) )
        retVal.append( ("Wilson MOS G:0.2641", { let t = AKTuningTable(); _ = t.momentOfSymmetry(generator: 0.264_1, level: 5, murchana: 0); return t.masterSet }) )

        // Wilson: proportional triads in MOS
        retVal.append( ("Wilson MOS G:0.292787", { let t = AKTuningTable(); _ = t.momentOfSymmetry(generator: 0.292_787, level: 6, murchana: 0); return t.masterSet }) )
        retVal.append( ("Wilson MOS G:0.405699", { let t = AKTuningTable(); _ = t.momentOfSymmetry(generator: 0.405_699_700_117_111, level: 5, murchana: 0); return t.masterSet }) )
        retVal.append( ("Wilson MOS G:0.415226", { let t = AKTuningTable(); _ = t.momentOfSymmetry(generator: 0.415_226, level: 5, murchana: 0); return t.masterSet }) )
        retVal.append( ("Wilson MOS G:0.436385", { let t = AKTuningTable(); _ = t.momentOfSymmetry(generator: 0.436_385, level: 5, murchana: 0); return t.masterSet }) )
        retVal.append( ("Wilson MOS G:0.328173", { return [1.0, 1.139_858_796_310_911, 1.152_155_087_458_816_5, 1.164_584_025_542_011_2, 1.177_147_041_496_803_5, 1.189_845_581_695_805_6, 1.202_681_108_114_456_6, 1.215_655_098_499_338_2, 1.228_769_046_538_307_4, 1.242_024_462_032_462_8, 1.255_422_871_069_967_7, 1.431_004_802_679_001_4, 1.446_441_847_815_417_1, 1.462_045_420_948_172_4, 1.477_817_318_507_435_5, 1.493_759_356_302_464, 1.509_873_369_730_661_2, 1.526_161_213_988_883_4, 1.542_624_764_287_028_8, 1.559_265_916_063_926_6, 1.576_086_585_205_560_8, 1.796_516_157_894_184_6, 1.815_896_177_420_180_3, 1.835_485_260_001_455_1, 1.855_285_660_917_525_4, 1.875_299_659_776_866_1, 1.895_529_560_779_353_6, 1.915_977_692_981_552, 1.936_646_410_564_853_8, 1.957_538_093_106_518_3, 1.978_655_145_853_626_8] }) )

        retVal.append( ("Wilson Evangelina", { let s: [Double] =  [1 / 1, 135 / 128, 13 / 12, 10 / 9, 9 / 8, 7 / 6, 11 / 9, 5 / 4, 81 / 64, 4 / 3, 11 / 8, 45 / 32, 17 / 12, 3 / 2, 19 / 12, 13 / 8, 5 / 3, 27 / 16, 7 / 4, 11 / 6, 15 / 8, 243 / 128]; return s }) )
        retVal.append( ("Wilson North Indian:Kafi", { let t = AKTuningTable(); _ = t.presetPersian17NorthIndian05Kafi(); return t.masterSet }) )
        retVal.append( ("Wilson North Indian:Bhairavi", { let t = AKTuningTable(); _ = t.presetPersian17NorthIndian07Bhairavi(); return t.masterSet }) )
        retVal.append( ("Wilson North Indian:Bhairav", { let t = AKTuningTable(); _ = t.presetPersian17NorthIndian15Bhairav(); return t.masterSet }) )
        retVal.append( ("Wilson North Indian:Marwa", { let t = AKTuningTable(); _ = t.presetPersian17NorthIndian08Marwa(); return t.masterSet }) )
        retVal.append( ("Wilson North Indian:Purvi", { let t = AKTuningTable(); _ = t.presetPersian17NorthIndian09Purvi(); return t.masterSet }) )
        retVal.append( ("Wilson North Indian:Todi", { let t = AKTuningTable(); _ = t.presetPersian17NorthIndian11Todi(); return t.masterSet }) )
        retVal.append( ("Wilson North Indian:Bhairav", { let t = AKTuningTable(); _ = t.presetPersian17NorthIndian15Bhairav(); return t.masterSet }) )
        retVal.append( ("Wilson North Indian:Madhubanti", { let t = AKTuningTable(); _ = t.presetPersian17NorthIndian17Madhubanti(); return t.masterSet }) )
        retVal.append( ("Wilson North Indian:AhirBhairav", { let t = AKTuningTable(); _ = t.presetPersian17NorthIndian19AhirBhairav(); return t.masterSet }) )
        retVal.append( ("Wilson North Indian:ChandraKanada", { let t = AKTuningTable(); _ = t.presetPersian17NorthIndian20ChandraKanada(); return t.masterSet }) )
        retVal.append( ("Wilson North Indian:BasantMukhair", { let t = AKTuningTable(); _ = t.presetPersian17NorthIndian21BasantMukhari(); return t.masterSet }) )
        retVal.append( ("Wilson North Indian:Champakali", { let t = AKTuningTable(); _ = t.presetPersian17NorthIndian22Champakali(); return t.masterSet }) )
        retVal.append( ("Wilson North Indian:Patdeep", { let t = AKTuningTable(); _ = t.presetPersian17NorthIndian23Patdeep(); return t.masterSet }) )
        retVal.append( ("Wilson North Indian:MohanKauns", { let t = AKTuningTable(); _ = t.presetPersian17NorthIndian24MohanKauns(); return t.masterSet }) )
        retVal.append( ("Wilson North Indian:17", { let t = AKTuningTable(); _ = t.presetPersian17NorthIndian00_17(); return t.masterSet }) )

        /// Scales designed by Jose Garcia
        retVal.append( ("Garcia: Meta Mavila (37-50-67-91)", { let s: [Double] =  [ 1/1, 1027/1024, 67/64, 559/512, 37/32, 153/128,
                                                                                    2539/2048, 167/128, 1389/1024, 91/64, 189/128, 25/16, 415/256, 225/128, 937/512, 31/16]; return s }) )
        retVal.append( ("Garcia: Wilson 7-limit marimba", { let s: [Double] =  [1 / 1, 28 / 27, 16 / 15, 10 / 9, 9 / 8, 7 / 6, 6 / 5, 5 / 4, 35 / 27, 4 / 3, 27 / 20, 45 / 32, 35 / 24, 3 / 2, 14 / 9, 8 / 5, 5 / 3, 27 / 16, 7 / 4, 9 / 5, 15 / 8, 35 / 18]; return s }) )
        retVal.append( ("Garcia: linear 15/13-52/45 alternating", { let s: [Double] =  [1 / 1,  40/39, 27/26, 16/15, 128/117, 9/8, 15/13, 32/27, 6/5, 16/13, 81/64, 135/104, 4/3, 160/117, 18/13, 64/45,  512/351,  3/2, 20/13, 81/52, 8/5,  64/39,  27/16,  45/26,  16/9,  9/5,  24/13,  256/135, 405/208]; return s }) )

        /// scales designed by Kraig Grady
        retVal.append( ("Grady: S 7-limit Pentatonic", { let s: [Double] = [1 / 1, 7 / 6, 4 / 3, 3 / 2, 7 / 4]; return s }) )
        retVal.append( ("Grady: S Pentatonic 11-limit Scale 1", { let s: [Double] = [1 / 1, 9 / 8, 11 / 8, 3 / 2, 7 / 4]; return s }) )
        retVal.append( ("Grady: S Pentatonic 11-limit Scale 2", { let s: [Double] = [1 / 1, 5 / 4, 11 / 8, 3 / 2, 7 / 4]; return s }) )
        retVal.append( ("Grady: S Centaur 7-limit Minor", { let s: [Double] = [1 / 1, 9 / 8, 7 / 6, 4 / 3, 3 / 2, 14 / 9, 7 / 4]; return s }) )
        retVal.append( ("Grady: S Centaur Soft Major on E", { let s: [Double] = [1 / 1, 28 / 25, 56 / 46, 4 / 3, 3 / 2, 42 / 25, 28 / 15]; return s }) )
        retVal.append( ("Grady: A Centaur", { let s: [Double] = [1 / 1, 21 / 20, 9 / 8, 7 / 6, 5 / 4, 4 / 3, 7 / 5, 3 / 2, 14 / 9, 5 / 3, 7 / 4, 15 / 8]; return s }) )
        retVal.append( ("Grady: Double Dekany 14-tone", { let s: [Double] = [1.0 / 1, 35 / 32, 9 / 8, 7 / 6, 5 / 4, 21 / 16, 45 / 32, 35 / 24, 3 / 2, 105 / 64, 5 / 3, 7 / 4, 15 / 8, 63 / 32]; return s }) )
        retVal.append( ("Grady: A-Narushima 19-tone 7-limit", { let s: [Double] =  [1 / 1, 21 / 20, 35 / 32, 9 / 8, 7 / 6, 6 / 5, 5 / 4, 21 / 16, 4 / 3, 7 / 5, 35 / 24, 3 / 2, 14 / 9, 8 / 5, 5 / 3, 7 / 4, 9 / 5, 15 / 8, 63 / 32]; return s }) )
        retVal.append( ("Grady: Sisiutl 12-tone", { let s: [Double] = [ 1 / 1, 28 / 27, 9 / 8, 7 / 6, 14 / 11, 4 / 3, 11 / 8, 3 / 2, 14 / 9, 56 / 33, 7 / 4, 11 / 6]; return s }) )
        retVal.append( ("Grady: Wilson pre-Sisiutl 17", { let s: [Double] = [ 1 / 1, 28 / 27, 9 / 8, 7 / 6, 14 / 11, 4 / 3, 11 / 8, 3 / 2, 14 / 9, 3 / 2, 14 / 9, 56 / 33, 7 / 4, 11 / 6]; return s }) )
        retVal.append( ("Grady: Beebalm 7-limit", { let s: [Double] = [ 1 / 1, 17 / 16, 9 / 8, 7 / 6, 5 / 4, 4 / 3, 17 / 12, 3 / 2, 14 / 9, 5 / 3, 16 / 9, 17 / 9]; return s }) )
        retVal.append( ("Grady: Schulter Zeta Centauri 12 tone", { let s: [Double] = [ 1 / 1, 13 / 12, 9 / 8, 7 / 6, 11 / 9, 4 / 3, 13 / 9, 3 / 2, 14 / 9, 13 / 8, 7 / 4, 11 / 6]; return s }) )
        retVal.append( ("Grady: Schulter Shur", { let s: [Double] = [ 1 / 1, 27 / 26, 9 / 8, 27 / 22, 4 / 3, 18 / 13, 3 / 2, 18 / 11, 16 / 9, 24 / 13]; return s }) )
        retVal.append( ("Grady: Poole 17", { let s: [Double] = [ 1 / 1, 33 / 32, 13 / 12, 9 / 8, 7 / 6, 11 / 9, 14 / 11, 4 / 3, 11 / 8, 13 / 9, 3 / 2, 14 / 9, 44 / 27, 27 / 16, 7 / 4, 11 / 6, 21 / 11]; return s }) )
        retVal.append( ("Grady: 11-limit Helix Song", { let s: [Double] = [ 1 / 1, 9 / 8, 7 / 6, 5 / 4, 4 / 3, 11 / 8, 3 / 2, 5 / 3, 7 / 4, 11 / 6]; return s }) )
        retVal.append( ("David: Double 1-3-5-7 Hexany 12-Tone", { let s: [Double] = [ 1.0 / 1, 16 / 15, 35 / 32, 7 / 6, 5 / 4, 4 / 3, 7 / 5, 35 / 24, 8 / 5, 5 / 3, 7 / 4, 28 / 15]; return s }) )
        retVal.append( ("Wilson Double Hexany+ 12 tone", { let s: [Double] = [ 1 / 1, 49 / 48, 8 / 7, 7 / 6, 5 / 4, 4 / 3, 10 / 7, 35 / 24, 80 / 49, 5 / 3, 7 / 4, 40 / 21]; return s }) )
        retVal.append( ("Grady: Wilson Triple Hexany +", { let s: [Double] = [ 1 / 1, 15 / 14, 9 / 8, 7 / 6, 5 / 4, 21 / 16, 10 / 7, 3 / 2, 45 / 28, 5 / 3, 7 / 4, 15 / 8]; return s }) )
        retVal.append( ("Grady: Wilson Super 7", { let s: [Double] = [ 1 / 1, 35 / 32, 8 / 7, 5 / 4, 245 / 192, 10 / 7, 35 / 24, 3 / 2, 49 / 32, 12 / 7, 7 / 4, 245 / 128]; return s }) )
        retVal.append( ("David: Dual Harmonic Subharmonic", { let s: [Double] = [ 1 / 1, 16 / 15, 9 / 8, 6 / 5, 9 / 7, 4 / 3, 7 / 5, 3 / 2, 8 / 5, 12 / 7, 9 / 5, 28 / 15]; return s }) )
        retVal.append( ("Wilson/David: Enharmonics", { let s: [Double] = [ 1 / 1, 28 / 27, 9 / 8, 7 / 6, 6 / 5, 4 / 3, 35 / 24, 3 / 2, 14 / 9, 8 / 5, 7 / 4, 25 / 18]; return s }) )
        retVal.append( ("Grady: Wilson First Pelog", { let s: [Double] = [ 1 / 1, 16 / 15, 64 / 55, 5 / 4, 4 / 3, 16 / 11, 8 / 5, 128 / 75, 20 / 11]; return s }) )
        retVal.append( ("Grady: Wilson Meta-Pelog 1", { let s: [Double] = [ 1 / 1, 571 / 512, 153 / 128, 41 / 32, 4 / 3, 11 / 8, 209 / 128, 7 / 4, 15 / 8]; return s }) )
        retVal.append( ("Grady: Wilson Meta-Pelog 2", { let s: [Double] = [ 1 / 1, 9 / 8, 19 / 16, 41 / 32, 11 / 8, 3 / 2, 13 / 8, 7 / 4, 15 / 8]; return s }) )
        retVal.append( ("Grady: Wilson Meta-Ptolemy 10", { let s: [Double] =  [ 1 / 1, 33 / 32, 9 / 8, 73 / 64, 5 / 4, 11 / 8, 3 / 2, 49 / 32, 27 / 16, 15 / 8]; return s }) )
        retVal.append( ("Grady: Olympos Staircase", { let s: [Double] = [1/1, 28/27, 9/8, 7/6, 9/7, 4/3, 49/36, 3/2, 14/9, 12/7, 7/4, 49/27]; return s } ) )

        // Scales designed by Marcus Hobbs using Wilsonic
        retVal.append( ("Hobbs MOS G:0.238186", { let t = AKTuningTable(); _ = t.momentOfSymmetry(generator: 0.238_186, level: 6, murchana: 0); return t.masterSet }) )
        retVal.append( ("Hobbs Hexany(9, 25, 49, 81)", { return Tunings.hexany( [9, 25, 49, 81] ) }) )

        //    •    Hexany Fibonacci Triplets (X-3, 3, X, X+3) where X=[3,6]
        retVal.append( ("Hobbs Hexany(3, 2.111, 5.111, 8.111)", { return Tunings.hexany( [3, 2.111, 5.111, 8.111] ) }) )
        retVal.append( ("Hobbs Hexany(3, 1.346, 4.346, 7.346)", { return Tunings.hexany( [3, 1.346, 4.346, 7.346] ) }) )

        //H[n] = H[n-1] + H[n-7], seeds (2,2,2,1,1,1,1) 5: 1,19,5,3,15, 7: 1,75,19,5,47,3,15
        retVal.append( ("Hobbs Recurrence Relation 01", { let s: [Double] = [1, 19, 5, 3, 15]; return s }) )
        retVal.append( ("Hobbs Recurrence Relation 02", { let s: [Double] = [35, 74, 23, 51, 61]; return s }) )
        retVal.append( ("Hobbs Recurrence Relation 03", { let s: [Double] = [74, 150, 85, 106, 120, 61]; return s }) )
        retVal.append( ("Hobbs Recurrence Relation 04", { let s: [Double] = [1, 9, 5, 23, 48, 7]; return s }) )
        retVal.append( ("Hobbs Recurrence Relation 05", { let s: [Double] = [1, 9, 21, 3, 25, 15]; return s }) )
        retVal.append( ("Hobbs Recurrence Relation 06", { let s: [Double] = [1, 75, 19, 5, 3, 15]; return s }) )
        retVal.append( ("Hobbs Recurrence Relation 07", { let s: [Double] = [1, 17, 10, 47, 3, 13, 7]; return s }) )
        retVal.append( ("Hobbs Recurrence Relation 08", { let s: [Double] = [1, 9, 5, 21, 3, 27, 7]; return s }) )
        retVal.append( ("Hobbs Recurrence Relation 09", { let s: [Double] = [1, 9, 21, 3, 25, 15, 31]; return s }) )
        retVal.append( ("Hobbs Recurrence Relation 10", { let s: [Double] = [1, 75, 19, 5, 94, 3, 15]; return s }) )
        retVal.append( ("Hobbs Recurrence Relation 11", { let s: [Double] = [9, 40, 21, 25, 52, 15, 31]; return s }) )
        retVal.append( ("Hobbs Recurrence Relation 12", { let s: [Double] = [1, 18, 5, 21, 3, 25, 15]; return s }) )
        retVal.append( ("Hobbs Recurrence Relation 13", { let s: [Double] = [1, 65, 9, 37, 151, 21, 86, 12, 49, 200, 28, 114]; return s }) )

        /// scales designed by Stephen Taylor
        retVal.append( ("Taylor MOS G: 0.855088", { let t = AKTuningTable(); _ = t.momentOfSymmetry(generator: 0.855_088, level: 6, murchana: 0 ); return t.masterSet }) )
        retVal.append( ("Taylor MOS G: 0.855088", { return [1.0, 1.094_694_266_037_451, 1.198_355_536_095_273_3, 1.210_363_175_255_471_5, 1.324_977_627_775_046_9, 1.338_254_032_623_560_6, 1.464_979_016_014_507_3, 1.479_658_248_405_658_6, 1.619_773_400_224_692_8, 1.636_003_687_418_558_8, 1.790_923_855_833_222_1, 1.808_869_087_257_869_4, 1.980_158_617_833_586_4] }) )
        retVal.append( ("Taylor MOS G: 0.791400", { let t = AKTuningTable(); _ = t.momentOfSymmetry(generator: 0.791_400, level: 5, murchana: 0 ); return t.masterSet }) )
        retVal.append( ("Taylor MOS G: 0.78207964", { let t = AKTuningTable(); _ = t.momentOfSymmetry(generator: 0.782_079_64, level: 5, murchana: 0 ); return t.masterSet }) )
        retVal.append( ("Taylor MOS G: 0.618033", { let t = AKTuningTable(); _ = t.momentOfSymmetry(generator: 0.618_033, level: 4, murchana: 0 ); return t.masterSet }) )
        retVal.append( ("Taylor MOS G: 0.232587", { let t = AKTuningTable(); _ = t.momentOfSymmetry(generator: 0.232_587, level: 5, murchana: 0 ); return t.masterSet }) )
        retVal.append( ("Taylor MOS G: 0.5757381", { let t = AKTuningTable(); _ = t.momentOfSymmetry(generator: 0.575_738_1, level: 6, murchana: 0 ); return t.masterSet }) )
        retVal.append( ("Taylor Pasadena JI 27", { let s: [Double] = [ 1.0 / 1, 81 / 80, 17 / 16, 16 / 15, 10 / 9, 9 / 8, 8 / 7, 7 / 6, 19 / 16, 6 / 5, 11 / 9, 5 / 4, 9 / 7, 21 / 16, 4 / 3, 11 / 8, 7 / 5, 3 / 2, 11 / 7, 8 / 5, 5 / 3, 13 / 8, 27 / 16, 7 / 4, 9 / 5, 11 / 6, 15 / 8 ]; return s }) )

        // Harry Partch: PARTCH_43.scl Harry Partch's 43-tone pure scale
        retVal.append( ("Partch", { let s: [Double] = [1/1, 81/80, 33/32, 21/20, 16/15, 12/11, 11/10, 10/9, 9/8, 8/7, 7/6, 32/27, 6/5, 11/9, 5/4, 14/11, 9/7, 21/16, 4/3, 27/20, 11/8, 7/5, 10/7, 16/11, 40/27, 3/2, 32/21, 14/9, 11/7, 8/5, 18/11, 5/3, 27/16, 12/7, 7/4, 16/9, 9/5, 20/11, 11/6, 15/8, 40/21, 64/33, 160/81]; return s } ) )

        // ET
        retVal.append( ("Equal Temperament", { let t = AKTuningTable(); _ = t.equalTemperament(notesPerOctave: 7); return t.masterSet }) )
        retVal.append( ("Equal Temperament", { let t = AKTuningTable(); _ = t.equalTemperament(notesPerOctave: 31); return t.masterSet }) )
        retVal.append( ("Equal Temperament", { let t = AKTuningTable(); _ = t.equalTemperament(notesPerOctave: 41); return t.masterSet }) )
        retVal.append( ("Equal Temperament", { let t = AKTuningTable(); _ = t.equalTemperament(notesPerOctave: 53); return t.masterSet }) )

        return retVal
    }

    internal static func hexanyTriadTunings() -> [(String, S1TuningCallback)] {
        var retVal = [(String, S1TuningCallback)]()

        // HEXANY:[1, 3, 5, 25] = [3, 5, 25, 15, 75, 125]
        // Tuning:
        // NPO:6, master set:[1.078125, 1.25, 1.4375, 1.5, 1.796875, 1.875]
        // Proportional Triads: [[(0, 3, 5)], [(1, 3, 4)], [(3, 5, 0)], [(4, 1, 3)]]
        // Subcontrary Triads: [[(1, 2, 4)], [(2, 4, 1)], [(3, 4, 0)], [(4, 0, 3)]]
        retVal.append( ( "TETRANY MAJOR:[1, 3, 5, 25]", { return [1, 3, 5, 25] } ) )
        retVal.append( ( "TETRANY MINOR:[1, 3, 5, 25]", { return [375, 125, 75, 15] } ) )
        retVal.append( ( "HEXANY:[1, 3, 5, 25]", { return [3, 5, 25, 15, 75, 125] } ) )

        // HEXANY:[1, 3, 9, 15] = [3, 9, 15, 27, 45, 135]
        // Tuning:
        // NPO:6, master set:[1.125, 1.21875, 1.5, 1.625, 1.6875, 1.828125]
        // Proportional Triads: [[(1, 2, 4)], [(1, 3, 5)], [(3, 4, 5)], [(3, 5, 1)], [(4, 1, 2)]]
        // Subcontrary Triads: [[(1, 2, 5)], [(2, 4, 0)], [(4, 5, 0)], [(4, 0, 2)], [(5, 1, 2)]]
        retVal.append( ( "TETRANY MAJOR:[1, 3, 9, 15]", { return [1, 3, 9, 15] } ) )
        retVal.append( ( "TETRANY MINOR:[1, 3, 9, 15]", { return [405, 135, 45, 27] } ) )
        retVal.append( ( "HEXANY:[1, 3, 9, 15]", { return [3, 9, 15, 27, 45, 135] } ) )

        // HEXANY:[1, 5, 15, 25] = [5, 15, 25, 75, 125, 375]
        // Tuning:
        // NPO:6, master set:[1.171875, 1.25, 1.34765625, 1.4375, 1.796875, 1.875]
        // Proportional Triads: [[(0, 3, 5)], [(1, 3, 4)], [(3, 5, 0)], [(4, 1, 3)]]
        // Subcontrary Triads: [[(0, 2, 5)], [(3, 4, 0)], [(4, 0, 3)], [(5, 0, 2)]]
        retVal.append( ( "TETRANY MAJOR:[1, 5, 15, 25]", { return [1, 5, 15, 25] } ) )
        retVal.append( ( "TETRANY MINOR:[1, 5, 15, 25]", { return [1875, 375, 125, 75] } ) )
        retVal.append( ( "HEXANY:[1, 5, 15, 25]", { return [5, 15, 25, 75, 125, 375] } ) )

        // HEXANY:[3, 5, 7, 15] = [15, 21, 45, 35, 75, 105]
        // Tuning:
        // NPO:6, master set:[1.015625, 1.09375, 1.21875, 1.3125, 1.421875, 1.875]
        // Proportional Triads: [[(1, 3, 4)], [(3, 4, 5)], [(3, 5, 1)], [(5, 1, 3)]]
        // Subcontrary Triads: [[(0, 2, 4)], [(2, 4, 0)], [(4, 5, 0)], [(5, 0, 2)]]
        retVal.append( ( "TETRANY MAJOR:[3, 5, 7, 15]", { return [3, 5, 7, 15] } ) )
        retVal.append( ( "TETRANY MINOR:[3, 5, 7, 15]", { return [525, 315, 225, 105] } ) )
        retVal.append( ( "HEXANY:[3, 5, 7, 15]", { return [15, 21, 45, 35, 75, 105] } ) )

        // HEXANY:[3, 5, 7, 21] = [15, 21, 63, 35, 105, 147]
        // Tuning:
        // NPO:6, master set:[1.0390625, 1.09375, 1.3125, 1.484375, 1.78125, 1.875]
        // Proportional Triads: [[(2, 3, 5)], [(3, 5, 1)], [(5, 1, 2)], [(5, 2, 3)]]
        // Subcontrary Triads: [[(0, 2, 3)], [(2, 3, 0)], [(3, 4, 0)], [(4, 0, 2)]]
        retVal.append( ( "TETRANY MAJOR:[3, 5, 7, 21]", { return [3, 5, 7, 21] } ) )
        retVal.append( ( "TETRANY MINOR:[3, 5, 7, 21]", { return [735, 441, 315, 105] } ) )
        retVal.append( ( "HEXANY:[3, 5, 7, 21]", { return [15, 21, 63, 35, 105, 147] } ) )

        // HEXANY:[3, 5, 7, 35] = [15, 21, 105, 35, 175, 245]
        // Tuning:
        // NPO:6, master set:[1.09375, 1.2890625, 1.3125, 1.546875, 1.8046875, 1.875]
        // Proportional Triads: [[(0, 2, 3)], [(2, 3, 5)], [(3, 5, 0)], [(3, 0, 2)]]
        // Subcontrary Triads: [[(0, 1, 3)], [(1, 3, 0)], [(3, 4, 0)], [(4, 0, 1)]]
        retVal.append( ( "TETRANY MAJOR:[3, 5, 7, 35]", { return [3, 5, 7, 35] } ) )
        retVal.append( ( "TETRANY MINOR:[3, 5, 7, 35]", { return [1225, 735, 525, 105] } ) )
        retVal.append( ( "HEXANY:[3, 5, 7, 35]", { return [15, 21, 105, 35, 175, 245] } ) )

        // HEXANY:[3, 5, 15, 21] = [15, 45, 63, 75, 105, 315]
        // Tuning:
        // NPO:6, master set:[1.11328125, 1.171875, 1.40625, 1.484375, 1.78125, 1.875]
        // Proportional Triads: [[(0, 2, 3)], [(2, 3, 4)], [(2, 4, 0)], [(4, 0, 2)]]
        // Subcontrary Triads: [[(1, 2, 3)], [(2, 3, 5)], [(3, 5, 1)], [(5, 1, 3)]]
        retVal.append( ( "TETRANY MAJOR:[3, 5, 15, 21]", { return [3, 5, 15, 21] } ) )
        retVal.append( ( "TETRANY MINOR:[3, 5, 15, 21]", { return [1575, 945, 315, 225] } ) )
        retVal.append( ( "HEXANY:[3, 5, 15, 21]", { return [15, 45, 63, 75, 105, 315] } ) )

        // HEXANY:[3, 5, 15, 35] = [15, 45, 105, 75, 175, 525]
        // Tuning:
        // NPO:6, master set:[1.171875, 1.2890625, 1.40625, 1.546875, 1.875, 1.93359375]
        // Proportional Triads: [[(1, 3, 4)], [(3, 4, 5)], [(3, 5, 1)], [(5, 1, 3)]]
        // Subcontrary Triads: [[(0, 1, 2)], [(1, 2, 4)], [(2, 4, 0)], [(4, 0, 2)]]
        retVal.append( ( "TETRANY MAJOR:[3, 5, 15, 35]", { return [3, 5, 15, 35] } ) )
        retVal.append( ( "TETRANY MINOR:[3, 5, 15, 35]", { return [2625, 1575, 525, 225] } ) )
        retVal.append( ( "HEXANY:[3, 5, 15, 35]", { return [15, 45, 105, 75, 175, 525] } ) )

        // HEXANY:[3, 5, 15, 45] = [15, 45, 135, 75, 225, 675]
        // Tuning:
        // NPO:6, master set:[1.0078125, 1.171875, 1.259765625, 1.40625, 1.6796875, 1.875]
        // Proportional Triads: [[(0, 3, 4)], [(3, 4, 0)], [(3, 5, 1)], [(5, 0, 1)], [(5, 1, 3)]]
        // Subcontrary Triads: [[(0, 1, 2)], [(0, 2, 4)], [(1, 3, 4)], [(3, 4, 1)], [(4, 0, 2)]]
        retVal.append( ( "TETRANY MAJOR:[3, 5, 15, 45]", { return [3, 5, 15, 45] } ) )
        retVal.append( ( "TETRANY MINOR:[3, 5, 15, 45]", { return [3375, 2025, 675, 225] } ) )
        retVal.append( ( "HEXANY:[3, 5, 15, 45]", { return [15, 45, 135, 75, 225, 675] } ) )

        // HEXANY:[3, 5, 15, 75] = [15, 45, 225, 75, 375, 1125]
        // Tuning:
        // NPO:6, master set:[1.0693359375, 1.171875, 1.40625, 1.42578125, 1.7109375, 1.875]
        // Proportional Triads: [[(1, 3, 4)], [(2, 5, 1)], [(4, 1, 3)], [(5, 1, 2)]]
        // Subcontrary Triads: [[(1, 2, 4)], [(2, 4, 1)], [(3, 4, 0)], [(4, 0, 3)]]
        retVal.append( ( "TETRANY MAJOR:[3, 5, 15, 75]", { return [3, 5, 15, 75] } ) )
        retVal.append( ( "TETRANY MINOR:[3, 5, 15, 75]", { return [5625, 3375, 1125, 225] } ) )
        retVal.append( ( "HEXANY:[3, 5, 15, 75]", { return [15, 45, 225, 75, 375, 1125] } ) )

        // HEXANY:[3, 7, 21, 35] = [21, 63, 105, 147, 245, 735]
        // Tuning:
        // NPO:6, master set:[1.1484375, 1.3125, 1.353515625, 1.546875, 1.8046875, 1.96875]
        // Proportional Triads: [[(1, 3, 5)], [(3, 5, 0)], [(5, 0, 1)], [(5, 1, 3)]]
        // Subcontrary Triads: [[(0, 2, 4)], [(2, 3, 4)], [(3, 4, 0)], [(4, 0, 2)]]
        retVal.append( ( "TETRANY MAJOR:[3, 7, 21, 35]", { return [3, 7, 21, 35] } ) )
        retVal.append( ( "TETRANY MINOR:[3, 7, 21, 35]", { return [5145, 2205, 735, 441] } ) )
        retVal.append( ( "HEXANY:[3, 7, 21, 35]", { return [21, 63, 105, 147, 245, 735] } ) )

        // HEXANY:[3, 9, 15, 25] = [27, 45, 75, 135, 225, 375]
        // Tuning:
        // NPO:6, master set:[1.0546875, 1.078125, 1.34765625, 1.40625, 1.6171875, 1.6875]
        // Proportional Triads: [[(0, 2, 5)], [(1, 3, 5)], [(2, 5, 0)], [(5, 1, 3)]]
        // Subcontrary Triads: [[(1, 2, 5)], [(2, 4, 0)], [(2, 5, 1)], [(4, 0, 2)]]
        retVal.append( ( "TETRANY MAJOR:[3, 9, 15, 25]", { return [3, 9, 15, 25] } ) )
        retVal.append( ( "TETRANY MINOR:[3, 9, 15, 25]", { return [3375, 1125, 675, 405] } ) )
        retVal.append( ( "HEXANY:[3, 9, 15, 25]", { return [27, 45, 75, 135, 225, 375] } ) )

        // HEXANY:[3, 15, 21, 35] = [45, 63, 105, 315, 525, 735]
        // Tuning:
        // NPO:6, master set:[1.23046875, 1.271484375, 1.40625, 1.453125, 1.81640625, 1.96875]
        // Proportional Triads: [[(0, 1, 3)], [(1, 3, 4)], [(1, 4, 0)], [(4, 0, 1)]]
        // Subcontrary Triads: [[(1, 2, 4)], [(2, 4, 5)], [(4, 5, 1)], [(5, 1, 4)]]
        retVal.append( ( "TETRANY MAJOR:[3, 15, 21, 35]", { return [3, 15, 21, 35] } ) )
        retVal.append( ( "TETRANY MINOR:[3, 15, 21, 35]", { return [11025, 2205, 1575, 945] } ) )
        retVal.append( ( "HEXANY:[3, 15, 21, 35]", { return [45, 63, 105, 315, 525, 735] } ) )

        // HEXANY:[3, 15, 25, 75] = [45, 75, 225, 375, 1125, 1875]
        // Tuning:
        // NPO:6, master set:[1.0693359375, 1.171875, 1.40625, 1.46484375, 1.7109375, 1.7822265625]
        // Proportional Triads: [[(0, 3, 5)], [(1, 3, 4)], [(3, 5, 0)], [(4, 1, 3)]]
        // Subcontrary Triads: [[(1, 2, 4)], [(2, 4, 1)], [(3, 4, 0)], [(4, 0, 3)]]
        retVal.append( ( "TETRANY MAJOR:[3, 15, 25, 75]", { return [3, 15, 25, 75] } ) )
        retVal.append( ( "TETRANY MINOR:[3, 15, 25, 75]", { return [28125, 5625, 3375, 1125] } ) )
        retVal.append( ( "HEXANY:[3, 15, 25, 75]", { return [45, 75, 225, 375, 1125, 1875] } ) )

        // HEXANY:[5, 7, 15, 35] = [35, 75, 175, 105, 245, 525]
        // Tuning:
        // NPO:6, master set:[1.09375, 1.171875, 1.2890625, 1.640625, 1.8046875, 1.93359375]
        // Proportional Triads: [[(1, 3, 4)], [(3, 4, 5)], [(4, 5, 1)], [(4, 1, 3)], [(5, 0, 1)]]
        // Subcontrary Triads: [[(0, 1, 2)], [(0, 2, 3)], [(2, 3, 4)], [(3, 4, 0)], [(4, 0, 3)]]
        retVal.append( ( "TETRANY MAJOR:[5, 7, 15, 35]", { return [5, 7, 15, 35] } ) )
        retVal.append( ( "TETRANY MINOR:[5, 7, 15, 35]", { return [3675, 2625, 1225, 525] } ) )
        retVal.append( ( "HEXANY:[5, 7, 15, 35]", { return [35, 75, 175, 105, 245, 525] } ) )

        // HEXANY:[5, 7, 21, 35] = [35, 105, 175, 147, 245, 735]
        // Tuning:
        // NPO:6, master set:[1.09375, 1.1484375, 1.2890625, 1.353515625, 1.640625, 1.8046875]
        // Proportional Triads: [[(0, 2, 4)], [(2, 4, 5)], [(4, 5, 0)], [(4, 0, 2)]]
        // Subcontrary Triads: [[(1, 3, 5)], [(3, 4, 5)], [(4, 5, 1)], [(5, 1, 3)]]
        retVal.append( ( "TETRANY MAJOR:[5, 7, 21, 35]", { return [5, 7, 21, 35] } ) )
        retVal.append( ( "TETRANY MINOR:[5, 7, 21, 35]", { return [5145, 3675, 1225, 735] } ) )
        retVal.append( ( "HEXANY:[5, 7, 21, 35]", { return [35, 105, 175, 147, 245, 735] } ) )

        // HEXANY:[5, 9, 15, 25] = [45, 75, 125, 135, 225, 375]
        // Tuning:
        // NPO:6, master set:[1.0546875, 1.171875, 1.34765625, 1.40625, 1.6171875, 1.796875]
        // Proportional Triads: [[(0, 2, 4)], [(1, 3, 4)], [(2, 4, 0)], [(4, 1, 3)]]
        // Subcontrary Triads: [[(1, 2, 4)], [(1, 3, 5)], [(2, 4, 1)], [(5, 1, 3)]]
        retVal.append( ( "TETRANY MAJOR:[5, 9, 15, 25]", { return [5, 9, 15, 25] } ) )
        retVal.append( ( "TETRANY MINOR:[5, 9, 15, 25]", { return [3375, 1875, 1125, 675] } ) )
        retVal.append( ( "HEXANY:[5, 9, 15, 25]", { return [45, 75, 125, 135, 225, 375] } ) )

        // HEXANY:[5, 9, 15, 45] = [45, 75, 225, 135, 405, 675]
        // Tuning:
        // NPO:6, master set:[1.0546875, 1.171875, 1.259765625, 1.40625, 1.51171875, 1.6796875]
        // Proportional Triads: [[(0, 2, 4)], [(0, 3, 5)], [(3, 4, 5)], [(3, 5, 0)], [(4, 0, 2)]]
        // Subcontrary Triads: [[(0, 1, 2)], [(0, 2, 5)], [(1, 3, 5)], [(3, 5, 1)], [(5, 0, 2)]]
        retVal.append( ( "TETRANY MAJOR:[5, 9, 15, 45]", { return [5, 9, 15, 45] } ) )
        retVal.append( ( "TETRANY MINOR:[5, 9, 15, 45]", { return [6075, 3375, 2025, 675] } ) )
        retVal.append( ( "HEXANY:[5, 9, 15, 45]", { return [45, 75, 225, 135, 405, 675] } ) )

        // HEXANY:[7, 15, 21, 35] = [105, 147, 245, 315, 525, 735]
        // Tuning:
        // NPO:6, master set:[1.1484375, 1.23046875, 1.353515625, 1.640625, 1.8046875, 1.93359375]
        // Proportional Triads: [[(0, 2, 3)], [(2, 3, 4)], [(2, 4, 0)], [(4, 0, 2)]]
        // Subcontrary Triads: [[(1, 3, 5)], [(3, 4, 5)], [(4, 5, 1)], [(5, 1, 3)]]
        retVal.append( ( "TETRANY MAJOR:[7, 15, 21, 35]", { return [7, 15, 21, 35] } ) )
        retVal.append( ( "TETRANY MINOR:[7, 15, 21, 35]", { return [11025, 5145, 3675, 2205] } ) )
        retVal.append( ( "HEXANY:[7, 15, 21, 35]", { return [105, 147, 245, 315, 525, 735] } ) )

        // HEXANY:[9, 11, 15, 33] = [99, 135, 297, 165, 363, 495]
        // Tuning:
        // NPO:6, master set:[1.0546875, 1.08984375, 1.2890625, 1.33203125, 1.546875, 1.81640625]
        // Proportional Triads: [[(1, 2, 3)], [(1, 4, 5)], [(2, 3, 4)], [(4, 5, 1)]]
        // Subcontrary Triads: [[(0, 1, 2)], [(2, 4, 5)], [(4, 5, 2)], [(5, 0, 1)]]
        retVal.append( ( "TETRANY MAJOR:[9, 11, 15, 33]", { return [9, 11, 15, 33] } ) )
        retVal.append( ( "TETRANY MINOR:[9, 11, 15, 33]", { return [5445, 4455, 3267, 1485] } ) )
        retVal.append( ( "HEXANY:[9, 11, 15, 33]", { return [99, 135, 297, 165, 363, 495] } ) )

        // HEXANY:[9, 15, 25, 45] = [135, 225, 405, 375, 675, 1125]
        // Tuning:
        // NPO:6, master set:[1.0498046875, 1.0546875, 1.259765625, 1.46484375, 1.51171875, 1.7578125]
        // Proportional Triads: [[(0, 2, 4)], [(2, 5, 1)], [(4, 0, 2)], [(5, 1, 2)]]
        // Subcontrary Triads: [[(0, 2, 5)], [(3, 5, 1)], [(5, 0, 2)], [(5, 1, 3)]]
        retVal.append( ( "TETRANY MAJOR:[9, 15, 25, 45]", { return [9, 15, 25, 45] } ) )
        retVal.append( ( "TETRANY MINOR:[9, 15, 25, 45]", { return [16875, 10125, 6075, 3375] } ) )
        retVal.append( ( "HEXANY:[9, 15, 25, 45]", { return [135, 225, 405, 375, 675, 1125] } ) )

        // HEXANY:[9, 15, 25, 75] = [135, 225, 675, 375, 1125, 1875]
        // Tuning:
        // NPO:6, master set:[1.0546875, 1.0693359375, 1.283203125, 1.46484375, 1.7578125, 1.7822265625]
        // Proportional Triads: [[(1, 3, 5)], [(2, 4, 1)], [(3, 5, 1)], [(4, 1, 2)]]
        // Subcontrary Triads: [[(0, 2, 4)], [(3, 4, 1)], [(4, 0, 2)], [(4, 1, 3)]]
        retVal.append( ( "TETRANY MAJOR:[9, 15, 25, 75]", { return [9, 15, 25, 75] } ) )
        retVal.append( ( "TETRANY MINOR:[9, 15, 25, 75]", { return [28125, 16875, 10125, 3375] } ) )
        retVal.append( ( "HEXANY:[9, 15, 25, 75]", { return [135, 225, 675, 375, 1125, 1875] } ) )

        // HEXANY:[15, 21, 35, 45] = [315, 525, 675, 735, 945, 1575]
        // Tuning:
        // NPO:6, master set:[1.025390625, 1.23046875, 1.259765625, 1.435546875, 1.4697265625, 1.763671875]
        // Proportional Triads: [[(0, 1, 3)], [(0, 3, 5)], [(1, 4, 5)], [(5, 1, 4)]]
        // Subcontrary Triads: [[(0, 1, 4)], [(0, 2, 5)], [(1, 4, 0)], [(2, 4, 5)]]
        retVal.append( ( "TETRANY MAJOR:[15, 21, 35, 45]", { return [15, 21, 35, 45] } ) )
        retVal.append( ( "TETRANY MINOR:[15, 21, 35, 45]", { return [33075, 23625, 14175, 11025] } ) )
        retVal.append( ( "HEXANY:[15, 21, 35, 45]", { return [315, 525, 675, 735, 945, 1575] } ) )

        // HEXANY:[15, 33, 45, 55] = [495, 675, 825, 1485, 1815, 2475]
        // Tuning:
        // NPO:6, master set:[1.16455078125, 1.318359375, 1.4501953125, 1.552734375, 1.7080078125, 1.93359375]
        // Proportional Triads: [[(2, 3, 4)], [(2, 5, 0)], [(3, 4, 5)], [(5, 0, 2)]]
        // Subcontrary Triads: [[(0, 1, 2)], [(1, 2, 3)], [(3, 5, 0)], [(5, 0, 3)]]
        retVal.append( ( "TETRANY MAJOR:[15, 33, 45, 55]", { return [15, 33, 45, 55] } ) )
        retVal.append( ( "TETRANY MINOR:[15, 33, 45, 55]", { return [81675, 37125, 27225, 22275] } ) )
        retVal.append( ( "HEXANY:[15, 33, 45, 55]", { return [495, 675, 825, 1485, 1815, 2475] } ) )

        // HEXANY:[41, 67, 97, 127] = [2747, 3977, 5207, 6499, 8509, 12319]
        // Tuning:
        // NPO:6, master set:[1.211181640625, 1.34130859375, 1.4327392578125, 1.586669921875, 1.94189453125, 1.979248046875]
        // Proportional Triads: [[(0, 1, 3)], [(2, 5, 1)]]
        // Subcontrary Triads: [[(2, 4, 5)], [(4, 0, 3)]]
        retVal.append( ( "TETRANY MAJOR:[41, 67, 97, 127]", { return [41, 67, 97, 127] } ) )
        retVal.append( ( "TETRANY MINOR:[41, 67, 97, 127]", { return [825373, 505079, 348869, 266459] } ) )
        retVal.append( ( "HEXANY:[41, 67, 97, 127]", { return [2747, 3977, 5207, 6499, 8509, 12319] } ) )

        // HEXANY:[31, 41, 61, 103] = [1271, 1891, 3193, 2501, 4223, 6283]
        // Tuning:
        // NPO:6, master set:[1.010986328125, 1.22119140625, 1.2412109375, 1.504150390625, 1.52880859375, 1.8466796875]
        // Proportional Triads: [[(1, 3, 5)], [(5, 2, 4)]]
        // Subcontrary Triads: [[(0, 2, 4)], [(1, 3, 0)]]
        retVal.append( ( "TETRANY MAJOR:[31, 41, 61, 103]", { return [31, 41, 61, 103] } ) )
        retVal.append( ( "TETRANY MINOR:[31, 41, 61, 103]", { return [257603, 194773, 130913, 77531] } ) )
        retVal.append( ( "HEXANY:[31, 41, 61, 103]", { return [1271, 1891, 3193, 2501, 4223, 6283] } ) )

        // HEXANY:[19, 23, 31, 61] = [437, 589, 1159, 713, 1403, 1891]
        // Tuning:
        // NPO:6, master set:[1.0947265625, 1.150390625, 1.3251953125, 1.392578125, 1.70703125, 1.7861328125]
        // Proportional Triads: [[(1, 4, 0)], [(3, 5, 1)]]
        // Subcontrary Triads: [[(2, 4, 0)], [(3, 5, 2)]]
        retVal.append( ( "TETRANY MAJOR:[19, 23, 31, 61]", { return [19, 23, 31, 61] } ) )
        retVal.append( ( "TETRANY MINOR:[19, 23, 31, 61]", { return [43493, 35929, 26657, 13547] } ) )
        retVal.append( ( "HEXANY:[19, 23, 31, 61]", { return [437, 589, 1159, 713, 1403, 1891] } ) )

        return retVal
    }
}
