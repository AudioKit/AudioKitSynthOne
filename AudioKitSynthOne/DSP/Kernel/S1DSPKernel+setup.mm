//
//  S1DSPKernel+setup.m
//  AudioKitSynthOne
//
//  Created by Aurelius Prochazka on 6/4/18.
//  Copyright © 2018 AudioKit. All rights reserved.
//

#import "S1DSPKernel.hpp"
#import "S1NoteState.hpp"

//TODO:make ft_array 3d array
void S1DSPKernel::setupWaveform(uint32_t waveform, uint32_t size) {
    tbl_size = size;
    sp_ftbl_create(sp, &ft_array[waveform], tbl_size);
}

//TODO:make ft_array 3d array
void S1DSPKernel::setWaveformValue(uint32_t waveform, uint32_t index, float value) {
    ft_array[waveform]->tbl[index] = value;
}


// initializeNoteStates() must be called AFTER init returns
void S1DSPKernel::initializeNoteStates() {
    if (initializedNoteStates == false) {
        initializedNoteStates = true;
        // POLY INIT
        for (int i = 0; i < S1_MAX_POLYPHONY; i++) {
            S1NoteState& state = noteStates[i];
            state.kernel = this;
            state.init();
            state.stage = S1NoteState::stageOff;
            state.internalGate = 0;
            state.rootNoteNumber = -1;
        }

        // MONO INIT
        monoNote->kernel = this;
        monoNote->init();
        monoNote->stage = S1NoteState::stageOff;
        monoNote->internalGate = 0;
        monoNote->rootNoteNumber = -1;
    }
}
