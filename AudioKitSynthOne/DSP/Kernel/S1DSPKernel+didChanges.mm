//
//  S1DSPKernel+didChanges.mm
//  AudioKitSynthOne
//
//  Created by Aurelius Prochazka on 6/4/18.
//  Copyright © 2018 AudioKit. All rights reserved.
//

#import "S1DSPKernel.hpp"
#import "AEArray.h"
#import "AEMessageQueue.h"
#import "S1NoteState.hpp"

void S1DSPKernel::dependentParameterDidChange(DependentParameter param) {
    AEMessageQueuePerformSelectorOnMainThread(audioUnit->_messageQueue,
                                              audioUnit,
                                              @selector(dependentParameterDidChange:),
                                              AEArgumentStruct(param),
                                              AEArgumentNone);
}

//can be called from within the render loop
void S1DSPKernel::beatCounterDidChange() {
    S1ArpBeatCounter retVal = {sequencer.getArpBeatCount(), heldNoteNumbersAE.count};
    AEMessageQueuePerformSelectorOnMainThread(audioUnit->_messageQueue,
                                              audioUnit,
                                              @selector(arpBeatCounterDidChange:),
                                              AEArgumentStruct(retVal),
                                              AEArgumentNone);
}


///can be called from within the render loop
void S1DSPKernel::playingNotesDidChange() {
    aePlayingNotes.polyphony = S1_MAX_POLYPHONY;
    if (parameters[isMono] > 0.f) {
        aePlayingNotes.playingNotes[0] = { monoNote->rootNoteNumber, monoNote->transpose, monoNote->velocity, monoNote->amp };
        for(int i = 1; i<S1_MAX_POLYPHONY; i++) {
            aePlayingNotes.playingNotes[i] = { -1, -1, -1, -1 };
        }
    } else {
        for(int i=0; i<S1_MAX_POLYPHONY; i++) {
            const auto& note = (*noteStates)[i];
            aePlayingNotes.playingNotes[i] = { note.rootNoteNumber, note.transpose, note.velocity, note.amp };
        }
    }
    AEMessageQueuePerformSelectorOnMainThread(audioUnit->_messageQueue,
                                              audioUnit,
                                              @selector(playingNotesDidChange:),
                                              AEArgumentStruct(aePlayingNotes),
                                              AEArgumentNone);
}

///can be called from within the render loop
void S1DSPKernel::heldNotesDidChange() {
    for(int i = 0; i<S1_NUM_MIDI_NOTES; i++)
        aeHeldNotes.heldNotes[i] = false;
    int count = 0;
    AEArrayEnumeratePointers(heldNoteNumbersAE, NoteNumber *, note) {
        const int nn = note->noteNumber;
        aeHeldNotes.heldNotes[nn] = true;
        ++count;
    }
    aeHeldNotes.heldNotesCount = count;
    AEMessageQueuePerformSelectorOnMainThread(audioUnit->_messageQueue,
                                              audioUnit,
                                              @selector(heldNotesDidChange:),
                                              AEArgumentStruct(aeHeldNotes),
                                              AEArgumentNone);
}
