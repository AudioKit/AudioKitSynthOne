//
//  TuningsPitchWheelView.swift
//  AudioKitSynthOne
//
//  Created by Marcus W. Hobbs on 5/6/18.
//  Copyright © 2018 AudioKit. All rights reserved.
//

import UIKit
import AudioKit

public class TuningsPitchWheelView: UIView {

    var overlayView: TuningsPitchWheelOverlayView
    var masterPitch: [Double]?
    var masterFrequency: [Double]?
    var pxy = [CGPoint]()

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

    public func updateFromGlobalTuningTable() {
        DispatchQueue.global(qos: .background).async {
            // no access to the master set so recreate it from midi note numbers [60, 60 + npo]
            let mc = AKPolyphonicNode.tuningTable.middleCFrequency
            if mc < 1 { return }
            let npo = AKPolyphonicNode.tuningTable.npo
            if npo < 1 { return }
            var mp = [Double]()
            var mf = [Double]()
            for i: Int in 0..<npo {
                let nn = Int(AKPolyphonicNode.tuningTable.middleCNoteNumber) + i
                let f = AKPolyphonicNode.tuningTable.frequency(forNoteNumber: MIDINoteNumber(nn)) / mc
                mf.append(f)
                let p = log2(f)
                mp.append(p)
            }

            self.masterFrequency = mf
            self.masterPitch = mp
            self.overlayView.masterPitch = mp

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
        let fontSize: CGFloat = 16
        let sdf = UIFont.systemFont(ofSize: fontSize)
        let bdf2 = UIFont.boldSystemFont(ofSize: 2 * fontSize)
        UIColor.black.setStroke()

        var mspxy = [CGPoint]()
        for (_, p) in masterSet.enumerated() {
            context.setLineWidth(1)
            let cfp = TuningsPitchWheelView.color(forPitch: p, brightness: 1, alpha: 0.65)
            cfp.setStroke()
            cfp.setFill()

            // Scale degree line: polar (origin...p2, log2 f % 1)
            let r0: CGFloat = 0
            let r1f: CGFloat = 1 - 0.25 + 0.1
            let r1: CGFloat = r * r1f
            let r2: CGFloat = r * r1f * (0.75 - 0.05 - 0.05)
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

            // draw text of log2 f
            let msd = String(format: "%.04f", p)
            _ = msd.drawCentered(atPoint: p1, font: sdf, color: cfp)
        }
        pxy = mspxy
        self.overlayView.pxy = pxy

        // draw NPO
        UIColor.darkGray.setStroke()
        UIColor.lightGray.setFill()
        let npostr = "\(masterSet.count)"
        let npopt = CGPoint(x: 2 * fontSize, y: 2 * fontSize)
        _ = npostr.drawCentered(atPoint: npopt, font: bdf2, color: UIColor.lightGray, drawStroke: false)

        // POP
        context.restoreGState()
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

        var attributes = [NSAttributedStringKey: Any]()
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

    var pxy = [CGPoint]()
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
        context.setLineWidth(1)
        let pxyCopy = pxy
        let npo = Int32(pxyCopy.count)
        if npo < 1 { return }

        if let pn = playingNotes {
            // must match AKS1_MAX_POLYPHONY
            let na = [pn.playingNotes.0, pn.playingNotes.1, pn.playingNotes.2,
                      pn.playingNotes.3, pn.playingNotes.4, pn.playingNotes.5]
            for playingNote in na where playingNote.noteNumber != -1 {
                let v = 2 * playingNote.amp
                if v > 0 {
                    var nn = playingNote.noteNumber - Int32(AKPolyphonicNode.tuningTable.middleCNoteNumber)
                    while nn < 0 { nn = nn + Int32(npo) }
                    while nn >= npo { nn = nn - Int32(npo) }
                    nn = nn % npo
                    let p = pxyCopy[Int(nn)]
                    let bigR = CGFloat(v * 26)
                    let a = bigR < 36 ? bigR / 36 : 1
                    let pitch = masterPitch[Int(nn)]
                    TuningsPitchWheelView.color(forPitch: pitch,
                                                saturation: 0.36,
                                                brightness: 1,
                                                alpha: a).setStroke()
                    let bigDotR = CGRect(x: p.x - bigR / 2, y: p.y - bigR / 2, width: bigR, height: bigR)
                    context.strokeEllipse(in: bigDotR)
                }
            }
        }

        // POP
        context.restoreGState()
    }
}
