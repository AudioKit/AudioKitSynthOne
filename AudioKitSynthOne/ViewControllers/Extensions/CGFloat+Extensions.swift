//
//  CGFloat+Extensions.swift
//  AudioKit Synth One
//
//  Created by AudioKit Contributors on 1/17/16.
//  Copyright © 2016 AudioKit. All rights reserved.
//

import UIKit

extension CGFloat {

    // Formatted percentage string e.g. 0.55 -> 55%
    var percentageString: String {
        return "\(Int(100 * self))%"
    }

}
