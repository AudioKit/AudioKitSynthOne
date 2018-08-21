//
//  DisplayHelpers.swift
//  AudioKitSynthOne
//
//  Created by Aurelius Prochazka on 6/4/18.
//  Copyright © 2018 AudioKit. All rights reserved.
//

/// Get the key of a dictionary from a value
extension Dictionary where Value: Equatable {
    func getKey(forValue val: Value) -> Key? {
        return first(where: { $1 == val })?.key
    }
}

// MARK: - Display Helpers

extension CGFloat {
    // Formatted percentage string e.g. 0.55 -> 55%
    var percentageString: String {
        return NumberFormatter.localizedString(from: NSNumber(value: 100 * Int(self)), number: .percent)
    }
}

extension Double {

    // Return string formatted to 2 decimal places
    var decimalString: String {
        return String(format: "%.02f", self)
    }

    // Return string shifted 3 decimal places to left
    var decimal1000String: String {
        let newValue = 1_000 * self
        return String(format: "%.02f", newValue)
    }

    // Return ms 3 decimal places to left
    var msFormattedString: String {
        let newValue = 1_000 * self
        return String(format: NSLocalizedString("%.00f ms", comment:"Number of milliseconds"), newValue)
    }

    // Formatted percentage string e.g. 0.55 -> 55%
    var percentageString: String {
        return NumberFormatter.localizedString(from: NSNumber(value: 100 * Int(self)), number: .percent)
    }
}

@IBDesignable
class RotatableLabel: UILabel {
}

extension UILabel {
    @IBInspectable
    var rotation: Int {
        get {
            return 0
        } set {
            let radians = ((CGFloat.pi) * CGFloat(newValue) / CGFloat(180.0))
            self.transform = CGAffineTransform(rotationAngle: radians)
        }
    }
}

// MARK: - Conversion helper

extension Double {
    // Logarithmically scale 0.0 to 1.0 to any range
    public static func scaleRangeLog(_ value: Double, rangeMin: Double, rangeMax: Double) -> Double {
        let scale = (log(rangeMax) - log(rangeMin))
        return exp(log(rangeMin) + (scale * (0...1).clamp(value)))
    }

    // Logarithmically scale 0.0 to 1.0 to any range
    public static func scaleRangeLog2(_ value: Double, rangeMin: Double, rangeMax: Double) -> Double {
        let scale = (log2(rangeMax) - log2(rangeMin))
        return exp2(log2(rangeMin) + (scale * (0...1).clamp(value)))
    }

}
