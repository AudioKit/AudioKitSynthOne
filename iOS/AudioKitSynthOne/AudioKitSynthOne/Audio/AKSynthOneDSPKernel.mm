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
#import "AKS1NoteState.hpp"

#define AKS1_RELEASE_AMPLITUDE_THRESHOLD (0.000000000232831f) // 1/2^32
#define AKS1_PORTAMENTO_HALF_TIME (0.1f)
#define AKS1_DEPENDENT_PARAM_TAPER (0.4f)

// Convert note number to [possibly] microtonal frequency.  12ET is the default.
// Profiling shows that while this takes a special Swift lock it still resolves to ~0% of CPU on a device
static inline double tuningTableNoteToHz(int noteNumber) {
    return [AKPolyphonicNode.tuningTable frequencyForNoteNumber:noteNumber];
}

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

// MARK: AKSynthOneDSPKernel Member Functions

AKSynthOneDSPKernel::AKSynthOneDSPKernel() {}

AKSynthOneDSPKernel::~AKSynthOneDSPKernel() = default;

///panic...hard-resets DSP.  artifacts.
void AKSynthOneDSPKernel::resetDSP() {
    [heldNoteNumbers removeAllObjects];
    [heldNoteNumbersAE updateWithContentsOfArray:heldNoteNumbers];
    arpSeqLastNotes.clear();
    arpSeqNotes.clear();
    arpSeqNotes2.clear();
    arpBeatCounter = 0;
    _setAK1Parameter(arpIsOn, 0.f);
    monoNote->clear();
    for(int i =0; i < AKS1_MAX_POLYPHONY; i++)
        noteStates[i].clear();
}


///puts all notes in release mode...no artifacts
void AKSynthOneDSPKernel::stopAllNotes() {
    [heldNoteNumbers removeAllObjects];
    [heldNoteNumbersAE updateWithContentsOfArray:heldNoteNumbers];
    if (p[isMono] > 0.f) {
        stopNote(60);
    } else {
        for(int i=0; i<AKS1_NUM_MIDI_NOTES; i++)
            stopNote(i);
    }
}

//TODO:set aks1 param arpRate
void AKSynthOneDSPKernel::handleTempoSetting(float currentTempo) {
    if (currentTempo != tempo) {
        tempo = currentTempo;
    }
}

//
void AKSynthOneDSPKernel::dependentParameterDidChange(DependentParam param) {
    AEMessageQueuePerformSelectorOnMainThread(audioUnit->_messageQueue,
                                              audioUnit,
                                              @selector(dependentParamDidChange:),
                                              AEArgumentStruct(param),
                                              AEArgumentNone);
}

///can be called from within the render loop
void AKSynthOneDSPKernel::beatCounterDidChange() {
    AKS1ArpBeatCounter retVal = {arpBeatCounter, heldNoteNumbersAE.count};
    AEMessageQueuePerformSelectorOnMainThread(audioUnit->_messageQueue,
                                              audioUnit,
                                              @selector(arpBeatCounterDidChange:),
                                              AEArgumentStruct(retVal),
                                              AEArgumentNone);
}


///can be called from within the render loop
void AKSynthOneDSPKernel::playingNotesDidChange() {
    if (p[isMono] > 0.f) {
        aePlayingNotes.playingNotes[0] = {monoNote->rootNoteNumber};
        for(int i=1; i<AKS1_MAX_POLYPHONY; i++) {
            aePlayingNotes.playingNotes[i] = {-1};
        }
    } else {
        for(int i=0; i<AKS1_MAX_POLYPHONY; i++) {
            aePlayingNotes.playingNotes[i] = {noteStates[i].rootNoteNumber};
        }
    }
    AEMessageQueuePerformSelectorOnMainThread(audioUnit->_messageQueue,
                                              audioUnit,
                                              @selector(playingNotesDidChange:),
                                              AEArgumentStruct(aePlayingNotes),
                                              AEArgumentNone);
}

///can be called from within the render loop
void AKSynthOneDSPKernel::heldNotesDidChange() {
    for(int i = 0; i<AKS1_NUM_MIDI_NOTES; i++)
        aeHeldNotes.heldNotes[i] = false;
    int count = 0;
    AEArrayEnumeratePointers(heldNoteNumbersAE, NoteNumber *, note) {
        const int nn = note->noteNumber;
        aeHeldNotes.heldNotes[nn] = true;
        ++count;
    }
    aeHeldNotes.heldNotesCount = count;
    AEMessageQueuePerformSelectorOnMainThread(audioUnit->_messageQueue,
                                              audioUnit,
                                              @selector(heldNotesDidChange:),
                                              AEArgumentStruct(aeHeldNotes),
                                              AEArgumentNone);
}

