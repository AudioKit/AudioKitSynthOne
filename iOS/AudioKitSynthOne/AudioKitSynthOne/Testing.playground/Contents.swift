//: Playground - noun: a place where people can play

import UIKit
import AudioKit
import AudioKitUI

var taper = 3.0

var custom = AKTable(.sine, count: 100)
for i in custom.indices {
    custom[i] = Float((Double(i)/100).denormalized(to: 0...10, taper: taper))
}

class PlaygroundView: AKPlaygroundView {

    override func setup() {

        addTitle("Denormalization Playground")

        addLabel("Taper = \(taper)")
        addSubview(AKTableView(custom))
    }
}

import PlaygroundSupport
PlaygroundPage.current.needsIndefiniteExecution = true
PlaygroundPage.current.liveView = PlaygroundView()
