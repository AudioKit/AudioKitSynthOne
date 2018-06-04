//
//  AKS1Tuning.swift
//  AudioKitSynthOne
//
//  Created by AudioKit Contributors on 5/12/18.
//  Copyright © 2018 AudioKit. All rights reserved.
//

class AKS1Tuning: Codable, CustomStringConvertible {

    static let defaultName = "12 ET"
    var name = defaultName

    // 12 ET masterSet as [Double]
    static let defaultMasterSet: [Double] = [1.0, 1.059_463_094_359_295_3, 1.122_462_048_309_373, 1.189_207_115_002_721, 1.259_921_049_894_873_2, 1.334_839_854_170_034_4, 1.414_213_562_373_095_1, 1.498_307_076_876_681_5, 1.587_401_051_968_199_4, 1.681_792_830_507_429, 1.781_797_436_280_678_5, 1.887_748_625_363_386_8]
    var masterSet = defaultMasterSet

    var encoding: String {
        get {
            return AKS1Tuning.encode(inputMasterSet: masterSet)
        }
    }

    var description: String {
        return "\(name): \(masterSet)"
    }

    class public func defaultTuning() -> AKS1Tuning {
        let t = AKS1Tuning()
        t.name = defaultName
        t.masterSet = defaultMasterSet
        return t
    }

    class public func encode(inputMasterSet: [Double]) -> String {
        var retVal = ""
        let validF = inputMasterSet.filter { $0 > 0 }
        let l2 = validF.map({ (input: Double) -> Double in
            var f = input
            while f < 1 { f *= 2 }
            while f > 2 { f /= 2 }
            let p = log2(f).truncatingRemainder(dividingBy: 1)
            return p
        }).sorted()
        for p in l2 {
            let msd = String(format: "%.12f_", p)
            retVal += msd
        }

        return retVal
    }

    init() {}

    init(dictionary: [String: Any]) {
        name = dictionary["name"] as? String ?? AKS1Tuning.defaultName
        masterSet = dictionary["masterSet"] as? [Double] ?? AKS1Tuning.defaultMasterSet
    }
}
