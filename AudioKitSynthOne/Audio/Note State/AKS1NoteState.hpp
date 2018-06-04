//
//  AKS1NoteState.hpp
//  AudioKitSynthOne
//
//  Created by AudioKit Contributors on 4/30/18.
//  Copyright © 2018 AudioKit. All rights reserved.
//
//  Atomic unit of a "note"; managed by AKSynthOneDSPKernel

#pragma once

#import <vector>
#import <list>
#import <string>
#import "AKSoundpipeKernel.hpp"
#import "AKSynthOneAudioUnit.h"
#import "AKSynthOneParameter.h"
#import "AKS1Rate.hpp"

#ifdef __cplusplus

class AKSynthOneDSPKernel;

struct AKS1NoteState {
    
    AKSynthOneDSPKernel* kernel;
    
    enum NoteStateStage { stageOff, stageOn, stageRelease };
    NoteStateStage stage = stageOff;
    
    float internalGate = 0;
    float amp = 0;
    float filter = 0;
    int rootNoteNumber = 0; // -1 denotes an invalid note number
    
    //Amplitude ADSR
    sp_adsr *adsr;
    
    //Filter Cutoff Frequency ADSR
    sp_adsr *fadsr;
    
    //Morphing Oscillator 1 & 2
    sp_oscmorph *oscmorph1;
    sp_oscmorph *oscmorph2;
    sp_crossfade *morphCrossFade;
    
    //Subwoofer OSC
    sp_osc *subOsc;
    
    //FM OSC
    sp_fosc *fmOsc;
    
    //NOISE OSC
    sp_noise *noise;
    
    //FILTERS
    sp_moogladder *loPass;
    sp_buthp *hiPass;
    sp_butbp *bandPass;
    sp_crossfade *filterCrossFade;
    
    inline float getParam(AKSynthOneParameter param);

    void init();

    void destroy();
    
    void clear();

    void startNoteHelper(int noteNumber, int velocity, float frequency);

    void run(int frameIndex, float *outL, float *outR);
};

#endif
