//
//  S1DSPKernel.hpp
//  AudioKit
//
//  Created by AudioKit Contributors, revision history on Github.
//  Join us at AudioKitPro.com, github.com/audiokit
//
//  20170926: Super HD refactor by Marcus Hobbs

#pragma once

#import <array>
#import <vector>
#import <list>
#import <optional>
#import <string>
#import "AudioKit/AKSoundpipeKernel.hpp"
#import "S1AudioUnit.h"
#import "S1Parameter.h"
#import "S1Rate.hpp"
#import "../Sequencer/S1Sequencer.hpp"
#import "S1DSPCompressor.hpp"

@class AEArray;
@class AEMessageQueue;

#define S1_FTABLE_SIZE (4096)
#define S1_NUM_WAVEFORMS (4)
#define S1_NUM_BANDLIMITED_FTABLES (13)

#define S1_RELEASE_AMPLITUDE_THRESHOLD (0.01f)
#define S1_PORTAMENTO_HALF_TIME (0.1f)
#define S1_DEPENDENT_PARAM_TAPER (0.4f)

#ifdef __cplusplus

struct S1NoteState;
class S1Sequencer;
using DSPParameters = std::array<float, S1Parameter::S1ParameterCount>;
using NoteStateArray = std::array<S1NoteState, S1_MAX_POLYPHONY>;

class S1DSPKernel : public AKSoundpipeKernel, public AKOutputBuffered {

    // MARK: S1DSPKernel Member Functions

public:
    
    S1DSPKernel(int _channels, double _sampleRate);

    // Dont allow default construction, copying or moving of Kernel.
    S1DSPKernel() = delete;
    S1DSPKernel(S1DSPKernel&&) = delete;
    S1DSPKernel(const S1DSPKernel&) = delete;

    ~S1DSPKernel();

    // public accessor for protected sp
    inline sp_data *spp() {
        return sp;
    }
    inline int sampleRate() {
        return sp->sr;
    }

    float getSynthParameter(S1Parameter param);
    void setSynthParameter(S1Parameter param, float value);

    // lfo1Rate, lfo2Rate, autoPanRate, delayTime, and arpSeqTempoMultiplier; returns on [0,1]
    float getDependentParameter(S1Parameter param);
    void setDependentParameter(S1Parameter param, float value, int payload);

    // AUParameter/AUValue
    void setParameters(float params[]);
    
    void setParameter(AUParameterAddress address, AUValue value);
    
    AUValue getParameter(AUParameterAddress address);
    
    void startRamp(AUParameterAddress address, AUValue value, AUAudioFrameCount duration) override;
    
    ///panic...hard-resets DSP.  artifacts.
    void resetDSP();
    
    ///puts all notes in release mode...no artifacts
    void stopAllNotes();
    
    void handleTempoSetting(float currentTempo);
    
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
    
    /// Sets beatcounter to 0
    void resetSequencer();
    
    // MIDI
    virtual void handleMIDIEvent(AUMIDIEvent const& midiEvent) override;
    
    void init(int _channels, double _sampleRate) override;

    // Restore Parameter Values to DSP
    void restoreValues(std::optional<DSPParameters> params);
    
    void destroy();
    
    void updatePortamento(float halfTime);

    // initializeNoteStates() must be called AFTER init returns
    void initializeNoteStates();
    
    void setupWaveform(uint32_t tableIndex, uint32_t size);

    void setWaveformValue(uint32_t tableIndex, uint32_t sampleIndex, float value);

    void setBandlimitFrequency(uint32_t blIndex, float frequency);

    ///parameter min
    float minimum(S1Parameter i);
    
    ///parameter max
    float maximum(S1Parameter i);
    
    ///parameter defaults
    float defaultValue(S1Parameter i);
    
    ///parameter unit
    AudioUnitParameterUnit parameterUnit(S1Parameter i);
    
    ///parameter clamp
    float clampedValue(S1Parameter i, float inputValue);

    ///friendly description of parameter
    std::string friendlyName(S1Parameter i);
    
    ///C string friendly description of parameter
    const char* cString(S1Parameter i);

    ///parameter presetKey
    std::string presetKey(S1Parameter i);

private:

    S1Sequencer sequencer;
    // moved the private functions to try to get rid of errors, I don't think we need to be that worried about privacy

public:
    
    void updateWavetableIncrementValuesForCurrentSampleRate();

    void _setSynthParameter(S1Parameter param, float inputValue01);

    void _setSynthParameterHelper(S1Parameter param, float inputValue, bool notifyMainThread, int payload);

