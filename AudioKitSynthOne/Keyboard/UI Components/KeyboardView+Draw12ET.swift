//
//  KeyboardView+Draw12ET.swift
//  AudioKitSynthOne
//
//  Created by Marcus W. Hobbs on 7/20/19.
//  Copyright © 2019 AudioKit. All rights reserved.
//

extension KeyboardView {

    // MARK: - Draw 12ET Keyboard

    internal func draw12ET(_ rect: CGRect) {

        updateOneOctaveSize()

        for i in 0 ..< octaveCount {
            drawOctaveCanvas(i)
        }
        let tempWidth = CGFloat(self.frame.width) - CGFloat((octaveCount * 7) - 1) * whiteKeySize.width - 1
        let backgroundPath = UIBezierPath(rect: CGRect(x: oneOctaveSize.width * CGFloat(octaveCount),
                                                       y: 0,
                                                       width: tempWidth,
                                                       height: oneOctaveSize.height))
        UIColor.black.setFill()
        backgroundPath.fill()
        let lastCRect = CGRect(x: whiteKeyX(0, octaveNumber: octaveCount),
                               y: 1,
                               width: tempWidth / 2,
                               height: whiteKeySize.height)
        let lastC = UIBezierPath(roundedRect: lastCRect, byRoundingCorners: [.bottomLeft, .bottomRight],
                                 cornerRadii: CGSize(width: 5, height: 5))
        whiteKeyColor(0, octaveNumber: octaveCount).setFill()
        lastC.fill()
        addLabels(i: 0, octaveNumber: octaveCount, whiteKeysRect: lastCRect)
    }

    /// Update the screen size of one octave
    internal func updateOneOctaveSize() {

        let width = Int(self.frame.width)
        let height = Int(self.frame.height)
        oneOctaveSize = CGSize(width: Double(width / octaveCount - width / (octaveCount * octaveCount * 7)),
                               height: Double(height))
    }

    /// Draw one octave
    func drawOctaveCanvas(_ octaveNumber: Int) {

        //// background Drawing
        let backgroundPath = UIBezierPath(rect: CGRect(x: 0 + oneOctaveSize.width * CGFloat(octaveNumber),
                                                       y: 0,
                                                       width: oneOctaveSize.width,
                                                       height: oneOctaveSize.height))
        UIColor.black.setFill()
        backgroundPath.fill()
        var whiteKeysPaths = [UIBezierPath]()
        for i in 0 ..< 7 {
            let whiteKeysRect = CGRect(x: whiteKeyX(i, octaveNumber: octaveNumber),
                                       y: 1,
                                       width: whiteKeySize.width - 1,
                                       height: whiteKeySize.height)
            whiteKeysPaths.append(UIBezierPath(roundedRect: whiteKeysRect,
                                               byRoundingCorners: [.bottomLeft, .bottomRight],
                                               cornerRadii: CGSize(width: 5, height: 5)))
            whiteKeyColor(i, octaveNumber: octaveNumber).setFill()
            whiteKeysPaths[i].fill()
            addLabels(i: i, octaveNumber: octaveNumber, whiteKeysRect: whiteKeysRect)
        }

        var topKeyPaths = [UIBezierPath]()
        for i in 0 ..< 28 {
            let topKeysRect = CGRect(x: topKeyX(i, octaveNumber: octaveNumber),
                                     y: 1,
                                     width: topKeySize.width + topKeyWidthIncrease,
                                     height: topKeySize.height)
            topKeyPaths.append(UIBezierPath(roundedRect: topKeysRect,
                                            byRoundingCorners: [.bottomLeft, .bottomRight],
                                            cornerRadii: CGSize(width: 3, height: 3)))
            topKeyColor(i, octaveNumber: octaveNumber).setFill()
            topKeyPaths[i].fill()

            // Add fancy paintcode blackkey code
        }
    }

