//
//  MIDILearnable.swift
//  AudioKitSynthOne
//
//  Created by AudioKit Contributors on 10/21/17.
//  Copyright © 2018 AudioKit. All rights reserved.
//

import AudioKit

protocol MIDILearnable {
    var midiCC: MIDIByte { get set }
    var midiLearnMode: Bool { get set }
    var isActive: Bool { get set }
}
