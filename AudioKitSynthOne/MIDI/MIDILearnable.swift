//
//  MIDILearnable.swift
//  AudioKitSynthOne
//
//  Created by AudioKit Contributors on 10/21/17.
//  Copyright © 2018 AudioKit. All rights reserved.
//

import AudioKit


protocol MIDILearnable: AnyObject {

    var midiByteRange:ClosedRange<MIDIByte> { get set }

    var hotspotView: UIView { get set }

    var midiCC: MIDIByte { get set }

    var midiLearnMode: Bool { get set }

    var isActive: Bool { get set }

    func addHotspot()

    func hideHotspot()

    func showHotspot()

    func setControlValueFrom(midiValue: MIDIByte)
    
    func updateDisplayLabel()
    
}
