//
//  Arpeggiator.swift
//  AudioKit Synth One
//
//  Created by Matthew Fecher on 3/17/16.
//  Copyright © 2016 AudioKit. All rights reserved.
//

class Arpeggiator {
    var baseNote = 0.0
    var beatCounter = 0.0
    var direction = 0.0
    var interval = 12.0
    var isOn = 0.0
    var lastNotes = [0]
    var octave = 1.0
    var rate = 120.0
    var isSequencer = false
    var totalSteps = 8.0
    var seqPattern = [0, 7, -2, 0, 0, 7, -2, 0, 0, 7, -2, 0, 0, 7, -2, 0]
    var seqNoteOn = [true, true, true, true, true, true, true, true, true, true, true, true, true, true, true, true]
}
