//
//  AKS1Tunings.swift
//  AudioKitSynthOne
//
//  Created by Marcus W. Hobbs on 5/12/18.
//  Copyright © 2018 AudioKit. All rights reserved.
//

import UIKit
import AudioKit

@objc open class AKS1Tunings: NSObject {
    
    public var tuningsDelegate: TuningsPitchWheelViewTuningDidChange? = nil
    
    public typealias AKS1TuningCallback = () -> (Void)
    
    public typealias Frequency = Double
    
    public class func harmonicSeries( _ root: Int ) -> [Frequency] {
        var retVal: [Frequency] = [1] // octave-based tuning with default root 1/1
        if root < 1 { return retVal }
        let octave = 2 * root
        for n in root..<octave { // wouldn't that be cool if you could have an open range like root>.<octave   ? in math would be R(root, octave)
            if n == root { continue } // root: don't add 1/1
            let f = Frequency(n) / Frequency(root)
            retVal.append(f)
        }
        return retVal
    }
    
    public class func subHarmonicSeries( _ root: Int ) -> [Frequency] {
        var retVal: [Frequency] = [1] // octave-based tuning with default root 1/1
        if root < 1 { return retVal }
        let octave = 2 * root
        for n in root..<octave {
            if n == root { continue } // root: don't add 1/1
            let f = Frequency(root) / Frequency(n)
            retVal.append(f)
        }
        return retVal
    }

    public class func harmonicSubharmonicSeries( _ root: Int) -> [Frequency] {
        var retVal: [Frequency] = [1] // octave-based tuning with default root 1/1
        if root < 1 { return retVal }
        let harmonic = harmonicSeries(root)
        let subHarmonic = subHarmonicSeries(root)
        retVal = Array( Set(harmonic + subHarmonic) )
        retVal.sort()
        return retVal
    }
    
    //CPS
    // 4 choose 2
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
    
    public func setTuning(withMasterArray master:[Double]) -> Int? {
        if master.count == 0 { return nil}
        _ = AKPolyphonicNode.tuningTable.tuningTable(fromFrequencies: master)
        tuningsDelegate?.tuningDidChange()
        return tunings.count - 1
    }
    
    public func resetTuning() -> Int {
        let i = 0
        let tuning = tunings[i]
        tuning.1()
        let f = Conductor.sharedInstance.synth!.getParameterDefault(.frequencyA4)
        Conductor.sharedInstance.synth!.setAK1Parameter(.frequencyA4, f)
        tuningsDelegate?.tuningDidChange()
        return i
    }
    
