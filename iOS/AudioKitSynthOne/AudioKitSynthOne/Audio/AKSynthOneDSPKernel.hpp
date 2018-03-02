//
//  AKSynthOneDSPKernel.hpp
//  AudioKit
//
//  Created by Aurelius Prochazka, revision history on Github.
//  Copyright © 2017 Aurelius Prochazka. All rights reserved.
//
//  20170926: Super HD refactor by Marcus Hobbs

#pragma once

#import <vector>
#import <list>
#include <string>

#import "AKSoundpipeKernel.hpp"
#import "AKSynthOneAudioUnit.h"
#import "AKSynthOneParameter.h"

@class AEArray;
@class AEMessageQueue;

#define MAX_POLYPHONY (6)
#define NUM_MIDI_NOTES (128)
#define FTABLE_SIZE (4096)
#define NUM_FTABLES (4)

#ifdef __cplusplus

class AKSynthOneDSPKernel : public AKSoundpipeKernel, public AKOutputBuffered {
    
public:

    // MARK: AKSynthOneDSPKernel Member Functions
    
    AKSynthOneDSPKernel();
    
    ~AKSynthOneDSPKernel();

    void setAK1Parameter(AKSynthOneParameter param, float inputValue);
    
    float getAK1Parameter(AKSynthOneParameter param);

    // AUParameter/AUValue
    void setParameters(float params[]);
    
    void setParameter(AUParameterAddress address, AUValue value);
    
    AUValue getParameter(AUParameterAddress address);
    
    void startRamp(AUParameterAddress address, AUValue value, AUAudioFrameCount duration) override;
    
    void print_debug();
    
    ///panic...hard-resets DSP.  artifacts.
    void resetDSP();
    
    ///puts all notes in release mode...no artifacts
    void stopAllNotes();
    
    void handleTempoSetting(float currentTempo);
    
    ///can be called from within the render loop
    void beatCounterDidChange();
    
    ///can be called from within the render loop
    void playingNotesDidChange();
    
    ///can be called from within the render loop
    void heldNotesDidChange();
    
    ///PROCESS
    void process(AUAudioFrameCount frameCount, AUAudioFrameCount bufferOffset) override;
    
    // turnOnKey is called by render thread in "process", so access note via AEArray
    void turnOnKey(int noteNumber, int velocity);
    
    // turnOnKey is called by render thread in "process", so access note via AEArray
    void turnOnKey(int noteNumber, int velocity, float frequency);
    
    // turnOffKey is called by render thread in "process", so access note via AEArray
    void turnOffKey(int noteNumber);
    
    // NOTE ON
    // startNote is not called by render thread, but turnOnKey is
    void startNote(int noteNumber, int velocity);
    
    // NOTE ON
    // startNote is not called by render thread, but turnOnKey is
    void startNote(int noteNumber, int velocity, float frequency);
    
    // NOTE OFF...put into release mode
    void stopNote(int noteNumber);
    
    /// Puts all notes in release mode
    void reset();
    
    /// Sets beatcounter to 0 and clears sequence
    void resetSequencer();
    
    // MIDI
    virtual void handleMIDIEvent(AUMIDIEvent const& midiEvent) override;
    
    void init(int _channels, double _sampleRate) override;
    
    void destroy();
    
    // initializeNoteStates() must be called AFTER init returns
    void initializeNoteStates();
    
    void setupWaveform(uint32_t waveform, uint32_t size);
    
    void setWaveformValue(uint32_t waveform, uint32_t index, float value);
    
    ///parameter min
    float parameterMin(AKSynthOneParameter i);
    
    ///parameter max
    float parameterMax(AKSynthOneParameter i);
    
    ///parameter defaults
    float parameterDefault(AKSynthOneParameter i);
    
    ///parameter unit
    AudioUnitParameterUnit parameterUnit(AKSynthOneParameter i);
    
    ///parameter clamp
    float parameterClamp(AKSynthOneParameter i, float inputValue);

    ///friendly description of parameter
    std::string parameterFriendlyName(AKSynthOneParameter i);
    
    ///C string friendly description of parameter
    const char* parameterCStr(AKSynthOneParameter i);

