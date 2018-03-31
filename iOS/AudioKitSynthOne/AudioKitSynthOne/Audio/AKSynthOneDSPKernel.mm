//
//  AKSynthOneDSPKernel.mm
//  AudioKitSynthOne
//
//  Created by Marcus W. Hobbs aka Marcus Satellite on 1/27/18.
//  Copyright © 2018 AudioKit. All rights reserved.
//

#import <AudioKit/AudioKit-swift.h>
#import "AKSynthOneDSPKernel.hpp"
#import <AudioToolbox/AudioToolbox.h>
#import <AudioUnit/AudioUnit.h>
#import <AVFoundation/AVFoundation.h>
#import "AEArray.h"
#import "AEMessageQueue.h"

#define SAMPLE_RATE (44100.f)
#define RELEASE_AMPLITUDE_THRESHOLD (0.00001f)
#define AKS1_PORTAMENTO_HALF_TIME (0.1f)
//#define AKS1_PORTAMENTO_HALF_TIME (0.25f) // too slow for prod synth
//#define AKS1_PORTAMENTO_HALF_TIME (0.5f) // try this for fun
//#define AKS1_PORTAMENTO_HALF_TIME (1.f) // alice in wonderland
#define DEBUG_DSP_LOGGING (0)
#define DEBUG_NOTE_STATE_LOGGING (0)


// Relative note number to frequency
static inline float nnToHz(float noteNumber) {
    return exp2(noteNumber/12.f);
}

// Convert note number to [possibly] microtonal frequency.  12ET is the default.
// Profiling shows that while this takes a special Swift lock it still resolves to ~0% of CPU on a device
static inline double tuningTableNoteToHz(int noteNumber) {
    return [AKPolyphonicNode.tuningTable frequencyForNoteNumber:noteNumber];
}


// helper for midi/render thread communication, held-notes, etc
struct AKSynthOneDSPKernel::NoteNumber {
    
    int noteNumber;
    
    void init() {
        noteNumber = 60;
    }
};


// helper for arp/seq
struct AKSynthOneDSPKernel::SeqNoteNumber {
    
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


// MARK: NoteState: atomic unit of a "note"
struct AKSynthOneDSPKernel::NoteState {
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
    
    void init() {
        // OSC AMPLITUDE ENVELOPE
        sp_adsr_create(&adsr);
        sp_adsr_init(kernel->sp, adsr);
        
        // FILTER FREQUENCY ENVELOPE
        sp_adsr_create(&fadsr);
        sp_adsr_init(kernel->sp, fadsr);
        
        // OSC1
        sp_oscmorph_create(&oscmorph1);
        sp_oscmorph_init(kernel->sp, oscmorph1, kernel->ft_array, AKS1_NUM_FTABLES, 0);
        oscmorph1->freq = 0;
        oscmorph1->amp = 0;
        oscmorph1->wtpos = 0;
        
        // OSC2
        sp_oscmorph_create(&oscmorph2);
        sp_oscmorph_init(kernel->sp, oscmorph2, kernel->ft_array, AKS1_NUM_FTABLES, 0);
        oscmorph2->freq = 0;
        oscmorph2->amp = 0;
        oscmorph2->wtpos = 0;
        
        // CROSSFADE OSC1 and OSC2
        sp_crossfade_create(&morphCrossFade);
        sp_crossfade_init(kernel->sp, morphCrossFade);
        
        // CROSSFADE DRY AND FILTER
        sp_crossfade_create(&filterCrossFade);
        sp_crossfade_init(kernel->sp, filterCrossFade);
        
        // SUB OSC
        sp_osc_create(&subOsc);
        sp_osc_init(kernel->sp, subOsc, kernel->sine, 0.f);
        
        // FM osc
        sp_fosc_create(&fmOsc);
        sp_fosc_init(kernel->sp, fmOsc, kernel->sine);
        
        // NOISE
        sp_noise_create(&noise);
        sp_noise_init(kernel->sp, noise);
        
        // FILTER
        sp_moogladder_create(&loPass);
        sp_moogladder_init(kernel->sp, loPass);
        sp_butbp_create(&bandPass);
        sp_butbp_init(kernel->sp, bandPass);
        sp_buthp_create(&hiPass);
        sp_buthp_init(kernel->sp, hiPass);
    }
    
    void destroy() {
        sp_adsr_destroy(&adsr);
        sp_adsr_destroy(&fadsr);
        sp_oscmorph_destroy(&oscmorph1);
        sp_oscmorph_destroy(&oscmorph2);
        sp_crossfade_destroy(&morphCrossFade);
        sp_crossfade_destroy(&filterCrossFade);
        sp_osc_destroy(&subOsc);
        sp_fosc_destroy(&fmOsc);
        sp_noise_destroy(&noise);
        sp_moogladder_destroy(&loPass);
        sp_butbp_destroy(&bandPass);
        sp_buthp_destroy(&hiPass);
    }
    
    void clear() {
        internalGate = 0;
        stage = stageOff;
        amp = 0;
        rootNoteNumber = -1;
    }
    
    // helper...supports initialization of playing note for both mono and poly
    void startNoteHelper(int noteNumber, int velocity, float frequency) {
        oscmorph1->freq = frequency;
        oscmorph2->freq = frequency;
        subOsc->freq = frequency;
        fmOsc->freq = frequency;
        
        const float amplitude = (float)pow2(velocity / 127.f);
        oscmorph1->amp = amplitude;
        oscmorph2->amp = amplitude;
        subOsc->amp = amplitude;
        fmOsc->amp = amplitude;
        noise->amp = amplitude;
        
        stage = NoteState::stageOn;
        internalGate = 1;
        rootNoteNumber = noteNumber;
    }
    
