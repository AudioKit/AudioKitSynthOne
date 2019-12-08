//
//  String+Drawing.swift
//  AudioKitSynthOne
//
//  Created by Marcus W. Hobbs on 7/20/19.
//  Copyright © 2019 AudioKit. All rights reserved.
//

extension String {
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