    ///parameter presetKey
    std::string parameterPresetKey(AKSynthOneParameter i);

    // MARK: Member Variables
public:
    
    AKSynthOneAudioUnit* audioUnit;
    
    bool resetted = false;
    
    int arpBeatCounter = 0;
    
    /// dsp params
    float p[AKSynthOneParameter::AKSynthOneParameterCount];
    
    // Portamento values
    float morphBalanceSmooth = 0.5666f;
    float detuningMultiplierSmooth = 1.f;
    float cutoffSmooth = 1666.f;
    float resonanceSmooth = 0.5f;
    float monoFrequency = 440.f * exp2((60.f - 69.f)/12.f);
    
    // phasor values
    float lfo1 = 0.f;
    float lfo2 = 0.f;
    
    // midi
    bool notesHeld = false;
    
private:
    
    struct NoteNumber;
    
    struct SeqNoteNumber;
    
    struct NoteState;
    
    struct AKS1Param {
        AKSynthOneParameter param;
        float min;
        float defaultValue;
        float max;
        std::string presetKey;
        std::string friendlyName;
        AudioUnitParameterUnit unit;
    };
    
    // array of struct NoteState of count MAX_POLYPHONY
    AKSynthOneDSPKernel::NoteState* noteStates;
    
    // monophonic: single instance of NoteState
    AKSynthOneDSPKernel::NoteState* monoNote;
    
    bool initializedNoteStates = false;
    
    // MAX_POLYPHONY is the limit of hard-coded number of simultaneous notes to render to manage computation.
    // New noteOn events will steal voices to keep this number.
    // For now "polyphony" is constant equal to MAX_POLYPHONY, but with some refactoring we could make it dynamic.
    const int polyphony = MAX_POLYPHONY;
    
    int playingNoteStatesIndex = 0;
    sp_ftbl *ft_array[NUM_FTABLES];
    UInt32 tbl_size = FTABLE_SIZE;
    sp_phasor *lfo1Phasor;
    sp_phasor *lfo2Phasor;
    sp_ftbl *sine;
    sp_bitcrush *bitcrush;
    sp_pan2 *pan;
    sp_osc *panOscillator;
    sp_phaser *phaser0;
    sp_smoothdelay *delayL;
    sp_smoothdelay *delayR;
    sp_smoothdelay *delayRR;
    sp_smoothdelay *delayFillIn;
    sp_crossfade *delayCrossfadeL;
    sp_crossfade *delayCrossfadeR;
    sp_revsc *reverbCostello;
    sp_buthp *butterworthHipassL;
    sp_buthp *butterworthHipassR;
    sp_crossfade *revCrossfadeL;
    sp_crossfade *revCrossfadeR;
    sp_compressor *compressor0;
    sp_compressor *compressor1;
    sp_port *midiNotePort;
    float midiNote = 0.f;
    float midiNoteSmooth = 0.f;
    sp_port *multiplierPort;
    sp_port *balancePort;
    sp_port *cutoffPort;
    sp_port *resonancePort;
    sp_port *monoFrequencyPort;
    float monoFrequencySmooth = 261.6255653006f;
    float tempo = 120.f;
    float previousProcessMonoPolyStatus = 0.f;
    
    // Arp/Seq
    double arpSampleCounter = 0;
    double arpTime = 0;
    int notesPerOctave = 12;
    
    ///once init'd: arpSeqNotes can be accessed and mutated only within process and resetDSP
    std::vector<SeqNoteNumber> arpSeqNotes;
    std::vector<NoteNumber> arpSeqNotes2;
    const int maxArpSeqNotes = 1024; // 128 midi note numbers * 4 arp octaves * up+down
    
    ///once init'd: arpSeqLastNotes can be accessed and mutated only within process and resetDSP
    std::list<int> arpSeqLastNotes;
    
