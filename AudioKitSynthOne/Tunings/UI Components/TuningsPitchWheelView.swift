//
//  TuningsPitchWheelView.swift
//  AudioKitSynthOne
//
//  Created by Marcus Hobbs on 5/6/18.
//  Copyright © 2018 AudioKit. All rights reserved.
//

import UIKit
import AudioKit

enum TuningsPitchWheelViewLabelMode: Int {
    case frequency = 0
    case pitch = 1
    case cents = 2
    case harmonic = 3
    func simpleDescription() -> String {
        switch self {
        case .frequency:
            return "frequency"
        case .pitch:
            return "pitch"
        case .cents:
            return "cents"
        case .harmonic:
            return "harmonic"
        }
    }
}

/// Visualize an octave-based tuning as log2(frequency) modulo 1.  12 o'clock = middle C (note number 60)

public class TuningsPitchWheelView: UIView {

    var masterFrequency: [Double]?
    var masterPitch: [Double]?
    var masterCents: [Double]?
    var pxy = [CGPoint]()
    var px0 = CGPoint()
    var labelMode: TuningsPitchWheelViewLabelMode = .harmonic


    var overlayView: TuningsPitchWheelOverlayView

    public required init?(coder aDecoder: NSCoder) {
        self.overlayView = TuningsPitchWheelOverlayView(frame: CGRect())
        super.init(coder: aDecoder)
        configure()
    }

    public override init(frame: CGRect) {
        self.overlayView = TuningsPitchWheelOverlayView(frame: frame)
        super.init(frame: frame)
        configure()
    }

    internal func configure() {
        self.isOpaque = false
        self.backgroundColor = UIColor.clear
        overlayView.frame = self.bounds
        overlayView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        addSubview(overlayView)
    }

    /// return tuple of ([master set of frequencies], [master set of pitches]) both arrays of length npo, normalized
    internal func masterFrequenciesFromGlobalTuningTable() -> ([Double], [Double], [Double]) {
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

    public func updateFromGlobalTuningTable() {
        DispatchQueue.global(qos: .userInteractive).async {
            let gtt = self.masterFrequenciesFromGlobalTuningTable()
            self.masterFrequency = gtt.0
            self.masterPitch = gtt.1
            self.masterCents = gtt.2
            self.overlayView.masterPitch = gtt.1

            DispatchQueue.main.async {
                self.setNeedsDisplay()
                self.overlayView.setNeedsDisplay()
            }
        }
    }

    ///update overlay
    public func playingNotesDidChange(_ playingNotes: PlayingNotes) {
        overlayView.playingNotes = playingNotes
        overlayView.setNeedsDisplay()
    }

    ///draw the state of AKPolyphonicNode.tuningTable.masterSet as a PitchWheel
    override public func draw(_ rect: CGRect) {
        guard let masterSet = masterPitch else { return }
        guard let context = UIGraphicsGetCurrentContext() else { return }

        context.saveGState()

        let x: CGFloat = rect.origin.x
        let y: CGFloat = rect.origin.y
        let w: CGFloat = rect.size.width
        let h: CGFloat = rect.size.height
        let inset: CGFloat = 0.85 + 0.1 - 0.05
        let r = inset * (w < h ? w : h)
        let xp = x + 0.5 * w
        let yp = y + 0.5 * h
        var fontSize: CGFloat = 16
        if Conductor.sharedInstance.device == .phone {
            fontSize = 15
        }
        let sdf = UIFont.systemFont(ofSize: fontSize)
        let bdf2 = UIFont.boldSystemFont(ofSize: 2 * fontSize)
        UIColor.black.setStroke()

        // Origin
        let mspx0 = CGPoint(x: xp, y: yp)

        // Array of pitches
        var mspxy = [CGPoint]()

        for p in masterSet {
            context.setLineWidth(1)
            let cfp = TuningsPitchWheelView.color(forPitch: p, brightness: 1, alpha: 0.65)
            cfp.setStroke()
            cfp.setFill()

            // Scale degree line: polar (origin...p2, log2 f % 1)
            let r0: CGFloat = 0
            let r1f: CGFloat = 1 - 0.25 + 0.1
            let r1: CGFloat = r * r1f * 1.1
            let r2: CGFloat = r * r1f * 0.65
            let p00: CGPoint = horagram01ToCartesian01(p: CGPoint(x: p, y: Double(0.5 * r0)))
            let p0 = CGPoint(x: p00.x + xp, y: p00.y + yp)
            let p11 = horagram01ToCartesian01(p: CGPoint(x: p, y: Double(0.5 * r1)))
            let p1 = CGPoint(x: p11.x + xp, y: p11.y + yp)
            let p22 = horagram01ToCartesian01(p: CGPoint(x: p, y: Double(0.5 * r2)))
            let p2: CGPoint = CGPoint(x: p22.x + xp, y: p22.y + yp)

            mspxy.append(p2)
            generalLineP(context, p0, p2)

            // BIG DOT
            let bfp = TuningsPitchWheelView.color(forPitch: p, alpha: 1)
            bfp.setStroke()
            bfp.setFill()
            let bigR: CGFloat = 12
            let bigDotR = CGRect(x: CGFloat(p2.x - 0.5 * bigR),
                                 y: CGFloat(p2.y - 0.5 * bigR),
                                 width: bigR, height: bigR)
            context.fillEllipse(in: bigDotR)

            // LABEL MODE
            var msd: String
            switch labelMode {
            case .frequency:
                // draw frequency
                let harmonic = pow(2, p)
                msd = String(format: "%1.3f", harmonic)
            case .pitch:
                // draw pitch
                let harmonic = p
                msd = String(format: "%.4f", harmonic)
            case .cents:
                // draw pitch in cents
                let harmonic = p * 1_200
                msd = String(format: "%.0f", harmonic)
            case .harmonic:
                // draw harmonic approximation of pitch
                msd = Tunings.approximateHarmonicFromPitch(p)
            }
            _ = msd.drawCentered(atPoint: p1, font: sdf, color: cfp)

        }

        pxy = mspxy
        px0 = mspx0
        self.overlayView.pxy = pxy
        self.overlayView.px0 = px0

        // draw NPO
        UIColor.darkGray.setStroke()
        UIColor.lightGray.setFill()
        let npostr = "\(masterSet.count)"
        let npopt = CGPoint(x: 1 * fontSize, y: 1 * fontSize)
        _ = npostr.drawLeft(atPoint: npopt, font: bdf2, color: UIColor.lightGray, drawStroke: false)

        // draw label mode
        UIColor.darkGray.setStroke()
        UIColor.lightGray.setFill()
        let lmpt = CGPoint(x: npopt.x, y: npopt.y + 2 * fontSize)

        var lmstr: String
        switch labelMode {
        case .frequency:
            lmstr = "Frequency"
        case .pitch:
            lmstr = "Pitch"
        case .cents:
            lmstr = "Cents"
        case .harmonic:
            lmstr = "Harmonic"
        }
        _ = lmstr.drawLeft(atPoint: lmpt, font: sdf, color: UIColor.darkGray, drawStroke: false)

        // POP
        context.restoreGState()
    }

    override public func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        for _ in touches {
            switch labelMode {
            case .frequency:
                labelMode = .pitch
            case .pitch:
                labelMode = .cents
            case .cents:
                labelMode = .harmonic
            case .harmonic:
                labelMode = .frequency
            }
            setNeedsDisplay()
        }
    }

}

