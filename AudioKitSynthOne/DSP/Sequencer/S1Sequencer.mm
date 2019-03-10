//
//  S1Arpegiator.mm
//  AudioKitSynthOne
//
//  Created by AudioKit Contributors on 3/06/19.
//  Copyright © 2019 AudioKit. All rights reserved.
//

#import <AudioKit/AudioKit-swift.h>

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
    {}

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

void S1Sequencer::process(DSPParameters &params, AEArray *heldNoteNumbersAE) {
    /// MARK: ARPEGGIATOR + SEQUENCER BEGIN
    const int heldNoteNumbersAECount = heldNoteNumbersAE.count;
    const BOOL arpSeqIsOn = (params[arpIsOn] == 1.f);
    const BOOL firstTimeAnyKeysHeld = (previousHeldNoteNumbersAECount == 0 && heldNoteNumbersAECount > 0);
    const BOOL firstTimeNoKeysHeld = (heldNoteNumbersAECount == 0 && previousHeldNoteNumbersAECount > 0);
    
    // reset arp/seq when user goes from 0 to N, or N to 0 held keys
    if ( arpSeqIsOn && (firstTimeNoKeysHeld || firstTimeAnyKeysHeld) ) {
        
        arpTime = 0;
        arpSampleCounter = 0;
        arpBeatCounter = 0;
        
        // Turn OFF previous beat's notes
        for (std::list<int>::iterator arpLastNotesIterator = sequencerLastNotes.begin(); arpLastNotesIterator != sequencerLastNotes.end(); ++arpLastNotesIterator) {
            mTurnOffKey(*arpLastNotesIterator);
        }
        sequencerLastNotes.clear();
        
        mBeatCounterDidChange();
    }
    
    // If arp is ON, or if previous beat's notes need to be turned OFF
    if ( arpSeqIsOn || sequencerLastNotes.size() > 0 ) {
        
        // Compare previous arpTime to current to see if we crossed a beat boundary
        const double secPerBeat = 60.f * params[arpSeqTempoMultiplier] / params[arpRate];
        const double r0 = fmod(arpTime, secPerBeat);
        arpTime = arpSampleCounter/mSampleRate;
        const double r1 = fmod(arpTime, secPerBeat);
        arpSampleCounter += 1.f;
        
        // If keys are now held, or if beat boundary was crossed
        if ( firstTimeAnyKeysHeld || r1 < r0 ) {
            
            // Turn off previous beat's notes even if arp is off
            for (std::list<int>::iterator arpLastNotesIterator = sequencerLastNotes.begin(); arpLastNotesIterator != sequencerLastNotes.end(); ++arpLastNotesIterator) {
                mTurnOffKey(*arpLastNotesIterator);
            }
            sequencerLastNotes.clear();
            
            // ARP/SEQ is ON
            if (arpSeqIsOn) {
                
                // Held Notes
                if (heldNoteNumbersAECount > 0) {
                    // Create Arp/Seq array based on held notes and/or sequence parameters
                    sequencerNotes.clear();
                    sequencerNotes2.clear();
                    
                    // Only update "notes per octave" when beat counter changes so sequencerNotes and sequencerLastNotes match
                    notesPerOctave = (int)AKPolyphonicNode.tuningTable.npo;
                    if (notesPerOctave <= 0) notesPerOctave = 12;
                    const float npof = (float)notesPerOctave/12.f; // 12ET ==> npof = 1
                    
                    if ( params[arpIsSequencer] == 1.f ) {
                        
                        // SEQUENCER
                        const int numSteps = params[arpTotalSteps] > 16 ? 16 : (int)params[arpTotalSteps];
                        for(int i = 0; i < numSteps; i++) {
                            const int onOff = params[(S1Parameter)(i + sequencerNoteOn00)];
                            const int octBoost = params[(S1Parameter)(i + sequencerOctBoost00)];
                            const int nn = params[(S1Parameter)(i + sequencerPattern00)] * npof;
                            const int nnob = (nn < 0) ? (nn - octBoost * notesPerOctave) : (nn + octBoost * notesPerOctave);
                            SeqNoteNumber snn{nnob, onOff};
                            sequencerNotes.push_back(snn);
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
                                Arpeggiator::up(sequencerNotes, sequencerNotes2, heldNotesCount, arpOctaves, arpIntervalUp);
                                break;
                            }
                            case ArpeggiatorMode::UpDown: {
                                int index = Arpeggiator::up(sequencerNotes, sequencerNotes2, heldNotesCount, arpOctaves, arpIntervalUp);
                                const bool noTail = true;
                                Arpeggiator::down(sequencerNotes, sequencerNotes2, heldNotesCount, arpOctaves, arpIntervalUp, noTail, index);
                                break;
                            }
                            case ArpeggiatorMode::Down: {
                                Arpeggiator::down(sequencerNotes, sequencerNotes2, heldNotesCount, arpOctaves, arpIntervalUp, false);
                                break;
                            }
                        }
                    }
                    
                    // At least one key is held down, and a non-empty sequence has been created
                    if ( sequencerNotes.size() > 0 ) {
                        
                        // Advance arp/seq beatCounter, notify delegates
                        const int seqNotePosition = arpBeatCounter % sequencerNotes.size();
                        ++arpBeatCounter;
                        mBeatCounterDidChange();
                        
                        //MARK: ARP+SEQ: turn ON the note of the sequence
                        SeqNoteNumber& snn = sequencerNotes[seqNotePosition];
                        
                        if (params[arpIsSequencer] == 1.f) {
                            
                            // SEQUENCER
                            if (snn.onOff == 1) {
                                AEArrayEnumeratePointers(heldNoteNumbersAE, NoteNumber *, noteStruct) {
                                    const int baseNote = noteStruct->noteNumber;
                                    const int note = baseNote + snn.noteNumber;
                                    if (note >= 0 && note < S1_NUM_MIDI_NOTES) {
                                        mTurnOnKey(note, 127); //TODO: Add ARP/SEQ Velocity
                                        sequencerLastNotes.push_back(note);
                                    }
                                }
                            }
                        } else {
                            
                            // ARPEGGIATOR
                            const int note = snn.noteNumber;
                            if (note >= 0 && note < S1_NUM_MIDI_NOTES) {
                                mTurnOnKey(note, 127); //TODO: Add ARP/SEQ velocity
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
    return arpBeatCounter;
}


void S1Sequencer::setSampleRate(double sampleRate) {
    mSampleRate = sampleRate;
}
