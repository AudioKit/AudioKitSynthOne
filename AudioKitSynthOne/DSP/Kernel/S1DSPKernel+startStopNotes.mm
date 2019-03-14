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
    const int nn = clamp(noteNumber, 0, 127);
    return [AKPolyphonicNode.tuningTable frequencyForNoteNumber:nn];
}

// NOTE ON
// startNote is not called by render thread, but turnOnKey is
void S1DSPKernel::startNote(int noteNumber, int velocity) {
    if (noteNumber < 0 || noteNumber >= S1_NUM_MIDI_NOTES)
        return;

    startNote(noteNumber, velocity, 1.f); // freq unused
}

// NOTE ON
// startNote is not called by render thread, but turnOnKey is
void S1DSPKernel::startNote(int noteNumber, int velocity, float frequency) {
    if (noteNumber < 0 || noteNumber >= S1_NUM_MIDI_NOTES)
        return;

    NSInteger index = -1;
    NoteNumber existingNote;
    for(int i = 0; i < heldNoteNumbers.count; i++) {
        NSValue* value = heldNoteNumbers[i];
        [value getValue:&existingNote];
        if(existingNote.noteNumber == noteNumber) {
            index = i;
            break;
        }
    }
    if(index != -1)
        [heldNoteNumbers removeObjectAtIndex:index];

    NoteNumber note = {noteNumber, (int)p[transpose], velocity};
    NSValue *value = [NSValue valueWithBytes:&note objCType:@encode(NoteNumber)];
    [heldNoteNumbers insertObject:value atIndex:0];
    [heldNoteNumbersAE updateWithContentsOfArray:heldNoteNumbers];

    // the tranpose feature leads to the override the AKPolyphonicNode::startNote frequency
    const float frequencyTranposeOverride = tuningTableNoteToHz(noteNumber + (int)p[transpose]);

    // ARP/SEQ
    if (p[arpIsOn] == 1.f) {
        return;
    } else {
        turnOnKey(noteNumber, velocity, frequencyTranposeOverride);
    }
}


// NOTE OFF...put into release mode
void S1DSPKernel::stopNote(int noteNumber) {
    if (noteNumber < 0 || noteNumber >= S1_NUM_MIDI_NOTES)
        return;

    NSInteger index = -1;
    NoteNumber existingNote;
    for(int i = 0; i < heldNoteNumbers.count; i++) {
        NSValue* value = heldNoteNumbers[i];
        [value getValue:&existingNote];
        if(existingNote.noteNumber == noteNumber) {
            index = i;
            break;
        }
    }
    if(index != -1)
        [heldNoteNumbers removeObjectAtIndex:index];

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
