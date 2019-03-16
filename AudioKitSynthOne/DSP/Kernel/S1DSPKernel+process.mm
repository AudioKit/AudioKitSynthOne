//
//  S1DSPKernel+process.mm
//  AudioKitSynthOne
//
//  Created by Aurelius Prochazka on 6/4/18.
//  Copyright © 2018 AudioKit. All rights reserved.
//

#import <AudioKit/AudioKit-swift.h>
#import "../Sequencer/S1ArpModes.hpp"
#import "S1DSPKernel.hpp"
#import "AEArray.h"
#import "S1NoteState.hpp"

void S1DSPKernel::process(AUAudioFrameCount frameCount, AUAudioFrameCount bufferOffset) {
    initializeNoteStates();

    // PREPARE FOR RENDER LOOP...updates here happen at 44100/frameCount Hz
    float* outL = (float*)outBufferListPtr->mBuffers[0].mData + bufferOffset;
    float* outR = (float*)outBufferListPtr->mBuffers[1].mData + bufferOffset;

    // currently UI is visible in DEV panel only so can't be portamento


    /// transition playing notes from release to off
    if (parameters[isMono] > 0.f) {
        if (monoNote->stage == S1NoteState::stageRelease && monoNote->amp < S1_RELEASE_AMPLITUDE_THRESHOLD) {
            monoNote->clear();
        }
    } else {
        for(int i=0; i<polyphony; i++) {
            auto& note = (*noteStates)[i];
            if (note.stage == S1NoteState::stageRelease && note.amp < S1_RELEASE_AMPLITUDE_THRESHOLD) {
                note.clear();
            }
        }
    }

    /// throttle main thread notification to < 30hz
    processSampleCounter += frameCount;
    if (processSampleCounter > 2048.0) {
        playingNotesDidChange();
        processSampleCounter = 0;
    }


    ///MARK: RENDER LOOP: Render one audio frame at sample rate, i.e. 44100 HZ
    for (AUAudioFrameCount frameIndex = 0; frameIndex < frameCount; ++frameIndex) {

        // CLEAR BUFFER
        outL[frameIndex] = outR[frameIndex] = 0.f;

        ///MARK:MONO CHAIN
        // MONO chain uses outL, ignores outR.  STEREO starts at AutoPan

        //MARK: PORTAMENTO
        for(int i = 0; i< S1Parameter::S1ParameterCount; i++) {
            if (s1p[i].usePortamento) {
                sp_port_compute(sp, s1p[i].portamento, &s1p[i].portamentoTarget, &parameters[i]);
            }
        }
        monoFrequencyPort->htime = parameters[glide];
        sp_port_compute(sp, monoFrequencyPort, &monoFrequency, &monoFrequencySmooth);

        // Clear all notes when toggling Mono <==> Poly
        if (parameters[isMono] != previousProcessMonoPolyStatus ) {
            previousProcessMonoPolyStatus = parameters[isMono];
            reset(); // clears all mono and poly notes
            sequencer.reset(true);
        }

        //MARK: LFO
        ///LFO1 on [-1, 1]
        lfo1Phasor->freq = parameters[lfo1Rate];
        sp_phasor_compute(sp, lfo1Phasor, nil, &lfo1); // sp_phasor_compute [0,1]
        if (parameters[lfo1Index] == 0) { // Sine
            lfo1 = sin(lfo1 * M_PI * 2.f);
        } else if (parameters[lfo1Index] == 1) { // Square
            if (lfo1 > 0.5f) {
                lfo1 = 1.f;
            } else {
                lfo1 = -1.f;
            }
        } else if (parameters[lfo1Index] == 2) { // Saw
            lfo1 = (lfo1 - 0.5f) * 2.f;
        } else if (parameters[lfo1Index] == 3) { // Reversed Saw
            lfo1 = (0.5f - lfo1) * 2.f;
        }
        lfo1_0_1 = 0.5f * (1.f + lfo1) * parameters[lfo1Amplitude];
        lfo1_1_0 = 1.f - (0.5f * (1.f + -lfo1) * parameters[lfo1Amplitude]);

        //LFO2 on [-1, 1]
        lfo2Phasor->freq = parameters[lfo2Rate];
        sp_phasor_compute(sp, lfo2Phasor, nil, &lfo2);  // sp_phasor_compute [0,1]
        if (parameters[lfo2Index] == 0) { // Sine
            lfo2 = sin(lfo2 * M_PI * 2.0);
        } else if (parameters[lfo2Index] == 1) { // Square
            if (lfo2 > 0.5f) {
                lfo2 = 1.f;
            } else {
                lfo2 = -1.f;
            }
        } else if (parameters[lfo2Index] == 2) { // Saw
            lfo2 = (lfo2 - 0.5f) * 2.f;
        } else if (parameters[lfo2Index] == 3) { // Reversed Saw
            lfo2 = (0.5f - lfo2) * 2.f;
        }
        lfo2_0_1 = 0.5f * (1.f + lfo2) * parameters[lfo2Amplitude];
        lfo2_1_0 = 1.f - (0.5f * (1.f + -lfo2) * parameters[lfo2Amplitude]);
        lfo3_0_1 = 0.5f * (lfo1_0_1 + lfo2_0_1);
        lfo3_1_0 = 0.5f * (lfo1_1_0 + lfo2_1_0);

        /// MARK: ARPEGGIATOR + SEQUENCER BEGIN
        sequencer.process(parameters, heldNoteNumbersAE);
        /// MARK: ARPEGGIATOR + SEQUENCER END

        /// MONO
        /// MARK: MONO CHAIN (EFX):

        // RENDER NoteState into (outL, outR)
        if (parameters[isMono] > 0.f) {
            if (monoNote->rootNoteNumber != -1 && monoNote->stage != S1NoteState::stageOff)
                monoNote->run(frameIndex, outL, outR);
        } else {
            for(int i=0; i<polyphony; i++) {
                S1NoteState& note = (*noteStates)[i];
                if (note.rootNoteNumber != -1 && note.stage != S1NoteState::stageOff)
                    note.run(frameIndex, outL, outR);
            }
        }

        // MONO: NoteState render output "synthOut" is mono
        float synthOut = outL[frameIndex];

        // BITCRUSH LFO
        float bitcrushSrate = parameters[bitCrushSampleRate];
        bitcrushSrate = log2(bitcrushSrate);
        const float magicNumber = 4.f;
        if (parameters[bitcrushLFO] == 1.f)
            bitcrushSrate += magicNumber * lfo1_0_1;
        else if (parameters[bitcrushLFO] == 2.f)
            bitcrushSrate += magicNumber * lfo2_0_1;
        else if (parameters[bitcrushLFO] == 3.f)
            bitcrushSrate += magicNumber * lfo3_0_1;
        bitcrushSrate = exp2(bitcrushSrate);
        bitcrushSrate = clampedValue(bitCrushSampleRate, bitcrushSrate); // clamp

        ///BITCRUSH
        float bitCrushOut = synthOut;
        bitcrushIncr = sampleRate() / bitcrushSrate;
        if (bitcrushIncr < 1.f) bitcrushIncr = 1.f; // for the case where the audio engine samplerate > 44100 (i.e., 48000)
        if (bitcrushIndex <= bitcrushSampleIndex) {
            bitCrushOut = bitcrushValue = synthOut;
            bitcrushIndex += bitcrushIncr; // bitcrushIncr >= 1
            bitcrushIndex -= bitcrushSampleIndex;
            bitcrushSampleIndex = 0;
        } else {
            bitCrushOut = bitcrushValue;
        }
        bitcrushSampleIndex += 1.f;

        ///TREMOLO
        if (parameters[tremoloLFO] == 1.f)
            bitCrushOut *= lfo1_1_0;
        else if (parameters[tremoloLFO] == 2.f)
            bitCrushOut *= lfo2_1_0;
        else if (parameters[tremoloLFO] == 3.f)
            bitCrushOut *= lfo3_1_0;

        ///MARK: STEREO CHAIN (EFX)

        // Signal goes from mono to stereo with autopan
        panOscillator->freq = parameters[autoPanFrequency];
        panOscillator->amp = parameters[autoPanAmount];
        float panValue = 0.f;
        sp_osc_compute(sp, panOscillator, nil, &panValue);
        pan->pan = panValue;
        float panL = 0.f, panR = 0.f;
        sp_pan2_compute(sp, pan, &bitCrushOut, &panL, &panR); // pan2 is equal power

        // PHASER+CROSSFADE
        float phaserOutL = panL;
        float phaserOutR = panR;
        float lPhaserMix = parameters[phaserMix];
        *phaser0->Notch_width = parameters[phaserNotchWidth];
        *phaser0->feedback_gain = parameters[phaserFeedback];
        *phaser0->lfobpm = parameters[phaserRate];
        if (lPhaserMix != 0.f) {
            lPhaserMix = 1.f - lPhaserMix;
            sp_phaser_compute(sp, phaser0, &panL, &panR, &phaserOutL, &phaserOutR);
            phaserOutL = lPhaserMix * panL + (1.f - lPhaserMix) * phaserOutL;
            phaserOutR = lPhaserMix * panR + (1.f - lPhaserMix) * phaserOutR;
        }

        // For lowpass osc filter: use a lowpass on delay input, with magically-attenuated cutoff
        float delayInputLowPassOutL = phaserOutL;
        float delayInputLowPassOutR = phaserOutR;
        if(parameters[filterType] == 0.f) {
            const float pmin2 = log2(1024.f);
            const float pmax2 = log2(maximum(cutoff));
            const float pval1 = parameters[cutoff];
            float pval2 = log2(pval1);
            if (pval2 < pmin2) pval2 = pmin2;
            if (pval2 > pmax2) pval2 = pmax2;
            const float pnorm2 = (pval2 - pmin2)/(pmax2 - pmin2);
            const float mmax = parameters[delayInputCutoffTrackingRatio];
            const float mmin = 1.f;
            const float oscFilterFreqCutoffPercentage = mmin + pnorm2 * (mmax - mmin);
            const float oscFilterResonance = 0.f; // constant
            float oscFilterFreqCutoff = pval1 * oscFilterFreqCutoffPercentage;
            oscFilterFreqCutoff = clampedValue(cutoff, oscFilterFreqCutoff);
            loPassInputDelayL->freq = oscFilterFreqCutoff;
            loPassInputDelayL->res = oscFilterResonance;
            loPassInputDelayR->freq = oscFilterFreqCutoff;
            loPassInputDelayR->res = oscFilterResonance;
            sp_moogladder_compute(sp, loPassInputDelayL, &phaserOutL, &delayInputLowPassOutL);
            sp_moogladder_compute(sp, loPassInputDelayR, &phaserOutR, &delayInputLowPassOutR);
        }

        // PING PONG DELAY
        float delayOutL = 0.f;
        float delayOutR = 0.f;
        float delayOutRR = 0.f;
        float delayFillInOut = 0.f;
        delayL->del = delayR->del = parameters[delayTime] * 2.f;
        delayRR->del = delayFillIn->del = parameters[delayTime];
        delayL->feedback = delayR->feedback = parameters[delayFeedback];
        delayRR->feedback = delayFillIn->feedback = parameters[delayFeedback];
        sp_vdelay_compute(sp, delayL,      &delayInputLowPassOutL, &delayOutL);
        sp_vdelay_compute(sp, delayR,      &delayInputLowPassOutR, &delayOutR);
        sp_vdelay_compute(sp, delayFillIn, &delayInputLowPassOutR, &delayFillInOut);
        sp_vdelay_compute(sp, delayRR,     &delayOutR,  &delayOutRR);
        delayOutRR += delayFillInOut;

        // DELAY MIXER
        float mixedDelayL = 0.f;
        float mixedDelayR = 0.f;
        delayCrossfadeL->pos = parameters[delayMix] * parameters[delayOn];
        delayCrossfadeR->pos = parameters[delayMix] * parameters[delayOn];
        sp_crossfade_compute(sp, delayCrossfadeL, &phaserOutL, &delayOutL, &mixedDelayL);
        sp_crossfade_compute(sp, delayCrossfadeR, &phaserOutR, &delayOutRR, &mixedDelayR);

        // REVERB INPUT HIPASS FILTER
        float butOutL = 0.f;
        float butOutR = 0.f;
        butterworthHipassL->freq = parameters[reverbHighPass];
        butterworthHipassR->freq = parameters[reverbHighPass];
        sp_buthp_compute(sp, butterworthHipassL, &mixedDelayL, &butOutL);
        sp_buthp_compute(sp, butterworthHipassR, &mixedDelayR, &butOutR);

        // Pre Gain + compression on reverb input
        butOutL *= 2.f;
        butOutR *= 2.f;
        float butCompressOutL = 0.f;
        float butCompressOutR = 0.f;
        mCompReverbIn.compute(butOutL, butOutR, butCompressOutL, butCompressOutR);

        // REVERB
        float reverbWetL = 0.f;
        float reverbWetR = 0.f;
        reverbCostello->feedback = parameters[reverbFeedback];
        reverbCostello->lpfreq = 0.5f * sampleRate();
        sp_revsc_compute(sp, reverbCostello, &butCompressOutL, &butCompressOutR, &reverbWetL, &reverbWetR);

        // compressor for wet reverb; like X2, FM
        float wetReverbLimiterL = reverbWetL;
        float wetReverbLimiterR = reverbWetR;
        mCompReverbWet.compute(reverbWetL, reverbWetR, wetReverbLimiterL, wetReverbLimiterR);

        // crossfade wet reverb with wet+dry delay
        float reverbCrossfadeOutL = 0.f;
        float reverbCrossfadeOutR = 0.f;
        float reverbMixFactor = parameters[reverbMix] * parameters[reverbOn];
        if (parameters[reverbMixLFO] == 1.f)
            reverbMixFactor *= lfo1_1_0;
        else if (parameters[reverbMixLFO] == 2.f)
            reverbMixFactor *= lfo2_1_0;
        else if (parameters[reverbMixLFO] == 3.f)
            reverbMixFactor *= lfo3_1_0;
        revCrossfadeL->pos = reverbMixFactor;
        revCrossfadeR->pos = reverbMixFactor;
        sp_crossfade_compute(sp, revCrossfadeL, &mixedDelayL, &wetReverbLimiterL, &reverbCrossfadeOutL);
        sp_crossfade_compute(sp, revCrossfadeR, &mixedDelayR, &wetReverbLimiterR, &reverbCrossfadeOutR);

        // MASTER COMPRESSOR/LIMITER
        // 3db pre gain on input to master compressor
        reverbCrossfadeOutL *= (2.f * parameters[masterVolume]);
        reverbCrossfadeOutR *= (2.f * parameters[masterVolume]);
        float compressorOutL = reverbCrossfadeOutL;
        float compressorOutR = reverbCrossfadeOutR;

        // MASTER COMPRESSOR TOGGLE: 0 = no compressor, 1 = compressor
        mCompMaster.compute(reverbCrossfadeOutL, reverbCrossfadeOutR, compressorOutL, compressorOutR);

        // WIDEN: constant delay with no filtering, so functionally equivalent to being inside master
        float widenOutR = 0.f;
        sp_delay_compute(sp, widenDelay, &compressorOutR, &widenOutR);
        widenOutR = parameters[widen] * widenOutR + (1.f - parameters[widen]) * compressorOutR;

        // MASTER
        outL[frameIndex] = compressorOutL;
        outR[frameIndex] = widenOutR;
    }
}
