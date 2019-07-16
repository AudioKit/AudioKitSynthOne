//
//  Tunings+Drawing.swift
//  AudioKitSynthOne
//
//  Created by Marcus W. Hobbs on 7/17/19.
//  Copyright © 2019 AudioKit. All rights reserved.
//

import Foundation
import UIKit


extension Tunings {

    /// return tuple of ([master set of frequencies], [master set of pitches]) both arrays of length npo, normalized
    public static func masterFrequenciesFromGlobalTuningTable() -> ([Double], [Double], [Double]) {

        let mmm = AKPolyphonicNode.tuningTable.masterSet
        var mf: [Double] = [1]
        var mp: [Double] = [0]
        var mc: [Double] = [0]
        if mmm.count < 1 { return (mf, mp, mc) }
        mf.removeAll()
        mp.removeAll()
        mc.removeAll()
        for f in mmm {
            mf.append(f)
            mp.append(log2(f))
            mc.append(log2(f) * 1_200)
        }
        return (mf, mp, mc)
    }

    public static func color(forPitch pitch: Double,
                             saturation: CGFloat = 0.625,
                             brightness: CGFloat = 1,
                             alpha: CGFloat = 0.75) -> UIColor {

        let hue = CGFloat(pitch.truncatingRemainder(dividingBy: 1))
        let r = UIColor(hue: hue, saturation: saturation, brightness: brightness, alpha: alpha)
        return r
    }


    public static func color(forNoteNumber nn: MIDINoteNumber, isOn: Bool) -> UIColor {

        let pitch = Tunings.pitch(forNoteNumber: nn)
        let saturation = 0.65 * CGFloat(0.625)
//        let brightness = CGFloat(isOn ? 1 : 0.45)
//        let brightness = CGFloat(isOn ? 1 : 0.35)
        let brightness = CGFloat(isOn ? 1 : 0.25)
        let alpha = CGFloat(1)
        let color = Tunings.color(forPitch: pitch, saturation: saturation, brightness: brightness, alpha: alpha)
        return color
    }

    public static func pitch(forNoteNumber nn: MIDINoteNumber) -> Double {

        guard (0...127).contains(Int32(nn)) else { return 0 }

        let masterSet = AKPolyphonicNode.tuningTable.masterSet
        guard masterSet.count > 0 else { return 0 }

        let npo = Int32(masterSet.count)
        var nn = Int32(Int32(nn))
        nn -= Int32(AKPolyphonicNode.tuningTable.middleCNoteNumber)
        while nn < 0 { nn = nn + Int32(npo) }
        while nn >= npo { nn = nn - Int32(npo) }
        nn = nn % npo
        let frequency = masterSet[Int(nn)]
        guard frequency > 0 else { return 0 }

        return log2(frequency)
    }

    public static func text(forPitch pitch: Pitch, labelMode: TuningScaleDegreeDescription) -> String {

        var result = ""
        switch labelMode {
        case .frequency:
            let harmonic = pow(2, pitch)
            result = String(format: "%1.3f", harmonic)
        case .pitch:
            let harmonic = pitch
            result = String(format: "%.4f", harmonic)
        case .cents:
            let harmonic = pitch * 1_200
            result = String(format: "%.0f", harmonic)
        case .harmonic:
            result = Tunings.approximateHarmonicFromPitch(pitch)
        }
        return result
    }

    public static func text(forNoteNumber nn: MIDINoteNumber, labelMode: TuningScaleDegreeDescription) -> String {

        let pitch = Tunings.pitch(forNoteNumber: nn)
        let text = Tunings.text(forPitch: pitch, labelMode: labelMode)
        return text
    }

    public static func generalLineP(_ context: CGContext, _ p0: CGPoint, _ p1: CGPoint) {

        generalLine(context, p0.x, p0.y, p1.x, p1.y)
    }

    public static func generalLine(_ context: CGContext, _ x1: CGFloat, _ y1: CGFloat, _ x2: CGFloat, _ y2: CGFloat) {

        context.beginPath()
        context.move(to: CGPoint(x: x1, y: y1))
        context.addLine(to: CGPoint(x: x2, y: y2))
        context.strokePath()
    }
}
