//
//  S1NoteState.mm
//  AudioKitSynthOne
//
//  Created by AudioKit Contributors on 4/30/18.
//  Copyright © 2018 AudioKit. All rights reserved.
//

#import "S1NoteState.hpp"
#import <AudioKit/AudioKit-swift.h>
#import "S1DSPKernel.hpp"
#import <AudioToolbox/AudioToolbox.h>
#import <AudioUnit/AudioUnit.h>
#import <AVFoundation/AVFoundation.h>
#import "AEArray.h"
#import "AEMessageQueue.h"

// Relative note number to frequency
static inline float nnToHz(float noteNumber) {
    return exp2(noteNumber/12.f);
}

// MARK: Member Functions

inline float S1NoteState::getParam(S1Parameter param) {
    return kernel->parameters[param];
}

inline int S1NoteState::sampleRate() const{
    return kernel->sampleRate();
}

void S1NoteState::init() {
    // OSC AMPLITUDE ENVELOPE
    sp_adsr_create(&adsr);
    sp_adsr_init(kernel->spp(), adsr);
    
    // FILTER FREQUENCY ENVELOPE
    sp_adsr_create(&fadsr);
    sp_adsr_init(kernel->spp(), fadsr);
    
    // OSC1
    sp_oscmorph2d_create(&oscmorph1);
    sp_oscmorph2d_init(kernel->spp(), oscmorph1, kernel->ft_array, S1_NUM_WAVEFORMS, S1_NUM_BANDLIMITED_FTABLES, kernel->ft_frequencyBand, 0);
    oscmorph1->freq = 0;
    oscmorph1->amp = 0;
    oscmorph1->wtpos = 0;
    oscmorph1->enableBandlimit = getParam(oscBandlimitEnable);
    oscmorph1->bandlimitIndexOverride = -1;

    // OSC2
    sp_oscmorph2d_create(&oscmorph2);
    sp_oscmorph2d_init(kernel->spp(), oscmorph2, kernel->ft_array, S1_NUM_WAVEFORMS, S1_NUM_BANDLIMITED_FTABLES, kernel->ft_frequencyBand, 0);
    oscmorph2->freq = 0;
    oscmorph2->amp = 0;
    oscmorph2->wtpos = 0;
    oscmorph2->enableBandlimit = getParam(oscBandlimitEnable);
    oscmorph2->bandlimitIndexOverride = -1;

    // CROSSFADE OSC1 and OSC2
    sp_crossfade_create(&morphCrossFade);
    sp_crossfade_init(kernel->spp(), morphCrossFade);
    
    // CROSSFADE DRY AND FILTER
    sp_crossfade_create(&filterCrossFade);
    sp_crossfade_init(kernel->spp(), filterCrossFade);
    
    // SUB OSC
    sp_osc_create(&subOsc);
    sp_osc_init(kernel->spp(), subOsc, kernel->sine, 0.f);
    
    // FM osc
    sp_fosc_create(&fmOsc);
    sp_fosc_init(kernel->spp(), fmOsc, kernel->sine);
    
    // NOISE
    sp_noise_create(&noise);
    sp_noise_init(kernel->spp(), noise);
    
    // FILTER
    sp_moogladder_create(&loPass);
    sp_moogladder_init(kernel->spp(), loPass);
    sp_butbp_create(&bandPass);
    sp_butbp_init(kernel->spp(), bandPass);
    sp_buthp_create(&hiPass);
    sp_buthp_init(kernel->spp(), hiPass);
}

void S1NoteState::destroy() {
    sp_adsr_destroy(&adsr);
    sp_adsr_destroy(&fadsr);
    sp_oscmorph2d_destroy(&oscmorph1);
    sp_oscmorph2d_destroy(&oscmorph2);

    sp_crossfade_destroy(&morphCrossFade);
    sp_crossfade_destroy(&filterCrossFade);
    sp_osc_destroy(&subOsc);
    sp_fosc_destroy(&fmOsc);
    sp_noise_destroy(&noise);
    sp_moogladder_destroy(&loPass);
    sp_butbp_destroy(&bandPass);
    sp_buthp_destroy(&hiPass);
}

void S1NoteState::clear() {
    internalGate = 0;
    stage = stageOff;
    amp = 0;
    rootNoteNumber = -1;
    transpose = 0;
}