//MARK: PROCESS
void AKSynthOneDSPKernel::process(AUAudioFrameCount frameCount, AUAudioFrameCount bufferOffset) {
    initializeNoteStates();
    
    // PREPARE FOR RENDER LOOP...updates here happen at (typically) 44100/512 HZ
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
    
    // transition playing notes from release to off
    bool transitionedToOff = false;
    if (p[isMono] > 0.f) {
        if (monoNote->stage == AKS1NoteState::stageRelease && monoNote->amp <= AKS1_RELEASE_AMPLITUDE_THRESHOLD) {
            monoNote->clear();
            transitionedToOff = true;
        }
    } else {
        for(int i=0; i<polyphony; i++) {
            AKS1NoteState& note = noteStates[i];
            if (note.stage == AKS1NoteState::stageRelease && note.amp <= AKS1_RELEASE_AMPLITUDE_THRESHOLD) {
                note.clear();
                transitionedToOff = true;
            }
        }
    }
    if (transitionedToOff)
        playingNotesDidChange();

    const float arpTempo = p[arpRate];
    const double secPerBeat = 0.5f * 0.5f * 60.f / arpTempo;
    
    // RENDER LOOP: Render one audio frame at sample rate, i.e. 44100 HZ
    for (AUAudioFrameCount frameIndex = 0; frameIndex < frameCount; ++frameIndex) {

        //PORTAMENTO
        for(int i = 0; i< AKSynthOneParameter::AKSynthOneParameterCount; i++) {
            if (aks1p[i].usePortamento) {
                sp_port_compute(sp, aks1p[i].portamento, &aks1p[i].portamentoTarget, &p[i]);
            }
        }
        monoFrequencyPort->htime = p[glide];
        sp_port_compute(sp, monoFrequencyPort, &monoFrequency, &monoFrequencySmooth);
        
        // CLEAR BUFFER
        outL[frameIndex] = outR[frameIndex] = 0.f;
                
        // Clear all notes when toggling Mono <==> Poly
        if (p[isMono] != previousProcessMonoPolyStatus ) {
            previousProcessMonoPolyStatus = p[isMono];
            reset(); // clears all mono and poly notes
            arpSeqLastNotes.clear();
        }
        
        //MARK: ARP/SEQ
        if (p[arpIsOn] == 1.f || arpSeqLastNotes.size() > 0) {
            const double r0 = fmod(arpTime, secPerBeat);
            arpTime = arpSampleCounter/AKS1_SAMPLE_RATE;
            arpSampleCounter += 1.0;
            const double r1 = fmod(arpTime, secPerBeat);
            if (r1 < r0) {
                // NEW beatCounter
                // turn Off previous beat's notes
                for (std::list<int>::iterator arpLastNotesIterator = arpSeqLastNotes.begin(); arpLastNotesIterator != arpSeqLastNotes.end(); ++arpLastNotesIterator) {
                    turnOffKey(*arpLastNotesIterator);
                }
                arpSeqLastNotes.clear();

                // Create Arp/Seq array based on held notes and/or sequence parameters
                if (p[arpIsOn] == 1.f && heldNoteNumbersAE.count > 0) {
                    arpSeqNotes.clear();
                    arpSeqNotes2.clear();
                    
                    // only update "notes per octave" when beat counter changes so arpSeqNotes and arpSeqLastNotes match
                    notesPerOctave = (int)AKPolyphonicNode.tuningTable.npo;
                    if (notesPerOctave <= 0) notesPerOctave = 12;
                    const float npof = (float)notesPerOctave/12.f; // 12ET ==> npof = 1
                    
                    // only create arp/sequence if at least one key is held down
                    if (p[arpIsSequencer] == 1.f) {
                        // SEQUENCER
                        const int numSteps = p[arpTotalSteps] > 16 ? 16 : (int)p[arpTotalSteps];
                        for(int i = 0; i < numSteps; i++) {
                            const float onOff = p[(AKSynthOneParameter)(i + arpSeqNoteOn00)];
                            const int octBoost = p[(AKSynthOneParameter)(i + arpSeqOctBoost00)];
                            const int nn = p[(AKSynthOneParameter)(i + arpSeqPattern00)] * npof;
                            const int nnob = (nn < 0) ? (nn - octBoost * notesPerOctave) : (nn + octBoost * notesPerOctave);
                            struct SeqNoteNumber snn;
                            snn.init(nnob, onOff);
                            arpSeqNotes.push_back(snn);
                        }
                    } else {
                        // ARP state
                        AEArrayEnumeratePointers(heldNoteNumbersAE, NoteNumber *, note) {
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
                                    NoteNumber& note = arpSeqNotes2[i];
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
                                    NoteNumber& note = arpSeqNotes2[i];
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
                                        NoteNumber& note = arpSeqNotes2[i];
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
                                    NoteNumber& note = arpSeqNotes2[i];
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
                
                // No keys held down
                if (heldNoteNumbersAE.count == 0) {
                    if (arpBeatCounter > 0) {
                        arpBeatCounter = 0;
                        beatCounterDidChange();
                    }
                } else if (arpSeqNotes.size() == 0) {
                    // NOP for zero-length arp/seq
                } else {
                    // Advance arp/seq beatCounter, notify delegates
                    const int seqNotePosition = arpBeatCounter % arpSeqNotes.size();
                    ++arpBeatCounter;
                    beatCounterDidChange();
                    
                    // Play the arp/seq
                    if (p[arpIsOn] > 0.f) {
                        // ARP+SEQ: turnOn the note of the sequence
                        SeqNoteNumber& snn = arpSeqNotes[seqNotePosition];
                        if (p[arpIsSequencer] == 1.f) {
                            // SEQUENCER
                            if (snn.onOff == 1) {
                                AEArrayEnumeratePointers(heldNoteNumbersAE, NoteNumber *, noteStruct) {
                                    const int baseNote = noteStruct->noteNumber;
                                    const int note = baseNote + snn.noteNumber;
                                    if (note >= 0 && note < AKS1_NUM_MIDI_NOTES) {
                                        turnOnKey(note, 127);
                                        arpSeqLastNotes.push_back(note);
                                    }
                                }
                            }
                        } else {
                            // ARPEGGIATOR
                            const int note = snn.noteNumber;
                            if (note >= 0 && note < AKS1_NUM_MIDI_NOTES) {
                                turnOnKey(note, 127);
                                arpSeqLastNotes.push_back(note);
                            }
                        }
                    }
                }
            }
        }
        
        //LFO1 on [-1, 1]
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
        lfo1_1_0 = 1.f - lfo1_0_1; // good for multiplicative

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
        lfo2_1_0 = 1.f - lfo2_0_1;
        lfo3_0_1 = 0.5f * (lfo1_0_1 + lfo2_0_1);
        lfo3_1_0 = 1.f - lfo3_0_1;

        // RENDER NoteState into (outL, outR)
        if (p[isMono] > 0.f) {
            if (monoNote->rootNoteNumber != -1 && monoNote->stage != AKS1NoteState::stageOff)
                monoNote->run(frameIndex, outL, outR);
        } else {
            for(int i=0; i<polyphony; i++) {
                AKS1NoteState& note = noteStates[i];
                if (note.rootNoteNumber != -1 && note.stage != AKS1NoteState::stageOff)
                    note.run(frameIndex, outL, outR);
            }
        }
        
        // NoteState render output "synthOut" is mono
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
        bitcrushSrate = parameterClamp(bitCrushSampleRate, bitcrushSrate); // clamp
        
        //BITCRUSH
        float bitCrushOut = synthOut;
        bitcrushIncr = AKS1_SAMPLE_RATE / bitcrushSrate; //TODO:use live sample rate, not hard-coded
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
        
        //TREMOLO
        if (p[tremoloLFO] == 1.f)
            bitCrushOut *= lfo1_1_0;
        else if (p[tremoloLFO] == 2.f)
            bitCrushOut *= lfo2_1_0;
        else if (p[tremoloLFO] == 3.f)
            bitCrushOut *= lfo3_1_0;
        
        // signal goes from mono to stereo with autopan
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
        
        // DELAY INPUT LOW PASS FILTER
        //linear interpolation of percentage in pitch space
        const float pmin2 = log2(1024.f);
        const float pmax2 = log2(parameterMax(cutoff));
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
        oscFilterFreqCutoff = parameterClamp(cutoff, oscFilterFreqCutoff);
        loPassInputDelayL->freq = oscFilterFreqCutoff;
        loPassInputDelayL->res = oscFilterResonance;
        loPassInputDelayR->freq = oscFilterFreqCutoff;
        loPassInputDelayR->res = oscFilterResonance;
        float delayInputLowPassOutL = phaserOutL;
        float delayInputLowPassOutR = phaserOutR;
        sp_moogladder_compute(sp, loPassInputDelayL, &phaserOutL, &delayInputLowPassOutL);
        sp_moogladder_compute(sp, loPassInputDelayR, &phaserOutR, &delayInputLowPassOutR);

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
        reverbCostello->lpfreq = 0.5f * AKS1_SAMPLE_RATE;
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

void AKSynthOneDSPKernel::turnOnKey(int noteNumber, int velocity) {
    if (noteNumber < 0 || noteNumber >= AKS1_NUM_MIDI_NOTES)
        return;
    
    const float frequency = tuningTableNoteToHz(noteNumber);
    turnOnKey(noteNumber, velocity, frequency);
}

// turnOnKey is called by render thread in "process", so access note via AEArray
void AKSynthOneDSPKernel::turnOnKey(int noteNumber, int velocity, float frequency) {
    if (noteNumber < 0 || noteNumber >= AKS1_NUM_MIDI_NOTES)
        return;
    initializeNoteStates();
    
    if (p[isMono] > 0.f) {
        AKS1NoteState& note = *monoNote;
        monoFrequency = frequency;
        
        // PORTAMENTO: set the ADSRs to release mode here, then into attack mode inside startNoteHelper
        if (p[monoIsLegato] == 0) {
            note.internalGate = 0;
            note.stage = AKS1NoteState::stageRelease;
            sp_adsr_compute(sp, note.adsr, &note.internalGate, &note.amp);
            sp_adsr_compute(sp, note.fadsr, &note.internalGate, &note.filter);
        }
        
        // legato+portamento: Legato means that Presets with low sustains will sound like they did not retrigger.
        note.startNoteHelper(noteNumber, velocity, frequency);
        
    } else {
        // Note Stealing: Is noteNumber already playing?
        int index = -1;
        for(int i = 0 ; i < polyphony; i++) {
            if (noteStates[i].rootNoteNumber == noteNumber) {
                index = i;
                break;
            }
        }
        if (index != -1) {
            // noteNumber is playing...steal it
            playingNoteStatesIndex = index;
        } else {
            // noteNumber is not playing: search for non-playing notes (-1) starting with current index
            for(int i = 0; i < polyphony; i++) {
                const int modIndex = (playingNoteStatesIndex + i) % polyphony;
                if (noteStates[modIndex].rootNoteNumber == -1) {
                    index = modIndex;
                    break;
                }
            }
            
            if (index == -1) {
                // if there are no non-playing notes then steal oldest note
                ++playingNoteStatesIndex %= polyphony;
            } else {
                // use non-playing note slot
                playingNoteStatesIndex = index;
            }
        }
        
        // POLY: INIT NoteState
        AKS1NoteState& note = noteStates[playingNoteStatesIndex];
        note.startNoteHelper(noteNumber, velocity, frequency);
    }
    
    heldNotesDidChange();
    playingNotesDidChange();
}

// turnOffKey is called by render thread in "process", so access note via AEArray
void AKSynthOneDSPKernel::turnOffKey(int noteNumber) {
    if (noteNumber < 0 || noteNumber >= AKS1_NUM_MIDI_NOTES)
        return;
    initializeNoteStates();
    if (p[isMono] > 0.f) {
        if (p[arpIsOn] == 1.f || heldNoteNumbersAE.count == 0) {
            // the case where this was the only held note and now it should be off, OR
            // the case where the sequencer turns off this key even though a note is held down
            if (monoNote->stage != AKS1NoteState::stageOff) {
                monoNote->stage = AKS1NoteState::stageRelease;
                monoNote->internalGate = 0;
            }
        } else {
            // the case where you had more than one held note and released one (CACA): Keep note ON and set to freq of head
            AEArrayToken token = AEArrayGetToken(heldNoteNumbersAE);
            NoteNumber* nn = (NoteNumber*)AEArrayGetItem(token, 0);
            const int headNN = nn->noteNumber;
            monoFrequency = tuningTableNoteToHz(headNN);
            monoNote->rootNoteNumber = headNN;
            monoFrequency = tuningTableNoteToHz(headNN);
            monoNote->oscmorph1->freq = monoFrequency;
            monoNote->oscmorph2->freq = monoFrequency;
            monoNote->subOsc->freq = monoFrequency;
            monoNote->fmOsc->freq = monoFrequency;
            
            // PORTAMENTO: reset the ADSR inside the render loop
            if (p[monoIsLegato] == 0.f) {
                monoNote->internalGate = 0;
                monoNote->stage = AKS1NoteState::stageRelease;
                sp_adsr_compute(sp, monoNote->adsr, &monoNote->internalGate, &monoNote->amp);
                sp_adsr_compute(sp, monoNote->fadsr, &monoNote->internalGate, &monoNote->filter);
            }
            
            // legato+portamento: Legato means that Presets with low sustains will sound like they did not retrigger.
            monoNote->stage = AKS1NoteState::stageOn;
            monoNote->internalGate = 1;
        }
    } else {
        // Poly:
        int index = -1;
        for(int i=0; i<polyphony; i++) {
            if (noteStates[i].rootNoteNumber == noteNumber) {
                index = i;
                break;
            }
        }
        
        if (index != -1) {
            // put NoteState into release
            AKS1NoteState& note = noteStates[index];
            note.stage = AKS1NoteState::stageRelease;
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
    if (noteNumber < 0 || noteNumber >= AKS1_NUM_MIDI_NOTES)
        return;
    
    const float frequency = tuningTableNoteToHz(noteNumber);
    startNote(noteNumber, velocity, frequency);
}

// NOTE ON
// startNote is not called by render thread, but turnOnKey is
void AKSynthOneDSPKernel::startNote(int noteNumber, int velocity, float frequency) {
    if (noteNumber < 0 || noteNumber >= AKS1_NUM_MIDI_NOTES)
        return;
    
    NSNumber* nn = @(noteNumber);
    [heldNoteNumbers removeObject:nn];
    [heldNoteNumbers insertObject:nn atIndex:0];
    [heldNoteNumbersAE updateWithContentsOfArray:heldNoteNumbers];
    
    // ARP/SEQ
    if (p[arpIsOn] == 1.f) {
        return;
    } else {
        turnOnKey(noteNumber, velocity, frequency);
    }
}

// NOTE OFF...put into release mode
void AKSynthOneDSPKernel::stopNote(int noteNumber) {
    if (noteNumber < 0 || noteNumber >= AKS1_NUM_MIDI_NOTES)
        return;
    
    NSNumber* nn = @(noteNumber);
    [heldNoteNumbers removeObject: nn];
    [heldNoteNumbersAE updateWithContentsOfArray: heldNoteNumbers];
    
    // ARP/SEQ
    if (p[arpIsOn] == 1.f)
        return;
    else
        turnOffKey(noteNumber);
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
    sp_phaser_create(&phaser0);
    sp_phaser_init(sp, phaser0);
    sp_port_create(&monoFrequencyPort);
    sp_port_init(sp, monoFrequencyPort, 0.05f);
    sp_osc_create(&panOscillator);
    sp_osc_init(sp, panOscillator, sine, 0.f);
    sp_pan2_create(&pan);
    sp_pan2_init(sp, pan);
    
    sp_moogladder_create(&loPassInputDelayL);
    sp_moogladder_init(sp, loPassInputDelayL);
    sp_moogladder_create(&loPassInputDelayR);
    sp_moogladder_init(sp, loPassInputDelayR);
    sp_vdelay_create(&delayL);
    sp_vdelay_create(&delayR);
    sp_vdelay_create(&delayRR);
    sp_vdelay_create(&delayFillIn);
    sp_vdelay_init(sp, delayL, 10.f);
    sp_vdelay_init(sp, delayR, 10.f);
    sp_vdelay_init(sp, delayRR, 10.f);
    sp_vdelay_init(sp, delayFillIn, 10.f);
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
    sp_delay_create(&widenDelay);
    sp_delay_init(sp, widenDelay, 0.05f);
    widenDelay->feedback = 0.f;
    
    noteStates = (AKS1NoteState*)malloc(AKS1_MAX_POLYPHONY * sizeof(AKS1NoteState));
    
    monoNote = (AKS1NoteState*)malloc(sizeof(AKS1NoteState));
    
    heldNoteNumbers = (NSMutableArray<NSNumber*>*)[NSMutableArray array];
    heldNoteNumbersAE = [[AEArray alloc] initWithCustomMapping:^void *(id item) {
        const int nn = [(NSNumber*)item intValue];
        NoteNumber* noteNumber = (NoteNumber*)malloc(sizeof(NoteNumber));
        noteNumber->noteNumber = nn;
        return noteNumber;
    }];
    
    _rate.init();

    // copy default dsp values
    for(int i = 0; i< AKSynthOneParameter::AKSynthOneParameterCount; i++) {
        const float value = parameterDefault((AKSynthOneParameter)i);
        if (aks1p[i].usePortamento) {
            aks1p[i].portamentoTarget = value;
            sp_port_create(&aks1p[i].portamento);
            sp_port_init(sp, aks1p[i].portamento, value);
            aks1p[i].portamento->htime = AKS1_PORTAMENTO_HALF_TIME;
        }
        p[i] = value;
    }
    _lfo1Rate = {AKSynthOneParameter::lfo1Rate, getAK1DependentParameter(lfo1Rate), getAK1Parameter(lfo1Rate),0};
    _lfo2Rate = {AKSynthOneParameter::lfo2Rate, getAK1DependentParameter(lfo2Rate), getAK1Parameter(lfo2Rate),0};
    _autoPanRate = {AKSynthOneParameter::autoPanFrequency, getAK1DependentParameter(autoPanFrequency), getAK1Parameter(autoPanFrequency),0};
    _delayTime = {AKSynthOneParameter::delayTime, getAK1DependentParameter(delayTime),getAK1Parameter(delayTime),0};

    previousProcessMonoPolyStatus = p[isMono];
    
    *phaser0->MinNotch1Freq = 100;
    *phaser0->MaxNotch1Freq = 800;
    *phaser0->Notch_width = 1000;
    *phaser0->NotchFreq = 1.5;
    *phaser0->VibratoMode = 1;
    *phaser0->depth = 1;
    *phaser0->feedback_gain = 0;
    *phaser0->invert = 0;
    *phaser0->lfobpm = 30;

    *compressorMasterL->ratio = getAK1Parameter(compressorMasterRatio);
    *compressorMasterR->ratio = getAK1Parameter(compressorMasterRatio);
    *compressorReverbInputL->ratio = getAK1Parameter(compressorReverbInputRatio);
    *compressorReverbInputR->ratio = getAK1Parameter(compressorReverbInputRatio);
    *compressorReverbWetL->ratio = getAK1Parameter(compressorReverbWetRatio);
    *compressorReverbWetR->ratio = getAK1Parameter(compressorReverbWetRatio);
    *compressorMasterL->thresh = getAK1Parameter(compressorMasterThreshold);
    *compressorMasterR->thresh = getAK1Parameter(compressorMasterThreshold);
    *compressorReverbInputL->thresh = getAK1Parameter(compressorReverbInputThreshold);
    *compressorReverbInputR->thresh = getAK1Parameter(compressorReverbInputThreshold);
    *compressorReverbWetL->thresh = getAK1Parameter(compressorReverbWetThreshold);
    *compressorReverbWetR->thresh = getAK1Parameter(compressorReverbWetThreshold);
    *compressorMasterL->atk = getAK1Parameter(compressorMasterAttack);
    *compressorMasterR->atk = getAK1Parameter(compressorMasterAttack);
    *compressorReverbInputL->atk = getAK1Parameter(compressorReverbInputAttack);
    *compressorReverbInputR->atk = getAK1Parameter(compressorReverbInputAttack);
    *compressorReverbWetL->atk = getAK1Parameter(compressorReverbWetAttack);
    *compressorReverbWetR->atk = getAK1Parameter(compressorReverbWetAttack);
    *compressorMasterL->rel = getAK1Parameter(compressorMasterRelease);
    *compressorMasterR->rel = getAK1Parameter(compressorMasterRelease);
    *compressorReverbInputL->rel = getAK1Parameter(compressorReverbInputRelease);
    *compressorReverbInputR->rel = getAK1Parameter(compressorReverbInputRelease);
    *compressorReverbWetL->rel = getAK1Parameter(compressorReverbWetRelease);
    *compressorReverbWetR->rel = getAK1Parameter(compressorReverbWetRelease);

    loPassInputDelayL->freq = getAK1Parameter(cutoff);
    loPassInputDelayL->res = getAK1Parameter(delayInputResonance);
    loPassInputDelayR->freq = getAK1Parameter(cutoff);
    loPassInputDelayR->res = getAK1Parameter(delayInputResonance);

    // Reserve arp note cache to reduce possibility of reallocation on audio thread.
    arpSeqNotes.reserve(maxArpSeqNotes);
    arpSeqNotes2.reserve(maxArpSeqNotes);
    arpSeqLastNotes.resize(maxArpSeqNotes);
    
    // initializeNoteStates() must be called AFTER init returns, BEFORE process, turnOnKey, and turnOffKey
}

void AKSynthOneDSPKernel::destroy() {
    for(int i = 0; i< AKSynthOneParameter::AKSynthOneParameterCount; i++) {
        if (aks1p[i].usePortamento) {
            sp_port_destroy(&aks1p[i].portamento);
        }
    }
    sp_port_destroy(&monoFrequencyPort);

    sp_ftbl_destroy(&sine);
    sp_phasor_destroy(&lfo1Phasor);
    sp_phasor_destroy(&lfo2Phasor);
    sp_phaser_destroy(&phaser0);
    sp_osc_destroy(&panOscillator);
    sp_pan2_destroy(&pan);
    sp_moogladder_destroy(&loPassInputDelayL);
    sp_moogladder_destroy(&loPassInputDelayR);
    sp_vdelay_destroy(&delayL);
    sp_vdelay_destroy(&delayR);
    sp_vdelay_destroy(&delayRR);
    sp_vdelay_destroy(&delayFillIn);
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
    if (initializedNoteStates == false) {
        initializedNoteStates = true;
        // POLY INIT
        for (int i = 0; i < AKS1_MAX_POLYPHONY; i++) {
            AKS1NoteState& state = noteStates[i];
            state.kernel = this;
            state.init();
            state.stage = AKS1NoteState::stageOff;
            state.internalGate = 0;
            state.rootNoteNumber = -1;
        }
        
        // MONO INIT
        monoNote->kernel = this;
        monoNote->init();
        monoNote->stage = AKS1NoteState::stageOff;
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

// algebraic taper and inverse for input range [0,1]
inline float AKSynthOneDSPKernel::taper01(float inputValue01, float taper) {
    return powf(inputValue01, 1.f / taper);
}
inline float AKSynthOneDSPKernel::taper01Inverse(float inputValue01, float taper) {
    return powf(inputValue01, taper);
}

// algebraic and exponential taper and inverse generalized for all ranges
inline float AKSynthOneDSPKernel::taper(float inputValue01, float min, float max, float taper) {
    if ( (min == 0.f || max == 0.f) && (taper < 0.f) ) {
        printf("can have a negative taper with a range that includes 0\n");
        return min;
    }
    
    if (taper > 0.f) {
        // algebraic taper
        return powf((inputValue01 - min )/(max - min), 1.f / taper);
    } else {
        // exponential taper
        return min * expf(logf(max/min) * inputValue01);
    }
}

inline float AKSynthOneDSPKernel::taperInverse(float inputValue01, float min, float max, float taper) {
    if ((min == 0.f || max == 0.f) && taper < 0.f) {
        printf("can have a negative taper with a range that includes 0\n");
        return min;
    }
    
    // Avoiding division by zero in this trivial case
    if ((max - min) < FLT_EPSILON) {
        return min;
    }
    
    if (taper > 0.f) {
        // algebraic taper
        return min + (max - min) * pow(inputValue01, taper);
    } else {
        // exponential taper
        float adjustedMinimum = 0.0;
        float adjustedMaximum = 0.0;
        if (min == 0.f) { adjustedMinimum = FLT_EPSILON; }
        if (max == 0.f) { adjustedMaximum = FLT_EPSILON; }
        return logf(inputValue01 / adjustedMinimum) / logf(adjustedMaximum / adjustedMinimum);
    }
}

float AKSynthOneDSPKernel::getAK1Parameter(AKSynthOneParameter param) {
    AKS1Param& s = aks1p[param];
    if (s.usePortamento)
        return s.portamentoTarget;
    else
        return p[param];
}

inline void AKSynthOneDSPKernel::_setAK1Parameter(AKSynthOneParameter param, float inputValue) {
    const float value = parameterClamp(param, inputValue);
    AKS1Param& s = aks1p[param];
    if (s.usePortamento) {
        s.portamentoTarget = value;
    } else {
        p[param] = value;
    }
}

void AKSynthOneDSPKernel::setAK1Parameter(AKSynthOneParameter param, float inputValue) {
    _setAK1ParameterHelper(param, inputValue, true, 0);
}

inline void AKSynthOneDSPKernel::_rateHelper(AKSynthOneParameter param, float inputValue, bool notifyMainThread, int payload) {
    
    // pitchbend
    if (param == pitchbend) {
        const float val = parameterClamp(param, inputValue);
        const float val01 = (val - parameterMin(pitchbend)) / (parameterMax(pitchbend) - parameterMin(pitchbend));
        _pitchbend = {param, val01, val, payload};
        _setAK1Parameter(param, val);
        if (notifyMainThread) {
            dependentParameterDidChange(_pitchbend);
        }
        return;
    }
    
    if (p[tempoSyncToArpRate] > 0.f) {
        // tempo sync
        if (param == lfo1Rate || param == lfo2Rate || param == autoPanFrequency) {
            const float value = parameterClamp(param, inputValue);
            AKS1RateArgs syncdValue = _rate.nearestFrequency(value, p[arpRate], parameterMin(param), parameterMax(param));
            _setAK1Parameter(param, syncdValue.value);
            DependentParam outputDP = {AKSynthOneParameter::AKSynthOneParameterCount, 0.f, 0.f, 0};
            switch(param) {
                case lfo1Rate:
                    outputDP = _lfo1Rate = {param, syncdValue.value01, syncdValue.value, payload};
                    break;
                case lfo2Rate:
                    outputDP = _lfo2Rate = {param, syncdValue.value01, syncdValue.value, payload};
                    break;
                case autoPanFrequency:
                    outputDP = _autoPanRate = {param, syncdValue.value01, syncdValue.value, payload};
                    break;
                default:
                    break;
            }
            if (notifyMainThread) {
                dependentParameterDidChange(outputDP);
            }
        } else if (param == delayTime) {
            const float value = parameterClamp(param, inputValue);
            AKS1RateArgs syncdValue = _rate.nearestTime(value, p[arpRate], parameterMin(param), parameterMax(param));
            _setAK1Parameter(param, syncdValue.value);
            _delayTime = {param, 1.f - syncdValue.value01, syncdValue.value, payload};
            DependentParam outputDP = _delayTime;
            if (notifyMainThread) {
                dependentParameterDidChange(outputDP);
            }
        }
    } else {
        // no tempo sync
        _setAK1Parameter(param, inputValue);
        const float val = p[param];
        const float min = parameterMin(param);
        const float max = parameterMax(param);
        const float val01 = clamp((val - min) / (max - min), 0.f, 1.f);
        if (param == lfo1Rate || param == lfo2Rate || param == autoPanFrequency || param == delayTime) {
            DependentParam outputDP = {AKSynthOneParameter::AKSynthOneParameterCount, 0.f, 0.f, 0};
            switch(param) {
                case lfo1Rate:
                    outputDP = _lfo1Rate = {param, val01, val, payload};
                    break;
                case lfo2Rate:
                    outputDP = _lfo2Rate = {param, val01, val, payload};
                    break;
                case autoPanFrequency:
                    outputDP = _autoPanRate = {param, val01, val, payload};
                    break;
                case delayTime:
                    outputDP = _delayTime = {param, val01, val, payload};
                    break;
                default:
                    break;
            }
            if (notifyMainThread) {
                outputDP = {param, taper01Inverse(outputDP.value01, AKS1_DEPENDENT_PARAM_TAPER), outputDP.value};
                dependentParameterDidChange(outputDP);
            }
        }
    }
}

inline void AKSynthOneDSPKernel::_setAK1ParameterHelper(AKSynthOneParameter param, float inputValue, bool notifyMainThread, int payload) {
    if (param == tempoSyncToArpRate || param == arpRate) {
        _setAK1Parameter(param, inputValue);
        _rateHelper(lfo1Rate, getAK1Parameter(lfo1Rate), notifyMainThread, payload);
        _rateHelper(lfo2Rate, getAK1Parameter(lfo2Rate), notifyMainThread, payload);
        _rateHelper(autoPanFrequency, getAK1Parameter(autoPanFrequency), notifyMainThread, payload);
        _rateHelper(delayTime, getAK1Parameter(delayTime), notifyMainThread, payload);
    } else if (param == lfo1Rate || param == lfo2Rate || param == autoPanFrequency || param == delayTime) {
        // dependent params
        _rateHelper(param, inputValue, notifyMainThread, payload);
    } else if (param == pitchbend) {
        _rateHelper(param, inputValue, notifyMainThread, payload);
    } else {
        // independent params
        _setAK1Parameter(param, inputValue);
    }
}

float AKSynthOneDSPKernel::getAK1DependentParameter(AKSynthOneParameter param) {

    if (param == pitchbend) {
        return _pitchbend.value;
    }

    DependentParam dp;
    switch(param) {
        case lfo1Rate: dp = _lfo1Rate; break;
        case lfo2Rate: dp = _lfo2Rate; break;
        case autoPanFrequency: dp = _autoPanRate; break;
        case delayTime: dp = _delayTime; break;
        default:printf("error\n");break;
    }
    
    if (p[tempoSyncToArpRate] > 0.f) {
        return dp.value01;
    } else {
        return taper01Inverse(dp.value01, AKS1_DEPENDENT_PARAM_TAPER);
    }
}

// map normalized input to parameter range
void AKSynthOneDSPKernel::setAK1DependentParameter(AKSynthOneParameter param, float inputValue01, int payload) {
    const bool notify = true;
    switch(param) {
        case lfo1Rate: case lfo2Rate: case autoPanFrequency:
            if (p[tempoSyncToArpRate] > 0.f) {
                // tempo sync
                AKSynthOneRate rate = _rate.rateFromFrequency01(inputValue01);
                const float val = _rate.frequency(getAK1Parameter(arpRate), rate);
                _setAK1ParameterHelper(param, val, notify, payload);
            } else {
                // no tempo sync
                const float min = parameterMin(param);
                const float max = parameterMax(param);
                const float taperValue01 = taper01(inputValue01, AKS1_DEPENDENT_PARAM_TAPER);
                const float val = min + taperValue01 * (max - min);
                _setAK1ParameterHelper(param, val, notify, payload);
            }
            break;
        case delayTime:
            if (p[tempoSyncToArpRate] > 0.f) {
                // tempo sync
                const float valInvert = 1.f - inputValue01;
                AKSynthOneRate rate = _rate.rateFromTime01(valInvert);
                const float val = _rate.time(p[arpRate], rate);
                _setAK1ParameterHelper(delayTime, val, notify, payload);
            } else {
                // no tempo sync
                const float min = parameterMin(delayTime);
                const float max = parameterMax(delayTime);
                const float taperValue01 = taper01(inputValue01, AKS1_DEPENDENT_PARAM_TAPER);
                const float val = min + taperValue01 * (max - min);
                _setAK1ParameterHelper(delayTime, val, notify, payload);
            }
            break;
        case pitchbend:
        {
            const float min = parameterMin(param);
            const float max = parameterMax(param);
            const float val = min + inputValue01 * (max - min);
            _setAK1ParameterHelper(pitchbend, val, notify, payload);
        }
            break;
        default:
            printf("error\n");
            break;
    }
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