    /// Text
    func addLabels(i: Int, octaveNumber: Int, whiteKeysRect: CGRect) {

        let textColor: UIColor = darkMode ? #colorLiteral(red: 0.3176470588, green: 0.337254902, blue: 0.3647058824, alpha: 1) : #colorLiteral(red: 0.5098039216, green: 0.5098039216, blue: 0.5294117647, alpha: 1)

        // labelMode == 1, Only C, labelMode == 2, All notes
        if labelMode == 1 && i == 0 || labelMode == 2 {

            // Add Label
            guard let context = UIGraphicsGetCurrentContext(),
                let font = UIFont(name: "AvenirNextCondensed-Regular", size: 14) else { return }
            let whiteKeysTextContent = getWhiteNoteName(i) + String(firstOctave + octaveNumber)
            let whiteKeysStyle = NSMutableParagraphStyle()
            whiteKeysStyle.alignment = .center
            let whiteKeysFontAttributes  = [
                NSAttributedString.Key.font: font,
                NSAttributedString.Key.foregroundColor: textColor,
                NSAttributedString.Key.paragraphStyle: whiteKeysStyle
                ] as [NSAttributedString.Key: Any]
            let whiteKeysTextHeight: CGFloat = whiteKeysTextContent.boundingRect(
                with: CGSize(width: whiteKeysRect.width,
                             height: CGFloat.infinity),
                options: .usesLineFragmentOrigin,
                attributes: whiteKeysFontAttributes,
                context: nil).height
            context.saveGState()
            context.clip(to: whiteKeysRect)

            // adjust for keyboard being hidden
            whiteKeysTextContent.draw(in: CGRect(x: whiteKeysRect.minX,
                                                 y: whiteKeysRect.minY + whiteKeysRect.height - whiteKeysTextHeight - 6,
                                                 width: whiteKeysRect.width,
                                                 height: whiteKeysTextHeight),
                                      withAttributes: whiteKeysFontAttributes)
            context.restoreGState()
        }
    }

    var whiteKeySize: CGSize {

        return CGSize(width: oneOctaveSize.width / 7.0, height: oneOctaveSize.height - 2)
    }

    var topKeySize: CGSize {

        return CGSize(width: oneOctaveSize.width / (4 * 7), height: oneOctaveSize.height * topKeyHeightRatio)
    }

    // swiftlint:disable identifier_name:min_length
    func whiteKeyX(_ n: Int, octaveNumber: Int) -> CGFloat {

        return CGFloat(n) * whiteKeySize.width + xOffset + oneOctaveSize.width * CGFloat(octaveNumber)
    }

    func topKeyX(_ n: Int, octaveNumber: Int) -> CGFloat {

        return CGFloat(n) * topKeySize.width - (topKeyWidthIncrease / 2) + xOffset +
            oneOctaveSize.width * CGFloat(octaveNumber)
    }

    func whiteKeyColor(_ n: Int, octaveNumber: Int) -> UIColor {

        let nn = MIDINoteNumber((firstOctave + octaveNumber) * 12 + whiteKeyNotes[n] + baseMIDINote )
        if darkMode {
            whiteKeyOff = #colorLiteral(red: 0.1333333333, green: 0.1333333333, blue: 0.1333333333, alpha: 1)
            keyOnColor = keyOnUserColor
        } else {
            whiteKeyOff = #colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0)
            keyOnColor = keyOnUserColor
        }

        return onKeys.contains( nn ) ? keyOnColor : whiteKeyOff
    }

    func topKeyColor(_ n: Int, octaveNumber: Int) -> UIColor {

        let nn = MIDINoteNumber((firstOctave + octaveNumber) * 12 + topKeyNotes[n] + baseMIDINote )
        if darkMode {
            blackKeyOff = #colorLiteral(red: 0.2352941176, green: 0.2352941176, blue: 0.2549019608, alpha: 1)
            keyOnColor = keyOnUserColor
        } else {
            blackKeyOff = #colorLiteral(red: 0.09411764706, green: 0.09411764706, blue: 0.09411764706, alpha: 1)
            keyOnColor = keyOnUserColor
        }
        if notesWithSharps[topKeyNotes[n]].range(of: "#") != nil {
            return onKeys.contains( nn ) ? keyOnColor : blackKeyOff
        }
        return #colorLiteral(red: 1.000, green: 1.000, blue: 1.000, alpha: 0.000)
    }

    func getNoteName(_ note: Int) -> String {

        let keyInOctave = note % 12
        return notesWithSharps[keyInOctave]
    }

    func getWhiteNoteName(_ keyIndex: Int) -> String {

        return naturalNotes[keyIndex]
    }
}
