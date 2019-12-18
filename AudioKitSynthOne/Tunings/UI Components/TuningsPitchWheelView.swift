//
//  TuningsPitchWheelView.swift
//  AudioKitSynthOne
//
//  Created by Marcus Hobbs on 5/6/18.
//  Copyright © 2018 AudioKit. All rights reserved.
//

import UIKit
import AudioKit

/// Visualize an octave-based tuning as log2(frequency) modulo 1.  12 o'clock = middle C (note number 60)

public class TuningsPitchWheelView: UIView {

    var masterFrequency: [Double]?
    var masterPitch: [Double]?
    var masterCents: [Double]?
    var pxy = [CGPoint]()
    var px0 = CGPoint()
    var labelMode: TuningScaleDegreeDescription = .harmonic
    var overlayView: TuningsPitchWheelOverlayView

    // MARK: - INIT

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
        overlayView.removeFromSuperview()
        addSubview(overlayView)

        NotificationCenter.default.removeObserver(self, name: .tuningDidChange, object: nil)
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(updateFromGlobalTuningTable(notification:)),
                                               name: .tuningDidChange,
                                               object: nil)
    }

    deinit {
        NotificationCenter.default.removeObserver(self, name: .tuningDidChange, object: nil)
    }

    // MARK: - Drawing

    @objc internal func updateFromGlobalTuningTable(notification: NSNotification) {
        DispatchQueue.global(qos: .userInteractive).async {
            let gtt = Tunings.masterFrequenciesFromGlobalTuningTable()
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
    ///This is tightly-coupled to TuningsPitchWheelOverlayView draw
    override public func draw(_ rect: CGRect) {
        guard let masterSet = masterPitch else { return }
        guard let context = UIGraphicsGetCurrentContext() else { return }

        // PUSH
        context.saveGState()
        UIColor.black.setStroke()

        // LAYOUT
        let x: CGFloat = rect.origin.x
        let y: CGFloat = rect.origin.y
        let w: CGFloat = rect.size.width
        let h: CGFloat = rect.size.height
        let inset: CGFloat = 0.85 + 0.1 - 0.05
        let r = inset * (w < h ? w : h)
        let xp = x + 0.5 * w
        let yp = y + 0.5 * h
        let fontSize: CGFloat = Conductor.sharedInstance.device == .phone ? 15 : 16
        let sdf = UIFont.systemFont(ofSize: fontSize)
        let bdf2 = UIFont.boldSystemFont(ofSize: 2 * fontSize)
        let mspx0 = CGPoint(x: xp, y: yp)
        var mspxy = [CGPoint]()

        // DRAW EACH DEGREE
        for p in masterSet {
            context.setLineWidth(1)
            let cfp = Tunings.color(forPitch: p, brightness: 1, alpha: 0.25)
            cfp.setStroke()
            cfp.setFill()

            // Scale degree line: polar (origin...p2, log2 f % 1)
            let r0: CGFloat = 0
            let r1f: CGFloat = 1 - 0.25 + 0.1
            let r1: CGFloat = r * r1f * 1.1
            let r2: CGFloat = r * r1f * 0.65
            let p00: CGPoint = Tunings.horagram01ToCartesian01(p: CGPoint(x: p, y: Double(0.5 * r0)))
            let p0 = CGPoint(x: p00.x + xp, y: p00.y + yp)
            let p11 = Tunings.horagram01ToCartesian01(p: CGPoint(x: p, y: Double(0.5 * r1)))
            let p1 = CGPoint(x: p11.x + xp, y: p11.y + yp)
            let p22 = Tunings.horagram01ToCartesian01(p: CGPoint(x: p, y: Double(0.5 * r2)))
            let p2: CGPoint = CGPoint(x: p22.x + xp, y: p22.y + yp)

            // LINE
            mspxy.append(p2)
            Tunings.generalLineP(context, p0, p2)

            // BIG DOT
            let bfp = Tunings.color(forPitch: p, alpha: 0.618)
            bfp.setStroke()
            bfp.setFill()
            let bigR: CGFloat = 12
            let bigDotR = CGRect(x: CGFloat(p2.x - 0.5 * bigR),
                                 y: CGFloat(p2.y - 0.5 * bigR),
                                 width: bigR, height: bigR)
            context.fillEllipse(in: bigDotR)

            // LABEL
            let cfd = Tunings.color(forPitch: p, brightness: 1, alpha: 0.75)
            let msd = Tunings.text(forPitch: p, labelMode: labelMode)
            _ = msd.drawCentered(atPoint: p1, font: sdf, color: cfd)

        }

        // CACHE FOR OVERLAY
        pxy = mspxy
        px0 = mspx0
        self.overlayView.pxy = pxy
        self.overlayView.px0 = px0

        // NPO
        UIColor.darkGray.setStroke()
        UIColor.lightGray.setFill()
        let npostr = "\(masterSet.count)"
        let npopt = CGPoint(x: 1 * fontSize, y: 1 * fontSize)
        _ = npostr.drawLeft(atPoint: npopt, font: bdf2, color: UIColor.lightGray, drawStroke: false)

        // LABEL
        UIColor.darkGray.setStroke()
        UIColor.lightGray.setFill()
        let lmpt = CGPoint(x: npopt.x, y: npopt.y + 2 * fontSize)
        let lmstr = labelMode.simpleDescription()
        _ = lmstr.drawLeft(atPoint: lmpt, font: sdf, color: UIColor.darkGray, drawStroke: false)

        // POP
        context.restoreGState()
    }

    // MARK: - Touches

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

