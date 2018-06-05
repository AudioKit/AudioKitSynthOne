//
//  S1DSPKernel+startStopNotes.mm
//  AudioKitSynthOne
//
//  Created by Aurelius Prochazka on 6/4/18.
//  Copyright © 2018 AudioKit. All rights reserved.
//

#import <AudioKit/AudioKit-swift.h>
#import "S1DSPKernel.hpp"
#import "AEArray.h"

// Convert note number to [possibly] microtonal frequency.  12ET is the default.
// Profiling shows that while this takes a special Swift lock it still resolves to ~0% of CPU on a device
static inline double tuningTableNoteToHz(int noteNumber) {
    return [AKPolyphonicNode.tuningTable frequencyForNoteNumber:noteNumber];
}

// NOTE ON
// startNote is not called by render thread, but turnOnKey is
void S1DSPKernel::startNote(int noteNumber, int velocity) {
    if (noteNumber < 0 || noteNumber >= S1_NUM_MIDI_NOTES)
        return;

    const float frequency = tuningTableNoteToHz(noteNumber);
    startNote(noteNumber, velocity, frequency);
}

// NOTE ON
// startNote is not called by render thread, but turnOnKey is
void S1DSPKernel::startNote(int noteNumber, int velocity, float frequency) {
    if (noteNumber < 0 || noteNumber >= S1_NUM_MIDI_NOTES)
        return;

    NSNumber* nn = @(noteNumber);
    [heldNoteNumbers removeObject:nn];
    [heldNoteNumbers insertObject:nn atIndex:0];
    [heldNoteNumbersAE updateWithContentsOfArray:heldNoteNumbers];

    // ARP/SEQ
    if (p[arpIsOn] == 1.f) {
        return;
    } else {
        turnOnKey(noteNumber, velocity, frequency);
    }
}


// NOTE OFF...put into release mode
void S1DSPKernel::stopNote(int noteNumber) {
    if (noteNumber < 0 || noteNumber >= S1_NUM_MIDI_NOTES)
        return;

    NSNumber* nn = @(noteNumber);
    [heldNoteNumbers removeObject: nn];
    [heldNoteNumbersAE updateWithContentsOfArray: heldNoteNumbers];

    // ARP/SEQ
    if (p[arpIsOn] == 1.f)
        return;
    else
        turnOffKey(noteNumber);
}



///puts all notes in release mode...no artifacts
void S1DSPKernel::stopAllNotes() {
    [heldNoteNumbers removeAllObjects];
    [heldNoteNumbersAE updateWithContentsOfArray:heldNoteNumbers];
    if (p[isMono] > 0.f) {
        stopNote(60);
    } else {
        for(int i=0; i<S1_NUM_MIDI_NOTES; i++)
            stopNote(i);
    }
}
