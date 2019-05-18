//
//  S1Sequencer.mm
//  AudioKitSynthOne
//
//  Created by AudioKit Contributors on 3/06/19.
//  Copyright © 2019 AudioKit. All rights reserved.
//

#import <AudioKit/AudioKit-Swift.h>

#include "S1Arpeggiator.hpp"
#include "S1Sequencer.hpp"
#import "AEArray.h"
#import "S1ArpModes.hpp"
#import "S1AudioUnit.h"


S1Sequencer::S1Sequencer(KeyOnCallback keyOnCb,
    KeyOffCallback keyOffCb, BeatCounterChangedCallback beatChangedCb) :
    mTurnOnKey(keyOnCb),
    mTurnOffKey(keyOffCb),
    mBeatCounterDidChange(beatChangedCb)
    {
        static_assert(decltype(mStepCounter)::is_always_lock_free, "StepCounter not lockfree!");
    }

void S1Sequencer::init() {
    previousHeldNoteNumbersAECount = 0;
    reserveNotes();
}

void S1Sequencer::reset(bool resetNotes) {
    previousHeldNoteNumbersAECount = resetNotes ? 0 : previousHeldNoteNumbersAECount;
    sequencerLastNotes.clear();
    sequencerNotes.clear();
    sequencerNotes2.clear();
}

