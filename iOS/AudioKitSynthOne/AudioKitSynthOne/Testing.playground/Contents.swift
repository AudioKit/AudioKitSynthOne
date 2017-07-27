//: Playground - noun: a place where people can play

import UIKit
import AudioKit

func scaleRangeLog(_ value: Double, rangeMin: Double, rangeMax: Double) -> Double {
    let scale = (log(rangeMax) - log(rangeMin))
    return exp(log(rangeMin) + (scale * value))
}
let a = 0.5


var custom = AKTable(.sine, count: 1000)
for i in custom.indices {
    let val = Double(i)/1000
    custom[i] = 
}

class PlaygroundView: AKPlaygroundView {

    override func setup() {

        addTitle("Tables")

        addLabel("Custom")
        addSubview(AKTableView(custom))
    }
}

import PlaygroundSupport
PlaygroundPage.current.needsIndefiniteExecution = true
PlaygroundPage.current.liveView = PlaygroundView()
