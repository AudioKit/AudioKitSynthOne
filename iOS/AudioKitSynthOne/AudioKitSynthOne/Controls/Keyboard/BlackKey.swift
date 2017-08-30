//
//  BlackKey.swift
//  AudioKitSynthOne
//
//  Created by Matthew Fecher on 8/29/17.
//  Copyright © 2017 AudioKit. All rights reserved.
//


import UIKit

@IBDesignable
class BlackKey: UIView {
    
    var x = 0.0
    var y = 0.0
    var width = 36.0
    var height = 112.0
    
    override func draw(_ rect: CGRect) {
        BlackKeyStyleKit.drawBlackKeyCanvas2(frame: CGRect(x: x, y: y, width: width, height: height) )
    }
    
}


