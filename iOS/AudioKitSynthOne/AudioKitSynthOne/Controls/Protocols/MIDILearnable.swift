//
//  MIDILearnable.swift
//  RomPlayer
//
//  Created by Matthew Fecher on 10/21/17.
//  Copyright © 2017 Matthew Fecher. All rights reserved.
//

import AudioKit

protocol MIDILearnable {
    var midiCC: MIDIByte { get set }
    var midiLearnMode: Bool { get set }
    var isActive: Bool { get set }
}