    void _rateHelper(S1Parameter param, float inputValue, bool notifyMainThread, int payload);

    // algebraic only
    float taper01(float inputValue01, float taper);
    float taper01Inverse(float inputValue01, float taper);

    // > 0 algebraic, < 0 exponential
    float taper(float inputValue01, float min, float max, float taper);
    float taperInverse(float inputValue01, float min, float max, float taper);

    __weak S1AudioUnit* audioUnit;
    
    bool resetted = false;
    
    int arpBeatCounter = 0;
    
    /// dsp params
    DSPParameters parameters;
    
    // Portamento values
    float monoFrequency = 440.f * exp2((60.f - 69.f)/12.f);
    
    // phasor values
    float lfo1 = 0.f;
    float lfo2 = 0.f;
    
    // midi
    bool notesHeld = false;
    
    PlayingNotes aePlayingNotes;
    
    HeldNotes aeHeldNotes;

    sp_ftbl *ft_array[S1_NUM_WAVEFORMS * S1_NUM_BANDLIMITED_FTABLES];
    float   ft_frequencyBand[S1_NUM_BANDLIMITED_FTABLES];

    sp_ftbl *sine;
    
    float lfo1_0_1 = 0.f;
    float lfo1_1_0 = 0.f;
    float lfo2_0_1 = 0.f;
    float lfo2_1_0 = 0.f;
    float lfo3_0_1 = 0.f;
    float lfo3_1_0 = 0.f;
    
    float monoFrequencySmooth = 261.6255653006f;

    // S1TuningTable protocol
    void setTuningTable(float value, int index);
    float getTuningTableFrequency(int index);
    void setTuningTableNPO(int npo);

private:
    std::array<std::atomic<float>, 128> tuningTable;
    std::atomic<int> tuningTableNPO{12};

    // private tuningTable lookup
    double tuningTableNoteToHz(int noteNumber);

    S1Rate _rate;
    
    DependentParameter _lfo1Rate;
    
    DependentParameter _lfo2Rate;
    
    DependentParameter _autoPanRate;
    
    DependentParameter _delayTime;
    
    DependentParameter _pitchbend;

    DependentParameter _arpSeqTempoMultiplier;
    
    void dependentParameterDidChange(DependentParameter param);

    ///can be called from within the render loop
    void beatCounterDidChange();
    
    ///can be called from within the render loop
    void playingNotesDidChange();
    
    ///can be called from within the render loop
    void heldNotesDidChange();
    
    struct S1ParameterInfo {
        S1Parameter parameter;
        float minimum;
        float defaultValue;
        float maximum;
        std::string presetKey;
        std::string friendlyName;
        AudioUnitParameterUnit unit;
        bool usePortamento;
        sp_port *portamento;
        float portamentoTarget;
    };

    // array of struct S1NoteState of count MAX_POLYPHONY
    std::unique_ptr<NoteStateArray> noteStates;
    
    // monophonic: single instance of NoteState
    std::unique_ptr<S1NoteState> monoNote;
    
    bool initializedNoteStates = false;
    
    // S1_MAX_POLYPHONY is the limit of hard-coded number of simultaneous notes to render to manage computation.
    // New noteOn events will steal voices to keep this number.
    // For now "polyphony" is constant equal to S1_MAX_POLYPHONY, but with some refactoring we could make it dynamic.
    const int polyphony = S1_MAX_POLYPHONY;
    
    int playingNoteStatesIndex = 0;
    UInt32 tbl_size = S1_FTABLE_SIZE;
    sp_phasor *lfo1Phasor;
    sp_phasor *lfo2Phasor;
    sp_pan2 *pan;
    sp_osc *panOscillator;
    sp_phaser *phaser0;
    
