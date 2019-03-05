//
//  S1DSPKernel+setup.m
//  AudioKitSynthOne
//
//  Created by Aurelius Prochazka on 6/4/18.
//  Copyright © 2018 AudioKit. All rights reserved.
//

#import "S1DSPKernel.hpp"
#import "S1NoteState.hpp"

/// tableIndex is on [0, S1_NUM_WAVEFORMS * S1_NUM_BANDLIMITED_FTABLES)
void S1DSPKernel::setupWaveform(uint32_t tableIndex, uint32_t size) {
    tbl_size = size;
    sp_ftbl_create(sp, &ft_array[tableIndex], tbl_size);
}


void S1DSPKernel::updateWavetableIncrementValuesForCurrentSampleRate() {
    
    double currentSampleIncrement = 1.0 * SP_FT_MAXLEN / sp->sr;
    for (unsigned int i = 0; i < S1_NUM_WAVEFORMS * S1_NUM_BANDLIMITED_FTABLES; i++) {
        ft_array[i]->sicvt = currentSampleIncrement;
    }
    sine->sicvt = currentSampleIncrement;
}

/// tableIndex is on [0, S1_NUM_WAVEFORMS * S1_NUM_BANDLIMITED_FTABLES)
/// sampleIndex is on [0, S1_FTABLE_SIZE)
void S1DSPKernel::setWaveformValue(uint32_t tableIndex, uint32_t sampleIndex, float value) {
    ft_array[tableIndex]->tbl[sampleIndex] = value;
}

void S1DSPKernel::setBandlimitFrequency(uint32_t blIndex, float frequency) {
    ft_frequencyBand[blIndex] = frequency;
}

// initializeNoteStates() must be called AFTER init returns
void S1DSPKernel::initializeNoteStates() {
    if (initializedNoteStates == false) {
        initializedNoteStates = true;
        // POLY INIT
        for (int i = 0; i < S1_MAX_POLYPHONY; i++) {
            S1NoteState& state = (*noteStates)[i];
            state.kernel = this;
            state.init();
            state.stage = S1NoteState::stageOff;
            state.internalGate = 0;
            state.rootNoteNumber = -1;
            state.transpose = 0;
        }

        // MONO INIT
        monoNote->kernel = this;
        monoNote->init();
        monoNote->stage = S1NoteState::stageOff;
        monoNote->internalGate = 0;
        monoNote->rootNoteNumber = -1;
        monoNote->transpose = 0;
    }
}