    //MARK:NoteState.run()
    //This function needs to be heavily optimized...it is called at SampleRate for each NoteState
    void run(int frameIndex, float *outL, float *outR) {
        
        // isMono
        const bool isMonoMode = (kernel->p[isMono] == 1);
        
        // convenience
        const float lfo1_0_1 = kernel->lfo1_0_1;
        const float lfo1_1_0 = kernel->lfo1_1_0;
        const float lfo2_0_1 = kernel->lfo2_0_1;
        const float lfo2_1_0 = kernel->lfo2_1_0;
        const float lfo3_0_1 = kernel->lfo3_0_1;
        const float lfo3_1_0 = kernel->lfo3_1_0;
        
        //pitchLFO common frequency coefficient
        float commonFrequencyCoefficient = 1.f;
        if (kernel->p[pitchLFO] == 1.f) {
            commonFrequencyCoefficient = 1.f + lfo1_0_1;
        } else if (kernel->p[pitchLFO] == 2.f) {
            commonFrequencyCoefficient = 1.f + lfo2_0_1;
        } else if (kernel->p[pitchLFO] == 3.f) {
            commonFrequencyCoefficient = 1.f + lfo3_0_1;
        }
        
        //OSC1 frequency
        const float cachedFrequencyOsc1 = oscmorph1->freq;
        float newFrequencyOsc1 = isMonoMode ?kernel->monoFrequencySmooth :cachedFrequencyOsc1;
        newFrequencyOsc1 *= nnToHz((int)kernel->p[morph1SemitoneOffset]);
        newFrequencyOsc1 *= kernel->p[detuningMultiplier] * commonFrequencyCoefficient;
        newFrequencyOsc1 = clamp(newFrequencyOsc1, 0.f, 0.5f*SAMPLE_RATE);
        oscmorph1->freq = newFrequencyOsc1;
        
        //OSC1: wavetable
        oscmorph1->wtpos = kernel->p[index1];
        
        //OSC2 frequency
        const float cachedFrequencyOsc2 = oscmorph2->freq;
        float newFrequencyOsc2 = isMonoMode ?kernel->monoFrequencySmooth :cachedFrequencyOsc2;
        newFrequencyOsc2 *= nnToHz((int)kernel->p[morph2SemitoneOffset]);
        newFrequencyOsc2 *= kernel->p[detuningMultiplier] * commonFrequencyCoefficient;
        
        
        //LFO DETUNE OSC2: original additive method, now with scaled range based on 4Hz at C3
        const float magicDetune = cachedFrequencyOsc2/261.6255653006f;
        if (kernel->p[detuneLFO] == 1.f) {
            newFrequencyOsc2 += lfo1_0_1 * kernel->p[morph2Detuning] * magicDetune;
        } else if (kernel->p[detuneLFO] == 2.f) {
            newFrequencyOsc2 += lfo2_0_1 * kernel->p[morph2Detuning] * magicDetune;
        } else if (kernel->p[detuneLFO] == 3.f) {
            newFrequencyOsc2 += lfo3_0_1 * kernel->p[morph2Detuning] * magicDetune;
        } else {
            newFrequencyOsc2 += kernel->p[morph2Detuning] * magicDetune;
        }
        newFrequencyOsc2 = clamp(newFrequencyOsc2, 0.f, 0.5f*SAMPLE_RATE);
        oscmorph2->freq = newFrequencyOsc2;
        
        //OSC2: wavetable
        oscmorph2->wtpos = kernel->p[index2];
        
        //SUB OSC FREQ
        const float cachedFrequencySub = subOsc->freq;
        float newFrequencySub = isMonoMode ?kernel->monoFrequencySmooth :cachedFrequencySub;
        newFrequencySub *= kernel->p[detuningMultiplier] / (2.f * (1.f + kernel->p[subOctaveDown])) * commonFrequencyCoefficient;
        newFrequencySub = clamp(newFrequencySub, 0.f, 0.5f*SAMPLE_RATE);
        subOsc->freq = newFrequencySub;
        
        //FM OSC FREQ
        const float cachedFrequencyFM = fmOsc->freq;
        float newFrequencyFM = isMonoMode ?kernel->monoFrequencySmooth :cachedFrequencyFM;
        newFrequencyFM *= kernel->p[detuningMultiplier] * commonFrequencyCoefficient;
        newFrequencyFM = clamp(newFrequencyFM, 0.f, 0.5f*SAMPLE_RATE);
        fmOsc->freq = newFrequencyFM;
        
        //FM LFO
        float fmOscIndx = kernel->p[fmAmount];
        if (kernel->p[fmLFO] == 1.f) {
            fmOscIndx = kernel->p[fmAmount] * lfo1_1_0;
        } else if (kernel->p[fmLFO] == 2.f) {
            fmOscIndx = kernel->p[fmAmount] * lfo2_1_0;
        } else if (kernel->p[fmLFO] == 3.f) {
            fmOscIndx = kernel->p[fmAmount] * lfo3_1_0;
        }
        fmOscIndx = kernel->parameterClamp(fmAmount, fmOscIndx);
        fmOsc->indx = fmOscIndx;
        
        //ADSR
        adsr->atk = kernel->p[attackDuration];
        adsr->rel = kernel->p[releaseDuration];
        
        //ADSR decay LFO
        float dec = kernel->p[decayDuration];
        if (kernel->p[decayLFO] == 1.f) {
            dec *= lfo1_1_0;
        } else if (kernel->p[decayLFO] == 2.f) {
            dec *= lfo2_1_0;
        } else if (kernel->p[decayLFO] == 3.f) {
            dec *= lfo3_1_0;
        }

        dec = kernel->parameterClamp(decayDuration, dec);
        adsr->dec = dec;
        
        //ADSR sustain LFO
        float sus = kernel->p[sustainLevel];
        if (kernel->p[sustainLFO] == 1.f) {
            sus *= lfo1_1_0;
        } else if (kernel->p[sustainLFO] == 2.f) {
            sus *= lfo2_1_0;
        } else if (kernel->p[sustainLFO] == 3.f) {
            sus *= lfo3_1_0;
        }
        sus = kernel->parameterClamp(sustainLevel, sus);
        adsr->sus = sus;
        
        //FILTER FREQ CUTOFF ADSR
        fadsr->atk = (float)kernel->p[filterAttackDuration];
        fadsr->dec = (float)kernel->p[filterDecayDuration];
        fadsr->sus = (float)kernel->p[filterSustainLevel];
        fadsr->rel = (float)kernel->p[filterReleaseDuration];
        
        //OSCMORPH CROSSFADE
        float crossFadePos = kernel->p[morphBalance];
        if (kernel->p[oscMixLFO] == 1.f) {
            crossFadePos = kernel->p[morphBalance] + lfo1_0_1;
        } else if (kernel->p[oscMixLFO] == 2.f) {
            crossFadePos = kernel->p[morphBalance] + lfo2_0_1;
        } else if (kernel->p[oscMixLFO] == 3.f) {
            crossFadePos = kernel->p[morphBalance] + lfo3_0_1;
        }
        crossFadePos = clamp(crossFadePos, 0.f, 1.f);
        morphCrossFade->pos = crossFadePos;
        
        //TODO:param filterMix is hard-coded to 1
        filterCrossFade->pos = kernel->p[filterMix];
        
        //FILTER RESONANCE LFO
        float filterResonance = kernel->p[resonance];
        if (kernel->p[resonanceLFO] == 1) {
            filterResonance *= lfo1_1_0;
        } else if (kernel->p[resonanceLFO] == 2) {
            filterResonance *= lfo2_1_0;
        } else if (kernel->p[resonanceLFO] == 3) {
            filterResonance *= lfo3_1_0;
        }
        filterResonance = kernel->parameterClamp(resonance, filterResonance);
        if(kernel->p[filterType] == 0) {
            loPass->res = filterResonance;
        } else if(kernel->p[filterType] == 1) {
            // bandpass bandwidth is a different unit than lopass resonance.
            // take advantage of the range of resonance [0,1].
            const float bandwidth = (0.5f * 0.5f * 0.5f * 0.5f) * SAMPLE_RATE * (-1.f + exp2( clamp(1.f - filterResonance, 0.f, 1.f) ) );
            bandPass->bw = bandwidth;
        }
        
        //FINAL OUTs
        float oscmorph1_out = 0.f;
        float oscmorph2_out = 0.f;
        float osc_morph_out = 0.f;
        float subOsc_out = 0.f;
        float fmOsc_out = 0.f;
        float noise_out = 0.f;
        float filterOut = 0.f;
        float finalOut = 0.f;
        
        // osc amp adsr
        sp_adsr_compute(kernel->sp, adsr, &internalGate, &amp);
        
        // filter cutoff adsr
        sp_adsr_compute(kernel->sp, fadsr, &internalGate, &filter);
        
        // filter frequency cutoff calculation
        float filterCutoffFreq = kernel->p[cutoff];
        if (kernel->p[cutoffLFO] == 1.f) {
            filterCutoffFreq *= lfo1_1_0;
        } else if (kernel->p[cutoffLFO] == 2.f) {
            filterCutoffFreq *= lfo2_1_0;
        } else if (kernel->p[cutoffLFO] == 3.f) {
            filterCutoffFreq *= lfo3_1_0;
        }

        // filter frequency env lfo crossfade
        float filterEnvLFOMix = kernel->p[filterADSRMix];
        if (kernel->p[filterEnvLFO] == 1.f) {
            filterEnvLFOMix *= lfo1_1_0;
        } else if (kernel->p[filterEnvLFO] == 2.f) {
            filterEnvLFOMix *= lfo2_1_0;
        } else if (kernel->p[filterEnvLFO] == 3.f) {
            filterEnvLFOMix *= lfo3_1_0;
        }

        // filter frequency mixer
        filterCutoffFreq -= filterCutoffFreq * filterEnvLFOMix * (1.f - filter);
        filterCutoffFreq = kernel->parameterClamp(cutoff, filterCutoffFreq);
        loPass->freq = filterCutoffFreq;
        bandPass->freq = filterCutoffFreq;
        hiPass->freq = filterCutoffFreq;
        
        //oscmorph1_out
        sp_oscmorph_compute(kernel->sp, oscmorph1, nil, &oscmorph1_out);
        oscmorph1_out *= kernel->p[morph1Volume];
        
        //oscmorph2_out
        sp_oscmorph_compute(kernel->sp, oscmorph2, nil, &oscmorph2_out);
        oscmorph2_out *= kernel->p[morph2Volume];
        
        //osc_morph_out
        sp_crossfade_compute(kernel->sp, morphCrossFade, &oscmorph1_out, &oscmorph2_out, &osc_morph_out);
        
        //subOsc_out
        sp_osc_compute(kernel->sp, subOsc, nil, &subOsc_out);
        if (kernel->p[subIsSquare]) {
            if (subOsc_out > 0.f) {
                subOsc_out = kernel->p[subVolume];
            } else {
                subOsc_out = -kernel->p[subVolume];
            }
        } else {
            // make sine louder
            subOsc_out *= kernel->p[subVolume] * 2.f * 1.5f;
        }
        
        //fmOsc_out
        sp_fosc_compute(kernel->sp, fmOsc, nil, &fmOsc_out);
        fmOsc_out *= kernel->p[fmVolume];
        
        //noise_out
        sp_noise_compute(kernel->sp, noise, nil, &noise_out);
        noise_out *= kernel->p[noiseVolume];
        if (kernel->p[noiseLFO] == 1.f) {
            noise_out *= lfo1_1_0;
        } else if (kernel->p[noiseLFO] == 2.f) {
            noise_out *= lfo2_1_0;
        } else if (kernel->p[noiseLFO] == 3.f) {
            noise_out *= lfo3_1_0;
        }

        //synthOut
        float synthOut = amp * (osc_morph_out + subOsc_out + fmOsc_out + noise_out);
        
        //filterOut
        if(kernel->p[filterType] == 0.f) {
            sp_moogladder_compute(kernel->sp, loPass, &synthOut, &filterOut);
        } else if (kernel->p[filterType] == 1.f) {
            sp_butbp_compute(kernel->sp, bandPass, &synthOut, &filterOut);
        } else if (kernel->p[filterType] == 2.f) {
            sp_buthp_compute(kernel->sp, hiPass, &synthOut, &filterOut);
        }
        
        // filter crossfade
        sp_crossfade_compute(kernel->sp, filterCrossFade, &synthOut, &filterOut, &finalOut);
        
        // final output
        outL[frameIndex] += finalOut;
        outR[frameIndex] += finalOut;
        
        // restore cached values
        oscmorph1->freq = cachedFrequencyOsc1;
        oscmorph2->freq = cachedFrequencyOsc2;
        subOsc->freq = cachedFrequencySub;
        fmOsc->freq = cachedFrequencyFM;
    }
};

// MARK: AKSynthOneDSPKernel Member Functions

AKSynthOneDSPKernel::AKSynthOneDSPKernel() {}

AKSynthOneDSPKernel::~AKSynthOneDSPKernel() = default;

//efficient parameter setter/getter method
void AKSynthOneDSPKernel::setAK1Parameter(AKSynthOneParameter param, float inputValue) {
    const float value = parameterClamp(param, inputValue);
    AKS1Param& s = aks1p[param];
    if(s.usePortamento) {
        s.portamentoTarget = value;
    } else {
        p[param] = value;
    }
#if DEBUG_DSP_LOGGING
    const char* d = AKSynthOneDSPKernel::parameterCStr(param);
    printf("AKSynthOneDSPKernel.hpp:setAK1Parameter(): %i:%s --> %f\n", param, d, value);
#endif
}

float AKSynthOneDSPKernel::getAK1Parameter(AKSynthOneParameter param) {
    AKS1Param& s = aks1p[param];
    if(s.usePortamento)
        return s.portamentoTarget;
    else
        return p[param];
}

void AKSynthOneDSPKernel::setParameters(float params[]) {
    for (int i = 0; i < AKSynthOneParameter::AKSynthOneParameterCount; i++) {
        setAK1Parameter((AKSynthOneParameter)i, params[i]);
    }
}

void AKSynthOneDSPKernel::setParameter(AUParameterAddress address, AUValue value) {
    const int i = (AKSynthOneParameter)address;
    setAK1Parameter((AKSynthOneParameter)i, value);
}

AUValue AKSynthOneDSPKernel::getParameter(AUParameterAddress address) {
    const int i = (AKSynthOneParameter)address;
    return p[i];
}

void AKSynthOneDSPKernel::startRamp(AUParameterAddress address, AUValue value, AUAudioFrameCount duration) {}

///DEBUG_NOTE_STATE_LOGGING (1) can cause race conditions
void AKSynthOneDSPKernel::print_debug() {
#if DEBUG_NOTE_STATE_LOGGING
    printf("\n-------------------------------------\n");
    printf("\nheldNoteNumbers:\n");
    for (NSNumber* nnn in heldNoteNumbers) {
        printf("%li, ", (long)nnn.integerValue);
    }
    
    if(p[isMono] == 1) {
        printf("\nmonoNote noteNumber:%i, freq:%f, freqSmooth:%f\n",monoNote->rootNoteNumber, monoFrequency, monoFrequencySmooth);
        
    } else {
        printf("\nplayingNotes:\n");
        for(int i=0; i<AKS1_MAX_POLYPHONY; i++) {
            if(playingNoteStatesIndex == i)
                printf("*");
            const int nn = noteStates[i].rootNoteNumber;
            printf("%i:%i, ", i, nn);
        }
    }
    printf("\n-------------------------------------\n");
#endif
}

///panic...hard-resets DSP.  artifacts.
void AKSynthOneDSPKernel::resetDSP() {
    [heldNoteNumbers removeAllObjects];
    [heldNoteNumbersAE updateWithContentsOfArray:heldNoteNumbers];
    arpSeqLastNotes.clear();
    arpSeqNotes.clear();
    arpSeqNotes2.clear();
    arpBeatCounter = 0;
    p[arpIsOn] = 0.f;
    monoNote->clear();
    for(int i =0; i < AKS1_MAX_POLYPHONY; i++)
        noteStates[i].clear();
    
    print_debug();
}


///puts all notes in release mode...no artifacts
void AKSynthOneDSPKernel::stopAllNotes() {
    [heldNoteNumbers removeAllObjects];
    [heldNoteNumbersAE updateWithContentsOfArray:heldNoteNumbers];
    if (p[isMono] == 1) {
        // MONO
        stopNote(60);
    } else {
        // POLY
        for(int i=0; i<AKS1_NUM_MIDI_NOTES; i++)
            stopNote(i);
    }
    print_debug();
}

void AKSynthOneDSPKernel::handleTempoSetting(float currentTempo) {
    if (currentTempo != tempo) {
        tempo = currentTempo;
    }
}

///can be called from within the render loop
void AKSynthOneDSPKernel::beatCounterDidChange() {
    const BOOL status =
    AEMessageQueuePerformSelectorOnMainThread(audioUnit->_messageQueue,
                                              audioUnit,
                                              @selector(arpBeatCounterDidChange),
                                              AEArgumentNone);
    if (!status) {
#if DEBUG_DSP_LOGGING
        printf("AKSynthOneDSPKernel::beatCounterDidChange: AEMessageQueuePerformSelectorOnMainThread FAILED!\n");
#endif
    }
}

///can be called from within the render loop
void AKSynthOneDSPKernel::playingNotesDidChange() {
    const BOOL status =
    AEMessageQueuePerformSelectorOnMainThread(audioUnit->_messageQueue,
                                              audioUnit,
                                              @selector(playingNotesDidChange),
                                              AEArgumentNone);
    if (!status) {
#if DEBUG_DSP_LOGGING
        printf("AKSynthOneDSPKernel::playingNotesDidChange: AEMessageQueuePerformSelectorOnMainThread FAILED!\n");
#endif
    }
}

///can be called from within the render loop
void AKSynthOneDSPKernel::heldNotesDidChange() {
    const BOOL status =
    AEMessageQueuePerformSelectorOnMainThread(audioUnit->_messageQueue,
                                              audioUnit,
                                              @selector(heldNotesDidChange),
                                              AEArgumentNone);
    if (!status) {
#if DEBUG_DSP_LOGGING
        printf("AKSynthOneDSPKernel::heldNotesDidChange: AEMessageQueuePerformSelectorOnMainThread FAILED!\n");
#endif
    }
}

//MARK: PROCESS
void AKSynthOneDSPKernel::process(AUAudioFrameCount frameCount, AUAudioFrameCount bufferOffset) {
    initializeNoteStates();
    
    // PREPARE FOR RENDER LOOP...updates here happen at (typically) 44100/512 HZ
    
    // define buffers
    float* outL = (float*)outBufferListPtr->mBuffers[0].mData + bufferOffset;
    float* outR = (float*)outBufferListPtr->mBuffers[1].mData + bufferOffset;
    
    //
    *compressorMasterL->ratio = p[compressorMasterRatio];
    *compressorMasterR->ratio = p[compressorMasterRatio];
    *compressorReverbInputL->ratio = p[compressorReverbInputRatio];
    *compressorReverbInputR->ratio = p[compressorReverbInputRatio];
    *compressorReverbWetL->ratio = p[compressorReverbWetRatio];
    *compressorReverbWetR->ratio = p[compressorReverbWetRatio];
    *compressorMasterL->thresh = p[compressorMasterThreshold];
    *compressorMasterR->thresh = p[compressorMasterThreshold];
    *compressorReverbInputL->thresh = p[compressorReverbInputThreshold];
    *compressorReverbInputR->thresh = p[compressorReverbInputThreshold];
    *compressorReverbWetL->thresh = p[compressorReverbWetThreshold];
    *compressorReverbWetR->thresh = p[compressorReverbWetThreshold];
    *compressorMasterL->atk = p[compressorMasterAttack];
    *compressorMasterR->atk = p[compressorMasterAttack];
    *compressorReverbInputL->atk = p[compressorReverbInputAttack];
    *compressorReverbInputR->atk = p[compressorReverbInputAttack];
    *compressorReverbWetL->atk = p[compressorReverbWetAttack];
    *compressorReverbWetR->atk = p[compressorReverbWetAttack];
    *compressorMasterL->rel = p[compressorMasterRelease];
    *compressorMasterR->rel = p[compressorMasterRelease];
    *compressorReverbInputL->rel = p[compressorReverbInputRelease];
    *compressorReverbInputR->rel = p[compressorReverbInputRelease];
    *compressorReverbWetL->rel = p[compressorReverbWetRelease];
    *compressorReverbWetR->rel = p[compressorReverbWetRelease];

    // transition playing notes from release to off...outside render block because it's not expensive to let the release linger
    bool transitionedToOff = false;
    if (p[isMono] == 1.f) {
        if (monoNote->stage == NoteState::stageRelease && monoNote->amp < RELEASE_AMPLITUDE_THRESHOLD) {
            monoNote->clear();
            transitionedToOff = true;
        }
    } else {
        for(int i=0; i<polyphony; i++) {
            NoteState& note = noteStates[i];
            if (note.stage == NoteState::stageRelease && note.amp < RELEASE_AMPLITUDE_THRESHOLD) {
                note.clear();
                transitionedToOff = true;
            }
        }
    }
    if (transitionedToOff)
        playingNotesDidChange();
    
    const float arpTempo = p[arpRate];
    const double secPerBeat = 0.5f * 0.5f * 60.f / arpTempo;
    
    // RENDER LOOP: Render one audio frame at sample rate, i.e. 44100 HZ ////////////////
    for (AUAudioFrameCount frameIndex = 0; frameIndex < frameCount; ++frameIndex) {

        //PORTAMENTO
        for(int i = 0; i< AKSynthOneParameter::AKSynthOneParameterCount; i++) {
            if(aks1p[i].usePortamento) {
                sp_port_compute(sp, aks1p[i].portamento, &aks1p[i].portamentoTarget, &p[i]);
            }
        }
        monoFrequencyPort->htime = p[glide]; // note that p[glide] is smoothed by above
        sp_port_compute(sp, monoFrequencyPort, &monoFrequency, &monoFrequencySmooth);

        lfo1Phasor->freq = p[lfo1Rate];
        lfo2Phasor->freq = p[lfo2Rate];
        
        panOscillator->freq = p[autoPanFrequency];
        panOscillator->amp = p[autoPanAmount];
        
        bitcrush->bitdepth = p[bitCrushDepth];
        
        delayL->del = delayR->del = p[delayTime] * 2.f;
        delayRR->del = delayFillIn->del = p[delayTime];
        delayL->feedback = delayR->feedback = p[delayFeedback];
        delayRR->feedback = p[delayFeedback]; // ?
        delayFillIn->feedback = p[delayFeedback]; // ?
        
        *phaser0->Notch_width = p[phaserNotchWidth];
        *phaser0->feedback_gain = p[phaserFeedback];
        *phaser0->lfobpm = p[phaserRate];

        // CLEAR BUFFER
        outL[frameIndex] = outR[frameIndex] = 0.f;
        
        // Clear all notes when toggling Mono <==> Poly
        if( p[isMono] != previousProcessMonoPolyStatus ) {
            previousProcessMonoPolyStatus = p[isMono];
            reset(); // clears all mono and poly notes
            arpSeqLastNotes.clear();
        }
        
        //MARK: ARP/SEQ
        if( p[arpIsOn] == 1.f || arpSeqLastNotes.size() > 0 ) {
            //TODO:here is where we are not sending beat zero to the delegate
            const double oldArpTime = arpTime;
            const double r0 = fmod(oldArpTime, secPerBeat);
            arpTime = arpSampleCounter/SAMPLE_RATE;
            const double r1 = fmod(arpTime, secPerBeat);
            arpSampleCounter += 1.0;
            if (r1 < r0 || oldArpTime >= arpTime) {
                
                // MARK: ARP+SEQ: NEW beatCounter: Create Arp/Seq array based on held notes and/or sequence parameters
                if (p[arpIsOn] == 1.f) {
                    arpSeqNotes.clear();
                    arpSeqNotes2.clear();
                    
                    // only update "notes per octave" when beat counter changes so arpSeqNotes and arpSeqLastNotes match
                    
                    notesPerOctave = (int)AKPolyphonicNode.tuningTable.npo; // Profiling shows this is ~0% of CPU on a device
                    if(notesPerOctave <= 0) notesPerOctave = 12;
                    const float npof = (float)notesPerOctave/12.f; // 12ET ==> npof = 1
                    
                    // SEQUENCER
                    if(p[arpIsSequencer] == 1.f) {
                        const int numSteps = p[arpTotalSteps] > 16 ? 16 : (int)p[arpTotalSteps];
                        for(int i = 0; i < numSteps; i++) {
                            const float onOff = p[i + arpSeqNoteOn00];
                            const int octBoost = p[i + arpSeqOctBoost00];
                            const int nn = p[i + arpSeqPattern00] * npof;
                            const int nnob = (nn < 0) ? (nn - octBoost * notesPerOctave) : (nn + octBoost * notesPerOctave);
                            struct SeqNoteNumber snn;
                            snn.init(nnob, onOff);
                            arpSeqNotes.push_back(snn);
                        }
                    } else {
                        
                        // ARP state
                        
                        // reverse
                        AEArrayEnumeratePointers(heldNoteNumbersAE, struct NoteNumber *, note) {
                            std::vector<NoteNumber>::iterator it = arpSeqNotes2.begin();
                            arpSeqNotes2.insert(it, *note);
                        }
                        const int heldNotesCount = (int)arpSeqNotes2.size();
                        const int arpIntervalUp = p[arpInterval] * npof;
                        const int onOff = 1;
                        const int arpOctaves = (int)p[arpOctave] + 1;
                        
                        if (p[arpDirection] == 0.f) {
                            
                            // ARP Up
                            int index = 0;
                            for (int octave = 0; octave < arpOctaves; octave++) {
                                for (int i = 0; i < heldNotesCount; i++) {
                                    struct NoteNumber& note = arpSeqNotes2[i];
                                    const int nn = note.noteNumber + (octave * arpIntervalUp);
                                    struct SeqNoteNumber snn;
                                    snn.init(nn, onOff);
                                    std::vector<SeqNoteNumber>::iterator it = arpSeqNotes.begin() + index;
                                    arpSeqNotes.insert(it, snn);
                                    ++index;
                                }
                            }
                            
                        } else if (p[arpDirection] == 1.f) {
                            
                            ///ARP Up + Down
                            //up
                            int index = 0;
                            for (int octave = 0; octave < arpOctaves; octave++) {
                                for (int i = 0; i < heldNotesCount; i++) {
                                    struct NoteNumber& note = arpSeqNotes2[i];
                                    const int nn = note.noteNumber + (octave * arpIntervalUp);
                                    struct SeqNoteNumber snn;
                                    snn.init(nn, onOff);
                                    std::vector<SeqNoteNumber>::iterator it = arpSeqNotes.begin() + index;
                                    arpSeqNotes.insert(it, snn);
                                    ++index;
                                }
                            }
                            //down, minus head and tail
                            for (int octave = arpOctaves - 1; octave >= 0; octave--) {
                                for (int i = heldNotesCount - 1; i >= 0; i--) {
                                    const bool firstNote = (i == heldNotesCount - 1) && (octave == arpOctaves - 1);
                                    const bool lastNote = (i == 0) && (octave == 0);
                                    if (!firstNote && !lastNote) {
                                        struct NoteNumber& note = arpSeqNotes2[i];
                                        const int nn = note.noteNumber + (octave * arpIntervalUp);
                                        struct SeqNoteNumber snn;
                                        snn.init(nn, onOff);
                                        std::vector<SeqNoteNumber>::iterator it = arpSeqNotes.begin() + index;
                                        arpSeqNotes.insert(it, snn);
                                        ++index;
                                    }
                                }
                            }
                            
                        } else if (p[arpDirection] == 2.f) {
                            
                            // ARP Down
                            int index = 0;
                            for (int octave = arpOctaves - 1; octave >= 0; octave--) {
                                for (int i = heldNotesCount - 1; i >= 0; i--) {
                                    struct NoteNumber& note = arpSeqNotes2[i];
                                    const int nn = note.noteNumber + (octave * arpIntervalUp);
                                    struct SeqNoteNumber snn;
                                    snn.init(nn, onOff);
                                    std::vector<SeqNoteNumber>::iterator it = arpSeqNotes.begin() + index;
                                    arpSeqNotes.insert(it, snn);
                                    ++index;
                                }
                            }
                        }
                    }
                }
                
                // MARK: ARP+SEQ: turnOff previous beat's notes
                for (std::list<int>::iterator arpLastNotesIterator = arpSeqLastNotes.begin(); arpLastNotesIterator != arpSeqLastNotes.end(); ++arpLastNotesIterator) {
                    turnOffKey(*arpLastNotesIterator);
                }
                
                // Remove last played notes
                arpSeqLastNotes.clear();
                
                // NOP: no midi input
                if(heldNoteNumbersAE.count == 0) {
                    if(arpBeatCounter > 0) {
                        arpBeatCounter = 0;
                        beatCounterDidChange();
                    }
                    continue;
                }
                
                // NOP: the arp/seq sequence is null
                if(arpSeqNotes.size() == 0)
                    continue;
                
                // Advance arp/seq beatCounter, notify delegates
                const int seqNotePosition = arpBeatCounter % arpSeqNotes.size();
                ++arpBeatCounter;
                beatCounterDidChange();
                
                // MARK: ARP+SEQ: turnOn the note of the sequence
                SeqNoteNumber& snn = arpSeqNotes[seqNotePosition];
                if (p[arpIsSequencer] == 1.f) {
                    // SEQUENCER
                    if(snn.onOff == 1) {
                        AEArrayEnumeratePointers(heldNoteNumbersAE, struct NoteNumber *, noteStruct) {
                            const int baseNote = noteStruct->noteNumber;
                            const int note = baseNote + snn.noteNumber;
                            if(note >= 0 && note < AKS1_NUM_MIDI_NOTES) {
                                turnOnKey(note, 127);
                                arpSeqLastNotes.push_back(note);
                            }
                        }
                    }
                } else {
                    // ARPEGGIATOR
                    const int note = snn.noteNumber;
                    if(note >= 0 && note < AKS1_NUM_MIDI_NOTES) {
                        turnOnKey(note, 127);
                        arpSeqLastNotes.push_back(note);
                    }
                }
            }
        }
        
        //LFO1 on [-1, 1]
        sp_phasor_compute(sp, lfo1Phasor, nil, &lfo1); // sp_phasor_compute [0,1]
        if (p[lfo1Index] == 0) { // Sine
            lfo1 = sin(lfo1 * M_PI * 2.f);
        } else if (p[lfo1Index] == 1) { // Square
            if (lfo1 > 0.5f) {
                lfo1 = 1.f;
            } else {
                lfo1 = -1.f;
            }
        } else if (p[lfo1Index] == 2) { // Saw
            lfo1 = (lfo1 - 0.5f) * 2.f;
        } else if (p[lfo1Index] == 3) { // Reversed Saw
            lfo1 = (0.5f - lfo1) * 2.f;
        }
        lfo1_0_1 = 0.5f * (1.f + lfo1) * p[lfo1Amplitude];
        lfo1_1_0 = 1.f - lfo1_0_1; // good for multiplicative

        //LFO2 on [-1, 1]
        sp_phasor_compute(sp, lfo2Phasor, nil, &lfo2);  // sp_phasor_compute [0,1]
        if (p[lfo2Index] == 0) { // Sine
            lfo2 = sin(lfo2 * M_PI * 2.0);
        } else if (p[lfo2Index] == 1) { // Square
            if (lfo2 > 0.5f) {
                lfo2 = 1.f;
            } else {
                lfo2 = -1.f;
            }
        } else if (p[lfo2Index] == 2) { // Saw
            lfo2 = (lfo2 - 0.5f) * 2.f;
        } else if (p[lfo2Index] == 3) { // Reversed Saw
            lfo2 = (0.5f - lfo2) * 2.f;
        }
        lfo2_0_1 = 0.5f * (1.f + lfo2) * p[lfo2Amplitude];
        lfo2_1_0 = 1.f - lfo2_0_1; // good for multiplicative
        
        lfo3_0_1 = 0.5f * (lfo1_0_1 + lfo2_0_1);
        lfo3_1_0 = 1.f - lfo3_0_1; // good for multiplicative

        // RENDER NoteState into (outL, outR)
        if(p[isMono] == 1.f) {
            if(monoNote->rootNoteNumber != -1 && monoNote->stage != NoteState::stageOff)
                monoNote->run(frameIndex, outL, outR);
        } else {
            for(int i=0; i<polyphony; i++) {
                NoteState& note = noteStates[i];
                if (note.rootNoteNumber != -1 && note.stage != NoteState::stageOff)
                    note.run(frameIndex, outL, outR);
            }
        }
        
        // NoteState render output "synthOut" is mono
        float synthOut = outL[frameIndex];
        
        //BITCRUSH
        float bitCrushOut = synthOut;
        
        //original lfo = bitCrushSampleRate frequency about which an lfo is applied...this is clamped
        float bitcrushSrate = p[bitCrushSampleRate];
        //TODO:@MATT BITCRUSH LFO SCHEME
#if 1
        // original linear scheme BITCRUSH LFO SCHEME
        if(p[bitcrushLFO] == 1.f) {
            bitcrushSrate *= (1.f + 0.5f * lfo1 * p[lfo1Amplitude]); // note this is NOT equal to lfo1_0_1
        } else if (p[bitcrushLFO] == 2.f) {
            bitcrushSrate *= (1.f + 0.5f * lfo2 * p[lfo2Amplitude]); // note this is NOT equal to lfo2_0_1
        } else if (p[bitcrushLFO] == 3.f) {
            bitcrushSrate *= (1.f + 0.25f * (lfo1 * p[lfo1Amplitude] + lfo2 * p[lfo2Amplitude])); // note this is NOT equal to lfo3_0_1
        }
#else
        //new log2 scheme BITCRUSH LFO SCHEME
        bitcrushSrate = log2(bitcrushSrate);
        const float magicNumber = 4.f;
        if(p[bitcrushLFO] == 1.f) {
            bitcrushSrate += magicNumber * lfo1_0_1;
        } else if (p[bitcrushLFO] == 2.f) {
            bitcrushSrate += magicNumber * lfo2_0_1;
        } else if (p[bitcrushLFO] == 3.f) {
            bitcrushSrate += magicNumber * lfo3_0_1;
        }
        bitcrushSrate = exp2(bitcrushSrate);
#endif
        bitcrushSrate = parameterClamp(bitCrushSampleRate, bitcrushSrate); // clamp
        bitcrush->srate = bitcrushSrate;
        
        // BITCRUSH VS. FOLD: FOLD IS THE BEST, BUT HAS AN INTERMITTENT BUG WHERE bitcrushSrate CHANGES ARE NOT EFFECTED IMMEDIATELY
        //TODO:@MATT/@AURE: 0 = sp_bitcrush, and 1 = sp_fold, which is the only subset of bitcrush that we need
#if 1
        // original bitcrush
        sp_bitcrush_compute(sp, bitcrush, &synthOut, &bitCrushOut);
#else
        // a subset of bitcrush, "folding" reduces the sample rate
        float bincr = SAMPLE_RATE / bitcrushSrate;
        if (bincr < 1.f) bincr = 1.f; // for the case where the audio engine samplerate > 44100
        bitcrushFold->incr = bincr;
//        bitcrushFold->incr = sp->sr / bitcrushSrate; // might be a bug here...not sure when sp->sr is updated.
        sp_fold_compute(sp, bitcrushFold, &synthOut, &bitCrushOut);
#endif
        
        //TREMOLO
        if(p[tremoloLFO] == 1.f) {
            bitCrushOut *= (1.f - lfo1_0_1);
        } else if (p[tremoloLFO] == 2.f) {
            bitCrushOut *= (1.f - lfo2_0_1);
        } else if (p[tremoloLFO] == 3.f) {
            bitCrushOut *= (1.f - lfo3_0_1);
        }
        
        //AUTOPAN
        float panValue = 0.f;
        sp_osc_compute(sp, panOscillator, nil, &panValue);
        panValue *= p[autoPanAmount];
        pan->pan = panValue;
        float panL = 0.f, panR = 0.f;
        sp_pan2_compute(sp, pan, &bitCrushOut, &panL, &panR);
        
        //PHASER
        float phaserOutL = panL;
        float phaserOutR = panR;
        float lPhaserMix = p[phaserMix];
        
        // crossfade phaser
        if(lPhaserMix != 0.f) {
            lPhaserMix = 1.f - lPhaserMix;
            sp_phaser_compute(sp, phaser0, &panL, &panR, &phaserOutL, &phaserOutR);
            phaserOutL = lPhaserMix * panL + (1.f - lPhaserMix) * phaserOutL;
            phaserOutR = lPhaserMix * panR + (1.f - lPhaserMix) * phaserOutR;
        }
        
        // delays
        float delayOutL = 0.f;
        float delayOutR = 0.f;
        float delayOutRR = 0.f;
        float delayFillInOut = 0.f;
        sp_smoothdelay_compute(sp, delayL,      &phaserOutL, &delayOutL);
        sp_smoothdelay_compute(sp, delayR,      &phaserOutR, &delayOutR);
        sp_smoothdelay_compute(sp, delayFillIn, &phaserOutR, &delayFillInOut);
        sp_smoothdelay_compute(sp, delayRR,     &delayOutR,  &delayOutRR);
        delayOutRR += delayFillInOut;
        
        // delays mixer
        float mixedDelayL = 0.f;
        float mixedDelayR = 0.f;
        delayCrossfadeL->pos = p[delayMix] * p[delayOn];
        delayCrossfadeR->pos = p[delayMix] * p[delayOn];
        sp_crossfade_compute(sp, delayCrossfadeL, &phaserOutL, &delayOutL, &mixedDelayL);
        sp_crossfade_compute(sp, delayCrossfadeR, &phaserOutR, &delayOutRR, &mixedDelayR);
        
        // Butterworth hi-pass filter for reverb input
        float butOutL = 0.f;
        float butOutR = 0.f;
        butterworthHipassL->freq = p[reverbHighPass];
        butterworthHipassR->freq = p[reverbHighPass];
        sp_buthp_compute(sp, butterworthHipassL, &mixedDelayL, &butOutL);
        sp_buthp_compute(sp, butterworthHipassR, &mixedDelayR, &butOutR);

        // Gain + compression on reverb input
        butOutL *= 2.f;
        butOutR *= 2.f;
        float butCompressOutL = 0.f;
        float butCompressOutR = 0.f;
        sp_compressor_compute(sp, compressorReverbInputL, &butOutL, &butCompressOutL);
        sp_compressor_compute(sp, compressorReverbInputR, &butOutR, &butCompressOutR);

        // reverb
        float reverbWetL = 0.f;
        float reverbWetR = 0.f;
        reverbCostello->feedback = p[reverbFeedback];
        
        //TODO:@MATT REVERB the variants  X, X2, FMPLAYER, AKS1
#if 0
        //TODO:@MATT: input reverb: "original" hipass and gain+compression on reverb input
        reverbCostello->lpfreq = 0.5f * SAMPLE_RATE; // changes default
        sp_revsc_compute(sp, reverbCostello, &butCompressOutL, &butCompressOutR, &reverbWetL, &reverbWetR);
#elif 1
        //TODO:@MATT:input reverb: high-pass, NO compressor/gain, on reverb input
        //pro:removes low frequency rumblies when reverb feedback is high
        // don't change default//reverbCostello->lpfreq = 0.5f * SAMPLE_RATE;
        sp_revsc_compute(sp, reverbCostello, &butOutL, &butOutR, &reverbWetL, &reverbWetR);
#elif 0
        //TODO:@MATT:input reverb: bypass hipass and gain...more like X
        sp_revsc_compute(sp, reverbCostello, &mixedDelayL, &mixedDelayR, &reverbWetL, &reverbWetR);
#endif

        // GAIN ON WET REVERB
        //TODO:@MATT: wet reverb gain schemes
#if 0
        // no gain on wet reverb
#elif 0
        // 3db gain on wet reverb
        reverbWetL *= 2.f;
        reverbWetR *= 2.f;
#elif 0
        // 6db gain on wet reverb
        reverbWetL *= 4.f;
        reverbWetR *= 4.f;
#endif
        
        // compressor for wet reverb; like X2, FM
        float wetReverbLimiterL = reverbWetL;
        float wetReverbLimiterR = reverbWetR;
#if 0 // 0 = NOP, 1 = compressor for wet reverb
        sp_compressor_compute(sp, compressorReverbWetL, &reverbWetL, &wetReverbLimiterL);
        sp_compressor_compute(sp, compressorReverbWetR, &reverbWetR, &wetReverbLimiterR);
#endif
        
        // crossfade wet reverb with wet+dry delay
        float reverbCrossfadeOutL = 0.f;
        float reverbCrossfadeOutR = 0.f;
        const float reverbMixFactor = p[reverbMix] * p[reverbOn];
        revCrossfadeL->pos = reverbMixFactor;
        revCrossfadeR->pos = reverbMixFactor;
        sp_crossfade_compute(sp, revCrossfadeL, &mixedDelayL, &wetReverbLimiterL, &reverbCrossfadeOutL);
        sp_crossfade_compute(sp, revCrossfadeR, &mixedDelayR, &wetReverbLimiterR, &reverbCrossfadeOutR);
        
        // MASTER COMPRESSOR/LIMITER
#if 0
        //TODO:@MATT:
        // no gain to master compressor
#elif 1
        // 3db gain on input to master compressor
        reverbCrossfadeOutL *= (2.f * p[masterVolume]);
        reverbCrossfadeOutR *= (2.f * p[masterVolume]);
#elif 0
        // 6db gain on input to master compressor
        reverbCrossfadeOutL *= (2.f * 2.f * p[masterVolume]);
        reverbCrossfadeOutR *= (2.f * 2.f * p[masterVolume]);
#endif

        float compressorOutL = reverbCrossfadeOutL;
        float compressorOutR = reverbCrossfadeOutR;
        
#if 1
        //TODO:@MATT
        // MASTER COMPRESSOR TOGGLE: 0 = no compressor, 1 = compressor
        sp_compressor_compute(sp, compressorMasterL, &reverbCrossfadeOutL, &compressorOutL);
        sp_compressor_compute(sp, compressorMasterR, &reverbCrossfadeOutR, &compressorOutR);
#endif

        // WIDEN.  literally a constant delay with no filtering, so functionally equivalent to being inside master
        float widenOutR = 0.f;
        sp_delay_compute(sp, widenDelay, &compressorOutR, &widenOutR);
        // exploit smoothing of widen toggle as a crossfade
        widenOutR = p[widen] * widenOutR + (1.f - p[widen]) * compressorOutR;

        
        // MASTER
        outL[frameIndex] = compressorOutL;
        outR[frameIndex] = widenOutR;
    }
}

void AKSynthOneDSPKernel::turnOnKey(int noteNumber, int velocity) {
    if(noteNumber < 0 || noteNumber >= AKS1_NUM_MIDI_NOTES)
        return;
    
    const float frequency = tuningTableNoteToHz(noteNumber);
    turnOnKey(noteNumber, velocity, frequency);
}

// turnOnKey is called by render thread in "process", so access note via AEArray
void AKSynthOneDSPKernel::turnOnKey(int noteNumber, int velocity, float frequency) {
    if(noteNumber < 0 || noteNumber >= AKS1_NUM_MIDI_NOTES)
        return;
    initializeNoteStates();
    
    if(p[isMono] == 1.f) {
        NoteState& note = *monoNote;
        monoFrequency = frequency;
        
        // PORTAMENTO: set the ADSRs to release mode here, then into attack mode inside startNoteHelper
        if(p[monoIsLegato] == 0) {
            note.internalGate = 0;
            note.stage = NoteState::stageRelease;
            sp_adsr_compute(sp, note.adsr, &note.internalGate, &note.amp);
            sp_adsr_compute(sp, note.fadsr, &note.internalGate, &note.filter);
        }
        
        // legato+portamento: Legato means that Presets with low sustains will sound like they did not retrigger.
        note.startNoteHelper(noteNumber, velocity, frequency);
        
    } else {
        // Note Stealing: Is noteNumber already playing?
        int index = -1;
        for(int i = 0 ; i < polyphony; i++) {
            if(noteStates[i].rootNoteNumber == noteNumber) {
                index = i;
                break;
            }
        }
        if(index != -1) {
            
            // noteNumber is playing...steal it
            playingNoteStatesIndex = index;
        } else {
            
            // noteNumber is not playing: search for non-playing notes (-1) starting with current index
            for(int i = 0; i < polyphony; i++) {
                const int modIndex = (playingNoteStatesIndex + i) % polyphony;
                if(noteStates[modIndex].rootNoteNumber == -1) {
                    index = modIndex;
                    break;
                }
            }
            
            if(index == -1) {
                
                // if there are no non-playing notes then steal oldest note
                ++playingNoteStatesIndex %= polyphony;
            } else {
                
                // use non-playing note slot
                playingNoteStatesIndex = index;
            }
        }
        
        // POLY: INIT NoteState
        NoteState& note = noteStates[playingNoteStatesIndex];
        note.startNoteHelper(noteNumber, velocity, frequency);
    }
    
    heldNotesDidChange();
    playingNotesDidChange();
}

// turnOffKey is called by render thread in "process", so access note via AEArray
void AKSynthOneDSPKernel::turnOffKey(int noteNumber) {
    if(noteNumber < 0 || noteNumber >= AKS1_NUM_MIDI_NOTES)
        return;
    initializeNoteStates();
    if(p[isMono] == 1.f) {
        
        if (heldNoteNumbersAE.count == 0 || p[arpIsOn] == 1.f) {
            
            // the case where this was the only held note and now it should be off
            // the case where the sequencer turns off this key even though a note is held down
            monoNote->stage = NoteState::stageRelease;
            monoNote->internalGate = 0;
        } else {
            
            // the case where you had more than one held note and released one (CACA): Keep note ON and set to freq of head
            AEArrayToken token = AEArrayGetToken(heldNoteNumbersAE);
            struct NoteNumber* nn = (struct NoteNumber*)AEArrayGetItem(token, 0);
            const int headNN = nn->noteNumber;
            monoFrequency = tuningTableNoteToHz(headNN);
            monoNote->rootNoteNumber = headNN;
            monoFrequency = tuningTableNoteToHz(headNN);
            monoNote->oscmorph1->freq = monoFrequency;
            monoNote->oscmorph2->freq = monoFrequency;
            monoNote->subOsc->freq = monoFrequency;
            monoNote->fmOsc->freq = monoFrequency;
            
            // PORTAMENTO: reset the ADSR inside the render loop
            if(p[monoIsLegato] == 0.f) {
                monoNote->internalGate = 0;
                monoNote->stage = NoteState::stageRelease;
                sp_adsr_compute(sp, monoNote->adsr, &monoNote->internalGate, &monoNote->amp);
                sp_adsr_compute(sp, monoNote->fadsr, &monoNote->internalGate, &monoNote->filter);
            }
            
            // legato+portamento: Legato means that Presets with low sustains will sound like they did not retrigger.
            monoNote->stage = NoteState::stageOn;
            monoNote->internalGate = 1;
        }
    } else {
        
        // Poly:
        int index = -1;
        for(int i=0; i<polyphony; i++) {
            if(noteStates[i].rootNoteNumber == noteNumber) {
                index = i;
                break;
            }
        }
        
        if(index != -1) {
            
            // put NoteState into release
            NoteState& note = noteStates[index];
            note.stage = NoteState::stageRelease;
            note.internalGate = 0;
        } else {
            
            // the case where a note was stolen before the noteOff
        }
    }
    heldNotesDidChange();
    playingNotesDidChange();
}

// NOTE ON
// startNote is not called by render thread, but turnOnKey is
void AKSynthOneDSPKernel::startNote(int noteNumber, int velocity) {
    if(noteNumber < 0 || noteNumber >= AKS1_NUM_MIDI_NOTES)
        return;
    
    const float frequency = tuningTableNoteToHz(noteNumber);
    startNote(noteNumber, velocity, frequency);
}

// NOTE ON
// startNote is not called by render thread, but turnOnKey is
void AKSynthOneDSPKernel::startNote(int noteNumber, int velocity, float frequency) {
    if(noteNumber < 0 || noteNumber >= AKS1_NUM_MIDI_NOTES)
        return;
    
    NSNumber* nn = @(noteNumber);
    [heldNoteNumbers removeObject:nn];
    [heldNoteNumbers insertObject:nn atIndex:0];
    [heldNoteNumbersAE updateWithContentsOfArray:heldNoteNumbers];
    
    // ARP/SEQ
    if(p[arpIsOn] == 1.f) {
        return;
    } else {
        turnOnKey(noteNumber, velocity, frequency);
    }
}

// NOTE OFF...put into release mode
void AKSynthOneDSPKernel::stopNote(int noteNumber) {
    if(noteNumber < 0 || noteNumber >= AKS1_NUM_MIDI_NOTES)
        return;
    
    NSNumber* nn = @(noteNumber);
    [heldNoteNumbers removeObject: nn];
    [heldNoteNumbersAE updateWithContentsOfArray: heldNoteNumbers];
    
    // ARP/SEQ
    if(p[arpIsOn] == 1.f) {
        return;
    } else {
        turnOffKey(noteNumber);
    }
}

void AKSynthOneDSPKernel::reset() {
    for (int i = 0; i<AKS1_MAX_POLYPHONY; i++)
        noteStates[i].clear();
    monoNote->clear();
    resetted = true;
}

void AKSynthOneDSPKernel::resetSequencer() {
    arpBeatCounter = 0;
    arpSampleCounter = 0;
    arpTime = 0;
    beatCounterDidChange();
}

// MIDI
void AKSynthOneDSPKernel::handleMIDIEvent(AUMIDIEvent const& midiEvent) {
    if (midiEvent.length != 3) return;
    uint8_t status = midiEvent.data[0] & 0xF0;
    switch (status) {
        case 0x80 : {
            // note off
            uint8_t note = midiEvent.data[1];
            if (note > 127) break;
            stopNote(note);
            break;
        }
        case 0x90 : {
            // note on
            uint8_t note = midiEvent.data[1];
            uint8_t veloc = midiEvent.data[2];
            if (note > 127 || veloc > 127) break;
            startNote(note, veloc);
            break;
        }
        case 0xB0 : {
            uint8_t num = midiEvent.data[1];
            if (num == 123) {
                stopAllNotes();
            }
            break;
        }
    }
}

void AKSynthOneDSPKernel::init(int _channels, double _sampleRate) {
    AKSoundpipeKernel::init(_channels, _sampleRate);
    sp_ftbl_create(sp, &sine, AKS1_FTABLE_SIZE);
    sp_gen_sine(sp, sine);
    sp_phasor_create(&lfo1Phasor);
    sp_phasor_init(sp, lfo1Phasor, 0);
    sp_phasor_create(&lfo2Phasor);
    sp_phasor_init(sp, lfo2Phasor, 0);
    sp_bitcrush_create(&bitcrush);
    sp_bitcrush_init(sp, bitcrush);
    sp_fold_create(&bitcrushFold);
    sp_fold_init(sp, bitcrushFold); bitcrushFold->incr = 1; // YES
    sp_phaser_create(&phaser0);
    sp_phaser_init(sp, phaser0);
    sp_port_create(&monoFrequencyPort);
    sp_port_init(sp, monoFrequencyPort, 0.05f);
    *phaser0->MinNotch1Freq = 100;
    *phaser0->MaxNotch1Freq = 800;
    *phaser0->Notch_width = 1000;
    *phaser0->NotchFreq = 1.5;
    *phaser0->VibratoMode = 1;
    *phaser0->depth = 1;
    *phaser0->feedback_gain = 0;
    *phaser0->invert = 0;
    *phaser0->lfobpm = 30;
    sp_osc_create(&panOscillator);
    sp_osc_init(sp, panOscillator, sine, 0.f);
    sp_pan2_create(&pan);
    sp_pan2_init(sp, pan);
    sp_smoothdelay_create(&delayL);
    sp_smoothdelay_create(&delayR);
    sp_smoothdelay_create(&delayRR);
    sp_smoothdelay_create(&delayFillIn);
    sp_smoothdelay_init(sp, delayL, 10.f, 512);
    sp_smoothdelay_init(sp, delayR, 10.f, 512);
    sp_smoothdelay_init(sp, delayRR, 10.f, 512);
    sp_smoothdelay_init(sp, delayFillIn, 10.f, 512);
    sp_crossfade_create(&delayCrossfadeL);
    sp_crossfade_create(&delayCrossfadeR);
    sp_crossfade_init(sp, delayCrossfadeL);
    sp_crossfade_init(sp, delayCrossfadeR);
    sp_revsc_create(&reverbCostello);
    sp_revsc_init(sp, reverbCostello);
    sp_buthp_create(&butterworthHipassL);
    sp_buthp_init(sp, butterworthHipassL);
    sp_buthp_create(&butterworthHipassR);
    sp_buthp_init(sp, butterworthHipassR);
    sp_crossfade_create(&revCrossfadeL);
    sp_crossfade_create(&revCrossfadeR);
    sp_crossfade_init(sp, revCrossfadeL);
    sp_crossfade_init(sp, revCrossfadeR);
    sp_compressor_create(&compressorMasterL);
    sp_compressor_init(sp, compressorMasterL);
    sp_compressor_create(&compressorMasterR);
    sp_compressor_init(sp, compressorMasterR);
    sp_compressor_create(&compressorReverbInputL);
    sp_compressor_init(sp, compressorReverbInputL);
    sp_compressor_create(&compressorReverbInputR);
    sp_compressor_init(sp, compressorReverbInputR);
    sp_compressor_create(&compressorReverbWetL);
    sp_compressor_init(sp, compressorReverbWetL);
    sp_compressor_create(&compressorReverbWetR);
    sp_compressor_init(sp, compressorReverbWetR);
    *compressorMasterL->ratio = 10.f;
    *compressorMasterR->ratio = 10.f;
    *compressorReverbInputL->ratio = 10.f;
    *compressorReverbInputR->ratio = 10.f;
    *compressorReverbWetL->ratio = 10.f;
    *compressorReverbWetR->ratio = 10.f;
    *compressorMasterL->thresh = -3.f;
    *compressorMasterR->thresh = -3.f;
    *compressorReverbInputL->thresh = -3.f;
    *compressorReverbInputR->thresh = -3.f;
    *compressorReverbWetL->thresh = -3.f;
    *compressorReverbWetR->thresh = -3.f;
    *compressorMasterL->atk = 0.001f;
    *compressorMasterR->atk = 0.001f;
    *compressorReverbInputL->atk = 0.001f;
    *compressorReverbInputR->atk = 0.001f;
    *compressorReverbWetL->atk = 0.001f;
    *compressorReverbWetR->atk = 0.001f;
    *compressorMasterL->rel = 0.01f;
    *compressorMasterR->rel = 0.01f;
    *compressorReverbInputL->rel = 0.01f;
    *compressorReverbInputR->rel = 0.01f;
    *compressorReverbWetL->rel = 0.01f;
    *compressorReverbWetR->rel = 0.01f;
    sp_delay_create(&widenDelay);
    sp_delay_init(sp, widenDelay, 0.05f);
    widenDelay->feedback = 0.f;
    noteStates = (NoteState*)malloc(AKS1_MAX_POLYPHONY * sizeof(NoteState));
    monoNote = (NoteState*)malloc(sizeof(NoteState));
    heldNoteNumbers = (NSMutableArray<NSNumber*>*)[NSMutableArray array];
    heldNoteNumbersAE = [[AEArray alloc] initWithCustomMapping:^void *(id item) {
        struct NoteNumber* noteNumber = (struct NoteNumber*)malloc(sizeof(struct NoteNumber));
        const int nn = [(NSNumber*)item intValue];
        noteNumber->noteNumber = nn;
        return noteNumber;
    }];
    
    // copy default dsp values
    for(int i = 0; i< AKSynthOneParameter::AKSynthOneParameterCount; i++) {
        const float value = parameterDefault((AKSynthOneParameter)i);
        if(aks1p[i].usePortamento) {
            aks1p[i].portamentoTarget = value;
            sp_port_create(&aks1p[i].portamento);
            sp_port_init(sp, aks1p[i].portamento, value);
            aks1p[i].portamento->htime = AKS1_PORTAMENTO_HALF_TIME;
        }
        p[i] = value;
#if DEBUG_DSP_LOGGING
        const char* d = AKSynthOneDSPKernel::parameterCStr((AKSynthOneParameter)i);
        printf("AKSynthOneDSPKernel.hpp:setAK1Parameter(): %i:%s --> %f\n", i, d, value);
#endif
    }
    previousProcessMonoPolyStatus = p[isMono];
    
    // Reserve arp note cache to reduce possibility of reallocation on audio thread.
    arpSeqNotes.reserve(maxArpSeqNotes);
    arpSeqNotes2.reserve(maxArpSeqNotes);
    arpSeqLastNotes.resize(maxArpSeqNotes);
    
    // initializeNoteStates() must be called AFTER init returns, BEFORE process, turnOnKey, and turnOffKey
}

void AKSynthOneDSPKernel::destroy() {
    for(int i = 0; i< AKSynthOneParameter::AKSynthOneParameterCount; i++) {
        if(aks1p[i].usePortamento) {
            sp_port_destroy(&aks1p[i].portamento);
        }
    }
    sp_port_destroy(&monoFrequencyPort);

    sp_ftbl_destroy(&sine);
    sp_phasor_destroy(&lfo1Phasor);
    sp_phasor_destroy(&lfo2Phasor);
    sp_bitcrush_destroy(&bitcrush);
    sp_fold_destroy(&bitcrushFold);
    sp_phaser_destroy(&phaser0);
    sp_osc_destroy(&panOscillator);
    sp_pan2_destroy(&pan);
    sp_smoothdelay_destroy(&delayL);
    sp_smoothdelay_destroy(&delayR);
    sp_smoothdelay_destroy(&delayRR);
    sp_smoothdelay_destroy(&delayFillIn);
    sp_delay_destroy(&widenDelay);
    sp_crossfade_destroy(&delayCrossfadeL);
    sp_crossfade_destroy(&delayCrossfadeR);
    sp_revsc_destroy(&reverbCostello);
    sp_buthp_destroy(&butterworthHipassL);
    sp_buthp_destroy(&butterworthHipassR);
    sp_crossfade_destroy(&revCrossfadeL);
    sp_crossfade_destroy(&revCrossfadeR);
    sp_compressor_destroy(&compressorMasterL);
    sp_compressor_destroy(&compressorMasterR);
    sp_compressor_destroy(&compressorReverbInputL);
    sp_compressor_destroy(&compressorReverbInputR);
    sp_compressor_destroy(&compressorReverbWetL);
    sp_compressor_destroy(&compressorReverbWetR);
    free(noteStates);
    free(monoNote);
}

// initializeNoteStates() must be called AFTER init returns
void AKSynthOneDSPKernel::initializeNoteStates() {
    if(initializedNoteStates == false) {
        initializedNoteStates = true;
        // POLY INIT
        for (int i = 0; i < AKS1_MAX_POLYPHONY; i++) {
            NoteState& state = noteStates[i];
            state.kernel = this;
            state.init();
            state.stage = NoteState::stageOff;
            state.internalGate = 0;
            state.rootNoteNumber = -1;
        }
        
        // MONO INIT
        monoNote->kernel = this;
        monoNote->init();
        monoNote->stage = NoteState::stageOff;
        monoNote->internalGate = 0;
        monoNote->rootNoteNumber = -1;
    }
}

void AKSynthOneDSPKernel::setupWaveform(uint32_t waveform, uint32_t size) {
    tbl_size = size;
    sp_ftbl_create(sp, &ft_array[waveform], tbl_size);
}

void AKSynthOneDSPKernel::setWaveformValue(uint32_t waveform, uint32_t index, float value) {
    ft_array[waveform]->tbl[index] = value;
}

///parameter min
float AKSynthOneDSPKernel::parameterMin(AKSynthOneParameter i) {
    return aks1p[i].min;
}

///parameter max
float AKSynthOneDSPKernel::parameterMax(AKSynthOneParameter i) {
    return aks1p[i].max;
}

///parameter defaults
float AKSynthOneDSPKernel::parameterDefault(AKSynthOneParameter i) {
    return parameterClamp(i, aks1p[i].defaultValue);
}

AudioUnitParameterUnit AKSynthOneDSPKernel::parameterUnit(AKSynthOneParameter i) {
    return aks1p[i].unit;
}

///return clamped value
float AKSynthOneDSPKernel::parameterClamp(AKSynthOneParameter i, float inputValue) {
    const float paramMin = aks1p[i].min;
    const float paramMax = aks1p[i].max;
    const float retVal = std::min(std::max(inputValue, paramMin), paramMax);
    return retVal;
}

///parameter friendly name as c string
const char* AKSynthOneDSPKernel::parameterCStr(AKSynthOneParameter i) {
    return aks1p[i].friendlyName.c_str();
}

///parameter friendly name
std::string AKSynthOneDSPKernel::parameterFriendlyName(AKSynthOneParameter i) {
    return aks1p[i].friendlyName;
}

///parameter presetKey
std::string AKSynthOneDSPKernel::parameterPresetKey(AKSynthOneParameter i) {
    return aks1p[i].presetKey;
}