    public func randomTuning() -> Int {
        let ri = Int(arc4random() % UInt32(tunings.count))
        let tuning = tunings[ri]
        //TODO:add preset tuning addings/setting here
        tuning.1()
        tuningsDelegate?.tuningDidChange()
        return ri
    }
    
    
    public let tunings: [(String, AKS1TuningCallback)] = [
        
        ("12 Tone Equal Temperament (default)", {_ = AKPolyphonicNode.tuningTable.defaultTuning() } ),
        ("12 Chain of pure fifths", {_ = AKPolyphonicNode.tuningTable.tuningTable(fromFrequencies: [1,3,9,27,81,243,729,2187,6561,19683,59049,177147]) } ),
        
        // experiments
        (" 2 Harmonic+Sub", {_ = AKPolyphonicNode.tuningTable.tuningTable(fromFrequencies: harmonicSubharmonicSeries(2))}),
        (" 3 Harmonic+Sub", {_ = AKPolyphonicNode.tuningTable.tuningTable(fromFrequencies: harmonicSubharmonicSeries(3))}),
        (" 4 Harmonic+Sub", {_ = AKPolyphonicNode.tuningTable.tuningTable(fromFrequencies: harmonicSubharmonicSeries(4))}),
        (" 5 Harmonic+Sub", {_ = AKPolyphonicNode.tuningTable.tuningTable(fromFrequencies: harmonicSubharmonicSeries(5))}),

        (" 2 Harmonic", {_ = AKPolyphonicNode.tuningTable.tuningTable(fromFrequencies: AKS1Tunings.harmonicSeries( 2))} ),
        (" 3 Harmonic", {_ = AKPolyphonicNode.tuningTable.tuningTable(fromFrequencies: AKS1Tunings.harmonicSeries( 3))} ),
        (" 4 Harmonic", {_ = AKPolyphonicNode.tuningTable.tuningTable(fromFrequencies: AKS1Tunings.harmonicSeries( 4))} ),
        (" 5 Harmonic", {_ = AKPolyphonicNode.tuningTable.tuningTable(fromFrequencies: AKS1Tunings.harmonicSeries( 5))} ),
        (" 6 Harmonic", {_ = AKPolyphonicNode.tuningTable.tuningTable(fromFrequencies: AKS1Tunings.harmonicSeries( 6))} ),
        (" 7 Harmonic", {_ = AKPolyphonicNode.tuningTable.tuningTable(fromFrequencies: AKS1Tunings.harmonicSeries( 7))} ),
        (" 9 Harmonic", {_ = AKPolyphonicNode.tuningTable.tuningTable(fromFrequencies: AKS1Tunings.harmonicSeries( 9))} ),
        ("12 Harmonic", {_ = AKPolyphonicNode.tuningTable.tuningTable(fromFrequencies: AKS1Tunings.harmonicSeries(12))} ),

        (" 2 Subharmonic", {_ = AKPolyphonicNode.tuningTable.tuningTable(fromFrequencies: AKS1Tunings.subHarmonicSeries( 2))} ),
        (" 3 Subharmonic", {_ = AKPolyphonicNode.tuningTable.tuningTable(fromFrequencies: AKS1Tunings.subHarmonicSeries( 3))} ),
        (" 4 Subharmonic", {_ = AKPolyphonicNode.tuningTable.tuningTable(fromFrequencies: AKS1Tunings.subHarmonicSeries( 4))} ),
        (" 5 Subharmonic", {_ = AKPolyphonicNode.tuningTable.tuningTable(fromFrequencies: AKS1Tunings.subHarmonicSeries( 5))} ),
        (" 6 Subharmonic", {_ = AKPolyphonicNode.tuningTable.tuningTable(fromFrequencies: AKS1Tunings.subHarmonicSeries( 6))} ),
        (" 7 Subharmonic", {_ = AKPolyphonicNode.tuningTable.tuningTable(fromFrequencies: AKS1Tunings.subHarmonicSeries( 7))} ),
        ("16 Subharmonic", {_ = AKPolyphonicNode.tuningTable.tuningTable(fromFrequencies: AKS1Tunings.subHarmonicSeries(16))} ),

        
        // scales designed by Marcus Hobbs using Wilsonic
        (" 6 Hexany(1, 3, 5, 7)", {_ = AKPolyphonicNode.tuningTable.hexany(1, 3, 5, 7)  } ),
        //("10 Dekany(1, 3, 5, 7, 11)", {_ = AKPolyphonicNode.tuningTable.tuningTable(fromFrequencies: AKS1Tunings.dekany([1,3,5,7,11])) } ),
        
        (" 6 Hexany(1, 3, 5, 45)", {_ = AKPolyphonicNode.tuningTable.hexany(1, 3, 5, 45)  } ),// 071
        //("10 Dekany(1, 3, 5, 45, 75) ",  {_ = AKPolyphonicNode.tuningTable.tuningTable(fromFrequencies: AKS1Tunings.dekany([1,3,5,45,75]) ) } ),
        //("15 Pentadekany(Hexany(1,3,5,45))", {_ = AKPolyphonicNode.tuningTable.tuningTable(fromFrequencies: AKS1Tunings.pentadekany(AKS1Tunings.hexany([1, 3, 5, 45])))} ),
        
        (" 6 Hexany(1, 3, 5, 9)", {_ = AKPolyphonicNode.tuningTable.hexany(1, 3, 5, 9) } ),
        //("10 Dekany(1, 3, 5, 9, 25)", {_ =  AKPolyphonicNode.tuningTable.tuningTable(fromFrequencies: AKS1Tunings.dekany([1, 3, 5, 9, 25] ) ) } ),
        //("15 Pentadekany(Hexany(1,3,5,9))", {_ = AKPolyphonicNode.tuningTable.tuningTable(fromFrequencies: AKS1Tunings.pentadekany(AKS1Tunings.hexany([1, 3, 5, 9])))} ),
        
        (" 6 Hexany(1, 3, 5, 15)", {_ = AKPolyphonicNode.tuningTable.hexany(1, 3, 5, 15) } ),
        //("10 Dekany(1, 3, 5, 9, 15)", {_ = AKPolyphonicNode.tuningTable.tuningTable(fromFrequencies: AKS1Tunings.dekany([1, 3, 5, 9, 15] ) ) } ),
        
        (" 6 Hexany(1, 3, 5, 81)", {_ = AKPolyphonicNode.tuningTable.hexany(1, 3, 5, 81) } ),
        ("10 Dekany(1, 3, 5, 9, 81)", {_ = AKPolyphonicNode.tuningTable.tuningTable(fromFrequencies: AKS1Tunings.dekany([1, 3, 5, 9, 81] ) ) } ),
        //("15 Pentadekany(Hexany(1,3,5,81))", {_ = AKPolyphonicNode.tuningTable.tuningTable(fromFrequencies: AKS1Tunings.pentadekany(AKS1Tunings.hexany([1, 3, 5, 81])))}),
        (" 6 Hexany(1, 3, 5, 121)", {_ = AKPolyphonicNode.tuningTable.hexany(1, 3, 5, 121) } ),
        //("10 Dekany(1, 3, 5, 11, 121)", {_ = AKPolyphonicNode.tuningTable.tuningTable(fromFrequencies: AKS1Tunings.dekany([1, 3, 5, 11, 121] ) ) } ),
        //("15 Pentadekany(Hexany(1, 3, 5, 121))", {_ = AKPolyphonicNode.tuningTable.tuningTable(fromFrequencies: AKS1Tunings.pentadekany(AKS1Tunings.hexany([1, 3, 5, 121])))}),
        (" 6 Hexany(1, 15, 45, 75)", {_ = AKPolyphonicNode.tuningTable.hexany(1, 15, 45, 75) } ),
        //("10 Dekany(1, 15, 45, 75, 105)", {_ = AKPolyphonicNode.tuningTable.tuningTable(fromFrequencies: AKS1Tunings.dekany([1,15,45,75,105]) ) } ),
        //("15 Pentadekany(1, 15, 45, 75)", {_ = AKPolyphonicNode.tuningTable.tuningTable(fromFrequencies: AKS1Tunings.pentadekany(AKS1Tunings.hexany([1, 15, 45, 75])))} ),
        (" 6 Hexany(1, 17, 19, 23)", {_ = AKPolyphonicNode.tuningTable.hexany(1, 17, 19, 23) } ),
        (" 6 Hexany(1, 45, 135, 225)", {_ = AKPolyphonicNode.tuningTable.hexany(1,45,135,225) } ),
        //("10 Dekany(1, 45, 135, 225, 315)", {_ = AKPolyphonicNode.tuningTable.tuningTable(fromFrequencies: AKS1Tunings.dekany([1,45,135,225, 315])) } ),
        (" 6 Hexany(3, 2.111, 5.111, 8.111)", {_ = AKPolyphonicNode.tuningTable.hexany(3, 2.111, 5.111, 8.111) } ),
        (" 6 Hexany(3, 1.346, 4.346, 7.346)", {_ = AKPolyphonicNode.tuningTable.hexany(3, 1.346, 4.346, 7.346) } ),
        (" 6 Hexany(3, 5, 7, 9)", {_ = AKPolyphonicNode.tuningTable.hexany(3, 5, 7, 9) } ),
        //(" 6 Hexany(3, 7, 9, 35)", {_ = AKPolyphonicNode.tuningTable.hexany(3, 7, 9, 35) } ),
        (" 6 Hexany(3, 5, 15, 19)", {_ = AKPolyphonicNode.tuningTable.hexany(3, 5, 15, 19) } ),
        (" 6 Hexany(5, 7, 21, 35)", {_ = AKPolyphonicNode.tuningTable.hexany(5, 7, 21, 35) } ),
        //("15 Pentadekany(5, 7, 21, 35)", {_ = AKPolyphonicNode.tuningTable.tuningTable(fromFrequencies: AKS1Tunings.pentadekany(AKS1Tunings.hexany([5, 7, 21, 35])))}  ),
        (" 6 Hexany(9, 25, 49, 81)", {_ = AKPolyphonicNode.tuningTable.hexany(9, 25, 49, 81) } ),
        (" 6 Hexany(1,  9, 25, 49)", {_ = AKPolyphonicNode.tuningTable.hexany(1, 9, 25, 49) } ),
        (" 5 Recurrence Relation", {_ = AKPolyphonicNode.tuningTable.tuningTable(fromFrequencies: [1,19,5,3,15])}),
        (" 5 Recurrence Relation", {_ = AKPolyphonicNode.tuningTable.tuningTable(fromFrequencies: [35,20,46,26,15])}),
        (" 5 Recurrence Relation", {_ = AKPolyphonicNode.tuningTable.tuningTable(fromFrequencies: [1,37,21,49,28])}),
        (" 5 Recurrence Relation", {_ = AKPolyphonicNode.tuningTable.tuningTable(fromFrequencies: [35,74,23,51,61])}),
        (" 6 Recurrence Relation", {_ = AKPolyphonicNode.tuningTable.tuningTable(fromFrequencies: [74,150,85,106,120,61])}),
        (" 6 Recurrence Relation", {_ = AKPolyphonicNode.tuningTable.tuningTable(fromFrequencies: [1,9,5,23,48,7])}),
        (" 6 Recurrence Relation", {_ = AKPolyphonicNode.tuningTable.tuningTable(fromFrequencies: [1,9,21,3,25,15])}),
        (" 6 Recurrence Relation", {_ = AKPolyphonicNode.tuningTable.tuningTable(fromFrequencies: [1,75,19,5,3,15])}),
        (" 7 Recurrence Relation", {_ = AKPolyphonicNode.tuningTable.tuningTable(fromFrequencies: [1,17,10,47,3,13,7])}),
        (" 7 Recurrence Relation", {_ = AKPolyphonicNode.tuningTable.tuningTable(fromFrequencies: [1,9,5,21,3,27,7])}),
        (" 7 Recurrence Relation", {_ = AKPolyphonicNode.tuningTable.tuningTable(fromFrequencies: [1,9,21,3,25,15,31])}),
        (" 7 Recurrence Relation", {_ = AKPolyphonicNode.tuningTable.tuningTable(fromFrequencies: [1,75,19,5,94,3,15])}),
        (" 7 Recurrence Relation", {_ = AKPolyphonicNode.tuningTable.tuningTable(fromFrequencies: [9,40,21,25,52,15,31])}),
        (" 7 Recurrence Relation", {_ = AKPolyphonicNode.tuningTable.tuningTable(fromFrequencies: [1,18,5,21,3,25,15])}),
        (" 8 Recurrence Relation", {_ = AKPolyphonicNode.tuningTable.tuningTable(fromFrequencies: [1,75,19,5,94,3,118,15])}),
        ("12 Recurrence Relation", {_ = AKPolyphonicNode.tuningTable.tuningTable(fromFrequencies: [1,65,9,37,151,21,86,12,49,200,28,114])}),
        
        
        /// scales designed by Jose Garcia
        //! wilson7.scl
        //Wilson's 22-tone 7-limit 'marimba' scale
        ("22 Garcia: Wilson 7-limit marimba", {_ = AKPolyphonicNode.tuningTable.tuningTable(fromFrequencies: [1/1, 28/27, 16/15, 10/9, 9/8, 7/6, 6/5, 5/4,  35/27, 4/3, 27/20, 45/32, 35/24, 3/2, 14/9, 8/5, 5/3, 27/16, 7/4, 9/5, 15/8,  35/18] ) } ),
        //! garcia.scl
        //Linear 29-tone scale by Jose L. Garcia (1988) 15/13-52/45 alternating
        ("29 Garcia: 15/13-52/45 alternating", {_ = AKPolyphonicNode.tuningTable.tuningTable(fromFrequencies: [1/1, 40/39, 27/26, 16/15, 128/117, 9/8, 15/13, 32/27, 6/5, 16/13, 81/64, 135/104, 4/3, 160/117, 18/13, 64/45, 512/351, 3/2, 20/13, 81/52, 8/5, 64/39, 27/16, 45/26, 16/9, 9/5, 24/13, 405/208] ) } ),
        
        
        /// scales designed by Kraig Grady
        ("Grady: S-7 limit pentatonic", {_ = AKPolyphonicNode.tuningTable.tuningTable(fromFrequencies: [1/1, 7/6,  4/3, 3/2,  7/4])}),
        ("Grady: S-Pentatonic 11 limit scale 1", {_ = AKPolyphonicNode.tuningTable.tuningTable(fromFrequencies: [1/1, 9/8, 11/8, 3/2, 7/4])}),
        ("Grady: S-Pentatonic 11 limit scale 2", {_ = AKPolyphonicNode.tuningTable.tuningTable(fromFrequencies: [1/1, 5/4, 11/8, 3/2, 7/4])}),
        ("Grady: S-Centaur 7limit minor", {_ = AKPolyphonicNode.tuningTable.tuningTable(fromFrequencies: [1/1,9/8,7/6,4/3,3/2,14/9,7/4])}),
        ("Grady: S-Centaur  soft Major on E", {_ = AKPolyphonicNode.tuningTable.tuningTable(fromFrequencies: [1/1,28/25,56/46,4/3,3/2,42/25,28/15])}),
        ("Grady: A-Centaur 10 tone", {_ = AKPolyphonicNode.tuningTable.tuningTable(fromFrequencies: [1/1,21/20,9/8,7/6,4/3,7/5,3/2,5/3,7/4,15/8])}),
        ("Grady: A-Centaur", {_ = AKPolyphonicNode.tuningTable.tuningTable(fromFrequencies: [1/1,21/20,9/8,7/6,5/4,4/3,7/5,3/2,14/9,5/3,7/4,15/8])}),
//        ("Grady: Grady 14 tone 7 limit
//        1/1
//        21/20
//        9/8
//        7/6
//        5/4
//        21/16
//        4/3
//        7/5
//        3/2
//        63/40
//        27/16
//        7/4
//        15/8
//        63/32
//        2/1
//        
//        ("Grady: Double Dekany 14 tone
//        1/1
//        35/32
//        9/8
//        7/6
//        5/4
//        21/16
//        45/32
//        35/24
//        3/2
//        105/64
//        5/3
//        7/4
//        15/8
//        63/32
//        2/1
//        
//        ("Grady: A- Narushima 19 tone 7 limit
//        
//        1/1
//        21/20
//        35/32
//        9/8
//        7/6
//        6/5
//        5/4
//        21/16
//        4/3
//        7/5
//        35/24
//        3/2
//        14/9
//        8/5
//        5/3
//        7/4
//        15/8
//        63/32
//        2/1
//        
//        ("Grady: A-Grady Sisiutl  12 tone
//        
//        1/1
//        28/27
//        9/8
//        7/6
//        14/11
//        4/3
//        11/8
//        3/2
//        14/9
//        3/2
//        14/9
//        56/33
//        7/4
//        11/6
//        2/1
//        
//        ("Grady: A-Wilson preSisiutl 17
//        
//        1/1
//        28/27
//        9/8
//        7/6
//        14/11
//        4/3
//        11/8
//        3/2
//        14/9
//        3/2
//        14/9
//        56/33
//        7/4
//        11/6
//        2/1
//        
//        ("Grady: A-Dakota Monarda 17 limit
//        1/1
//        17/16
//        10/9
//        7/6
//        5/4
//        4/3
//        17/12
//        3/2
//        14/9
//        5/3
//        7/4
//        17/9
//        2/1
//        
//        ("Grady: A-Grady Beebalm 7 limit
//        
//        1/1
//        17/16
//        9/8
//        7/6
//        5/4
//        4/3
//        17/12
//        3/2
//        14/9
//        5/3
//        16/9
//        17/9
//        2/1
//        
//        ("Grady: A-Schulter Zeta Centauri 12 tone
//        
//        1/1
//        13/12
//        9/8
//        7/6
//        11/9
//        4/3
//        13/9
//        3/2
//        14/9
//        13/8
//        7/4
//        11/6
//        2/1
//        
//        ("Grady: Shulter Shur
//        1/1
//        27/26
//        9/8
//        27/22
//        4/3
//        18/13
//        3/2
//        18/11
//        16/9
//        24/13
//        2/1
//        
//        ("Grady: Poole 17
//        1/1
//        33/32
//        13/12
//        9/8
//        7/6
//        11/9
//        14/11
//        4/3
//        11/8
//        13/9
//        3/2
//        14/9
//        44/27
//        27/16
//        7/4
//        11/6
//        21/11
//        2/1.
//        
////        include
////        these ETs
////
////        7
////        12
////        13
////        15
////        16
////        17
////        19
////        22
////        31
////        41
//        
//        ("Grady: 11limit helix song
//        1/1
//        9/8
//        7/6
//        5/4
//        4/3
//        11/8
//        3/2
//        5/3
//        7/4
//        11/6
//        2/1
//        
//        ("Grady: 17 limit helix song
//        1/1
//        13/12
//        9/8
//        7/6
//        5/4
//        4/3
//        11/8
//        17/12
//        3/2
//        13/8
//        5/3
//        7/4
//        11/6
//        15/16
//        2/1
//        
//        ("Grady: Gary David double 1-3-5-7 hexany 12 tone
//        
//        1/1
//        16/15
//        35/32
//        7/6
//        5/4
//        4/3
//        7/5
//        35/24
//        8/5
//        5/3
//        7/4
//        28/15
//        2/1
//        
//        ("Grady: Wilson double hexany+ 12 tone
//        
//        1/1
//        49/48
//        8/7
//        7/6
//        5/4
//        4/3
//        10/7
//        35/24
//        80/49
//        5/3
//        7/4
//        40/21
//        2/1
//        
//        ("Grady: WILSON TRIPLE HEXANY +
//        
//        1/1
//        15/14
//        9/8
//        7/6
//        5/4
//        21/16
//        10/7
//        3/2
//        45/28
//        5/3
//        7/4
//        15/8
//        2/1
//        
//        ("Grady: WILSON SUPER 7
//        
//        1/1
//        35/32
//        8/7
//        5/4
//        245/192
//        10/7
//        35/24
//        3/2
//        49/32
//        12/7
//        7/4
//        245/128
//        2/1
//        
//        ("Grady: DAVID DUAL HARMONIC SUBHARMONIC
//        1/1
//        16/15
//        9/8
//        6/5
//        9/7
//        4/3
//        7/5
//        3/2
//        8/5
//        12/7
//        9/5
//        28/15
//        2/1
//        
//        ("Grady: WILSONDAVID ENHARMONICS
//        1/1
//        28/27
//        9/8
//        7/6
//        6/5
//        4/3
//        35/24
//        3/2
//        14/9
//        8/5
//        7/4
//        25/18
//        2/1
//        
//        ("Grady: Wilson Meta Meantone (might need to check if it seems off)
//        
//        1/1
//        67/64
//        558/512
//        9/8
//        75/64
//        39/32
//        5/4
//        167/128
//        87/64
//        45/32
//        187/128
//        3/2
//        25/16
//        417/256
//        27/16
//        7/4
//        233/128
//        15/8
//        125/64
//        2/1
//        
//        ("Grady: Wilson first pelog
//        
//        1/1
//        16/15
//        64/55
//        5/4
//        4/3
//        16/11
//        8/5
//        128/75
//        20/11
//        2/1
//        
//        ("Grady: Wilson  meta pelog 1
//        
//        1/1
//        571/512
//        153/128
//        41/32
//        4/3
//        11/8
//        209/128
//        7/4
//        15/8
//        2/1
//        
//        ("Grady: Wilson  meta pelog 2
//        
//        1/1
//        9/8
//        19/16
//        41/32
//        11/8
//        3/2
//        13/8
//        7/4
//        15/8
//        2/1
//        
//        ("Grady: wilson metaptolemy10
//        
//        1/1
//        33/32
//        9/8
//        73/64
//        5/4
//        11/8
//        3/2
//        49/32
//        27/16
//        15/8
//        2/1
//        

        
        
        
        
        
        
        /// scales designed by Erv Wilson.  See http://anaphoria.com/genus.pdf
        (" 7 Highland Bagpipes", {_ = AKPolyphonicNode.tuningTable.presetHighlandBagPipes() } ),
        (" 7 MOS G:0.2641", {_ = AKPolyphonicNode.tuningTable.momentOfSymmetry(generator: 0.2641, level: 5, murchana: 0)}),
        (" 9 MOS G:0.238186", {_ = AKPolyphonicNode.tuningTable.momentOfSymmetry(generator: 0.238186, level: 6, murchana: 0)}),
        ("10 MOS G:0.292", {_ = AKPolyphonicNode.tuningTable.momentOfSymmetry(generator: 0.292, level: 6, murchana: 0)}),
        (" 7 MOS G:0.4057", {_ = AKPolyphonicNode.tuningTable.momentOfSymmetry(generator: 0.4057, level: 5, murchana: 0)}),
        (" 7 MOS G:0.415226", {_ = AKPolyphonicNode.tuningTable.momentOfSymmetry(generator: 0.415226, level: 5, murchana: 0)}),
        (" 7 MOS G:0.436385", {_ = AKPolyphonicNode.tuningTable.momentOfSymmetry(generator: 0.436385, level: 5, murchana: 0)}),
        ("31 Equal Temperament", {_ = AKPolyphonicNode.tuningTable.equalTemperament(notesPerOctave: 31)}),
        ("17 North Indian:17", {_ = AKPolyphonicNode.tuningTable.presetPersian17NorthIndian00_17() } ),
        (" 7 North Indian:Kalyan", {_ = AKPolyphonicNode.tuningTable.presetPersian17NorthIndian01Kalyan() } ),
        (" 7 North Indian:Bilawal", {_ = AKPolyphonicNode.tuningTable.presetPersian17NorthIndian02Bilawal() } ),
        (" 7 North Indian:Khamaj", {_ = AKPolyphonicNode.tuningTable.presetPersian17NorthIndian03Khamaj() } ),
        (" 7 North Indian:KafiOld", {_ = AKPolyphonicNode.tuningTable.presetPersian17NorthIndian04KafiOld() } ),
        (" 7 North Indian:Kafi", {_ = AKPolyphonicNode.tuningTable.presetPersian17NorthIndian05Kafi() } ),
        (" 7 North Indian:Asawari", {_ = AKPolyphonicNode.tuningTable.presetPersian17NorthIndian06Asawari() } ),
        (" 7 North Indian:Bhairavi", {_ = AKPolyphonicNode.tuningTable.presetPersian17NorthIndian07Bhairavi() } ),
        (" 7 North Indian:Bhairav", {_ = AKPolyphonicNode.tuningTable.presetPersian17NorthIndian15Bhairav() } ),
        (" 7 North Indian:Marwa", {_ = AKPolyphonicNode.tuningTable.presetPersian17NorthIndian08Marwa() } ),
        (" 7 North Indian:Purvi", {_ = AKPolyphonicNode.tuningTable.presetPersian17NorthIndian09Purvi() } ),
        (" 7 North Indian:Lalit2", {_ = AKPolyphonicNode.tuningTable.presetPersian17NorthIndian10Lalit2() } ),
        (" 7 North Indian:Todi", {_ = AKPolyphonicNode.tuningTable.presetPersian17NorthIndian11Todi() } ),
        (" 7 North Indian:Lalit", {_ = AKPolyphonicNode.tuningTable.presetPersian17NorthIndian12Lalit() } ),
        (" 7 North Indian:NoName", {_ = AKPolyphonicNode.tuningTable.presetPersian17NorthIndian13NoName() } ),
        (" 7 North Indian:AnandBhairav", {_ = AKPolyphonicNode.tuningTable.presetPersian17NorthIndian14AnandBhairav() } ),
        (" 7 North Indian:Bhairav", {_ = AKPolyphonicNode.tuningTable.presetPersian17NorthIndian15Bhairav() } ),
        (" 7 North Indian:JogiyaTodi", {_ = AKPolyphonicNode.tuningTable.presetPersian17NorthIndian16JogiyaTodi() } ),
        (" 7 North Indian:Madhubanti", {_ = AKPolyphonicNode.tuningTable.presetPersian17NorthIndian17Madhubanti() } ),
        (" 7 North Indian:NatBhairav", {_ = AKPolyphonicNode.tuningTable.presetPersian17NorthIndian18NatBhairav() } ),
        (" 7 North Indian:AhirBhairav", {_ = AKPolyphonicNode.tuningTable.presetPersian17NorthIndian19AhirBhairav() } ),
        (" 7 North Indian:ChandraKanada", {_ = AKPolyphonicNode.tuningTable.presetPersian17NorthIndian20ChandraKanada() } ),
        (" 7 North Indian:BasantMukhair", {_ = AKPolyphonicNode.tuningTable.presetPersian17NorthIndian21BasantMukhari() } ),
        (" 7 North Indian:Champakali", {_ = AKPolyphonicNode.tuningTable.presetPersian17NorthIndian22Champakali() } ),
        (" 7 North Indian:Patdeep", {_ = AKPolyphonicNode.tuningTable.presetPersian17NorthIndian23Patdeep() } ),
        (" 7 North Indian:MohanKauns", {_ = AKPolyphonicNode.tuningTable.presetPersian17NorthIndian24MohanKauns() } ),
        (" 7 North Indian:Parameswari", {_ = AKPolyphonicNode.tuningTable.presetPersian17NorthIndian25Parameswari() } ),
        (" - Tuning From Preset", {_ = 0})
    ]
    
    
   
//
//    /// scales designed by Stephen Taylor
//    //Wilsonic Favorite: MOS G = 0.855088472366333, NPO=13
//    //        ("13 SJT MOS G: 0.855088472366333", {_ = AKPolyphonicNode.tuningTable.momentOfSymmetry(generator: 0.855088472366333, level: 10, murchana: 0)}),
//    ("13 SJT MOS G: 0.855088", {_ = AKPolyphonicNode.tuningTable.momentOfSymmetry(generator: 0.855088, level: 10, murchana: 0)}),
//
//    //Wilsonic Favorite: MOS G = 0.855088472366333, NPO=6
//    (" 6 SJT MOS G: 0.855088", {_ = AKPolyphonicNode.tuningTable.momentOfSymmetry(generator: 0.855088, level: 6, murchana: 0)}),
//
//    //Wilsonic Favorite: MOS G = 0.7914000153541565, NPO=9
//    //        (" 6 SJT MOS G: 0.7914000153541565", {_ = AKPolyphonicNode.tuningTable.momentOfSymmetry(generator: 0.7914000153541565, level: 5, murchana: 0)}),
//    (" 6 SJT MOS G: 0.791400", {_ = AKPolyphonicNode.tuningTable.momentOfSymmetry(generator: 0.791400, level: 5, murchana: 0)}),
//
//    //Wilsonic Favorite: MOS G = 0.7820796370506287, NPO=5
//    //?
//    (" 5 SJT MOS G: 0.78207964", {_ = AKPolyphonicNode.tuningTable.momentOfSymmetry(generator: 0.78207964, level: 5, murchana: 0)}),
//
//    //Wilsonic Favorite: MOS G = 0.6180329918861389, NPO=5
//    //        (" 5 SJT MOS G: 0.6180329918861389", {_ = AKPolyphonicNode.tuningTable.momentOfSymmetry(generator: 0.6180329918861389, level: 0, murchana: 0)}),
//    (" 5 SJT MOS G: 0.618033", {_ = AKPolyphonicNode.tuningTable.momentOfSymmetry(generator: 0.618033, level: 0, murchana: 0)}),
//
//    //!MOS_0.232587_0_0.scl
//    //MOS: G=0.2325, NPO=17, M=0
//    //17
//    //!
//    //28.372765
//    //111.950397
//    //195.528030
//    //279.105592
//    //307.478142
//    //391.056061
//    //474.633551
//    //558.211184
//    //586.583805
//    //670.161438
//    //753.739071
//    //837.316775
//    //865.689468
//    //949.267101
//    //1032.844734
//    //1116.422367
//    //2/1
//    //! Created with the iOS app "Wilsonic" by Marcus Hobbs
//    //!
//    //! 0.000000 ==> Scale Degree: 0, Level: 0
//    //! 28.372765 ==> Scale Degree: 13, Level: 7
//    //! 111.950397 ==> Scale Degree: 9, Level: 6
//    //! 195.528030 ==> Scale Degree: 5, Level: 5
//    //! 279.105592 ==> Scale Degree: 1, Level: 1
//    //! 307.478142 ==> Scale Degree: 14, Level: 7
//    //! 391.056061 ==> Scale Degree: 10, Level: 6
//    //! 474.633551 ==> Scale Degree: 6, Level: 5
//    //! 558.211184 ==> Scale Degree: 2, Level: 2
//    //! 586.583805 ==> Scale Degree: 15, Level: 7
//    //! 670.161438 ==> Scale Degree: 11, Level: 6
//    //! 753.739071 ==> Scale Degree: 7, Level: 5
//    //! 837.316775 ==> Scale Degree: 3, Level: 3
//    //! 865.689468 ==> Scale Degree: 16, Level: 7
//    //! 949.267101 ==> Scale Degree: 12, Level: 6
//    //! 1032.844734 ==> Scale Degree: 8, Level: 5
//    //! 1116.422367 ==> Scale Degree: 4, Level: 4

    
}
