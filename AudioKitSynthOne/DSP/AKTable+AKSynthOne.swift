//
//  AKTable+AKSynthOne.swift
//  AudioKitSynthOne
//
//  Created by Marcus W. Hobbs on 7/23/18.
//  Copyright © 2018 AudioKit. All rights reserved.
//

import Foundation

extension AKTable {

    // set table to sum of sines approximating a sawtooth
    func saw(numberOfHarmonics: Int = 1_024) {
        self.phase = 0

        for i in indices {
            self[i] = 0
        }

        let coefficient = {(harmonic: Int) -> Float in
            return 1 / Float(harmonic)
        }

        for h in 1..<numberOfHarmonics {
            for i in indices {
                self[i] += Float(coefficient(h) * sin(h * 2 * 3.141_592_65 * Float(i + phaseOffset) / Float(count)))
            }
        }
    }

    // set table to sum of sines approximating a square
    func square(numberOfHarmonics: Int = 1_024) {
        self.phase = 0

        for i in indices {
            self[i] = 0
        }

        let coefficient = {(harmonic: Int) -> Float in
            return Float(harmonic % 2) / Float(harmonic)
        }

        for h in 1..<numberOfHarmonics {
            for i in indices {
                self[i] += Float(coefficient(h) * sin(h * 2 * 3.141_592_65 * Float(i + phaseOffset) / Float(count)))
            }
        }
    }

    // set table to sum of sines approximating a triangle
    func triangle(numberOfHarmonics: Int = 1_024) {
        self.phase = 0

        for i in indices {
            self[i] = 0
        }

        let coefficient = {(harmonic: Int) -> Float in
            var c: Float = 0
            let i = harmonic - 1
            let m2 = i % 2
            let m4 = i % 4
            if m4 == 0 {
                c = 1
            } else if m2 == 0 {
                c = -1
            }

            return c / Float(harmonic * harmonic)
        }

        for h in 1..<numberOfHarmonics {
            for i in indices {
                self[i] += Float(coefficient(h) * sin(h * 2 * 3.141_592_65 * Float(i + phaseOffset) / Float(count)))
            }
        }
    }

    // set table to sum of sines approximating a pwm with a period
    func pwm(numberOfHarmonics: Int = 1_024, period: Float = 1 / 8) {
        self.phase = 0

        let t: Float = 1
        let k: Float = period
        let d: Float = k / t
        let a: Float = 1
        let a0: Float = a * d
        for i in indices {
            self[i] = a0
        }

        let coefficient = {(harmonic: Int) -> Float in
            let c: Float = ((2 * a) / (Float(harmonic) * 3.141_592_65)) * sin( Float(harmonic * 3.141_592_65 * d) )
            return c
        }

        // offset the samples by the period
        let sampleOffset = Int(period * count)

        for h in 1..<numberOfHarmonics {
            for i in indices {
                let x = Float(coefficient(h) * cos(h * 2 * 3.141_592_65 * Float(i + phaseOffset) / Float(count)))
                let index = (i + sampleOffset) % count
                self[index] += x
            }
        }

        // finally, convert [0,1] to [-1,1]
        for i in indices {
            self[i] *= 2
            self[i] -= 1
        }
    }
}
