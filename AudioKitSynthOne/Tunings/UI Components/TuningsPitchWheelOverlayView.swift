//
//  TuningsPitchWheelOverlayView.swift
//  AudioKitSynthOne
//
//  Created by Marcus W. Hobbs on 7/20/19.
//  Copyright © 2019 AudioKit. All rights reserved.
//

///Transparent overlay for TuningsPitchWheelView which displays amplitudes of playing notes

public class TuningsPitchWheelOverlayView: UIView {
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

    // Tightly-coupled to TuningsPitchWheelView draw
    override public func draw(_ rect: CGRect) {
        guard let context = UIGraphicsGetCurrentContext() else { return }
        context.saveGState()
        let pxyCopy = pxy
        let px0Copy = px0
        let npo = Int32(pxyCopy.count)
        if npo < 1 { return }

        // Draw playing notes
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
                    while nn < 0 { nn = nn + npo }
                    while nn >= npo { nn = nn - npo }
                    nn = nn % npo
                    let p = pxyCopy[Int(nn)]
                    let bigR = CGFloat(v * 26)
                    let a = bigR < 36 ? bigR / 36 : 1
                    let pitch = masterPitch[Int(nn)]

                    // LINE
                    let vv = powf(Float(playingNote.velocity)/127, 0.175)
                    Tunings.color(forPitch: pitch,
                                  saturation: 0.36,
                                  brightness: 1,
                                  alpha: CGFloat(vv * 0.65)).setStroke()
                    context.setLineWidth(CGFloat(v * 2 * 1.5))
                    Tunings.generalLineP(context, px0Copy, p)

                    // BIG DOT CENTER
                    let bfpc = Tunings.color(forPitch: pitch, alpha: CGFloat(vv) )
                    bfpc.setStroke()
                    bfpc.setFill()
                    let bigDc: CGFloat = bigR * 0.25
                    let bigDotDc = CGRect(x: px0Copy.x - bigDc / 2,
                                          y: px0Copy.y - bigDc / 2,
                                          width: bigDc,
                                          height: bigDc)
                    context.fillEllipse(in: bigDotDc)

                    // BIG DOT
                    let bfp = Tunings.color(forPitch: pitch, alpha: 1)
                    bfp.setStroke()
                    bfp.setFill()
                    let bigD: CGFloat = 12
                    let bigDotD = CGRect(x: p.x - bigD / 2,
                                         y: p.y - bigD / 2,
                                         width: bigD,
                                         height: bigD)
                    context.fillEllipse(in: bigDotD)

                    // BIG DOT OUTLINE
                    Tunings.color(forPitch: pitch,
                                  saturation: 0.36,
                                  brightness: 1,
                                  alpha: a).setStroke()
                    context.setLineWidth(1)
                    let bigDotR = CGRect(x: p.x - bigR / 2,
                                         y: p.y - bigR / 2,
                                         width: bigR,
                                         height: bigR)
                    context.strokeEllipse(in: bigDotR)
                }
            }
        }

        // POP
        context.restoreGState()
    }
}
