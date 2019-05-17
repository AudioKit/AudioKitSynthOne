//
//  S1Sequencer.hpp
//  AudioKitSynthOne
//
//  Created by AudioKit Contributors on 3/06/19.
//  Copyright © 2019 AudioKit. All rights reserved.
//
#include <array>
#include <atomic>
#include <functional>
#include <list>
#include <vector>

#import "Foundation/Foundation.h"
#import "S1AudioUnit.h"
#import "S1Parameter.h"
#import "S1SeqNoteNumber.hpp"

@class AEArray;

#ifdef __cplusplus

using DSPParameters = std::array<float, S1Parameter::S1ParameterCount>;
using BeatCounterChangedCallback = std::function<void()>;
using KeyOnCallback = std::function<void(int, int)>;
using KeyOffCallback = std::function<void(int)>;

class S1Sequencer {

public:
    S1Sequencer() = delete;
    S1Sequencer(KeyOnCallback keyOnCb, KeyOffCallback keyOffCb, BeatCounterChangedCallback beatChangedCb);

    void setSampleRate(double sampleRate);
    void init();
    void reset(bool resetNotes);
    void setNotesPerOctave(int notes);

    int getArpBeatCount();
    void process(DSPParameters &params, AEArray *heldNoteNumbersAE);

private:
    double mSampleRate = 0;
    const int maxSequencerNotes = 1024; // 128 midi note numbers * 4 arp octaves * up+down
    void reserveNotes(); // Allocate notes before rendering

    // Array of midi note numbers of NoteState's which have had a noteOn event but not yet a noteOff event.
    int previousHeldNoteNumbersAECount; // previous render loop held key count

    // Beattime Counter
    double mBeatTime = 0;
    std::atomic<int> mStepCounter = 0;

    ///once init'd: sequencerNotes can be accessed and mutated only within process and resetDSP
    std::vector<SeqNoteNumber> sequencerNotes;
    std::vector<NoteNumber> sequencerNotes2;

    ///once init'd: sequencerLastNotes can be accessed and mutated only within process and resetDSP
    std::list<int> sequencerLastNotes;

    std::atomic<int> mNotesPerOctave{12};

    // Change notifications
    BeatCounterChangedCallback mBeatCounterDidChange;
    KeyOnCallback mTurnOnKey;
    KeyOffCallback mTurnOffKey;
};

#endif
