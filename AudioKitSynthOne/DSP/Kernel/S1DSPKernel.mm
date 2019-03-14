//
//  S1DSPKernel.mm
//  AudioKitSynthOne
//
//  Created by AudioKit Contributors on 1/27/18.
//  Copyright © 2018 AudioKit. All rights reserved.
//
#include <functional>

#import <AudioKit/AudioKit-swift.h>
#import "../Sequencer/S1ArpModes.hpp"
#import "S1DSPKernel.hpp"
#import "AEArray.h"
#import "S1NoteState.hpp"

using namespace std::placeholders;

S1DSPKernel::S1DSPKernel() :
    sequencer(std::bind(std::mem_fn<void(int, int)>(&S1DSPKernel::turnOnKey), this, _1, _2),
              std::bind(std::mem_fn<void(int)>(&S1DSPKernel::turnOffKey), this, _1),
              std::bind(std::bind(&S1DSPKernel::beatCounterDidChange, this))) {
}

S1DSPKernel::~S1DSPKernel() = default;

void S1DSPKernel::init(int _channels, double _sampleRate) {
    AKSoundpipeKernel::init(_channels, _sampleRate);
    sp_ftbl_create(sp, &sine, S1_FTABLE_SIZE);
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

    noteStates = std::make_unique<NoteStateArray>();

    monoNote = std::make_unique<S1NoteState>();

    heldNoteNumbers = (NSMutableArray<NSValue*>*)[NSMutableArray array];
    heldNoteNumbersAE = [[AEArray alloc] initWithCustomMapping:^void *(id item) {
        //TODO: Marcus: pretty sure this leaks
        NoteNumber* noteNumber = (NoteNumber*)malloc(sizeof(NoteNumber));
        NSValue* value = (NSValue*)item;
        [value getValue:noteNumber];
        return noteNumber;
    }];
    sequencer.setSampleRate(_sampleRate);
    sequencer.init();

    for(int i = 0; i< S1Parameter::S1ParameterCount; i++) {
        sp_port_create(&s1p[i].portamento);
    }
    _rate.init();

    restoreValues(std::nullopt);
}

void S1DSPKernel::restoreValues(std::optional<DSPParameters> params) {
    // copy dsp values or initialize with default
    for(int i = 0; i< S1Parameter::S1ParameterCount; i++) {
        const float value = (params != std::nullopt) ? (*params)[i] : defaultValue((S1Parameter)i);
        if (s1p[i].usePortamento) {
            s1p[i].portamentoTarget = value;
            sp_port_init(sp, s1p[i].portamento, value);
            s1p[i].portamento->htime = S1_PORTAMENTO_HALF_TIME;
        }
        p[i] = value;
    }
    updatePortamento(p[portamentoHalfTime]);
    _lfo1Rate = {S1Parameter::lfo1Rate, getDependentParameter(lfo1Rate), getSynthParameter(lfo1Rate),0};
    _lfo2Rate = {S1Parameter::lfo2Rate, getDependentParameter(lfo2Rate), getSynthParameter(lfo2Rate),0};
    _autoPanRate = {S1Parameter::autoPanFrequency, getDependentParameter(autoPanFrequency), getSynthParameter(autoPanFrequency),0};
    _delayTime = {S1Parameter::delayTime, getDependentParameter(delayTime),getSynthParameter(delayTime),0};
    _arpSeqTempoMultiplier = {S1Parameter::arpSeqTempoMultiplier, getDependentParameter(arpSeqTempoMultiplier), getSynthParameter(arpSeqTempoMultiplier),0};

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

    *compressorMasterL->ratio = getSynthParameter(compressorMasterRatio);
    *compressorMasterR->ratio = getSynthParameter(compressorMasterRatio);
    *compressorReverbInputL->ratio = getSynthParameter(compressorReverbInputRatio);
    *compressorReverbInputR->ratio = getSynthParameter(compressorReverbInputRatio);
    *compressorReverbWetL->ratio = getSynthParameter(compressorReverbWetRatio);
    *compressorReverbWetR->ratio = getSynthParameter(compressorReverbWetRatio);
    *compressorMasterL->thresh = getSynthParameter(compressorMasterThreshold);
    *compressorMasterR->thresh = getSynthParameter(compressorMasterThreshold);
    *compressorReverbInputL->thresh = getSynthParameter(compressorReverbInputThreshold);
    *compressorReverbInputR->thresh = getSynthParameter(compressorReverbInputThreshold);
    *compressorReverbWetL->thresh = getSynthParameter(compressorReverbWetThreshold);
    *compressorReverbWetR->thresh = getSynthParameter(compressorReverbWetThreshold);
    *compressorMasterL->atk = getSynthParameter(compressorMasterAttack);
    *compressorMasterR->atk = getSynthParameter(compressorMasterAttack);
    *compressorReverbInputL->atk = getSynthParameter(compressorReverbInputAttack);
    *compressorReverbInputR->atk = getSynthParameter(compressorReverbInputAttack);
    *compressorReverbWetL->atk = getSynthParameter(compressorReverbWetAttack);
    *compressorReverbWetR->atk = getSynthParameter(compressorReverbWetAttack);
    *compressorMasterL->rel = getSynthParameter(compressorMasterRelease);
    *compressorMasterR->rel = getSynthParameter(compressorMasterRelease);
    *compressorReverbInputL->rel = getSynthParameter(compressorReverbInputRelease);
    *compressorReverbInputR->rel = getSynthParameter(compressorReverbInputRelease);
    *compressorReverbWetL->rel = getSynthParameter(compressorReverbWetRelease);
    *compressorReverbWetR->rel = getSynthParameter(compressorReverbWetRelease);

    loPassInputDelayL->freq = getSynthParameter(cutoff);
    loPassInputDelayL->res = getSynthParameter(delayInputResonance);
    loPassInputDelayR->freq = getSynthParameter(cutoff);
    loPassInputDelayR->res = getSynthParameter(delayInputResonance);

    // Reserve arp note cache to reduce possibility of reallocation on audio thread.
    sequencer.init();

    initializedNoteStates = false;
    aePlayingNotes.polyphony = S1_MAX_POLYPHONY;

    AKPolyphonicNode.tuningTable.middleCFrequency = getSynthParameter(frequencyA4) * exp2((60.f - 69.f)/12.f);

    // initializeNoteStates() must be called AFTER init returns, BEFORE process, turnOnKey, and turnOffKey
}
