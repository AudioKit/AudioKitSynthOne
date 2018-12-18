//
//  Tunings+Math.swift
//  AudioKitSynthOne
//
//  Created by Marcus Hobbs on 6/1/18.
//  Copyright © 2018 AudioKit. All rights reserved.
//

import Foundation
import AudioKit

extension Tunings {

    // MARK: - Helpers

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