    // Array of midi note numbers of NoteState's which have had a noteOn event but not yet a noteOff event.
    NSMutableArray<NSNumber*>* heldNoteNumbers;
    AEArray* heldNoteNumbersAE;
    
    
    //AudioUnitParameterUnit
    //    kAudioUnitParameterUnit_Generic                = 0,
    //    kAudioUnitParameterUnit_Indexed                = 1,
    //    kAudioUnitParameterUnit_Boolean                = 2,
    //    kAudioUnitParameterUnit_Percent                = 3,
    //    kAudioUnitParameterUnit_Seconds                = 4,
    //    kAudioUnitParameterUnit_SampleFrames        = 5,
    //    kAudioUnitParameterUnit_Phase                = 6,
    //    kAudioUnitParameterUnit_Rate                = 7,
    //    kAudioUnitParameterUnit_Hertz                = 8,
    //    kAudioUnitParameterUnit_Cents                = 9,
    //    kAudioUnitParameterUnit_RelativeSemiTones    = 10,
    //    kAudioUnitParameterUnit_MIDINoteNumber        = 11,
    //    kAudioUnitParameterUnit_MIDIController        = 12,
    //    kAudioUnitParameterUnit_Decibels            = 13,
    //    kAudioUnitParameterUnit_LinearGain            = 14,
    //    kAudioUnitParameterUnit_Degrees                = 15,
    //    kAudioUnitParameterUnit_EqualPowerCrossfade = 16,
    //    kAudioUnitParameterUnit_MixerFaderCurve1    = 17,
    //    kAudioUnitParameterUnit_Pan                    = 18,
    //    kAudioUnitParameterUnit_Meters                = 19,
    //    kAudioUnitParameterUnit_AbsoluteCents        = 20,
    //    kAudioUnitParameterUnit_Octaves                = 21,
    //    kAudioUnitParameterUnit_BPM                    = 22,
    //    kAudioUnitParameterUnit_Beats               = 23,
    //    kAudioUnitParameterUnit_Milliseconds        = 24,
    //    kAudioUnitParameterUnit_Ratio                = 25,
    //    kAudioUnitParameterUnit_CustomUnit            = 26

