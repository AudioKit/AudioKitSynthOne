//
//  S1DSPKernel+toggleKeys.m
//  AudioKitSynthOne
//
//  Created by Aurelius Prochazka on 6/4/18.
//  Copyright © 2018 AudioKit. All rights reserved.
//

#import <AudioKit/AudioKit-Swift.h>
#import "S1DSPKernel.hpp"
#import "AEArray.h"
#import "S1NoteState.hpp"


void S1DSPKernel::turnOnKey(int noteNumber, int velocity) {
    if (noteNumber < 0 || noteNumber >= S1_NUM_MIDI_NOTES)
        return;

    const float frequency = tuningTableNoteToHz(noteNumber + (int)parameters[transpose]);
    turnOnKey(noteNumber, velocity, frequency);
}

// turnOnKey is called by render thread in "process", so access note via AEArray
void S1DSPKernel::turnOnKey(int noteNumber, int velocity, float frequency) {
    if (noteNumber < 0 || noteNumber >= S1_NUM_MIDI_NOTES)
        return;
    initializeNoteStates();

    if (parameters[isMono] > 0.f) {
        S1NoteState& note = *monoNote;
        monoFrequency = frequency;

        // PORTAMENTO: set the ADSRs to release mode here, then into attack mode inside startNoteHelper
        if (parameters[monoIsLegato] == 0) {
            note.internalGate = 0;
            note.stage = S1NoteState::stageRelease;
            sp_adsr_compute(sp, note.adsr, &note.internalGate, &note.amp);
            sp_adsr_compute(sp, note.fadsr, &note.internalGate, &note.filter);
        }

        // legato+portamento: Legato means that Presets with low sustains will sound like they did not retrigger.
        note.startNoteHelper(noteNumber, velocity, frequency);

    } else {
        // Note Stealing: Is noteNumber already playing?
        int index = -1;
        for(int i = 0 ; i < polyphony; i++) {
            if ((*noteStates)[i].rootNoteNumber == noteNumber) {
                index = i;
                break;
            }
        }
        if (index != -1) {
            // noteNumber is playing...steal it
            playingNoteStatesIndex = index;
        } else {
            // noteNumber is not playing: search for non-playing notes (-1) starting with current index
            for(int i = 0; i < polyphony; i++) {
                const int modIndex = (playingNoteStatesIndex + i) % polyphony;
                if ((*noteStates)[modIndex].rootNoteNumber == -1) {
                    index = modIndex;
                    break;
                }
            }

            if (index == -1) {
                // if there are no non-playing notes then steal oldest note
                ++playingNoteStatesIndex %= polyphony;
            } else {
                // use non-playing note slot
                playingNoteStatesIndex = index;
            }
        }

        // POLY: INIT NoteState
        S1NoteState& note = (*noteStates)[playingNoteStatesIndex];
        note.startNoteHelper(noteNumber, velocity, frequency);
    }

    heldNotesDidChange();
}

// turnOffKey is called by render thread in "process", so access note via AEArray
void S1DSPKernel::turnOffKey(int noteNumber) {

    if (noteNumber < 0 || noteNumber >= S1_NUM_MIDI_NOTES)
        return;
    initializeNoteStates();

    if (parameters[isMono] > 0.f) {

        // MONO:
        if (parameters[arpIsOn] == 1.f || heldNoteNumbersAE.count == 0) {

            // the case where this was the only held note and now it should be off, OR
            // the case where the sequencer turns off this key even though a note is held down
            if (monoNote->stage != S1NoteState::stageOff) {
                monoNote->stage = S1NoteState::stageRelease;
                monoNote->internalGate = 0;
            }
        } else {

            // the case where you had more than one held note and released one (CACA): Keep note ON and set to freq of head
            AEArrayToken token = AEArrayGetToken(heldNoteNumbersAE);
            NoteNumber* nn = (NoteNumber*)AEArrayGetItem(token, 0);

            // This logic is in S1NoteState::startNoteHelper...need a common function
            const int headNN = nn->noteNumber;
            monoNote->rootNoteNumber = headNN;
            monoNote->transpose = (int)parameters[transpose];
            monoNote->velocity = nn->velocity;
            monoNote->amp = (float)pow2(nn->velocity / 127.f);
            monoNote->oscmorph1->amp = monoNote->amp;
            monoNote->oscmorph2->amp = monoNote->amp;
            monoNote->subOsc->amp = monoNote->amp;
            monoNote->fmOsc->amp = monoNote->amp;
            monoFrequency = tuningTableNoteToHz(headNN + (int)parameters[transpose]);
            monoNote->oscmorph1->freq = monoFrequency;
            monoNote->oscmorph2->freq = monoFrequency;
            monoNote->subOsc->freq = monoFrequency;
            monoNote->fmOsc->freq = monoFrequency;

            // PORTAMENTO: reset the ADSR inside the render loop
            if (parameters[monoIsLegato] == 0.f) {
                monoNote->internalGate = 0;
                monoNote->stage = S1NoteState::stageRelease;
                sp_adsr_compute(sp, monoNote->adsr, &monoNote->internalGate, &monoNote->amp);
                sp_adsr_compute(sp, monoNote->fadsr, &monoNote->internalGate, &monoNote->filter);
            }

            // legato+portamento: Legato means that Presets with low sustains will sound like they did not retrigger.
            monoNote->stage = S1NoteState::stageOn;
            monoNote->internalGate = 1;
        }
    } else {

        // POLY:
        int index = -1;
        for(int i = 0; i < polyphony; i++) {
            if ((*noteStates)[i].rootNoteNumber == noteNumber) {
                index = i;
                break;
            }
        }

        if (index != -1) {

            // put NoteState into release
            S1NoteState& note = (*noteStates)[index];
            if (note.stage != S1NoteState::stageOff) {
                note.stage = S1NoteState::stageRelease;
                note.internalGate = 0;
            }
        } else {

            // the case where a note was stolen before the noteOff
        }
    }

    heldNotesDidChange();
}
