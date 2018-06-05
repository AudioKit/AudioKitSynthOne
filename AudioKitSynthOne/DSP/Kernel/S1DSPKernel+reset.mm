//
//  S1DSPKernel+reset.mm
//  AudioKitSynthOne
//
//  Created by Aurelius Prochazka on 6/4/18.
//  Copyright © 2018 AudioKit. All rights reserved.
//

#import "S1DSPKernel.hpp"
#import "S1NoteState.hpp"
#import "AEArray.h"

///panic...hard-resets DSP.  artifacts.
void S1DSPKernel::resetDSP() {
    [heldNoteNumbers removeAllObjects];
    [heldNoteNumbersAE updateWithContentsOfArray:heldNoteNumbers];
    arpSeqLastNotes.clear();
    arpSeqNotes.clear();
    arpSeqNotes2.clear();
    arpBeatCounter = 0;
    _setSynthParameter(arpIsOn, 0.f);
    monoNote->clear();
    for(int i =0; i < S1_MAX_POLYPHONY; i++)
        noteStates[i].clear();
}

void S1DSPKernel::reset() {
    for (int i = 0; i<S1_MAX_POLYPHONY; i++)
        noteStates[i].clear();
    monoNote->clear();
    resetted = true;
}

void S1DSPKernel::resetSequencer() {
    arpBeatCounter = 0;
    arpSampleCounter = 0;
    arpTime = 0;
    beatCounterDidChange();
}