    sp_moogladder *loPassInputDelayL;
    sp_moogladder *loPassInputDelayR;
    sp_vdelay *delayL;
    sp_vdelay *delayR;
    sp_vdelay *delayRR;
    sp_vdelay *delayFillIn;
    sp_crossfade *delayCrossfadeL;
    sp_crossfade *delayCrossfadeR;
    sp_revsc *reverbCostello;
    sp_buthp *butterworthHipassL;
    sp_buthp *butterworthHipassR;
    sp_crossfade *revCrossfadeL;
    sp_crossfade *revCrossfadeR;
    S1Compressor<compressorMasterRatio, compressorMasterThreshold,
        compressorMasterAttack, compressorMasterRelease, compressorMasterMakeupGain> mCompMaster;
    S1Compressor<compressorReverbInputRatio, compressorReverbInputThreshold,
        compressorReverbInputAttack, compressorReverbInputRelease, compressorReverbInputMakeupGain> mCompReverbIn;
    S1Compressor<compressorReverbWetRatio, compressorReverbWetThreshold,
        compressorReverbWetAttack, compressorReverbWetRelease, compressorReverbWetMakeupGain> mCompReverbWet;
    sp_compressor *compressorReverbInputL;
    sp_compressor *compressorReverbInputR;
    sp_compressor *compressorReverbWetL;
    sp_compressor *compressorReverbWetR;
    sp_delay *widenDelay;
    sp_port *monoFrequencyPort;
    float tempo = 120.f;
    float previousProcessMonoPolyStatus = 0.f;
    float bitcrushIncr = 1.f;
    float bitcrushIndex = 0.f;
    float bitcrushSampleIndex = 0.f;
    float bitcrushValue = 0.f;

    // Count samples to limit main thread notification
    double processSampleCounter = 0;
    
    ///once init'd: sequencerLastNotes can be accessed and mutated only within process and resetDSP
    std::list<int> sequencerLastNotes;

    
    // Array of midi note numbers of NoteState's which have had a noteOn event but not yet a noteOff event.
    NSMutableArray<NSValue*>* heldNoteNumbers;
    AEArray* heldNoteNumbersAE;

