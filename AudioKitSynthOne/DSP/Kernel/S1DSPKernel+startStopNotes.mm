//
//  S1DSPKernel+startStopNotes.mm
//  AudioKitSynthOne
//
//  Created by Aurelius Prochazka on 6/4/18.
//  Copyright © 2018 AudioKit. All rights reserved.
//

#import <AudioKit/AudioKit-Swift.h>
#import "S1DSPKernel.hpp"
#import "AEArray.h"


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

    NoteNumber existingNote;
    for(int i = 0; i < heldNoteNumbers.count; i++) {
        NSValue* value = heldNoteNumbers[i];
        [value getValue:&existingNote];
        if(existingNote.noteNumber == noteNumber) {
            [heldNoteNumbers removeObjectAtIndex:i];
            break;
        }
    }

    NoteNumber note = {noteNumber, (int)parameters[transpose], velocity};
    NSValue *value = [NSValue valueWithBytes:&note objCType:@encode(NoteNumber)];
    [heldNoteNumbers insertObject:value atIndex:0];
    [heldNoteNumbersAE updateWithContentsOfArray:heldNoteNumbers];

    // the tranpose feature leads to the override the AKPolyphonicNode::startNote frequency
    const float frequencyTranposeOverride = tuningTableNoteToHz(noteNumber + (int)parameters[transpose]);

    // ARP/SEQ
    if (parameters[arpIsOn] == 1.f) {
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
    if (parameters[arpIsOn] == 1.f)
        return;
    else
        turnOffKey(noteNumber);
}



///puts all notes in release mode...no artifacts
void S1DSPKernel::stopAllNotes() {
    [heldNoteNumbers removeAllObjects];
    [heldNoteNumbersAE updateWithContentsOfArray:heldNoteNumbers];
    if (parameters[isMono] > 0.f) {
        stopNote(60);
    } else {
        for(int i=0; i<S1_NUM_MIDI_NOTES; i++)
            stopNote(i);
    }
}
