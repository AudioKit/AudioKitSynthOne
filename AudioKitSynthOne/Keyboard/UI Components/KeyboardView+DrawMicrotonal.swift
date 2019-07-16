//
//  KeyboardView+DrawMicrotonal.swift
//  AudioKitSynthOne
//
//  Created by Marcus W. Hobbs on 7/20/19.
//  Copyright © 2019 AudioKit. All rights reserved.
//

extension KeyboardView {

    // MARK: - DRAW Microtonal keyboard

    /// Microtonal
    internal func drawMicrotonal(_ rect: CGRect) {

        // push
        let context = UIGraphicsGetCurrentContext()!
        context.saveGState()

        // paths are used for drawing and touches
        microtonalKeyPaths.removeAll()

        // black bg
        UIColor.black.setFill()
        let bgPath = UIBezierPath(rect: self.bounds)
        bgPath.fill()

        // layout
        let width = self.frame.width
        let height = self.frame.height
        let npo = AKPolyphonicNode.tuningTable.npo
        let cNN = Int(AKPolyphonicNode.tuningTable.middleCNoteNumber)
        let midiNNRange = 0...127
        let minNN = midiNNRange.clamp((firstOctave - 3) * npo + cNN)
        let maxNN = midiNNRange.clamp((firstOctave - 3 + octaveCount) * npo + cNN + 1)
        let numKeys = maxNN - minNN
        let keyWidth = width / CGFloat(numKeys)
        UIColor.black.setStroke()

        // draw keys
        for nn in minNN ... maxNN {
            let i = CGFloat(nn - minNN)
            let nnRect = CGRect(x: i * keyWidth, y: 0, width: keyWidth, height: height)
            let nnPath = MicrotonalBezierPath(roundedRect: nnRect,
                                              byRoundingCorners: [.bottomLeft, .bottomRight],
                                              cornerRadii: CGSize(width: 5, height: 5))
            nnPath.nn = MIDINoteNumber(nn) // includes transpose
            microtonalKeyPaths.append(nnPath)
            let nnColor = microtonalColor(forNN: nn, isOn: onKeys.contains(MIDINoteNumber(nn)))
            nnColor.setFill()
            nnPath.lineWidth = 1
            nnPath.fill()
            nnPath.stroke()

            // draw labels
            let text = Tunings.text(forNoteNumber: MIDINoteNumber(nn), labelMode: .harmonic)
            let point = CGPoint(x: nnRect.minX + 0.5 * nnRect.width,
                                y: nnRect.minY + nnRect.height - 20)
            let fontSize = UIDevice.current.userInterfaceIdiom == .pad ? 14 : 10
            if let font = UIFont(name: "AvenirNextCondensed-Regular", size: CGFloat(fontSize)) {
                let _ = text.drawCentered(atPoint: point, font: font, color: UIColor.black, drawStroke: false)
            }
        }
        context.restoreGState()
    }

    /// Microtonal
    internal func microtonalColor(forNN n: Int, isOn: Bool = false) -> UIColor {

        let nn = MIDINoteNumber(n)
        let offColor = Tunings.color(forNoteNumber: nn, isOn: false)
        let onColor = Tunings.color(forNoteNumber: nn, isOn: true)
        return isOn ? onColor : offColor
    }
}
