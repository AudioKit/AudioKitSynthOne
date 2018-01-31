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
#import "AKSoundPipeKernel.hpp"
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
    float monoFrequencySmooth = 261.f;
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
    
    AKS1Param aks1p[AKSynthOneParameter::AKSynthOneParameterCount] = {
//        { index1,                0, 0, 1, "index1", "Index 1"},
//        { index2,                0, 0, 1, "index2", "Index 2"},
        { index1,                0, 1, 1, "index1", "Index 1"},
        { index2,                0, 1, 1, "index2", "Index 2"},
        { morphBalance,          0, 0.5, 1, "morphBalance", "morphBalance" },
        { morph1SemitoneOffset,  -12, 0, 12, "morph1SemitoneOffset", "morph1SemitoneOffset" },
        { morph2SemitoneOffset,  -12, 0, 12, "morph2SemitoneOffset", "morph2SemitoneOffset" },
        { morph1Volume,          0, 0.8, 1, "morph1Volume", "morph1Volume" },
        { morph2Volume,          0, 0.8, 1, "morph2Volume", "morph2Volume" },
        { subVolume,             0, 0, 1, "subVolume", "subVolume" },
        { subOctaveDown,         0, 0, 1, "subOctaveDown", "subOctaveDown" },
        { subIsSquare,           0, 0, 1, "subIsSquare", "subIsSquare" },
        { fmVolume,              0, 0, 1, "fmVolume", "fmVolume" },
        { fmAmount,              0, 0, 15, "fmAmount", "fmAmount" },
        { noiseVolume,           0, 0, .25, "noiseVolume", "noiseVolume" },
        { lfo1Index,             0, 0, 3, "lfo1Index", "lfo1Index" },
        { lfo1Amplitude,         0, 0, 1, "lfo1Amplitude", "lfo1Amplitude" },
        { lfo1Rate,              0, 0.25, 10, "lfo1Rate", "lfo1Rate" },
//        { cutoff,                256, 2000, 28000, "cutoff", "cutoff" },
        { cutoff,                256, 20000, 28000, "cutoff", "cutoff" },
        { resonance,             0, 0.1, 0.75, "resonance", "resonance" },
        { filterMix,             0, 1, 1, "filterMix", "filterMix" },
        { filterADSRMix,         0, 0, 1.2, "filterADSRMix", "filterADSRMix" },
        { isMono,                0, 0, 1, "isMono", "isMono" },
        { glide,                 0, 0, 0.2, "glide", "glide" },
        { filterAttackDuration,  0.0005, 0.05, 2, "filterAttackDuration", "filterAttackDuration" },
        { filterDecayDuration,   0.005, 0.05, 2, "filterDecayDuration", "filterDecayDuration" },
        { filterSustainLevel,    0, 1, 1, "filterSustainLevel", "filterSustainLevel" },
        { filterReleaseDuration, 0, 0.5, 2, "filterReleaseDuration", "filterReleaseDuration" },
        { attackDuration,        0.0005, 0.05, 2, "attackDuration", "attackDuration" },
        { decayDuration,         0, 0.005, 2, "decayDuration", "decayDuration" },
        { sustainLevel,          0, 0.8, 1, "sustainLevel", "sustainLevel" },
        { releaseDuration,       0.004, 0.05, 2, "releaseDuration", "releaseDuration" },
        { morph2Detuning,        -4, 0, 4, "morph2Detuning", "morph2Detuning" },
        { detuningMultiplier,    1, 1, 2, "detuningMultiplier", "detuningMultiplier" },
        { masterVolume,          0, 0.5, 2, "masterVolume", "masterVolume" },//
        { bitCrushDepth,         1, 24, 24, "bitCrushDepth", "bitCrushDepth" },
        { bitCrushSampleRate,    4096, 44100, 44100, "bitCrushSampleRate", "bitCrushSampleRate" },
        { autoPanAmount,         0, 0, 1, "autoPanAmount", "autoPanAmount" },
        { autoPanFrequency,      0, 0.25, 10, "autoPanFrequency", "autoPanFrequency" },
        { reverbOn,              0, 1, 1, "reverbOn", "reverbOn" },
        { reverbFeedback,        0, 0.5, 1, "reverbFeedback", "reverbFeedback" },
        { reverbHighPass,        80, 700, 900, "reverbHighPass", "reverbHighPass" },
        { reverbMix,             0, 0, 1, "reverbMix", "reverbMix" },
        { delayOn,               0, 0, 1, "delayOn", "delayOn" },
        { delayFeedback,         0, 0.1, 0.9, "delayFeedback", "delayFeedback" },
        { delayTime,             0.1, 0.5, 1.5, "delayTime", "delayTime" },
        { delayMix,              0, 0.125, 1, "delayMix", "delayMix" },
        { lfo2Index,             0, 0, 3, "lfo2Index", "lfo2Index" },
        { lfo2Amplitude,         0, 0, 1, "lfo2Amplitude", "lfo2Amplitude" },
        { lfo2Rate,              0, 0.25, 10, "lfo2Rate", "lfo2Rate" },
        { cutoffLFO,             0, 0, 2, "cutoffLFO", "cutoffLFO" },
        { resonanceLFO,          0, 0, 2, "resonanceLFO", "resonanceLFO" },
        { oscMixLFO,             0, 0, 2, "oscMixLFO", "oscMixLFO" },
        { sustainLFO,            0, 0, 2, "sustainLFO", "sustainLFO" },
        { decayLFO,              0, 0, 2, "decayLFO", "decayLFO" },
        { noiseLFO,              0, 0, 2, "noiseLFO", "noiseLFO" },
        { fmLFO,                 0, 0, 2, "fmLFO", "fmLFO" },
        { detuneLFO,             0, 0, 2, "detuneLFO", "detuneLFO" },
        { filterEnvLFO,          0, 0, 2, "filterEnvLFO", "filterEnvLFO" },
        { pitchLFO,              0, 0, 2, "pitchLFO", "pitchLFO" },
        { bitcrushLFO,           0, 0, 2, "bitcrushLFO", "bitcrushLFO" },
        { autopanLFO,            0, 0, 2, "autopanLFO", "autopanLFO" },
        { arpDirection,          0, 1, 2, "arpDirection", "arpDirection" },
        { arpInterval,           0, 12, 12, "arpInterval", "arpInterval" },
        { arpIsOn,               0, 0, 1, "arpIsOn", "arpIsOn" },
        { arpOctave,             0, 1, 3, "arpOctave", "arpOctave" },
        { arpRate,               1, 64, 256, "arpRate", "arpRate" },
        { arpIsSequencer,        0, 0, 1, "arpIsSequencer", "arpIsSequencer" },
        { arpTotalSteps,         1, 4, 16, "arpTotalSteps", "arpTotalSteps" },
        { arpSeqPattern00,       -24, 0, 24, "arpSeqPattern00", "arpSeqPattern00" },
        { arpSeqPattern01,       -24, 0, 24, "arpSeqPattern01", "arpSeqPattern01" },
        { arpSeqPattern02,       -24, 0, 24, "arpSeqPattern02", "arpSeqPattern02" },
        { arpSeqPattern03,       -24, 0, 24, "arpSeqPattern03", "arpSeqPattern03" },
        { arpSeqPattern04,       -24, 0, 24, "arpSeqPattern04", "arpSeqPattern04" },
        { arpSeqPattern05,       -24, 0, 24, "arpSeqPattern05", "arpSeqPattern05" },
        { arpSeqPattern06,       -24, 0, 24, "arpSeqPattern06", "arpSeqPattern06" },
        { arpSeqPattern07,       -24, 0, 24, "arpSeqPattern07", "arpSeqPattern07" },
        { arpSeqPattern08,       -24, 0, 24, "arpSeqPattern08", "arpSeqPattern08" },
        { arpSeqPattern09,       -24, 0, 24, "arpSeqPattern09", "arpSeqPattern09" },
        { arpSeqPattern10,       -24, 0, 24, "arpSeqPattern10", "arpSeqPattern10" },
        { arpSeqPattern11,       -24, 0, 24, "arpSeqPattern11", "arpSeqPattern11" },
        { arpSeqPattern12,       -24, 0, 24, "arpSeqPattern12", "arpSeqPattern12" },
        { arpSeqPattern13,       -24, 0, 24, "arpSeqPattern13", "arpSeqPattern13" },
        { arpSeqPattern14,       -24, 0, 24, "arpSeqPattern14", "arpSeqPattern14" },
        { arpSeqPattern15,       -24, 0, 24, "arpSeqPattern15", "arpSeqPattern15" },
        { arpSeqOctBoost00,      0, 0, 1, "arpSeqOctBoost00", "arpSeqOctBoost00" },
        { arpSeqOctBoost01,      0, 0, 1, "arpSeqOctBoost01", "arpSeqOctBoost01" },
        { arpSeqOctBoost02,      0, 0, 1, "arpSeqOctBoost02", "arpSeqOctBoost02" },
        { arpSeqOctBoost03,      0, 0, 1, "arpSeqOctBoost03", "arpSeqOctBoost03" },
        { arpSeqOctBoost04,      0, 0, 1, "arpSeqOctBoost04", "arpSeqOctBoost04" },
        { arpSeqOctBoost05,      0, 0, 1, "arpSeqOctBoost05", "arpSeqOctBoost05" },
        { arpSeqOctBoost06,      0, 0, 1, "arpSeqOctBoost06", "arpSeqOctBoost06" },
        { arpSeqOctBoost07,      0, 0, 1, "arpSeqOctBoost07", "arpSeqOctBoost07" },
        { arpSeqOctBoost08,      0, 0, 1, "arpSeqOctBoost08", "arpSeqOctBoost08" },
        { arpSeqOctBoost09,      0, 0, 1, "arpSeqOctBoost09", "arpSeqOctBoost09" },
        { arpSeqOctBoost10,      0, 0, 1, "arpSeqOctBoost10", "arpSeqOctBoost10" },
        { arpSeqOctBoost11,      0, 0, 1, "arpSeqOctBoost11", "arpSeqOctBoost11" },
        { arpSeqOctBoost12,      0, 0, 1, "arpSeqOctBoost12", "arpSeqOctBoost12" },
        { arpSeqOctBoost13,      0, 0, 1, "arpSeqOctBoost13", "arpSeqOctBoost13" },
        { arpSeqOctBoost14,      0, 0, 1, "arpSeqOctBoost14", "arpSeqOctBoost14" },
        { arpSeqOctBoost15,      0, 0, 1, "arpSeqOctBoost15", "arpSeqOctBoost15" },
        { arpSeqNoteOn00,        0, 0, 1, "arpSeqNoteOn00", "arpSeqNoteOn00" },
        { arpSeqNoteOn01,        0, 0, 1, "arpSeqNoteOn01", "arpSeqNoteOn01" },
        { arpSeqNoteOn02,        0, 0, 1, "arpSeqNoteOn02", "arpSeqNoteOn02" },
        { arpSeqNoteOn03,        0, 0, 1, "arpSeqNoteOn03", "arpSeqNoteOn03" },
        { arpSeqNoteOn04,        0, 0, 1, "arpSeqNoteOn04", "arpSeqNoteOn04" },
        { arpSeqNoteOn05,        0, 0, 1, "arpSeqNoteOn05", "arpSeqNoteOn05" },
        { arpSeqNoteOn06,        0, 0, 1, "arpSeqNoteOn06", "arpSeqNoteOn06" },
        { arpSeqNoteOn07,        0, 0, 1, "arpSeqNoteOn07", "arpSeqNoteOn07" },
        { arpSeqNoteOn08,        0, 0, 1, "arpSeqNoteOn08", "arpSeqNoteOn08" },
        { arpSeqNoteOn09,        0, 0, 1, "arpSeqNoteOn09", "arpSeqNoteOn09" },
        { arpSeqNoteOn10,        0, 0, 1, "arpSeqNoteOn10", "arpSeqNoteOn10" },
        { arpSeqNoteOn11,        0, 0, 1, "arpSeqNoteOn11", "arpSeqNoteOn11" },
        { arpSeqNoteOn12,        0, 0, 1, "arpSeqNoteOn12", "arpSeqNoteOn12" },
        { arpSeqNoteOn13,        0, 0, 1, "arpSeqNoteOn13", "arpSeqNoteOn13" },
        { arpSeqNoteOn14,        0, 0, 1, "arpSeqNoteOn14", "arpSeqNoteOn14" },
        { arpSeqNoteOn15,        0, 0, 1, "arpSeqNoteOn15", "arpSeqNoteOn15" },
        { filterType,            0, 0, 2, "filterType", "filterType" },
        { phaserMix,             0, 0, 1, "phaserMix", "phaserMix" },
        { phaserRate,            12, 12, 300, "phaserRate", "phaserRate" },
        { phaserFeedback,        0, 0.0, 0.8, "phaserFeedback", "phaserFeedback" },
        { phaserNotchWidth,      100, 800, 1000, "phaserNotchWidth", "phaserNotchWidth" },
        { monoIsLegato,          0, 0, 1, "monoIsLegato", "monoIsLegato" }
    };
};
#endif