// helper...supports initialization of playing note for both mono and poly
void S1NoteState::startNoteHelper(int noteNumber, int vel, float frequency) {
    oscmorph1->freq = frequency;
    oscmorph2->freq = frequency;
    subOsc->freq = frequency;
    fmOsc->freq = frequency;

    velocity = vel;
    const float amplitude = (float)pow2(velocity / 127.f);
    oscmorph1->amp = amplitude;
    oscmorph2->amp = amplitude;
    subOsc->amp = amplitude;
    fmOsc->amp = amplitude;
    noise->amp = amplitude;
    
    stage = S1NoteState::stageOn;
    internalGate = 1;
    rootNoteNumber = noteNumber;
    transpose = getParam(S1Parameter::transpose);
}

//called at SampleRate for each S1NoteState.  Polyphony of 6 = 264,000 times per second
void S1NoteState::run(int frameIndex, float *outL, float *outR) {
    
    // isMono
    const bool isMonoMode = getParam(isMono) > 0.f;
    
    // convenience
    const float lfo1_0_1 = kernel->lfo1_0_1;
    const float lfo1_1_0 = kernel->lfo1_1_0;
    const float lfo2_0_1 = kernel->lfo2_0_1;
    const float lfo2_1_0 = kernel->lfo2_1_0;
    const float lfo3_0_1 = kernel->lfo3_0_1;
    const float lfo3_1_0 = kernel->lfo3_1_0;
    
    //pitchLFO common frequency coefficient
    float pitchLFOCoefficient = 1.f;
    const float semitone = 0.0594630944f; // 1 = 2^(1/12)
    if (getParam(pitchLFO) == 1.f)
        pitchLFOCoefficient = 1.f + lfo1_0_1 * semitone;
    else if (getParam(pitchLFO) == 2.f)
        pitchLFOCoefficient = 1.f + lfo2_0_1 * semitone;
    else if (getParam(pitchLFO) == 3.f)
        pitchLFOCoefficient = 1.f + lfo3_0_1 * semitone;
    
    // pitchbend coefficient
    const float pbmin = getParam(pitchbendMinSemitones);
    const float pbmax = getParam(pitchbendMaxSemitones);
    const float pbVal = getParam(pitchbend);
    float pitchbendCoefficient = 1.f;
    if (pbmin < 0.f && pbVal < 8192.f) {
        const float pbminst = pbmin * ((8191.f - pbVal) / 8191.f);
        pitchbendCoefficient = nnToHz(pbminst);
    } else if (pbmax > 0.f && pbVal >= 8192.f) {
        const float pbmaxst = pbmax * (-(8192.f - pbVal) / 8192.f);
        pitchbendCoefficient = nnToHz(pbmaxst);
    }
    
    //OSC1 frequency
    const float cachedFrequencyOsc1 = oscmorph1->freq;
    float newFrequencyOsc1 = isMonoMode ?kernel->monoFrequencySmooth :cachedFrequencyOsc1;
    newFrequencyOsc1 *= nnToHz((int)getParam(morph1SemitoneOffset));
    newFrequencyOsc1 *= getParam(detuningMultiplier) * pitchLFOCoefficient;
    newFrequencyOsc1 *= pitchbendCoefficient;
    newFrequencyOsc1 = clamp(newFrequencyOsc1, 0.f, 0.5f * sampleRate());
    oscmorph1->freq = newFrequencyOsc1;
    
    //OSC1: wavetable
    oscmorph1->wtpos = getParam(index1);
    oscmorph1->enableBandlimit = getParam(oscBandlimitEnable);

    //OSC2 frequency
    const float cachedFrequencyOsc2 = oscmorph2->freq;
    float newFrequencyOsc2 = isMonoMode ?kernel->monoFrequencySmooth :cachedFrequencyOsc2;
    newFrequencyOsc2 *= nnToHz((int)getParam(morph2SemitoneOffset));
    newFrequencyOsc2 *= getParam(detuningMultiplier) * pitchLFOCoefficient;
    newFrequencyOsc2 *= pitchbendCoefficient;

    //LFO DETUNE OSC2
    const float magicDetune = cachedFrequencyOsc2/261.6255653006f;
    if (getParam(detuneLFO) == 1.f)
        newFrequencyOsc2 += lfo1_0_1 * getParam(morph2Detuning) * magicDetune;
    else if (getParam(detuneLFO) == 2.f)
        newFrequencyOsc2 += lfo2_0_1 * getParam(morph2Detuning) * magicDetune;
    else if (getParam(detuneLFO) == 3.f)
        newFrequencyOsc2 += lfo3_0_1 * getParam(morph2Detuning) * magicDetune;
    else
        newFrequencyOsc2 += getParam(morph2Detuning) * magicDetune;
    newFrequencyOsc2 = clamp(newFrequencyOsc2, 0.f, 0.5f * sampleRate());
    oscmorph2->freq = newFrequencyOsc2;

    //OSC2: wavetable
    oscmorph2->wtpos = getParam(index2);
    oscmorph2->enableBandlimit = getParam(oscBandlimitEnable);

    //SUB OSC FREQ
    const float cachedFrequencySub = subOsc->freq;
    float newFrequencySub = isMonoMode ?kernel->monoFrequencySmooth :cachedFrequencySub;
    newFrequencySub *= getParam(detuningMultiplier) / (2.f * (1.f + getParam(subOctaveDown))) * pitchLFOCoefficient;
    newFrequencySub *= pitchbendCoefficient;
    newFrequencySub = clamp(newFrequencySub, 0.f, 0.5f * sampleRate());
    subOsc->freq = newFrequencySub;
    
    //FM OSC FREQ
    const float cachedFrequencyFM = fmOsc->freq;
    float newFrequencyFM = isMonoMode ?kernel->monoFrequencySmooth :cachedFrequencyFM;
    newFrequencyFM *= getParam(detuningMultiplier) * pitchLFOCoefficient;
    newFrequencyFM *= pitchbendCoefficient;
    newFrequencyFM = clamp(newFrequencyFM, 0.f, 0.5f * sampleRate());
    fmOsc->freq = newFrequencyFM;
    
    //FM LFO
    float fmOscIndx = getParam(fmAmount);
    if (getParam(fmLFO) == 1.f)
        fmOscIndx *= lfo1_1_0;
    else if (getParam(fmLFO) == 2.f)
        fmOscIndx *= lfo2_1_0;
    else if (getParam(fmLFO) == 3.f)
        fmOscIndx *= lfo3_1_0;
    fmOscIndx = kernel->clampedValue(fmAmount, fmOscIndx);
    fmOsc->indx = fmOscIndx;
    
    //ADSR
    adsr->atk = getParam(attackDuration);
    adsr->rel = getParam(releaseDuration);
    
    //ADSR decay LFO
    float dec = getParam(decayDuration);
    if (getParam(decayLFO) == 1.f)
        dec *= lfo1_1_0;
    else if (getParam(decayLFO) == 2.f)
        dec *= lfo2_1_0;
    else if (getParam(decayLFO) == 3.f)
        dec *= lfo3_1_0;
    dec = kernel->clampedValue(decayDuration, dec);
    adsr->dec = dec;
    
    //ADSR sustain LFO
    float sus = getParam(sustainLevel);
    adsr->sus = sus;
    
    //FILTER FREQ CUTOFF ADSR
    fadsr->atk = getParam(filterAttackDuration);
    fadsr->dec = getParam(filterDecayDuration);
    fadsr->sus = getParam(filterSustainLevel);
    fadsr->rel = getParam(filterReleaseDuration);
    
    //OSCMORPH CROSSFADE
    float crossFadePos = getParam(morphBalance);
    if (getParam(oscMixLFO) == 1.f)
        crossFadePos += lfo1_0_1;
    else if (getParam(oscMixLFO) == 2.f)
        crossFadePos += lfo2_0_1;
    else if (getParam(oscMixLFO) == 3.f)
        crossFadePos += lfo3_0_1;
    crossFadePos = clamp(crossFadePos, 0.f, 1.f);
    morphCrossFade->pos = crossFadePos;
    
    //TODO:param filterMix is hard-coded to 1.  I vote we get rid of it
    filterCrossFade->pos = getParam(filterMix);
    
    //FILTER RESONANCE LFO
    float filterResonance = getParam(resonance);
    if (getParam(resonanceLFO) == 1)
        filterResonance *= lfo1_1_0;
    else if (getParam(resonanceLFO) == 2)
        filterResonance *= lfo2_1_0;
    else if (getParam(resonanceLFO) == 3)
        filterResonance *= lfo3_1_0;
    filterResonance = kernel->clampedValue(resonance, filterResonance);
    if (getParam(filterType) == 0) {
        loPass->res = filterResonance;
    } else if (getParam(filterType) == 1) {
        // bandpass bandwidth is a different unit than lopass resonance.
        // take advantage of the range of resonance [0,1].
        const float bandwidth = 0.0625f * sampleRate() * (-1.f + exp2( clamp(1.f - filterResonance, 0.f, 1.f) ) );
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
    // amp was used to init the generators and is now be used for the adsr factor
    sp_adsr_compute(kernel->spp(), adsr, &internalGate, &amp);

    // filter cutoff adsr
    sp_adsr_compute(kernel->spp(), fadsr, &internalGate, &filter);
    
    // filter frequency cutoff calculation
    float filterCutoffFreq = getParam(cutoff);
    if (getParam(cutoffLFO) == 1.f)
        filterCutoffFreq *= lfo1_1_0;
    else if (getParam(cutoffLFO) == 2.f)
        filterCutoffFreq *= lfo2_1_0;
    else if (getParam(cutoffLFO) == 3.f)
        filterCutoffFreq *= lfo3_1_0;
    
    // filter frequency env lfo crossfade
    float filterEnvLFOMix = getParam(filterADSRMix);
    if (getParam(filterEnvLFO) == 1.f)
        filterEnvLFOMix *= lfo1_1_0;
    else if (getParam(filterEnvLFO) == 2.f)
        filterEnvLFOMix *= lfo2_1_0;
    else if (getParam(filterEnvLFO) == 3.f)
        filterEnvLFOMix *= lfo3_1_0;
    
    // filter frequency mixer
    filterCutoffFreq -= filterCutoffFreq * filterEnvLFOMix * (1.f - filter);
    filterCutoffFreq = kernel->clampedValue(cutoff, filterCutoffFreq);
    loPass->freq = filterCutoffFreq;
    bandPass->freq = filterCutoffFreq;
    hiPass->freq = filterCutoffFreq;
    
    //oscmorph1_out
    sp_oscmorph2d_compute(kernel->spp(), oscmorph1, nil, &oscmorph1_out);
    oscmorph1_out *= getParam(morph1Volume);
    
    //oscmorph2_out
    sp_oscmorph2d_compute(kernel->spp(), oscmorph2, nil, &oscmorph2_out);
    oscmorph2_out *= getParam(morph2Volume);

    //osc_morph_out
    sp_crossfade_compute(kernel->spp(), morphCrossFade, &oscmorph1_out, &oscmorph2_out, &osc_morph_out);
    
    //subOsc_out
    sp_osc_compute(kernel->spp(), subOsc, nil, &subOsc_out);
    if (getParam(subIsSquare)) {
        if (subOsc_out > 0.f) {
            subOsc_out = getParam(subVolume);
        } else {
            subOsc_out = -getParam(subVolume);
        }
    } else {
        // make sine louder
        subOsc_out *= getParam(subVolume) * 3.f;
    }
    
    //fmOsc_out
    sp_fosc_compute(kernel->spp(), fmOsc, nil, &fmOsc_out);
    fmOsc_out *= getParam(fmVolume);
    
    //noise_out
    sp_noise_compute(kernel->spp(), noise, nil, &noise_out);
    noise_out *= getParam(noiseVolume);
    if (getParam(noiseLFO) == 1.f)
        noise_out *= lfo1_1_0;
    else if (getParam(noiseLFO) == 2.f)
        noise_out *= lfo2_1_0;
    else if (getParam(noiseLFO) == 3.f)
        noise_out *= lfo3_1_0;

    // adsr pitch tracking
    const float pitch = log2(newFrequencyOsc1 > 0 ? newFrequencyOsc1 : 261.f);
    const float ymin = 6.f;
    const float ymax = 11.f;
    const float kt0 = (pitch - ymin)/(ymax-ymin);
    float kt1 = 1.f - clamp(kt0, 0.f, 1.f);
    kt1 *= kt1;
    const float ktfloor = 1.f - getParam(adsrPitchTracking); // ??
    const float kt2 = ((1.f-ktfloor) * kt1) + ktfloor;

    //synthOut
    float synthOut = amp * kt2 * (osc_morph_out + subOsc_out + fmOsc_out + noise_out);

    //filterOut:  Always calcuate all filters so when user switches the buffers are up-to-date.
    float moogOut;
    sp_moogladder_compute(kernel->spp(), loPass, &synthOut, &moogOut);
    float bandOut;
    sp_butbp_compute(kernel->spp(), bandPass, &synthOut, &bandOut);
    float hipassOut;
    sp_buthp_compute(kernel->spp(), hiPass, &synthOut, &hipassOut);
    if (getParam(filterType) == 0.f)
        filterOut = moogOut;
    else if (getParam(filterType) == 1.f)
        filterOut = bandOut;
    else if (getParam(filterType) == 2.f)
        filterOut = hipassOut;

    // filter crossfade
    sp_crossfade_compute(kernel->spp(), filterCrossFade, &synthOut, &filterOut, &finalOut);
    
    // final output
    outL[frameIndex] += finalOut;
    outR[frameIndex] += finalOut;
    
    // restore cached values
    oscmorph1->freq = cachedFrequencyOsc1;
    oscmorph2->freq = cachedFrequencyOsc2;
    subOsc->freq = cachedFrequencySub;
    fmOsc->freq = cachedFrequencyFM;
}
