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
    
    public func updateFromGlobalTuningTable() {
        DispatchQueue.main.async {
            self.setNeedsDisplay()
        }
    }
    
    //draw the state of AKPolyphonicNode.tuningTable.masterSet as a PitchWheel
    override public func draw(_ rect: CGRect) {
        guard let context = UIGraphicsGetCurrentContext() else { return }
        context.saveGState()
        #colorLiteral(red: 0.2549019754, green: 0.2745098174, blue: 0.3019607961, alpha: 1).setFill()
        context.fill(rect)
        
        let mc = AKPolyphonicNode.tuningTable.middleCFrequency
        if mc < 1 { return }
        let npo = AKPolyphonicNode.tuningTable.npo
        if npo < 1 { return }
        let x: CGFloat = rect.origin.x
        let y: CGFloat = rect.origin.y
        let w: CGFloat = rect.size.width
        let h: CGFloat = rect.size.height
        let inset: CGFloat = 0.85
        let r = inset * (w < h ? w : h)
        let xp = x + 0.5 * w
        let yp = y + 0.5 * h
        var masterPitch = [Double]()
        let fontSize: CGFloat = 16
        let sdf = UIFont.systemFont(ofSize: fontSize)
        let bdf = UIFont.boldSystemFont(ofSize: fontSize)
        UIColor.black.setStroke()
        
        // we don't have access to the master set so recreate it from (middle c nn, + npo)
        for i: Int in 0..<npo {
            let nn = Int(AKPolyphonicNode.tuningTable.middleCNoteNumber) + i
            let f = AKPolyphonicNode.tuningTable.frequency(forNoteNumber: MIDINoteNumber(nn)) / mc
            let p = log2(f)
            masterPitch.append(p)
        }
        
        for (_, p) in masterPitch.enumerated() {
            context.setLineWidth(1)
            let cfp = color(forPitch: p)
            cfp.setStroke()
            cfp.setFill()
            
            // Scale degree line: polar (origin...p2, log2 f % 1)
            let r0: CGFloat = 0
            let r1f: CGFloat = 1 - 0.25 + 0.1
            let r1: CGFloat = r * r1f
            let r2: CGFloat = r * r1f * 0.75
            let p00: CGPoint = horagram01ToCartesian01(p: CGPoint.init(x: p, y: Double(0.5 * r0)))
            let p0 = CGPoint.init(x: p00.x + xp, y: p00.y + yp)
            let p11 = horagram01ToCartesian01(p: CGPoint.init(x:p, y: Double(0.5 * r1)))
            let p1 = CGPoint.init(x: p11.x + xp, y: p11.y + yp)
            let p22 = horagram01ToCartesian01(p: CGPoint.init(x: p, y: Double(0.5 * r2)))
            let p2: CGPoint = CGPoint.init(x: p22.x + xp, y: p22.y + yp)
            generalLineP(context, p0, p2)
            
            // BIG DOT
            let bigR: CGFloat = 0.5 * 14
            let bigDotR = CGRect(x: CGFloat(p2.x - 0.5 * bigR), y: CGFloat(p2.y - 0.5 * bigR), width: bigR, height: bigR)
            context.fillEllipse(in: bigDotR)
            
            // draw text of log2 f
            let msd = "\(p.decimalString)"
            _ = msd.drawCentered(atPoint: p1, font: sdf, color: cfp)
        }
        
        // draw NPO
        UIColor.black.setStroke()
        UIColor.black.setFill()
        let npostr = "\(npo)"
        let npopt =  CGPoint.init(x: fontSize, y: fontSize)
        _ = npostr.drawCentered(atPoint: npopt, font: bdf, color: UIColor.black)
        
        // POP
        context.restoreGState()
    }
    
}


private extension TuningsPitchWheelView {
    func color(forPitch pitch: Double) -> UIColor {
        let r = UIColor.init(hue: CGFloat(pitch.truncatingRemainder(dividingBy: 1)), saturation: 1, brightness: 0.75, alpha: 1)
        return r
    }
    
    func horagram01ToCartesian01(p: CGPoint) -> CGPoint {
        let thetaRadians: CGFloat = CGFloat(radians01(d01: Float(p.x)) - 0.5 * Double.pi) // clockwise
        let x = p.y * cos(thetaRadians);
        let y = p.y * sin(thetaRadians);
        return CGPoint(x:x, y:y);
    }
    
    func radians01(d01: Float) -> Float {
        return Float(d01 * 2 * Double.pi);
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
    func drawCentered(atPoint point: CGPoint, font: UIFont, color: UIColor) -> CGSize {
        let labelSize = self.size(withAttributes: [.font:font, .strokeColor:color])
        let centeredAvgP = CGPoint(x: point.x - labelSize.width / 2.0, y: point.y - labelSize.height / 2.0)
        
        // draw stroke
        var attributes = [NSAttributedStringKey : Any]()
        attributes[.font] = font
        attributes[.strokeWidth] = 12
        attributes[.strokeColor] = UIColor.darkGray
        self.draw(at: centeredAvgP, withAttributes: attributes)
        
        // draw fill
        attributes.removeValue(forKey: .strokeWidth)
        attributes.removeValue(forKey: .strokeColor)
        attributes[.foregroundColor] = color
        self.draw(at: centeredAvgP, withAttributes:attributes)
        
        return labelSize
    }
}