    AKS1Param aks1p[AKSynthOneParameter::AKSynthOneParameterCount] = {
//        { index1,                0, 0, 1, "index1", "Index 1", kAudioUnitParameterUnit_Generic},
//        { index2,                0, 0, 1, "index2", "Index 2", kAudioUnitParameterUnit_Generic},
        { index1,                0, 1, 1, "index1", "Index 1", kAudioUnitParameterUnit_Generic},
        { index2,                0, 1, 1, "index2", "Index 2", kAudioUnitParameterUnit_Generic},
        { morphBalance,          0, 0.5, 1, "morphBalance", "morphBalance", kAudioUnitParameterUnit_Generic},
        { morph1SemitoneOffset,  -12, 0, 12, "morph1SemitoneOffset", "morph1SemitoneOffset", kAudioUnitParameterUnit_RelativeSemiTones},
        { morph2SemitoneOffset,  -12, 0, 12, "morph2SemitoneOffset", "morph2SemitoneOffset", kAudioUnitParameterUnit_RelativeSemiTones},
        { morph1Volume,          0, 0.8, 1, "morph1Volume", "morph1Volume", kAudioUnitParameterUnit_Generic},
        { morph2Volume,          0, 0.8, 1, "morph2Volume", "morph2Volume", kAudioUnitParameterUnit_Generic},
        { subVolume,             0, 0, 1, "subVolume", "subVolume", kAudioUnitParameterUnit_Generic},
        { subOctaveDown,         0, 0, 1, "subOctaveDown", "subOctaveDown", kAudioUnitParameterUnit_Generic},
        { subIsSquare,           0, 0, 1, "subIsSquare", "subIsSquare", kAudioUnitParameterUnit_Generic},
        { fmVolume,              0, 0, 1, "fmVolume", "fmVolume", kAudioUnitParameterUnit_Generic},
        { fmAmount,              0, 0, 15, "fmAmount", "fmAmount", kAudioUnitParameterUnit_Generic},
        { noiseVolume,           0, 0, .25, "noiseVolume", "noiseVolume", kAudioUnitParameterUnit_Generic},
        { lfo1Index,             0, 0, 3, "lfo1Index", "lfo1Index", kAudioUnitParameterUnit_Generic},
        { lfo1Amplitude,         0, 0, 1, "lfo1Amplitude", "lfo1Amplitude", kAudioUnitParameterUnit_Generic},
        { lfo1Rate,              0, 0.25, 10, "lfo1Rate", "lfo1Rate", kAudioUnitParameterUnit_Rate},
        { cutoff,                256, 20000, 28000, "cutoff", "cutoff", kAudioUnitParameterUnit_Hertz},
        { resonance,             0, 0.1, 0.75, "resonance", "resonance", kAudioUnitParameterUnit_Generic},
        { filterMix,             0, 1, 1, "filterMix", "filterMix", kAudioUnitParameterUnit_Generic},
        { filterADSRMix,         0, 0, 1.2, "filterADSRMix", "filterADSRMix", kAudioUnitParameterUnit_Generic},
        { isMono,                0, 0, 1, "isMono", "isMono", kAudioUnitParameterUnit_Generic},
        { glide,                 0, 0, 0.2, "glide", "glide", kAudioUnitParameterUnit_Generic},
        { filterAttackDuration,  0.0005, 0.05, 2, "filterAttackDuration", "filterAttackDuration", kAudioUnitParameterUnit_Seconds},
        { filterDecayDuration,   0.005, 0.05, 2, "filterDecayDuration", "filterDecayDuration", kAudioUnitParameterUnit_Seconds},
        { filterSustainLevel,    0, 1, 1, "filterSustainLevel", "filterSustainLevel", kAudioUnitParameterUnit_Generic},
        { filterReleaseDuration, 0, 0.5, 2, "filterReleaseDuration", "filterReleaseDuration", kAudioUnitParameterUnit_Seconds},
        { attackDuration,        0.0005, 0.05, 2, "attackDuration", "attackDuration", kAudioUnitParameterUnit_Seconds},
        { decayDuration,         0, 0.005, 2, "decayDuration", "decayDuration", kAudioUnitParameterUnit_Seconds},
        { sustainLevel,          0, 0.8, 1, "sustainLevel", "sustainLevel", kAudioUnitParameterUnit_Generic},
        { releaseDuration,       0.004, 0.05, 2, "releaseDuration", "releaseDuration", kAudioUnitParameterUnit_Seconds},
        { morph2Detuning,        -4, 0, 4, "morph2Detuning", "morph2Detuning", kAudioUnitParameterUnit_Generic},
        { detuningMultiplier,    1, 1, 2, "detuningMultiplier", "detuningMultiplier", kAudioUnitParameterUnit_Generic},
        { masterVolume,          0, 0.5, 2, "masterVolume", "masterVolume", kAudioUnitParameterUnit_Generic},
        { bitCrushDepth,         1, 24, 24, "bitCrushDepth", "bitCrushDepth", kAudioUnitParameterUnit_Generic},
        { bitCrushSampleRate,    4096, 44100, 44100, "bitCrushSampleRate", "bitCrushSampleRate", kAudioUnitParameterUnit_Hertz},
        { autoPanAmount,         0, 0, 1, "autoPanAmount", "autoPanAmount", kAudioUnitParameterUnit_Generic},
        { autoPanFrequency,      0, 0.25, 10, "autoPanFrequency", "autoPanFrequency", kAudioUnitParameterUnit_Hertz},
        { reverbOn,              0, 1, 1, "reverbOn", "reverbOn", kAudioUnitParameterUnit_Generic},
        { reverbFeedback,        0, 0.5, 1, "reverbFeedback", "reverbFeedback", kAudioUnitParameterUnit_Generic},
        { reverbHighPass,        80, 700, 900, "reverbHighPass", "reverbHighPass", kAudioUnitParameterUnit_Generic},
        { reverbMix,             0, 0, 1, "reverbMix", "reverbMix", kAudioUnitParameterUnit_Generic},
        { delayOn,               0, 0, 1, "delayOn", "delayOn", kAudioUnitParameterUnit_Generic},
        { delayFeedback,         0, 0.1, 0.9, "delayFeedback", "delayFeedback", kAudioUnitParameterUnit_Generic},
        { delayTime,             0.1, 0.5, 1.5, "delayTime", "delayTime", kAudioUnitParameterUnit_Seconds},
        { delayMix,              0, 0.125, 1, "delayMix", "delayMix", kAudioUnitParameterUnit_Generic},
        { lfo2Index,             0, 0, 3, "lfo2Index", "lfo2Index", kAudioUnitParameterUnit_Generic},
        { lfo2Amplitude,         0, 0, 1, "lfo2Amplitude", "lfo2Amplitude", kAudioUnitParameterUnit_Generic},
        { lfo2Rate,              0, 0.25, 10, "lfo2Rate", "lfo2Rate", kAudioUnitParameterUnit_Generic},
        { cutoffLFO,             0, 0, 3, "cutoffLFO", "cutoffLFO", kAudioUnitParameterUnit_Generic},
        { resonanceLFO,          0, 0, 3, "resonanceLFO", "resonanceLFO", kAudioUnitParameterUnit_Generic},
        { oscMixLFO,             0, 0, 3, "oscMixLFO", "oscMixLFO", kAudioUnitParameterUnit_Generic},
        { sustainLFO,            0, 0, 3, "sustainLFO", "sustainLFO", kAudioUnitParameterUnit_Generic},
        { decayLFO,              0, 0, 3, "decayLFO", "decayLFO", kAudioUnitParameterUnit_Generic},
        { noiseLFO,              0, 0, 3, "noiseLFO", "noiseLFO", kAudioUnitParameterUnit_Generic},
        { fmLFO,                 0, 0, 3, "fmLFO", "fmLFO", kAudioUnitParameterUnit_Generic},
        { detuneLFO,             0, 0, 3, "detuneLFO", "detuneLFO", kAudioUnitParameterUnit_Generic},
        { filterEnvLFO,          0, 0, 3, "filterEnvLFO", "filterEnvLFO", kAudioUnitParameterUnit_Generic},
        { pitchLFO,              0, 0, 3, "pitchLFO", "pitchLFO", kAudioUnitParameterUnit_Generic},
        { bitcrushLFO,           0, 0, 3, "bitcrushLFO", "bitcrushLFO", kAudioUnitParameterUnit_Generic},
        { autopanLFO,            0, 0, 3, "autopanLFO", "autopanLFO", kAudioUnitParameterUnit_Generic},
        { arpDirection,          0, 1, 2, "arpDirection", "arpDirection", kAudioUnitParameterUnit_Generic},
        { arpInterval,           0, 12, 12, "arpInterval", "arpInterval", kAudioUnitParameterUnit_Generic},
        { arpIsOn,               0, 0, 1, "arpIsOn", "arpIsOn", kAudioUnitParameterUnit_Generic},
        { arpOctave,             0, 1, 3, "arpOctave", "arpOctave", kAudioUnitParameterUnit_Generic},
        { arpRate,               1, 64, 256, "arpRate", "arpRate", kAudioUnitParameterUnit_BPM},
        { arpIsSequencer,        0, 0, 1, "arpIsSequencer", "arpIsSequencer", kAudioUnitParameterUnit_Generic},
        { arpTotalSteps,         1, 4, 16, "arpTotalSteps", "arpTotalSteps" , kAudioUnitParameterUnit_Generic},
        { arpSeqPattern00,       -24, 0, 24, "arpSeqPattern00", "arpSeqPattern00" , kAudioUnitParameterUnit_Generic},
        { arpSeqPattern01,       -24, 0, 24, "arpSeqPattern01", "arpSeqPattern01" , kAudioUnitParameterUnit_Generic},
        { arpSeqPattern02,       -24, 0, 24, "arpSeqPattern02", "arpSeqPattern02" , kAudioUnitParameterUnit_Generic},
        { arpSeqPattern03,       -24, 0, 24, "arpSeqPattern03", "arpSeqPattern03" , kAudioUnitParameterUnit_Generic},
        { arpSeqPattern04,       -24, 0, 24, "arpSeqPattern04", "arpSeqPattern04" , kAudioUnitParameterUnit_Generic},
        { arpSeqPattern05,       -24, 0, 24, "arpSeqPattern05", "arpSeqPattern05" , kAudioUnitParameterUnit_Generic},
        { arpSeqPattern06,       -24, 0, 24, "arpSeqPattern06", "arpSeqPattern06" , kAudioUnitParameterUnit_Generic},
        { arpSeqPattern07,       -24, 0, 24, "arpSeqPattern07", "arpSeqPattern07" , kAudioUnitParameterUnit_Generic},
        { arpSeqPattern08,       -24, 0, 24, "arpSeqPattern08", "arpSeqPattern08" , kAudioUnitParameterUnit_Generic},
        { arpSeqPattern09,       -24, 0, 24, "arpSeqPattern09", "arpSeqPattern09" , kAudioUnitParameterUnit_Generic},
        { arpSeqPattern10,       -24, 0, 24, "arpSeqPattern10", "arpSeqPattern10" , kAudioUnitParameterUnit_Generic},
        { arpSeqPattern11,       -24, 0, 24, "arpSeqPattern11", "arpSeqPattern11" , kAudioUnitParameterUnit_Generic},
        { arpSeqPattern12,       -24, 0, 24, "arpSeqPattern12", "arpSeqPattern12" , kAudioUnitParameterUnit_Generic},
        { arpSeqPattern13,       -24, 0, 24, "arpSeqPattern13", "arpSeqPattern13" , kAudioUnitParameterUnit_Generic},
        { arpSeqPattern14,       -24, 0, 24, "arpSeqPattern14", "arpSeqPattern14" , kAudioUnitParameterUnit_Generic},
        { arpSeqPattern15,       -24, 0, 24, "arpSeqPattern15", "arpSeqPattern15" , kAudioUnitParameterUnit_Generic},
        { arpSeqOctBoost00,      0, 0, 1, "arpSeqOctBoost00", "arpSeqOctBoost00" , kAudioUnitParameterUnit_Generic},
        { arpSeqOctBoost01,      0, 0, 1, "arpSeqOctBoost01", "arpSeqOctBoost01" , kAudioUnitParameterUnit_Generic},
        { arpSeqOctBoost02,      0, 0, 1, "arpSeqOctBoost02", "arpSeqOctBoost02" , kAudioUnitParameterUnit_Generic},
        { arpSeqOctBoost03,      0, 0, 1, "arpSeqOctBoost03", "arpSeqOctBoost03" , kAudioUnitParameterUnit_Generic},
        { arpSeqOctBoost04,      0, 0, 1, "arpSeqOctBoost04", "arpSeqOctBoost04" , kAudioUnitParameterUnit_Generic},
        { arpSeqOctBoost05,      0, 0, 1, "arpSeqOctBoost05", "arpSeqOctBoost05" , kAudioUnitParameterUnit_Generic},
        { arpSeqOctBoost06,      0, 0, 1, "arpSeqOctBoost06", "arpSeqOctBoost06" , kAudioUnitParameterUnit_Generic},
        { arpSeqOctBoost07,      0, 0, 1, "arpSeqOctBoost07", "arpSeqOctBoost07" , kAudioUnitParameterUnit_Generic},
        { arpSeqOctBoost08,      0, 0, 1, "arpSeqOctBoost08", "arpSeqOctBoost08" , kAudioUnitParameterUnit_Generic},
        { arpSeqOctBoost09,      0, 0, 1, "arpSeqOctBoost09", "arpSeqOctBoost09" , kAudioUnitParameterUnit_Generic},
        { arpSeqOctBoost10,      0, 0, 1, "arpSeqOctBoost10", "arpSeqOctBoost10" , kAudioUnitParameterUnit_Generic},
        { arpSeqOctBoost11,      0, 0, 1, "arpSeqOctBoost11", "arpSeqOctBoost11" , kAudioUnitParameterUnit_Generic},
        { arpSeqOctBoost12,      0, 0, 1, "arpSeqOctBoost12", "arpSeqOctBoost12" , kAudioUnitParameterUnit_Generic},
        { arpSeqOctBoost13,      0, 0, 1, "arpSeqOctBoost13", "arpSeqOctBoost13" , kAudioUnitParameterUnit_Generic},
        { arpSeqOctBoost14,      0, 0, 1, "arpSeqOctBoost14", "arpSeqOctBoost14" , kAudioUnitParameterUnit_Generic},
        { arpSeqOctBoost15,      0, 0, 1, "arpSeqOctBoost15", "arpSeqOctBoost15" , kAudioUnitParameterUnit_Generic},
        { arpSeqNoteOn00,        0, 0, 1, "arpSeqNoteOn00", "arpSeqNoteOn00" , kAudioUnitParameterUnit_Generic},
        { arpSeqNoteOn01,        0, 0, 1, "arpSeqNoteOn01", "arpSeqNoteOn01" , kAudioUnitParameterUnit_Generic},
        { arpSeqNoteOn02,        0, 0, 1, "arpSeqNoteOn02", "arpSeqNoteOn02" , kAudioUnitParameterUnit_Generic},
        { arpSeqNoteOn03,        0, 0, 1, "arpSeqNoteOn03", "arpSeqNoteOn03" , kAudioUnitParameterUnit_Generic},
        { arpSeqNoteOn04,        0, 0, 1, "arpSeqNoteOn04", "arpSeqNoteOn04" , kAudioUnitParameterUnit_Generic},
        { arpSeqNoteOn05,        0, 0, 1, "arpSeqNoteOn05", "arpSeqNoteOn05" , kAudioUnitParameterUnit_Generic},
        { arpSeqNoteOn06,        0, 0, 1, "arpSeqNoteOn06", "arpSeqNoteOn06" , kAudioUnitParameterUnit_Generic},
        { arpSeqNoteOn07,        0, 0, 1, "arpSeqNoteOn07", "arpSeqNoteOn07" , kAudioUnitParameterUnit_Generic},
        { arpSeqNoteOn08,        0, 0, 1, "arpSeqNoteOn08", "arpSeqNoteOn08" , kAudioUnitParameterUnit_Generic},
        { arpSeqNoteOn09,        0, 0, 1, "arpSeqNoteOn09", "arpSeqNoteOn09" , kAudioUnitParameterUnit_Generic},
        { arpSeqNoteOn10,        0, 0, 1, "arpSeqNoteOn10", "arpSeqNoteOn10" , kAudioUnitParameterUnit_Generic},
        { arpSeqNoteOn11,        0, 0, 1, "arpSeqNoteOn11", "arpSeqNoteOn11" , kAudioUnitParameterUnit_Generic},
        { arpSeqNoteOn12,        0, 0, 1, "arpSeqNoteOn12", "arpSeqNoteOn12" , kAudioUnitParameterUnit_Generic},
        { arpSeqNoteOn13,        0, 0, 1, "arpSeqNoteOn13", "arpSeqNoteOn13" , kAudioUnitParameterUnit_Generic},
        { arpSeqNoteOn14,        0, 0, 1, "arpSeqNoteOn14", "arpSeqNoteOn14" , kAudioUnitParameterUnit_Generic},
        { arpSeqNoteOn15,        0, 0, 1, "arpSeqNoteOn15", "arpSeqNoteOn15" , kAudioUnitParameterUnit_Generic},
        { filterType,            0, 0, 2, "filterType", "filterType" , kAudioUnitParameterUnit_Generic},
        { phaserMix,             0, 0, 1, "phaserMix", "phaserMix" , kAudioUnitParameterUnit_Generic},
        { phaserRate,            12, 12, 300, "phaserRate", "phaserRate" , kAudioUnitParameterUnit_Hertz},
        { phaserFeedback,        0, 0.0, 0.8, "phaserFeedback", "phaserFeedback" , kAudioUnitParameterUnit_Generic},
        { phaserNotchWidth,      100, 800, 1000, "phaserNotchWidth", "phaserNotchWidth" , kAudioUnitParameterUnit_Hertz},
        { monoIsLegato,          0, 0, 1, "monoIsLegato", "monoIsLegato" , kAudioUnitParameterUnit_Generic}
    };
};
#endif
