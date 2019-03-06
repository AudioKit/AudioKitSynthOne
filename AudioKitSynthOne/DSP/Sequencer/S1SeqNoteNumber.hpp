//
//  S1SeqNoteNumber.hpp
//  AudioKitSynthOne
//
//  Created by AudioKit Contributors on 3/06/19.
//  Copyright © 2019 AudioKit. All rights reserved.
//

struct SeqNoteNumber {
    int noteNumber;
    int onOff;

    void init() {
        noteNumber = 60;
        onOff = 1;
    }

    void init(int nn, int o) {
        noteNumber = nn;
        onOff = o;
    }
};