    // These expressions come from Rate.swift which is used for beat sync
    const float minutesPerSecond = 1.f / 60.f;
    const float beatsPerBar = 4.f;
    const float bpm_min = 1.f;
    const float bpm_max = 200.f;
    const float bars_min = 1.f / 64.f / 1.5f;
    const float bars_max = 8.f;
    const float rate_min = 1.f / ( (beatsPerBar * bars_max) / (bpm_min * minutesPerSecond) ); //  0.00052 8 bars at 1bpm
    const float rate_max = 1.f / ( (beatsPerBar * bars_min) / (bpm_max * minutesPerSecond) ); // 53.3333
    S1ParameterInfo s1p[S1Parameter::S1ParameterCount] = {
        { index1,                0, 1, 1, "index1", "Index 1", kAudioUnitParameterUnit_Generic, true, NULL},
        { index2,                0, 1, 1, "index2", "Index 2", kAudioUnitParameterUnit_Generic, true, NULL},
        { morphBalance,          0, 0.5, 1, "morphBalance", "morphBalance", kAudioUnitParameterUnit_Generic, true, NULL},
        { morph1SemitoneOffset,  -12, 0, 24, "morph1SemitoneOffset", "morph1SemitoneOffset", kAudioUnitParameterUnit_RelativeSemiTones, false, NULL},
        { morph2SemitoneOffset,  -12, 0, 24, "morph2SemitoneOffset", "morph2SemitoneOffset", kAudioUnitParameterUnit_RelativeSemiTones, false, NULL},
        { morph1Volume,          0, 0.8, 1, "morph1Volume", "morph1Volume", kAudioUnitParameterUnit_Generic, true, NULL},
        { morph2Volume,          0, 0.8, 1, "morph2Volume", "morph2Volume", kAudioUnitParameterUnit_Generic, true, NULL},
        { subVolume,             0, 0, 1, "subVolume", "subVolume", kAudioUnitParameterUnit_Generic, true, NULL},
        { subOctaveDown,         0, 0, 1, "subOctaveDown", "subOctaveDown", kAudioUnitParameterUnit_Generic, false, NULL},
        { subIsSquare,           0, 0, 1, "subIsSquare", "subIsSquare", kAudioUnitParameterUnit_Generic, false, NULL},
        { fmVolume,              0, 0, 1, "fmVolume", "fmVolume", kAudioUnitParameterUnit_Generic, true, NULL},
        { fmAmount,              0, 0, 15, "fmAmount", "fmAmount", kAudioUnitParameterUnit_Generic, true, NULL},
        { noiseVolume,           0, 0, 0.25, "noiseVolume", "noiseVolume", kAudioUnitParameterUnit_Generic, true, NULL},
        { lfo1Index,             0, 0, 3, "lfo1Index", "lfo1Index", kAudioUnitParameterUnit_Generic, false, NULL},
        { lfo1Amplitude,         0, 0, 1, "lfo1Amplitude", "lfo1Amplitude", kAudioUnitParameterUnit_Generic, true, NULL},
        { lfo1Rate,              rate_min, 0.25, rate_max, "lfo1Rate", "lfo1Rate", kAudioUnitParameterUnit_Rate, false, NULL},
        { cutoff,                64, 20000, 22050, "cutoff", "cutoff", kAudioUnitParameterUnit_Hertz, true, NULL},
        { resonance,             0, 0.1, 0.98, "resonance", "resonance", kAudioUnitParameterUnit_Generic, true, NULL},
        { filterMix,             0, 1, 1, "filterMix", "filterMix", kAudioUnitParameterUnit_Generic, true, NULL},
        { filterADSRMix,         0, 0, 1.2, "filterADSRMix", "filterADSRMix", kAudioUnitParameterUnit_Generic, true, NULL},
        { isMono,                0, 0, 1, "isMono", "isMono", kAudioUnitParameterUnit_Generic, false, NULL},
        { glide,                 0, 0, 0.2, "glide", "glide", kAudioUnitParameterUnit_Generic, true, NULL},
        { filterAttackDuration,  0.0005, 0.05, 2, "filterAttack", "filterAttackDuration", kAudioUnitParameterUnit_Seconds, true, NULL},
        { filterDecayDuration,   0.005, 0.05, 2, "filterDecay", "filterDecayDuration", kAudioUnitParameterUnit_Seconds, true, NULL},
        { filterSustainLevel,    0, 1, 1, "filterSustain", "filterSustainLevel", kAudioUnitParameterUnit_Generic, true, NULL},
        { filterReleaseDuration, 0, 0.5, 2, "filterRelease", "filterReleaseDuration", kAudioUnitParameterUnit_Seconds, true, NULL},
        { attackDuration,        0.0005, 0.05, 2, "attackDuration", "attackDuration", kAudioUnitParameterUnit_Seconds, true, NULL},
        { decayDuration,         0.005, 0.005, 2, "decayDuration", "decayDuration", kAudioUnitParameterUnit_Seconds, true, NULL},
        { sustainLevel,          0, 0.8, 1, "sustainLevel", "sustainLevel", kAudioUnitParameterUnit_Generic, true, NULL},
        { releaseDuration,       0.004, 0.05, 2, "releaseDuration", "releaseDuration", kAudioUnitParameterUnit_Seconds, true, NULL},
        { morph2Detuning,        -4, 0, 4, "morph2Detuning", "morph2Detuning", kAudioUnitParameterUnit_Generic, true, NULL},
        { detuningMultiplier,    1, 1, 2, "detuningMultiplier", "detuningMultiplier", kAudioUnitParameterUnit_Generic, true, NULL},
        { masterVolume,          0, 0.5, 2, "masterVolume", "masterVolume", kAudioUnitParameterUnit_Generic, true, NULL},
        { bitCrushDepth,         1, 24, 24, "bitCrushDepth", "bitCrushDepth", kAudioUnitParameterUnit_Generic, false, NULL},// UNUSED
        { bitCrushSampleRate,    2048, 48000, 48000, "bitCrushSampleRate", "bitCrushSampleRate", kAudioUnitParameterUnit_Hertz, true, NULL},
        { autoPanAmount,         0, 0, 1, "autoPanAmount", "autoPanAmount", kAudioUnitParameterUnit_Generic, true, NULL},
        { autoPanFrequency,      rate_min, 0.25, 10, "autoPanFrequency", "autoPanFrequency", kAudioUnitParameterUnit_Hertz, true, NULL},
        { reverbOn,              0, 1, 1, "reverbOn", "reverbOn", kAudioUnitParameterUnit_Generic, true, NULL},
        { reverbFeedback,        0, 0.5, 1, "reverbFeedback", "reverbFeedback", kAudioUnitParameterUnit_Generic, true, NULL},
        { reverbHighPass,        80, 700, 900, "reverbHighPass", "reverbHighPass", kAudioUnitParameterUnit_Generic, true, NULL},
        { reverbMix,             0, 0, 1, "reverbMix", "reverbMix", kAudioUnitParameterUnit_Generic, true, NULL},
        { delayOn,               0, 0, 1, "delayOn", "delayOn", kAudioUnitParameterUnit_Generic, true, NULL},
        { delayFeedback,         0, 0.1, 0.9, "delayFeedback", "delayFeedback", kAudioUnitParameterUnit_Generic, true, NULL},
        { delayTime,             0.0003628117914, 0.25, 2.5, "delayTime", "delayTime", kAudioUnitParameterUnit_Seconds, true, NULL},
        { delayMix,              0, 0.125, 1, "delayMix", "delayMix", kAudioUnitParameterUnit_Generic, true, NULL},
        { lfo2Index,             0, 0, 3, "lfo2Index", "lfo2Index", kAudioUnitParameterUnit_Generic, false, NULL},
        { lfo2Amplitude,         0, 0, 1, "lfo2Amplitude", "lfo2Amplitude", kAudioUnitParameterUnit_Generic, true, NULL},
        { lfo2Rate,              rate_min, 0.25, rate_max, "lfo2Rate", "lfo2Rate", kAudioUnitParameterUnit_Generic, false, NULL},
        { cutoffLFO,             0, 0, 3, "cutoffLFO", "cutoffLFO", kAudioUnitParameterUnit_Generic, false, NULL},
        { resonanceLFO,          0, 0, 3, "resonanceLFO", "resonanceLFO", kAudioUnitParameterUnit_Generic, false, NULL},
        { oscMixLFO,             0, 0, 3, "oscMixLFO", "oscMixLFO", kAudioUnitParameterUnit_Generic, false, NULL},
        { reverbMixLFO,            0, 0, 3, "reverbMixLFO", "reverbMixLFO", kAudioUnitParameterUnit_Generic, false, NULL},
        { decayLFO,              0, 0, 3, "decayLFO", "decayLFO", kAudioUnitParameterUnit_Generic, false, NULL},
        { noiseLFO,              0, 0, 3, "noiseLFO", "noiseLFO", kAudioUnitParameterUnit_Generic, false, NULL},
        { fmLFO,                 0, 0, 3, "fmLFO", "fmLFO", kAudioUnitParameterUnit_Generic, false, NULL},
        { detuneLFO,             0, 0, 3, "detuneLFO", "detuneLFO", kAudioUnitParameterUnit_Generic, false, NULL},
        { filterEnvLFO,          0, 0, 3, "filterEnvLFO", "filterEnvLFO", kAudioUnitParameterUnit_Generic, false, NULL},
        { pitchLFO,              0, 0, 3, "pitchLFO", "pitchLFO", kAudioUnitParameterUnit_Generic, false, NULL},
        { bitcrushLFO,           0, 0, 3, "bitcrushLFO", "bitcrushLFO", kAudioUnitParameterUnit_Generic, false, NULL},
        { tremoloLFO,            0, 0, 3, "tremoloLFO", "tremoloLFO", kAudioUnitParameterUnit_Generic, false, NULL},
        { arpDirection,          0, 1, 2, "arpDirection", "arpDirection", kAudioUnitParameterUnit_Generic, false, NULL},
        { arpInterval,           0, 12, 12, "arpInterval", "arpInterval", kAudioUnitParameterUnit_Generic, false, NULL},
        { arpIsOn,               0, 0, 1, "arpIsOn", "arpIsOn", kAudioUnitParameterUnit_Generic, false, NULL},
        { arpOctave,             0, 1, 3, "arpOctave", "arpOctave", kAudioUnitParameterUnit_Generic, false, NULL},
        { arpRate,               bpm_min, 120, bpm_max, "arpRate", "arpRate", kAudioUnitParameterUnit_BPM, false, NULL},
        { arpIsSequencer,        0, 0, 1, "arpIsSequencer", "arpIsSequencer", kAudioUnitParameterUnit_Generic, false, NULL},
        { arpTotalSteps,         1, 4, 16, "arpTotalSteps", "arpTotalSteps" , kAudioUnitParameterUnit_Generic, false, NULL},
        { sequencerPattern00,       -12, 0, 12, "sequencerPattern00", "sequencerPattern00" , kAudioUnitParameterUnit_Generic, false, NULL},
        { sequencerPattern01,       -12, 0, 12, "sequencerPattern01", "sequencerPattern01" , kAudioUnitParameterUnit_Generic, false, NULL},
        { sequencerPattern02,       -12, 0, 12, "sequencerPattern02", "sequencerPattern02" , kAudioUnitParameterUnit_Generic, false, NULL},
        { sequencerPattern03,       -12, 0, 12, "sequencerPattern03", "sequencerPattern03" , kAudioUnitParameterUnit_Generic, false, NULL},
        { sequencerPattern04,       -12, 0, 12, "sequencerPattern04", "sequencerPattern04" , kAudioUnitParameterUnit_Generic, false, NULL},
        { sequencerPattern05,       -12, 0, 12, "sequencerPattern05", "sequencerPattern05" , kAudioUnitParameterUnit_Generic, false, NULL},
        { sequencerPattern06,       -12, 0, 12, "sequencerPattern06", "sequencerPattern06" , kAudioUnitParameterUnit_Generic, false, NULL},
        { sequencerPattern07,       -12, 0, 12, "sequencerPattern07", "sequencerPattern07" , kAudioUnitParameterUnit_Generic, false, NULL},
        { sequencerPattern08,       -12, 0, 12, "sequencerPattern08", "sequencerPattern08" , kAudioUnitParameterUnit_Generic, false, NULL},
        { sequencerPattern09,       -12, 0, 12, "sequencerPattern09", "sequencerPattern09" , kAudioUnitParameterUnit_Generic, false, NULL},
        { sequencerPattern10,       -12, 0, 12, "sequencerPattern10", "sequencerPattern10" , kAudioUnitParameterUnit_Generic, false, NULL},
        { sequencerPattern11,       -12, 0, 12, "sequencerPattern11", "sequencerPattern11" , kAudioUnitParameterUnit_Generic, false, NULL},
        { sequencerPattern12,       -12, 0, 12, "sequencerPattern12", "sequencerPattern12" , kAudioUnitParameterUnit_Generic, false, NULL},
        { sequencerPattern13,       -12, 0, 12, "sequencerPattern13", "sequencerPattern13" , kAudioUnitParameterUnit_Generic, false, NULL},
        { sequencerPattern14,       -12, 0, 12, "sequencerPattern14", "sequencerPattern14" , kAudioUnitParameterUnit_Generic, false, NULL},
        { sequencerPattern15,       -12, 0, 12, "sequencerPattern15", "sequencerPattern15" , kAudioUnitParameterUnit_Generic, false, NULL},
        { sequencerOctBoost00,      0, 0, 1, "sequencerOctBoost00", "sequencerOctBoost00" , kAudioUnitParameterUnit_Generic, false, NULL},
        { sequencerOctBoost01,      0, 0, 1, "sequencerOctBoost01", "sequencerOctBoost01" , kAudioUnitParameterUnit_Generic, false, NULL},
        { sequencerOctBoost02,      0, 0, 1, "sequencerOctBoost02", "sequencerOctBoost02" , kAudioUnitParameterUnit_Generic, false, NULL},
        { sequencerOctBoost03,      0, 0, 1, "sequencerOctBoost03", "sequencerOctBoost03" , kAudioUnitParameterUnit_Generic, false, NULL},
        { sequencerOctBoost04,      0, 0, 1, "sequencerOctBoost04", "sequencerOctBoost04" , kAudioUnitParameterUnit_Generic, false, NULL},
        { sequencerOctBoost05,      0, 0, 1, "sequencerOctBoost05", "sequencerOctBoost05" , kAudioUnitParameterUnit_Generic, false, NULL},
        { sequencerOctBoost06,      0, 0, 1, "sequencerOctBoost06", "sequencerOctBoost06" , kAudioUnitParameterUnit_Generic, false, NULL},
        { sequencerOctBoost07,      0, 0, 1, "sequencerOctBoost07", "sequencerOctBoost07" , kAudioUnitParameterUnit_Generic, false, NULL},
        { sequencerOctBoost08,      0, 0, 1, "sequencerOctBoost08", "sequencerOctBoost08" , kAudioUnitParameterUnit_Generic, false, NULL},
        { sequencerOctBoost09,      0, 0, 1, "sequencerOctBoost09", "sequencerOctBoost09" , kAudioUnitParameterUnit_Generic, false, NULL},
        { sequencerOctBoost10,      0, 0, 1, "sequencerOctBoost10", "sequencerOctBoost10" , kAudioUnitParameterUnit_Generic, false, NULL},
        { sequencerOctBoost11,      0, 0, 1, "sequencerOctBoost11", "sequencerOctBoost11" , kAudioUnitParameterUnit_Generic, false, NULL},
        { sequencerOctBoost12,      0, 0, 1, "sequencerOctBoost12", "sequencerOctBoost12" , kAudioUnitParameterUnit_Generic, false, NULL},
        { sequencerOctBoost13,      0, 0, 1, "sequencerOctBoost13", "sequencerOctBoost13" , kAudioUnitParameterUnit_Generic, false, NULL},
        { sequencerOctBoost14,      0, 0, 1, "sequencerOctBoost14", "sequencerOctBoost14" , kAudioUnitParameterUnit_Generic, false, NULL},
        { sequencerOctBoost15,      0, 0, 1, "sequencerOctBoost15", "sequencerOctBoost15" , kAudioUnitParameterUnit_Generic, false, NULL},
        { sequencerNoteOn00,        0, 0, 1, "sequencerNoteOn00", "sequencerNoteOn00" , kAudioUnitParameterUnit_Generic, false, NULL},
        { sequencerNoteOn01,        0, 0, 1, "sequencerNoteOn01", "sequencerNoteOn01" , kAudioUnitParameterUnit_Generic, false, NULL},
        { sequencerNoteOn02,        0, 0, 1, "sequencerNoteOn02", "sequencerNoteOn02" , kAudioUnitParameterUnit_Generic, false, NULL},
        { sequencerNoteOn03,        0, 0, 1, "sequencerNoteOn03", "sequencerNoteOn03" , kAudioUnitParameterUnit_Generic, false, NULL},
        { sequencerNoteOn04,        0, 0, 1, "sequencerNoteOn04", "sequencerNoteOn04" , kAudioUnitParameterUnit_Generic, false, NULL},
        { sequencerNoteOn05,        0, 0, 1, "sequencerNoteOn05", "sequencerNoteOn05" , kAudioUnitParameterUnit_Generic, false, NULL},
        { sequencerNoteOn06,        0, 0, 1, "sequencerNoteOn06", "sequencerNoteOn06" , kAudioUnitParameterUnit_Generic, false, NULL},
        { sequencerNoteOn07,        0, 0, 1, "sequencerNoteOn07", "sequencerNoteOn07" , kAudioUnitParameterUnit_Generic, false, NULL},
        { sequencerNoteOn08,        0, 0, 1, "sequencerNoteOn08", "sequencerNoteOn08" , kAudioUnitParameterUnit_Generic, false, NULL},
        { sequencerNoteOn09,        0, 0, 1, "sequencerNoteOn09", "sequencerNoteOn09" , kAudioUnitParameterUnit_Generic, false, NULL},
        { sequencerNoteOn10,        0, 0, 1, "sequencerNoteOn10", "sequencerNoteOn10" , kAudioUnitParameterUnit_Generic, false, NULL},
        { sequencerNoteOn11,        0, 0, 1, "sequencerNoteOn11", "sequencerNoteOn11" , kAudioUnitParameterUnit_Generic, false, NULL},
        { sequencerNoteOn12,        0, 0, 1, "sequencerNoteOn12", "sequencerNoteOn12" , kAudioUnitParameterUnit_Generic, false, NULL},
        { sequencerNoteOn13,        0, 0, 1, "sequencerNoteOn13", "sequencerNoteOn13" , kAudioUnitParameterUnit_Generic, false, NULL},
        { sequencerNoteOn14,        0, 0, 1, "sequencerNoteOn14", "sequencerNoteOn14" , kAudioUnitParameterUnit_Generic, false, NULL},
        { sequencerNoteOn15,        0, 0, 1, "sequencerNoteOn15", "sequencerNoteOn15" , kAudioUnitParameterUnit_Generic, false, NULL},
        { filterType,            0, 0, 2, "filterType", "filterType" , kAudioUnitParameterUnit_Generic, false, NULL},
        { phaserMix,             0, 0, 1, "phaserMix", "phaserMix" , kAudioUnitParameterUnit_Generic, true, NULL},
        { phaserRate,            1, 12, 300, "phaserRate", "phaserRate" , kAudioUnitParameterUnit_Hertz, true, NULL},
        { phaserFeedback,        0, 0.0, 0.8, "phaserFeedback", "phaserFeedback" , kAudioUnitParameterUnit_Generic, true, NULL},
        { phaserNotchWidth,      100, 800, 1000, "phaserNotchWidth", "phaserNotchWidth" , kAudioUnitParameterUnit_Hertz, true, NULL},
        { monoIsLegato,          0, 0, 1, "monoIsLegato", "monoIsLegato" , kAudioUnitParameterUnit_Generic, false, NULL},
        { widen,                 0, 0, 1, "widen", "widen" , kAudioUnitParameterUnit_Generic, true, NULL},//this is a toggle, but we smooth it for crossfade
        
        { compressorMasterRatio,      1, 20, 20, "master compressor ratio", "master compressor ratio", kAudioUnitParameterUnit_Generic, false, NULL},
        { compressorReverbInputRatio, 1, 13, 20, "reverb input compressor ratio", "reverb input compressor ratio", kAudioUnitParameterUnit_Generic, false, NULL},
        { compressorReverbWetRatio,   1, 13, 20, "reverb wet compressor ratio", "reverb wet compressor ratio", kAudioUnitParameterUnit_Generic, false, NULL},
        
        { compressorMasterThreshold,      -60, -9, 0, "master compressor threshold", "master compressor threshold", kAudioUnitParameterUnit_Generic, false, NULL},
        { compressorReverbInputThreshold, -60, -8.5, 0, "reverb input compressor threshold", "reverb input compressor threshold", kAudioUnitParameterUnit_Generic, false, NULL},
        { compressorReverbWetThreshold,   -60, -8, 0, "reverb wet compressor threshold", "reverb wet compressor threshold", kAudioUnitParameterUnit_Generic, false, NULL},
        
        { compressorMasterAttack,      0, 0.001, 0.01, "master compressor attack", "master compressor attack", kAudioUnitParameterUnit_Generic, false, NULL},
        { compressorReverbInputAttack, 0, 0.001, 0.01, "reverb input compressor attack", "reverb input compressor attack", kAudioUnitParameterUnit_Generic, false, NULL},
        { compressorReverbWetAttack,   0, 0.001, 0.01, "reverb wet compressor attack", "reverb wet compressor attack", kAudioUnitParameterUnit_Generic, false, NULL},
        
        { compressorMasterRelease,      0, 0.15, 0.5, "master compressor release", "master compressor release", kAudioUnitParameterUnit_Generic, false, NULL},
        { compressorReverbInputRelease, 0, 0.225, 0.5, "reverb input compressor release", "reverb input compressor release", kAudioUnitParameterUnit_Generic, false, NULL},
        { compressorReverbWetRelease,   0, 0.15, 0.5, "reverb wet compressor release", "reverb wet compressor release", kAudioUnitParameterUnit_Generic, false, NULL},
        
        { compressorMasterMakeupGain, 0.5, 2, 4, "master compressor makeup gain", "master compressor makeup gain", kAudioUnitParameterUnit_Generic, false, NULL},
        { compressorReverbInputMakeupGain, 0.5, 1.88, 4, "reverb input compressor makeup gain", "reverb input compressor makeup gain", kAudioUnitParameterUnit_Generic, false, NULL},
        { compressorMasterMakeupGain, 0.5, 1.88, 4, "reverb wet compressor makeup gain", "reverb wet compressor makeup gain", kAudioUnitParameterUnit_Generic, false, NULL},
        
        { delayInputCutoffTrackingRatio, 0.5, 0.75, 1, "delayInputCutoffTrackingRatio", "delayInputCutoffTrackingRatio", kAudioUnitParameterUnit_Hertz, false, NULL},
        { delayInputResonance, 0, 0.0, 0.98, "delayInputResonance", "delayInputResonance", kAudioUnitParameterUnit_Generic, false, NULL},
        { tempoSyncToArpRate, 0, 1, 1, "tempoSyncToArpRate", "tempoSyncToArpRate", kAudioUnitParameterUnit_Generic, false, NULL},
        
        { pitchbend,              0, 8192, 16383, "pitchbend", "pitchbend", kAudioUnitParameterUnit_Generic, true, NULL},
        { pitchbendMinSemitones,  -24, -12, 0, "pitchbendMinSemitones", "pitchbendMinSemitones", kAudioUnitParameterUnit_Generic, false, NULL},
        { pitchbendMaxSemitones,  0, 12, 24, "pitchbendMaxSemitones", "pitchbendMaxSemitones", kAudioUnitParameterUnit_Generic, false, NULL},
        
        { frequencyA4,  410, 440, 470, "frequencyA4", "frequencyA4", kAudioUnitParameterUnit_Hertz, true, NULL},
        { portamentoHalfTime, 0.000001, 0.1, 0.99, "portamentoHalfTime", "portamentoHalfTime", kAudioUnitParameterUnit_Generic, true, NULL },

        /* DEPRECATED -1 = no override, else = index into bandlimited wavetable */
        { oscBandlimitIndexOverride, -1, -1, (S1_NUM_BANDLIMITED_FTABLES-1), "oscBandlimitIndexOverride", "oscBandlimitIndexOverride", kAudioUnitParameterUnit_Generic, false, NULL },
        { oscBandlimitEnable, 0, 0, 1, "oscBandlimitEnable", "oscBandlimitEnable", kAudioUnitParameterUnit_Generic, false, NULL},

        { arpSeqTempoMultiplier, bars_min, 0.25, bars_max, "arpSeqTempoMultiplier", "arpSeqTempoMultiplier", kAudioUnitParameterUnit_Generic, false, NULL},

        { transpose, -24, 0, 24, "transpose", "transpose", kAudioUnitParameterUnit_Generic, false, NULL},

        { adsrPitchTracking, 0, 0, 1, "adsrPitchTracking", "adsrPitchTracking", kAudioUnitParameterUnit_Generic, true, NULL}

    };
};
#endif