void S1Sequencer::process(DSPParameters &params, __weak AEArray *heldNoteNumbersAE) {
    
    /// MARK: ARPEGGIATOR + SEQUENCER BEGIN
    const int heldNoteNumbersAECount = heldNoteNumbersAE.count;
    const BOOL arpSeqIsOn = (params[arpIsOn] == 1.f);
    const BOOL firstTimeAnyKeysHeld = (previousHeldNoteNumbersAECount == 0 && heldNoteNumbersAECount > 0);
    const BOOL firstTimeNoKeysHeld = (heldNoteNumbersAECount == 0 && previousHeldNoteNumbersAECount > 0);
    
    // reset arp/seq when user goes from 0 to N, or N to 0 held keys
    if ( arpSeqIsOn && (firstTimeNoKeysHeld || firstTimeAnyKeysHeld) ) {
        
        mBeatTime = 0; // reset internal beattime
        mStepCounter = 0;

        // Turn OFF previous beat's notes
        std::for_each(sequencerLastNotes.begin(), sequencerLastNotes.end(), [&] (const auto &note) {
            mTurnOffKey(note);
        });
        sequencerLastNotes.clear();
        
        mBeatCounterDidChange();
    }
    
    // If arp is ON, or if previous beat's notes need to be turned OFF
    if ( arpSeqIsOn || sequencerLastNotes.size() > 0 ) {
        
        // Compare previous beatTime to current to see if we crossed a beat boundary
        const auto newBeatTime = mBeatTime + (params[arpRate] / 60.f) / mSampleRate;
        const double r0 = fmod(mBeatTime, params[arpSeqTempoMultiplier]);
        mBeatTime = newBeatTime;
        const double r1 = fmod(mBeatTime, params[arpSeqTempoMultiplier]);
        
        // If keys are now held, or if beat boundary was crossed
        if ( firstTimeAnyKeysHeld || r1 < r0 ) {
            
            // Turn off previous beat's notes even if arp is off
            std::for_each(sequencerLastNotes.begin(), sequencerLastNotes.end(), [&] (const auto &note) {
                mTurnOffKey(note);
            });
            sequencerLastNotes.clear();
            
            // ARP/SEQ is ON
            if (arpSeqIsOn) {
                
                // Held Notes
                if (heldNoteNumbersAECount > 0) {
                    // Create Arp/Seq array based on held notes and/or sequence parameters
                    sequencerNotes.clear();
                    sequencerNotes2.clear();
                    
                    // Only update "notes per octave" when beat counter changes so sequencerNotes and sequencerLastNotes match

                    if (mNotesPerOctave.load() <= 0) mNotesPerOctave.store(12);
                    const float npof = (float)mNotesPerOctave.load()/12.f; // 12ET ==> npof = 1
                    
                    if ( params[arpIsSequencer] == 1.f ) {
                        
                        // SEQUENCER
                        const int numSteps = params[arpTotalSteps] > 16 ? 16 : (int)params[arpTotalSteps];
                        for(int i = 0; i < numSteps; i++) {
                            const int onOff = params[(S1Parameter)(i + sequencerNoteOn00)];
                            const int octBoost = params[(S1Parameter)(i + sequencerOctBoost00)];
                            const int nn = params[(S1Parameter)(i + sequencerPattern00)] * npof;
                            const int nnob = (nn < 0) ? (nn - octBoost * mNotesPerOctave.load()) : (nn + octBoost * mNotesPerOctave.load());

                            // sequencer note velocity is reassigned below when constructed sequence is played
                            sequencerNotes.push_back({nnob, onOff, 127});
                        }
                    } else {
                        
                        // ARPEGGIATOR
                        AEArrayEnumeratePointers(heldNoteNumbersAE, NoteNumber *, note) {
                            std::vector<NoteNumber>::iterator it = sequencerNotes2.begin();
                            sequencerNotes2.insert(it, *note);
                        }
                        const int heldNotesCount = (int)sequencerNotes2.size();
                        const int arpIntervalUp = params[arpInterval] * npof;
                        const int arpOctaves = (int)params[arpOctave] + 1;
                        const auto arpMode = static_cast<ArpeggiatorMode>(params[arpDirection]);

                        switch(arpMode) {
                            case ArpeggiatorMode::Up: {
                                Arpeggiator<decltype(sequencerNotes), decltype(sequencerNotes2)>::up(
                                     sequencerNotes, sequencerNotes2, heldNotesCount, arpOctaves, arpIntervalUp);
                                break;
                            }
                            case ArpeggiatorMode::UpDown: {
                                int index = Arpeggiator<decltype(sequencerNotes), decltype(sequencerNotes2)>::up(
                                    sequencerNotes, sequencerNotes2, heldNotesCount, arpOctaves, arpIntervalUp);
                                const bool noTail = true;
                                Arpeggiator<decltype(sequencerNotes), decltype(sequencerNotes2)>::down(
                                    sequencerNotes, sequencerNotes2, heldNotesCount, arpOctaves, arpIntervalUp, noTail, index);
                                break;
                            }
                            case ArpeggiatorMode::Down: {
                                Arpeggiator<decltype(sequencerNotes), decltype(sequencerNotes2)>::down(
                                    sequencerNotes, sequencerNotes2, heldNotesCount, arpOctaves, arpIntervalUp, false);
                                break;
                            }
                        }
                    }
                    
                    // At least one key is held down, and a non-empty sequence has been created
                    if ( sequencerNotes.size() > 0 ) {
                        
                        // Advance arp/seq beatCounter, notify delegates
                        mStepCounter.store(static_cast<int>(mBeatTime / params[arpSeqTempoMultiplier]));
                        const int seqNotePosition = mStepCounter.load() % sequencerNotes.size();
                        mBeatCounterDidChange();
                        
                        //MARK: ARP+SEQ: turn ON the note of the sequence
                        SeqNoteNumber& snn = sequencerNotes[seqNotePosition];
                        
                        if (params[arpIsSequencer] == 1.f) {
                            
                            // SEQUENCER
                            if (snn.onOff == 1) {
                                AEArrayEnumeratePointers(heldNoteNumbersAE, NoteNumber *, noteStruct) {
                                    const int baseNote = noteStruct->noteNumber;
                                    const int note = baseNote + snn.noteNumber;
                                    const int velocity = noteStruct->velocity;
                                    if (note >= 0 && note < S1_NUM_MIDI_NOTES) {
                                        mTurnOnKey(note, velocity);
                                        sequencerLastNotes.push_back(note);
                                    }
                                }
                            }
                        } else {
                            
                            // ARPEGGIATOR
                            const int note = snn.noteNumber;
                            const int velocity = snn.velocity;
                            if (note >= 0 && note < S1_NUM_MIDI_NOTES) {
                                mTurnOnKey(note, velocity);
                                sequencerLastNotes.push_back(note);
                            }
                        }
                    }
                }
            }
        }
    }
    previousHeldNoteNumbersAECount = heldNoteNumbersAECount;
    
    /// MARK: ARPEGGIATOR + SEQUENCER END
}

void S1Sequencer::reserveNotes() {
    sequencerNotes.reserve(maxSequencerNotes);
    sequencerNotes2.reserve(maxSequencerNotes);
    sequencerLastNotes.resize(maxSequencerNotes);
}

// Getter and Setter

int S1Sequencer::getArpBeatCount() {
    return mStepCounter.load();
}


void S1Sequencer::setSampleRate(double sampleRate) {
    mSampleRate = sampleRate;
}

void S1Sequencer::setNotesPerOctave(int notes)
{
  mNotesPerOctave.store(notes);
}
