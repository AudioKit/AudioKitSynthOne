//
//  S1DSPKernel+process.mm
//  AudioKitSynthOne
//
//  Created by Aurelius Prochazka on 6/4/18.
//  Copyright © 2018 AudioKit. All rights reserved.
//

#import <AudioKit/AudioKit-swift.h>
#import "S1DSPKernel.hpp"
#import "AEArray.h"
#import "S1NoteState.hpp"

void S1DSPKernel::process(AUAudioFrameCount frameCount, AUAudioFrameCount bufferOffset) {
    initializeNoteStates();

    // PREPARE FOR RENDER LOOP...updates here happen at 44100/frameCount Hz
    float* outL = (float*)outBufferListPtr->mBuffers[0].mData + bufferOffset;
    float* outR = (float*)outBufferListPtr->mBuffers[1].mData + bufferOffset;

    // currently UI is visible in DEV panel only so can't be portamento
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

    /// transition playing notes from release to off
    if (p[isMono] > 0.f) {
        if (monoNote->stage == S1NoteState::stageRelease && monoNote->amp < S1_RELEASE_AMPLITUDE_THRESHOLD) {
            monoNote->clear();
        }
    } else {
        for(int i=0; i<polyphony; i++) {
            S1NoteState& note = noteStates[i];
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
                sp_port_compute(sp, s1p[i].portamento, &s1p[i].portamentoTarget, &p[i]);
            }
        }
        monoFrequencyPort->htime = p[glide];
        sp_port_compute(sp, monoFrequencyPort, &monoFrequency, &monoFrequencySmooth);

        // Clear all notes when toggling Mono <==> Poly
        if (p[isMono] != previousProcessMonoPolyStatus ) {
            previousProcessMonoPolyStatus = p[isMono];
            reset(); // clears all mono and poly notes
            sequencerLastNotes.clear();
        }

        //MARK: LFO
        ///LFO1 on [-1, 1]
        lfo1Phasor->freq = p[lfo1Rate];
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
        lfo1_1_0 = 1.f - (0.5f * (1.f + -lfo1) * p[lfo1Amplitude]);

        //LFO2 on [-1, 1]
        lfo2Phasor->freq = p[lfo2Rate];
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
        lfo2_1_0 = 1.f - (0.5f * (1.f + -lfo2) * p[lfo2Amplitude]);
        lfo3_0_1 = 0.5f * (lfo1_0_1 + lfo2_0_1);
        lfo3_1_0 = 0.5f * (lfo1_1_0 + lfo2_1_0);

        /// MARK: ARPEGGIATOR + SEQUENCER BEGIN
        const int heldNoteNumbersAECount = heldNoteNumbersAE.count;
        const BOOL arpSeqIsOn = (p[arpIsOn] == 1.f);
        const BOOL firstTimeAnyKeysHeld = (previousHeldNoteNumbersAECount == 0 && heldNoteNumbersAECount > 0);
        const BOOL firstTimeNoKeysHeld = (heldNoteNumbersAECount == 0 && previousHeldNoteNumbersAECount > 0);

        // reset arp/seq when user goes from 0 to N, or N to 0 held keys
        if ( arpSeqIsOn && (firstTimeNoKeysHeld || firstTimeAnyKeysHeld) ) {

            arpTime = 0;
            arpSampleCounter = 0;
            arpBeatCounter = 0;

            // Turn OFF previous beat's notes
            for (std::list<int>::iterator arpLastNotesIterator = sequencerLastNotes.begin(); arpLastNotesIterator != sequencerLastNotes.end(); ++arpLastNotesIterator) {
                turnOffKey(*arpLastNotesIterator);
            }
            sequencerLastNotes.clear();

            beatCounterDidChange();
        }

        // If arp is ON, or if previous beat's notes need to be turned OFF
        if ( arpSeqIsOn || sequencerLastNotes.size() > 0 ) {

            // Compare previous arpTime to current to see if we crossed a beat boundary
            const double secPerBeat = 60.f * p[arpSeqTempoMultiplier] / p[arpRate];
            const double r0 = fmod(arpTime, secPerBeat);
            arpTime = arpSampleCounter/S1_SAMPLE_RATE;
            const double r1 = fmod(arpTime, secPerBeat);
            arpSampleCounter += 1.f;

            // If keys are now held, or if beat boundary was crossed
            if ( firstTimeAnyKeysHeld || r1 < r0 ) {

                // Turn off previous beat's notes even if arp is off
                for (std::list<int>::iterator arpLastNotesIterator = sequencerLastNotes.begin(); arpLastNotesIterator != sequencerLastNotes.end(); ++arpLastNotesIterator) {
                    turnOffKey(*arpLastNotesIterator);
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

                        if ( p[arpIsSequencer] == 1.f ) {

                            // SEQUENCER
                            const int numSteps = p[arpTotalSteps] > 16 ? 16 : (int)p[arpTotalSteps];
                            for(int i = 0; i < numSteps; i++) {
                                const float onOff = p[(S1Parameter)(i + sequencerNoteOn00)];
                                const int octBoost = p[(S1Parameter)(i + sequencerOctBoost00)];
                                const int nn = p[(S1Parameter)(i + sequencerPattern00)] * npof;
                                const int nnob = (nn < 0) ? (nn - octBoost * notesPerOctave) : (nn + octBoost * notesPerOctave);
                                struct SeqNoteNumber snn;
                                snn.init(nnob, onOff);
                                sequencerNotes.push_back(snn);
                            }
                        } else {

                            // ARPEGGIATOR
                            AEArrayEnumeratePointers(heldNoteNumbersAE, NoteNumber *, note) {
                                std::vector<NoteNumber>::iterator it = sequencerNotes2.begin();
                                sequencerNotes2.insert(it, *note);
                            }
                            const int heldNotesCount = (int)sequencerNotes2.size();
                            const int arpIntervalUp = p[arpInterval] * npof;
                            const int onOff = 1;
                            const int arpOctaves = (int)p[arpOctave] + 1;

                            if (p[arpDirection] == 0.f) {

                                // ARP Up
                                int index = 0;
                                for (int octave = 0; octave < arpOctaves; octave++) {
                                    for (int i = 0; i < heldNotesCount; i++) {
                                        NoteNumber& note = sequencerNotes2[i];
                                        const int nn = note.noteNumber + (octave * arpIntervalUp);
                                        struct SeqNoteNumber snn;
                                        snn.init(nn, onOff);
                                        std::vector<SeqNoteNumber>::iterator it = sequencerNotes.begin() + index;
                                        sequencerNotes.insert(it, snn);
                                        ++index;
                                    }
                                }
                            } else if (p[arpDirection] == 1.f) {

                                //ARP Up + Down
                                //Up
                                int index = 0;
                                for (int octave = 0; octave < arpOctaves; octave++) {
                                    for (int i = 0; i < heldNotesCount; i++) {
                                        NoteNumber& note = sequencerNotes2[i];
                                        const int nn = note.noteNumber + (octave * arpIntervalUp);
                                        struct SeqNoteNumber snn;
                                        snn.init(nn, onOff);
                                        std::vector<SeqNoteNumber>::iterator it = sequencerNotes.begin() + index;
                                        sequencerNotes.insert(it, snn);
                                        ++index;
                                    }
                                }
                                //Down, minus head and tail
                                for (int octave = arpOctaves - 1; octave >= 0; octave--) {
                                    for (int i = heldNotesCount - 1; i >= 0; i--) {
                                        const bool firstNote = (i == heldNotesCount - 1) && (octave == arpOctaves - 1);
                                        const bool lastNote = (i == 0) && (octave == 0);
                                        if (!firstNote && !lastNote) {
                                            NoteNumber& note = sequencerNotes2[i];
                                            const int nn = note.noteNumber + (octave * arpIntervalUp);
                                            struct SeqNoteNumber snn;
                                            snn.init(nn, onOff);
                                            std::vector<SeqNoteNumber>::iterator it = sequencerNotes.begin() + index;
                                            sequencerNotes.insert(it, snn);
                                            ++index;
                                        }
                                    }
                                }
                            } else if (p[arpDirection] == 2.f) {

                                // ARP Down
                                int index = 0;
                                for (int octave = arpOctaves - 1; octave >= 0; octave--) {
                                    for (int i = heldNotesCount - 1; i >= 0; i--) {
                                        NoteNumber& note = sequencerNotes2[i];
                                        const int nn = note.noteNumber + (octave * arpIntervalUp);
                                        struct SeqNoteNumber snn;
                                        snn.init(nn, onOff);
                                        std::vector<SeqNoteNumber>::iterator it = sequencerNotes.begin() + index;
                                        sequencerNotes.insert(it, snn);
                                        ++index;
                                    }
                                }
                            }
                        }

                        // At least one key is held down, and a non-empty sequence has been created
                        if ( sequencerNotes.size() > 0 ) {

                            // Advance arp/seq beatCounter, notify delegates
                            const int seqNotePosition = arpBeatCounter % sequencerNotes.size();
                            ++arpBeatCounter;
                            beatCounterDidChange();

                            //MARK: ARP+SEQ: turn ON the note of the sequence
                            SeqNoteNumber& snn = sequencerNotes[seqNotePosition];

                            if (p[arpIsSequencer] == 1.f) {

                                // SEQUENCER
                                if (snn.onOff == 1) {
                                    AEArrayEnumeratePointers(heldNoteNumbersAE, NoteNumber *, noteStruct) {
                                        const int baseNote = noteStruct->noteNumber;
                                        const int note = baseNote + snn.noteNumber;
                                        if (note >= 0 && note < S1_NUM_MIDI_NOTES) {
                                            turnOnKey(note, 127); //TODO: Add ARP/SEQ Velocity
                                            sequencerLastNotes.push_back(note);
                                        }
                                    }
                                }
                            } else {

                                // ARPEGGIATOR
                                const int note = snn.noteNumber;
                                if (note >= 0 && note < S1_NUM_MIDI_NOTES) {
                                    turnOnKey(note, 127); //TODO: Add ARP/SEQ velocity
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

        /// MONO
        /// MARK: MONO CHAIN (EFX):

        // RENDER NoteState into (outL, outR)
        if (p[isMono] > 0.f) {
            if (monoNote->rootNoteNumber != -1 && monoNote->stage != S1NoteState::stageOff)
                monoNote->run(frameIndex, outL, outR);
        } else {
            for(int i=0; i<polyphony; i++) {
                S1NoteState& note = noteStates[i];
                if (note.rootNoteNumber != -1 && note.stage != S1NoteState::stageOff)
                    note.run(frameIndex, outL, outR);
            }
        }

        // MONO: NoteState render output "synthOut" is mono
        float synthOut = outL[frameIndex];

        // BITCRUSH LFO
        float bitcrushSrate = p[bitCrushSampleRate];
        bitcrushSrate = log2(bitcrushSrate);
        const float magicNumber = 4.f;
        if (p[bitcrushLFO] == 1.f)
            bitcrushSrate += magicNumber * lfo1_0_1;
        else if (p[bitcrushLFO] == 2.f)
            bitcrushSrate += magicNumber * lfo2_0_1;
        else if (p[bitcrushLFO] == 3.f)
            bitcrushSrate += magicNumber * lfo3_0_1;
        bitcrushSrate = exp2(bitcrushSrate);
        bitcrushSrate = clampedValue(bitCrushSampleRate, bitcrushSrate); // clamp

        ///BITCRUSH
        float bitCrushOut = synthOut;
        bitcrushIncr = S1_SAMPLE_RATE / bitcrushSrate; //TODO:use live sample rate, not hard-coded
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
        if (p[tremoloLFO] == 1.f)
            bitCrushOut *= lfo1_1_0;
        else if (p[tremoloLFO] == 2.f)
            bitCrushOut *= lfo2_1_0;
        else if (p[tremoloLFO] == 3.f)
            bitCrushOut *= lfo3_1_0;

        ///MARK: STEREO CHAIN (EFX)

        // Signal goes from mono to stereo with autopan
        panOscillator->freq = p[autoPanFrequency];
        panOscillator->amp = p[autoPanAmount];
        float panValue = 0.f;
        sp_osc_compute(sp, panOscillator, nil, &panValue);
        pan->pan = panValue;
        float panL = 0.f, panR = 0.f;
        sp_pan2_compute(sp, pan, &bitCrushOut, &panL, &panR); // pan2 is equal power

        // PHASER+CROSSFADE
        float phaserOutL = panL;
        float phaserOutR = panR;
        float lPhaserMix = p[phaserMix];
        *phaser0->Notch_width = p[phaserNotchWidth];
        *phaser0->feedback_gain = p[phaserFeedback];
        *phaser0->lfobpm = p[phaserRate];
        if (lPhaserMix != 0.f) {
            lPhaserMix = 1.f - lPhaserMix;
            sp_phaser_compute(sp, phaser0, &panL, &panR, &phaserOutL, &phaserOutR);
            phaserOutL = lPhaserMix * panL + (1.f - lPhaserMix) * phaserOutL;
            phaserOutR = lPhaserMix * panR + (1.f - lPhaserMix) * phaserOutR;
        }

        // For lowpass osc filter: use a lowpass on delay input, with magically-attenuated cutoff
        float delayInputLowPassOutL = phaserOutL;
        float delayInputLowPassOutR = phaserOutR;
        if(p[filterType] == 0.f) {
            const float pmin2 = log2(1024.f);
            const float pmax2 = log2(maximum(cutoff));
            const float pval1 = p[cutoff];
            float pval2 = log2(pval1);
            if (pval2 < pmin2) pval2 = pmin2;
            if (pval2 > pmax2) pval2 = pmax2;
            const float pnorm2 = (pval2 - pmin2)/(pmax2 - pmin2);
            const float mmax = p[delayInputCutoffTrackingRatio];
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
        delayL->del = delayR->del = p[delayTime] * 2.f;
        delayRR->del = delayFillIn->del = p[delayTime];
        delayL->feedback = delayR->feedback = p[delayFeedback];
        delayRR->feedback = delayFillIn->feedback = p[delayFeedback];
        sp_vdelay_compute(sp, delayL,      &delayInputLowPassOutL, &delayOutL);
        sp_vdelay_compute(sp, delayR,      &delayInputLowPassOutR, &delayOutR);
        sp_vdelay_compute(sp, delayFillIn, &delayInputLowPassOutR, &delayFillInOut);
        sp_vdelay_compute(sp, delayRR,     &delayOutR,  &delayOutRR);
        delayOutRR += delayFillInOut;

        // DELAY MIXER
        float mixedDelayL = 0.f;
        float mixedDelayR = 0.f;
        delayCrossfadeL->pos = p[delayMix] * p[delayOn];
        delayCrossfadeR->pos = p[delayMix] * p[delayOn];
        sp_crossfade_compute(sp, delayCrossfadeL, &phaserOutL, &delayOutL, &mixedDelayL);
        sp_crossfade_compute(sp, delayCrossfadeR, &phaserOutR, &delayOutRR, &mixedDelayR);

        // REVERB INPUT HIPASS FILTER
        float butOutL = 0.f;
        float butOutR = 0.f;
        butterworthHipassL->freq = p[reverbHighPass];
        butterworthHipassR->freq = p[reverbHighPass];
        sp_buthp_compute(sp, butterworthHipassL, &mixedDelayL, &butOutL);
        sp_buthp_compute(sp, butterworthHipassR, &mixedDelayR, &butOutR);

        // Pre Gain + compression on reverb input
        butOutL *= 2.f;
        butOutR *= 2.f;
        float butCompressOutL = 0.f;
        float butCompressOutR = 0.f;
        sp_compressor_compute(sp, compressorReverbInputL, &butOutL, &butCompressOutL);
        sp_compressor_compute(sp, compressorReverbInputR, &butOutR, &butCompressOutR);
        butCompressOutL *= p[compressorReverbInputMakeupGain];
        butCompressOutR *= p[compressorReverbInputMakeupGain];

        // REVERB
        float reverbWetL = 0.f;
        float reverbWetR = 0.f;
        reverbCostello->feedback = p[reverbFeedback];
        reverbCostello->lpfreq = 0.5f * S1_SAMPLE_RATE;
        sp_revsc_compute(sp, reverbCostello, &butCompressOutL, &butCompressOutR, &reverbWetL, &reverbWetR);

        // compressor for wet reverb; like X2, FM
        float wetReverbLimiterL = reverbWetL;
        float wetReverbLimiterR = reverbWetR;
        sp_compressor_compute(sp, compressorReverbWetL, &reverbWetL, &wetReverbLimiterL);
        sp_compressor_compute(sp, compressorReverbWetR, &reverbWetR, &wetReverbLimiterR);
        wetReverbLimiterL *= p[compressorReverbWetMakeupGain];
        wetReverbLimiterR *= p[compressorReverbWetMakeupGain];

        // crossfade wet reverb with wet+dry delay
        float reverbCrossfadeOutL = 0.f;
        float reverbCrossfadeOutR = 0.f;
        float reverbMixFactor = p[reverbMix] * p[reverbOn];
        if (p[reverbMixLFO] == 1.f)
            reverbMixFactor *= lfo1_1_0;
        else if (p[reverbMixLFO] == 2.f)
            reverbMixFactor *= lfo2_1_0;
        else if (p[reverbMixLFO] == 3.f)
            reverbMixFactor *= lfo3_1_0;
        revCrossfadeL->pos = reverbMixFactor;
        revCrossfadeR->pos = reverbMixFactor;
        sp_crossfade_compute(sp, revCrossfadeL, &mixedDelayL, &wetReverbLimiterL, &reverbCrossfadeOutL);
        sp_crossfade_compute(sp, revCrossfadeR, &mixedDelayR, &wetReverbLimiterR, &reverbCrossfadeOutR);

        // MASTER COMPRESSOR/LIMITER
        // 3db pre gain on input to master compressor
        reverbCrossfadeOutL *= (2.f * p[masterVolume]);
        reverbCrossfadeOutR *= (2.f * p[masterVolume]);
        float compressorOutL = reverbCrossfadeOutL;
        float compressorOutR = reverbCrossfadeOutR;

        // MASTER COMPRESSOR TOGGLE: 0 = no compressor, 1 = compressor
        sp_compressor_compute(sp, compressorMasterL, &reverbCrossfadeOutL, &compressorOutL);
        sp_compressor_compute(sp, compressorMasterR, &reverbCrossfadeOutR, &compressorOutR);

        // Makeup Gain on Master Compressor
        compressorOutL *= p[compressorMasterMakeupGain];
        compressorOutR *= p[compressorMasterMakeupGain];

        // WIDEN: constant delay with no filtering, so functionally equivalent to being inside master
        float widenOutR = 0.f;
        sp_delay_compute(sp, widenDelay, &compressorOutR, &widenOutR);
        widenOutR = p[widen] * widenOutR + (1.f - p[widen]) * compressorOutR;

        // MASTER
        outL[frameIndex] = compressorOutL;
        outR[frameIndex] = widenOutR;
    }
}
