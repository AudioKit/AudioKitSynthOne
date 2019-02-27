//
//  S1Tuning.swift
//  AudioKitSynthOne
//
//  Created by Marcus Hobbbs on 5/12/18.
//  Copyright © 2018 AudioKit. All rights reserved.
//

class Tuning: Codable, CustomStringConvertible {

    // Don't change these property names
    var name = defaultName
    var nameForCell: String {
        get {
            // prepend padded npo
            let npoString = String(npo)
            var retVal = npoString
            let toLength = 3 - npoString.count
            for _ in 0..<toLength {
                retVal = " " + retVal
            }
            retVal += " " + name
            return retVal
        }
    }
    var masterSet = defaultMasterSet
    var order: Int = defaultOrder
    var npo: Int {
        get {
            return masterSet.count
        }
    }

    /// Property defaults
    static let defaultName = "12 ET"
    static let defaultMasterSet: [Double] = [1.0, 1.059_463_094_359_295_3, 1.122_462_048_309_373, 1.189_207_115_002_721, 1.259_921_049_894_873_2, 1.334_839_854_170_034_4, 1.414_213_562_373_095_1, 1.498_307_076_876_681_5, 1.587_401_051_968_199_4, 1.681_792_830_507_429, 1.781_797_436_280_678_5, 1.887_748_625_363_386_8]
    static let defaultOrder: Int = 0


    ///
    var encoding: String {
        get {
            return Tuning.encode(inputMasterSet: masterSet)
        }
    }

    ///
    var description: String {
        return "name:\(name), nameForCell:\(nameForCell), masterSet:\(masterSet)"
    }

    /// The default tuning is always 12ET
    class public func defaultTuning() -> Tuning {
        let t = Tuning()
        t.name = defaultName
        t.masterSet = defaultMasterSet
        return t
    }

    /// Create a key for the scale for each element of its masterSet, to an arbitrary precision
    class public func encode(inputMasterSet: [Double]) -> String {
        let validF = inputMasterSet.filter { $0 > 0 }
        let l2 = validF.map({ (input: Double) -> Double in
            var f = input
            while f < 1 { f *= 2 }
            while f > 2 { f /= 2 }
            let p = log2(f).truncatingRemainder(dividingBy: 1)
            return p
        }).sorted()

        var retVal = ""
        for p in l2 {
            let msd = String(format: "%.12f_", p)
            retVal += msd
        }

        return retVal
    }

    ///
    init() {}

    /// Codable: property names must match dictionary keys
    init(dictionary: [String: Any]) {
        name = dictionary["name"] as? String ?? Tuning.defaultName
        masterSet = dictionary["masterSet"] as? [Double] ?? Tuning.defaultMasterSet
        order = dictionary["order"] as? Int ?? Tuning.defaultOrder
    }
}