extension TuningsPitchWheelView {

    public class func color(forPitch pitch: Double,
                            saturation: CGFloat = 0.625,
                            brightness: CGFloat = 1,
                            alpha: CGFloat = 0.75) -> UIColor {
        let hue = CGFloat(pitch.truncatingRemainder(dividingBy: 1))
        let r = UIColor(hue: hue, saturation: saturation, brightness: brightness, alpha: alpha)
        return r
    }

    func horagram01ToCartesian01(p: CGPoint) -> CGPoint {
        let thetaRadians: CGFloat = CGFloat(radians01(d01: Float(p.x)) - 0.5 * Double.pi) // clockwise
        let x = p.y * cos(thetaRadians)
        let y = p.y * sin(thetaRadians)
        return CGPoint(x: x, y: y)
    }

    func radians01(d01: Float) -> Float {
        return Float(d01 * 2 * Double.pi)
    }

    func generalLineP(_ context: CGContext, _ p0: CGPoint, _ p1: CGPoint) {
        generalLine(context, p0.x, p0.y, p1.x, p1.y)
    }

    func generalLine(_ context: CGContext, _ x1: CGFloat, _ y1: CGFloat, _ x2: CGFloat, _ y2: CGFloat) {
        context.beginPath()
        context.move(to: CGPoint(x: x1, y: y1))
        context.addLine(to: CGPoint(x: x2, y: y2))
        context.strokePath()
    }
}


private extension String {

    func drawCentered(atPoint point: CGPoint, font: UIFont, color: UIColor, drawStroke: Bool = true) -> CGSize {
        let labelSize = self.size(withAttributes: [.font: font, .strokeColor: color])
        let centeredAvgP = CGPoint(x: point.x - labelSize.width / 2.0, y: point.y - labelSize.height / 2.0)

        var attributes = [NSAttributedString.Key: Any]()
        attributes[.font] = font
        attributes[.strokeWidth] = 12

        if drawStroke {
            attributes[.strokeColor] = UIColor.black
            self.draw(at: centeredAvgP, withAttributes: attributes)
        }

        attributes.removeValue(forKey: .strokeWidth)
        attributes.removeValue(forKey: .strokeColor)
        attributes[.foregroundColor] = color
        self.draw(at: centeredAvgP, withAttributes: attributes)

        return labelSize
    }

