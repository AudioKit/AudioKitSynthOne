//
//  S1DSPKernel+MIDI.mm
//  AudioKitSynthOne
//
//  Created by Aurelius Prochazka on 6/4/18.
//  Copyright © 2018 AudioKit. All rights reserved.
//

#import "S1DSPKernel.hpp"

// MIDI
void S1DSPKernel::handleMIDIEvent(AUMIDIEvent const& midiEvent) {
    if (midiEvent.length != 3) return;
    uint8_t status = midiEvent.data[0] & 0xF0;
    switch (status) {
        case 0x80 : {
            // note off
            uint8_t note = midiEvent.data[1];
            if (note > 127) break;
            stopNote(note);
            break;
        }
        case 0x90 : {
            // note on
            uint8_t note = midiEvent.data[1];
            uint8_t veloc = midiEvent.data[2];
            if (note > 127 || veloc > 127) break;
            startNote(note, veloc);
            break;
        }
        case 0xB0 : {
            uint8_t num = midiEvent.data[1];
            if (num == 123) {
                stopAllNotes();
            }
            break;
        }
    }
}



