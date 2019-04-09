//
//  S1Arpeggiator.hpp
//  AudioKitSynthOne
//
//  Created by AudioKit Contributors on 3/06/19.
//  Copyright © 2019 AudioKit. All rights reserved.
//

#import "S1AudioUnit.h"
#import "S1SeqNoteNumber.hpp"

#include <vector>

template<typename SeqNoteNumbers, typename NoteNumbers>
struct Arpeggiator {
    Arpeggiator() = delete;

    static int up(SeqNoteNumbers &sequencerNotes, NoteNumbers &sequencerNotes2,
                   const int heldNotesCount, const int arpOctaves, const int interval) {
        int index = 0;
        for (int octave = 0; octave < arpOctaves; octave++) {
            for (int i = 0; i < heldNotesCount; i++) {
                NoteNumber& note = sequencerNotes2[i];
                const int nn = note.noteNumber + (octave * interval);
                const int velocity = note.velocity;
                SeqNoteNumber snn{nn, 1, velocity};
                std::vector<SeqNoteNumber>::iterator it = sequencerNotes.begin() + index;
                sequencerNotes.insert(it, snn);
                ++index;
            }
        }
        return index;
    }

    static void down(SeqNoteNumbers &sequencerNotes, NoteNumbers &sequencerNotes2,
                          const int heldNotesCount, const int arpOctaves, const int interval, const bool noTail, int index = 0)
    {
        for (int octave = arpOctaves - 1; octave >= 0; octave--) {
            for (int i = heldNotesCount - 1; i >= 0; i--) {
                const bool firstNote = (i == heldNotesCount - 1) && (octave == arpOctaves - 1);
                const bool lastNote = (i == 0) && (octave == 0);
                if ((firstNote || lastNote) && noTail) {
                    continue;
                }

                NoteNumber& note = sequencerNotes2[i];
                const int nn = note.noteNumber + (octave * interval);
                const int velocity = note.velocity;
                SeqNoteNumber snn{nn, 1, velocity};
                std::vector<SeqNoteNumber>::iterator it = sequencerNotes.begin() + index;
                sequencerNotes.insert(it, snn);
                ++index;
            }
        }
    };
};
