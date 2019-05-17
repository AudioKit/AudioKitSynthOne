//
//  S1TuningTable.swift
//  AudioKitSynthOne
//
//  Created by Marcus W. Hobbs on 5/14/19.
//  Copyright © 2019 AudioKit. All rights reserved.
//

public protocol S1TuningTable {

    func setTuningTable(_ frequency: Double, index: Int)

    func getTuningTableFrequency(_ index: Int) -> Double

    func setTuningTableNPO(_ npo: Int)
}
