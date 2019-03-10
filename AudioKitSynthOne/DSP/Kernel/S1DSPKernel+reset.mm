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
    sequencer.reset(true);

    _setSynthParameter(arpIsOn, 0.f);
    monoNote->clear();
    for(int i =0; i < S1_MAX_POLYPHONY; i++)
        (*noteStates)[i].clear();

    sp_vdelay_reset(sp, delayL);
    sp_vdelay_reset(sp, delayR);
    sp_vdelay_reset(sp, delayRR);
    sp_vdelay_reset(sp, delayFillIn);
}

void S1DSPKernel::reset() {
    for (int i = 0; i<S1_MAX_POLYPHONY; i++)
        (*noteStates)[i].clear();
    monoNote->clear();
    resetted = true;
    sp_vdelay_reset(sp, delayL);
    sp_vdelay_reset(sp, delayR);
    sp_vdelay_reset(sp, delayRR);
    sp_vdelay_reset(sp, delayFillIn);
}

void S1DSPKernel::resetSequencer() {

    // don't remove held notes

    sequencer.reset(false);
    beatCounterDidChange();
}