    func drawLeft(atPoint point: CGPoint, font: UIFont, color: UIColor, drawStroke: Bool = true) -> CGSize {
        let labelSize = self.size(withAttributes: [.font: font, .strokeColor: color])
        let centeredAvgP = CGPoint(x: point.x, y: point.y)

        var attributes = [NSAttributedString.Key: Any]()
        attributes[.font] = font
        attributes[.strokeWidth] = 12

        if drawStroke {
            attributes[.strokeColor] = UIColor.black
            self.draw(at: centeredAvgP, withAttributes: attributes)
        }

        attributes.removeValue(forKey: .strokeWidth)
        attributes.removeValue(forKey: .strokeColor)
        attributes[.foregroundColor] = color
        self.draw(at: centeredAvgP, withAttributes: attributes)

        return labelSize
    }

}

///transparent overlay for tuning view which displays amplitudes of playing notes
public class TuningsPitchWheelOverlayView: UIView {

// common code between draw and overlay view draw
    func generalLineP(_ context: CGContext, _ p0: CGPoint, _ p1: CGPoint) {
        generalLine(context, p0.x, p0.y, p1.x, p1.y)
    }

    func generalLine(_ context: CGContext, _ x1: CGFloat, _ y1: CGFloat, _ x2: CGFloat, _ y2: CGFloat) {
        context.beginPath()
        context.move(to: CGPoint(x: x1, y: y1))
        context.addLine(to: CGPoint(x: x2, y: y2))
        context.strokePath()
    }
// move

    var pxy = [CGPoint]()
    var px0 = CGPoint()
    var masterPitch = [Double]()
    var playingNotes: PlayingNotes?

    required public override init(frame: CGRect) {
        super.init(frame: frame)
        self.isOpaque = false
        self.backgroundColor = UIColor.clear
    }

    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.isOpaque = false
        self.backgroundColor = UIColor.clear
    }

    override public func draw(_ rect: CGRect) {

        guard let context = UIGraphicsGetCurrentContext() else { return }
        context.saveGState()

        let pxyCopy = pxy
        let px0Copy = px0
        let npo = Int32(pxyCopy.count)
        if npo < 1 { return }

        if let pn = playingNotes {

            // must match S1_MAX_POLYPHONY
            let na = [pn.playingNotes.0, pn.playingNotes.1, pn.playingNotes.2,
                      pn.playingNotes.3, pn.playingNotes.4, pn.playingNotes.5]

            for playingNote in na where playingNote.noteNumber != -1 {
                var v = Double(playingNote.amp)
                v = pow(2 * v, 0.415926)
                if v > 0 {
                    var nn = playingNote.noteNumber + playingNote.transpose
                    nn -= Int32(AKPolyphonicNode.tuningTable.middleCNoteNumber)
                    while nn < 0 { nn = nn + Int32(npo) }
                    while nn >= npo { nn = nn - Int32(npo) }
                    nn = nn % npo
                    let p = pxyCopy[Int(nn)]
                    let bigR = CGFloat(v * 26)
                    let a = bigR < 36 ? bigR / 36 : 1
                    let pitch = masterPitch[Int(nn)]

                    // LINE
                    let vv = powf(Float(playingNote.velocity)/127, 0.25)
                    TuningsPitchWheelView.color(forPitch: pitch,
                                                saturation: 0.36,
                                                brightness: 1,
                                                alpha: CGFloat(vv * 0.65)).setStroke()
                    context.setLineWidth(CGFloat(v * 2 * 1.5))
                    generalLineP(context, px0Copy, p)

                    // BIG DOT CENTER
                    let bfpc = TuningsPitchWheelView.color(forPitch: pitch, alpha: 0.5 * a)
                    bfpc.setStroke()
                    bfpc.setFill()
                    //let bigDc: CGFloat = 12
                    let bigDc: CGFloat = bigR * 0.25
                    let bigDotDc = CGRect(x: px0Copy.x - bigDc / 2, y: px0Copy.y - bigDc / 2, width: bigDc, height: bigDc)
                    //let bigDotDc = CGRect(x: px0Copy.x - bigR / 2, y: px0Copy.y - bigR / 2, width: bigR, height: bigR)
                    context.fillEllipse(in: bigDotDc)


                    // BIG DOT
                    let bfp = TuningsPitchWheelView.color(forPitch: pitch, alpha: 1)
                    bfp.setStroke()
                    bfp.setFill()
                    let bigD: CGFloat = 12
                    let bigDotD = CGRect(x: p.x - bigD / 2, y: p.y - bigD / 2, width: bigD, height: bigD)
                    context.fillEllipse(in: bigDotD)

                    // BIG DOT OUTLINE
                    TuningsPitchWheelView.color(forPitch: pitch,
                                                saturation: 0.36,
                                                brightness: 1,
                                                alpha: a).setStroke()
                    context.setLineWidth(1)
                    let bigDotR = CGRect(x: p.x - bigR / 2, y: p.y - bigR / 2, width: bigR, height: bigR)
                    context.strokeEllipse(in: bigDotR)
                }
            }
        }

        // POP
        context.restoreGState()
    }
}
