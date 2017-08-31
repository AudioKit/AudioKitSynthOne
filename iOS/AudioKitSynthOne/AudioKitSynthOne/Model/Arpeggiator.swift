//
//  Arpeggiator.swift
//  AudioKit Synth One
//
//  Created by Matthew Fecher on 3/17/16.
//  Copyright © 2016 AudioKit. All rights reserved.
//

class Arpeggiator {
    var baseNote: Int = 0
    var beatCounter = 0
    var direction: Int = 0
    var interval: Int = 12
    var isOn = true
    var lastNotes = [0]
    var octave: Int = 1
    var rate: Double = 120.0
    var isSequencer = false
    var totalSteps: Int = 7
    var seqPattern = [0, 7, -2, 0, 0, 7, -2, 0, 0, 7, -2, 0, 0, 7, -2, 0]
    var seqNoteOn = [true, true, true, true, true, true, true, true, true, true, true, true, true, true, true, true]
}
