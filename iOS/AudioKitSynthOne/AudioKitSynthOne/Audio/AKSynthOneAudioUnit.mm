//
//  AKSynthOneAudioUnit.mm
//  AudioKit
//
//  Created by Aurelius Prochazka, revision history on Github.
//  Copyright © 2017 Aurelius Prochazka. All rights reserved.
//

#import "AKSynthOneAudioUnit.h"
#import "AKSynthOneDSPKernel.hpp"
#import "BufferedAudioBus.hpp"
#import "AEMessageQueue.h"

@implementation AKSynthOneAudioUnit {
    // C++ members need to be ivars; they would be copied on access if they were properties.
    AKSynthOneDSPKernel _kernel;
    BufferedOutputBus _outputBusBuffer;
    AUHostMusicalContextBlock _musicalContext;
}

@synthesize parameterTree = _parameterTree;

- (void)setAK1Parameter:(AKSynthOneParameter)param value:(float)value {
    _kernel.setAK1Parameter(param, value);
}

- (float)getAK1Parameter:(AKSynthOneParameter)inAKSynthOneParameterEnum {
    return _kernel.getAK1Parameter(inAKSynthOneParameterEnum);
}

- (float)getParameterMin:(AKSynthOneParameter)param {
    return _kernel.parameterMin(param);
}

- (float)getParameterMax:(AKSynthOneParameter)param {
    return _kernel.parameterMax(param);
}

- (float)getParameterDefault:(AKSynthOneParameter)param {
    return _kernel.parameterDefault(param);
}

///Note calling this method to access even a single element of this array results in creating the entire array
- (NSArray<NSNumber*> *)parameters {
    NSMutableArray *temp = [NSMutableArray arrayWithCapacity:AKSynthOneParameter::AKSynthOneParameterCount];
    for (int i = 0; i < AKSynthOneParameter::AKSynthOneParameterCount; i++) {
        [temp setObject:[NSNumber numberWithFloat:_kernel.p[i]] atIndexedSubscript:i];
    }
    return [NSArray arrayWithArray:temp];
}

- (void)setParameters:(NSArray<NSNumber*> *)parameters {
    float params[AKSynthOneParameter::AKSynthOneParameterCount];
    for (int i = 0; i < parameters.count; i++) {
        params[i] = [parameters[i] floatValue];
    }
    _kernel.setParameters(params);
}

- (void)resetSequencer {
    _kernel.resetSequencer();
}

- (BOOL)isSetUp {
    return _kernel.resetted;
}

- (void)stopNote:(uint8_t)note {
    _kernel.stopNote(note);
}

- (void)startNote:(uint8_t)note velocity:(uint8_t)velocity {
    _kernel.startNote(note, velocity);
}

- (void)startNote:(uint8_t)note velocity:(uint8_t)velocity frequency:(float)frequency {
    _kernel.startNote(note, velocity, frequency);
}

- (void)setupWaveform:(UInt32)waveform size:(int)size {
    _kernel.setupWaveform(waveform, (uint32_t)size);
}

- (void)setWaveform:(UInt32)waveform withValue:(float)value atIndex:(UInt32)index {
    _kernel.setWaveformValue(waveform, index, value);
}

- (void)reset {
    _kernel.reset();
}

///Puts all notes in Release...a kinder, gentler "reset".
- (void)stopAllNotes {
    _kernel.stopAllNotes();
}

///Resets DSP
- (void)resetDSP {
    _kernel.resetDSP();
}


- (void)createParameters {

    _messageQueue = [[AEMessageQueue alloc] init];

    //standardGeneratorSetup(SynthOne)
    self.rampTime = AKSettings.rampTime;
    self.defaultFormat = [[AVAudioFormat alloc] initStandardFormatWithSampleRate:AKSettings.sampleRate
                                                                        channels:AKSettings.numberOfChannels];
    _kernel.init(self.defaultFormat.channelCount, self.defaultFormat.sampleRate);
    _outputBusBuffer.init(self.defaultFormat, 2);
    self.outputBus = _outputBusBuffer.bus;
    self.outputBusArray = [[AUAudioUnitBusArray alloc] initWithAudioUnit:self
                                                                 busType:AUAudioUnitBusTypeOutput
                                                                  busses:@[self.outputBus]];
    _kernel.audioUnit = self;

    __block AKSynthOneDSPKernel *blockKernel = &_kernel;
    
    self.parameterTree.implementorValueObserver = ^(AUParameter *param, AUValue value) {
        blockKernel->setParameter(param.address, value);
        const AKSynthOneParameter p = (AKSynthOneParameter)param.address;
        blockKernel->setAK1Parameter(p, value);
    };
    
    self.parameterTree.implementorValueProvider = ^(AUParameter *param) {
        //?
        return blockKernel->getParameter(param.address);
        //?
        const AKSynthOneParameter p = (AKSynthOneParameter)param.address;
        return blockKernel->getAK1Parameter(p);
    };

    
    
    AUParameter *index1AU =                [AUParameter parameter:@"index1"                name:@"Index 1"                 address:index1                min:0.0 max:1.0   unit:kAudioUnitParameterUnit_Generic];
    AUParameter *index2AU =                [AUParameter parameter:@"index2"                name:@"Index 2"                 address:index2                min:0.0 max:1.0   unit:kAudioUnitParameterUnit_Generic];
    AUParameter *morphBalanceAU =          [AUParameter parameter:@"morphBalance"          name:@"Morph Balance"           address:morphBalance          min:0.0 max:1.0   unit:kAudioUnitParameterUnit_Generic];
    AUParameter *morph1SemitoneOffsetAU =  [AUParameter parameter:@"morph1SemitoneOffset"  name:@"Morph 1 Semitone Offset" address:morph1SemitoneOffset  min:0.0 max:1.0   unit:kAudioUnitParameterUnit_Generic];
    AUParameter *morph2SemitoneOffsetAU =  [AUParameter parameter:@"morph2SemitoneOffset"  name:@"Morph 2 Semitone Offset" address:morph2SemitoneOffset  min:0.0 max:1.0   unit:kAudioUnitParameterUnit_Generic];
    AUParameter *morph1VolumeAU =          [AUParameter parameter:@"morph1Volume"          name:@"Morph 1 Volume"          address:morph1Volume          min:0.0 max:1.0   unit:kAudioUnitParameterUnit_Generic];
    AUParameter *morph2VolumeAU =          [AUParameter parameter:@"morph2Volume"          name:@"Morph 2 Volume"          address:morph2Volume          min:0.0 max:1.0   unit:kAudioUnitParameterUnit_Generic];
    AUParameter *subVolumeAU =             [AUParameter parameter:@"subVolume"             name:@"Sub Volume"              address:subVolume             min:0.0 max:1.0   unit:kAudioUnitParameterUnit_Generic];
    AUParameter *subOctaveDownAU =         [AUParameter parameter:@"subOctaveDown"         name:@"Sub Octave Down"         address:subOctaveDown         min:0.0 max:1.0   unit:kAudioUnitParameterUnit_Generic];
    AUParameter *subIsSquareAU =           [AUParameter parameter:@"subIsSquare"           name:@"Sub Is Square"           address:subIsSquare           min:0.0 max:1.0   unit:kAudioUnitParameterUnit_Generic];
    AUParameter *fmVolumeAU =              [AUParameter parameter:@"fmVolume"              name:@"FM Volume"               address:fmVolume              min:0.0 max:1.0   unit:kAudioUnitParameterUnit_Generic];
    AUParameter *fmAmountAU =              [AUParameter parameter:@"fmAmount"              name:@"FM Amont"                address:fmAmount              min:0.0 max:1.0   unit:kAudioUnitParameterUnit_Generic];
    AUParameter *noiseVolumeAU =           [AUParameter parameter:@"noiseVolume"           name:@"Noise Volume"            address:noiseVolume           min:0.0 max:1.0   unit:kAudioUnitParameterUnit_Generic];
    AUParameter *lfo1IndexAU =              [AUParameter parameter:@"lfo1Index"              name:@"LFO 1 Index"               address:lfo1Index              min:0.0 max:1.0   unit:kAudioUnitParameterUnit_Generic];
    AUParameter *lfo1AmplitudeAU =          [AUParameter parameter:@"lfo1Amplitude"          name:@"LFO 1 Amplitude"           address:lfo1Amplitude          min:0.0 max:1.0   unit:kAudioUnitParameterUnit_Generic];
    AUParameter *lfo1RateAU =               [AUParameter parameter:@"lfo1Rate"               name:@"LFO 1 Rate"                address:lfo1Rate               min:0.0 max:1.0   unit:kAudioUnitParameterUnit_Generic];
    AUParameter *cutoffAU =                [AUParameter parameter:@"cutoff"                name:@"Cutoff"                  address:cutoff                min:0.0 max:22000 unit:kAudioUnitParameterUnit_Hertz];
    AUParameter *resonanceAU =             [AUParameter parameter:@"resonance"             name:@"Resonance"               address:resonance             min:0.0 max:1.0   unit:kAudioUnitParameterUnit_Generic];
    AUParameter *filterMixAU =             [AUParameter parameter:@"filterMix"             name:@"Filter Mix"              address:filterMix             min:0.0 max:1.0   unit:kAudioUnitParameterUnit_Generic];
    AUParameter *filterADSRMixAU =         [AUParameter parameter:@"filterADSRMix"         name:@"Filter ADSR Mix"         address:filterADSRMix         min:0.0 max:1.0   unit:kAudioUnitParameterUnit_Generic];
    AUParameter *isMonoAU =                [AUParameter parameter:@"isMono"                name:@"Is Mono"                 address:isMono                min:0.0 max:1.0   unit:kAudioUnitParameterUnit_Generic];
    AUParameter *glideAU =                 [AUParameter parameter:@"glide"                 name:@"Glide"                   address:glide                 min:0.0 max:1.0   unit:kAudioUnitParameterUnit_Generic];
    AUParameter *filterAttackDurationAU =  [AUParameter parameter:@"filterAttackDuration"  name:@"Filter Attack Duration"  address:filterAttackDuration  min:0.0 max:1.0   unit:kAudioUnitParameterUnit_Generic];
    AUParameter *filterDecayDurationAU =   [AUParameter parameter:@"filterDecayDuration"   name:@"Filter Decay Duration"   address:filterDecayDuration   min:0.0 max:1.0   unit:kAudioUnitParameterUnit_Generic];
    AUParameter *filterSustainLevelAU =    [AUParameter parameter:@"filterSustainLevel"    name:@"Filter Sustain Level"    address:filterSustainLevel    min:0.0 max:1.0   unit:kAudioUnitParameterUnit_Generic];
    AUParameter *filterReleaseDurationAU = [AUParameter parameter:@"filterReleaseDuration" name:@"Filter Release Duration" address:filterReleaseDuration min:0.0 max:1.0   unit:kAudioUnitParameterUnit_Generic];
    AUParameter *attackDurationAU =        [AUParameter parameter:@"attackDuration"        name:@"Attack Duration"         address:attackDuration        min:0.0 max:1.0   unit:kAudioUnitParameterUnit_Generic];
    AUParameter *decayDurationAU =         [AUParameter parameter:@"decayDuration"         name:@"Decay Duration"          address:decayDuration         min:0.0 max:1.0   unit:kAudioUnitParameterUnit_Generic];
    AUParameter *sustainLevelAU =          [AUParameter parameter:@"sustainLevel"          name:@"Sustain Level"           address:sustainLevel          min:0.0 max:1.0   unit:kAudioUnitParameterUnit_Generic];
    AUParameter *releaseDurationAU =       [AUParameter parameter:@"releaseDuration"       name:@"Release Duration"        address:releaseDuration       min:0.0 max:1.0   unit:kAudioUnitParameterUnit_Generic];
    AUParameter *morph2DetuningAU =        [AUParameter parameter:@"morph2Detuning"        name:@"Detuning Offset"         address:morph2Detuning        min:0.0 max:1.0   unit:kAudioUnitParameterUnit_Generic];
    AUParameter *detuningMultiplierAU =    [AUParameter parameter:@"detuningMultiplier"    name:@"Detuning Multiplier"     address:detuningMultiplier    min:0.0 max:1.0   unit:kAudioUnitParameterUnit_Generic];
    AUParameter *masterVolumeAU =          [AUParameter parameter:@"masterVolume"          name:@"Master Volume"           address:masterVolume          min:0.0 max:2.0   unit:kAudioUnitParameterUnit_Generic];
    AUParameter *bitCrushDepthAU =         [AUParameter parameter:@"bitCrushDepth"         name:@"Bit Depth"               address:bitCrushDepth         min:0.0 max:1.0   unit:kAudioUnitParameterUnit_Generic];
    AUParameter *bitCrushSampleRateAU =    [AUParameter parameter:@"bitCrushSampleRate"    name:@"Sample Rate"             address:bitCrushSampleRate    min:0.0 max:1.0   unit:kAudioUnitParameterUnit_Generic];
    AUParameter *autoPanAmountAU =             [AUParameter parameter:@"autoPanAmount"             name:@"Auto Pan Amount"             address:autoPanAmount             min:0.0 max:1.0   unit:kAudioUnitParameterUnit_Generic];
    AUParameter *autoPanFrequencyAU =      [AUParameter parameter:@"autoPanFrequency"      name:@"Auto Pan Frequency"      address:autoPanFrequency      min:0.0 max:10.0  unit:kAudioUnitParameterUnit_Hertz];
    AUParameter *reverbOnAU =              [AUParameter parameter:@"reverbOn"              name:@"Reverb On"               address:reverbOn              min:0.0 max:1.0   unit:kAudioUnitParameterUnit_Generic];
    AUParameter *reverbFeedbackAU =        [AUParameter parameter:@"reverbFeedback"        name:@"Reverb Feedback"         address:reverbFeedback        min:0.0 max:1.0   unit:kAudioUnitParameterUnit_Generic];
    AUParameter *reverbHighPassAU =        [AUParameter parameter:@"reverbHighPass"        name:@"Reverb HighPass"         address:reverbHighPass        min:0.0 max:1.0   unit:kAudioUnitParameterUnit_Hertz];
    AUParameter *reverbMixAU =             [AUParameter parameter:@"reverbMix"             name:@"Reverb Mix"              address:reverbMix             min:0.0 max:1.0   unit:kAudioUnitParameterUnit_Generic];
    AUParameter *delayOnAU =               [AUParameter parameter:@"delayOn"               name:@"Delay On"                address:delayOn               min:0.0 max:1.0   unit:kAudioUnitParameterUnit_Generic];
    AUParameter *delayFeedbackAU =         [AUParameter parameter:@"delayFeedback"         name:@"Delay Feedback"          address:delayFeedback         min:0.0 max:1.0   unit:kAudioUnitParameterUnit_Generic];
    AUParameter *delayTimeAU =             [AUParameter parameter:@"delayTime"             name:@"Delay Time"              address:delayTime             min:0.0 max:1.0   unit:kAudioUnitParameterUnit_Generic];
    AUParameter *delayMixAU =              [AUParameter parameter:@"delayMix"              name:@"Delay Mix"               address:delayMix              min:0.0 max:1.0   unit:kAudioUnitParameterUnit_Generic];
    AUParameter *lfo2IndexAU =              [AUParameter parameter:@"lfo2Index"              name:@"LFO 2 Index"               address:lfo2Index              min:0.0 max:1.0   unit:kAudioUnitParameterUnit_Generic];
    AUParameter *lfo2AmplitudeAU =          [AUParameter parameter:@"lfo2Amplitude"          name:@"LFO 2 Amplitude"           address:lfo2Amplitude          min:0.0 max:1.0   unit:kAudioUnitParameterUnit_Generic];
    AUParameter *lfo2RateAU =               [AUParameter parameter:@"lfo2Rate"               name:@"LFO 2 Rate"                address:lfo2Rate               min:0.0 max:1.0   unit:kAudioUnitParameterUnit_Generic];
    AUParameter *cutoffLFOAU =               [AUParameter parameter:@"cutoffLFO"               name:@"Cutoff LFO"                address:cutoffLFO               min:0.0 max:2.0   unit:kAudioUnitParameterUnit_Generic];
    AUParameter *resonanceLFOAU =             [AUParameter parameter:@"resonanceLFO"            name:@"resonance LFO"             address:resonanceLFO            min:0.0 max:2.0   unit:kAudioUnitParameterUnit_Generic];
    AUParameter *oscMixLFOAU =                [AUParameter parameter:@"oscMixLFO"               name:@"oscMixLFO"                address:oscMixLFO               min:0.0 max:2.0   unit:kAudioUnitParameterUnit_Generic];
    AUParameter *sustainLFOAU =               [AUParameter parameter:@"sustainLFO"              name:@"sustainLFO"               address:sustainLFO              min:0.0 max:2.0   unit:kAudioUnitParameterUnit_Generic];
    AUParameter *decayLFOAU =                [AUParameter parameter:@"decayLFO"               name:@"decayLFO"                address:decayLFO               min:0.0 max:2.0   unit:kAudioUnitParameterUnit_Generic];
    AUParameter *noiseLFOAU =                [AUParameter parameter:@"noiseLFO"               name:@"noiseLFO"                address:noiseLFO               min:0.0 max:2.0   unit:kAudioUnitParameterUnit_Generic];
    AUParameter *fmLFOAU =                    [AUParameter parameter:@"fmLFO"                   name:@"fmLFO"                    address:fmLFO                   min:0.0 max:2.0   unit:kAudioUnitParameterUnit_Generic];
    AUParameter *detuneLFOAU =                [AUParameter parameter:@"detuneLFO"               name:@"detuneLFO"                address:detuneLFO               min:0.0 max:2.0   unit:kAudioUnitParameterUnit_Generic];
    AUParameter *filterEnvLFOAU =             [AUParameter parameter:@"filterEnvLFO"            name:@"filterEnvLFO"             address:filterEnvLFO            min:0.0 max:2.0   unit:kAudioUnitParameterUnit_Generic];
    AUParameter *pitchLFOAU =                 [AUParameter parameter:@"pitchLFO"                name:@"pitchLFO"                 address:pitchLFO                min:0.0 max:2.0   unit:kAudioUnitParameterUnit_Generic];
    AUParameter *bitcrushLFOAU =              [AUParameter parameter:@"bitcrushLFO"             name:@"bitcrushLFO"              address:bitcrushLFO             min:0.0 max:2.0   unit:kAudioUnitParameterUnit_Generic];
    AUParameter *autopanLFOAU =               [AUParameter parameter:@"autopanLFO"              name:@"autopanLFO"               address:autopanLFO              min:0.0 max:2.0   unit:kAudioUnitParameterUnit_Generic];
    AUParameter *arpDirectionAU = [AUParameter parameter:@"arpDirection" name:@"arpDirection" address:arpDirection min:0.0 max:2.0 unit:kAudioUnitParameterUnit_Generic];
    AUParameter *arpIntervalAU = [AUParameter parameter:@"arpInterval" name:@"arpInterval" address:arpInterval min:0.0 max:2.0 unit:kAudioUnitParameterUnit_Generic];
    AUParameter *arpIsOnAU = [AUParameter parameter:@"arpIsOn" name:@"arpIsOn" address:arpIsOn min:0.0 max:2.0 unit:kAudioUnitParameterUnit_Generic];
    AUParameter *arpOctaveAU = [AUParameter parameter:@"arpOctave" name:@"arpOctave" address:arpOctave min:0.0 max:2.0 unit:kAudioUnitParameterUnit_Generic];
    AUParameter *arpRateAU = [AUParameter parameter:@"arpRate" name:@"arpRate" address:arpRate min:0.0 max:2.0 unit:kAudioUnitParameterUnit_Generic];
    AUParameter *arpIsSequencerAU = [AUParameter parameter:@"arpIsSequencer" name:@"arpIsSequencer" address:arpIsSequencer min:0.0 max:2.0 unit:kAudioUnitParameterUnit_Generic];
    AUParameter *arpTotalStepsAU = [AUParameter parameter:@"arpTotalSteps" name:@"arpTotalSteps" address:arpTotalSteps min:0.0 max:2.0 unit:kAudioUnitParameterUnit_Generic];
    AUParameter *arpSeqPattern00AU = [AUParameter parameter:@"arpSeqPattern00" name:@"arpSeqPattern00" address:arpSeqPattern00 min:0.0 max:2.0 unit:kAudioUnitParameterUnit_Generic];
    AUParameter *arpSeqPattern01AU = [AUParameter parameter:@"arpSeqPattern01" name:@"arpSeqPattern01" address:arpSeqPattern01 min:0.0 max:2.0 unit:kAudioUnitParameterUnit_Generic];
    AUParameter *arpSeqPattern02AU = [AUParameter parameter:@"arpSeqPattern02" name:@"arpSeqPattern02" address:arpSeqPattern02 min:0.0 max:2.0 unit:kAudioUnitParameterUnit_Generic];
    AUParameter *arpSeqPattern03AU = [AUParameter parameter:@"arpSeqPattern03" name:@"arpSeqPattern03" address:arpSeqPattern03 min:0.0 max:2.0 unit:kAudioUnitParameterUnit_Generic];
    AUParameter *arpSeqPattern04AU = [AUParameter parameter:@"arpSeqPattern04" name:@"arpSeqPattern04" address:arpSeqPattern04 min:0.0 max:2.0 unit:kAudioUnitParameterUnit_Generic];
    AUParameter *arpSeqPattern05AU = [AUParameter parameter:@"arpSeqPattern05" name:@"arpSeqPattern05" address:arpSeqPattern05 min:0.0 max:2.0 unit:kAudioUnitParameterUnit_Generic];
    AUParameter *arpSeqPattern06AU = [AUParameter parameter:@"arpSeqPattern06" name:@"arpSeqPattern06" address:arpSeqPattern06 min:0.0 max:2.0 unit:kAudioUnitParameterUnit_Generic];
    AUParameter *arpSeqPattern07AU = [AUParameter parameter:@"arpSeqPattern07" name:@"arpSeqPattern07" address:arpSeqPattern07 min:0.0 max:2.0 unit:kAudioUnitParameterUnit_Generic];
    AUParameter *arpSeqPattern08AU = [AUParameter parameter:@"arpSeqPattern08" name:@"arpSeqPattern08" address:arpSeqPattern08 min:0.0 max:2.0 unit:kAudioUnitParameterUnit_Generic];
    AUParameter *arpSeqPattern09AU = [AUParameter parameter:@"arpSeqPattern09" name:@"arpSeqPattern09" address:arpSeqPattern09 min:0.0 max:2.0 unit:kAudioUnitParameterUnit_Generic];
    AUParameter *arpSeqPattern10AU = [AUParameter parameter:@"arpSeqPattern10" name:@"arpSeqPattern10" address:arpSeqPattern10 min:0.0 max:2.0 unit:kAudioUnitParameterUnit_Generic];
    AUParameter *arpSeqPattern11AU = [AUParameter parameter:@"arpSeqPattern11" name:@"arpSeqPattern11" address:arpSeqPattern11 min:0.0 max:2.0 unit:kAudioUnitParameterUnit_Generic];
    AUParameter *arpSeqPattern12AU = [AUParameter parameter:@"arpSeqPattern12" name:@"arpSeqPattern12" address:arpSeqPattern12 min:0.0 max:2.0 unit:kAudioUnitParameterUnit_Generic];
    AUParameter *arpSeqPattern13AU = [AUParameter parameter:@"arpSeqPattern13" name:@"arpSeqPattern13" address:arpSeqPattern13 min:0.0 max:2.0 unit:kAudioUnitParameterUnit_Generic];
    AUParameter *arpSeqPattern14AU = [AUParameter parameter:@"arpSeqPattern14" name:@"arpSeqPattern14" address:arpSeqPattern14 min:0.0 max:2.0 unit:kAudioUnitParameterUnit_Generic];
    AUParameter *arpSeqPattern15AU = [AUParameter parameter:@"arpSeqPattern15" name:@"arpSeqPattern15" address:arpSeqPattern15 min:0.0 max:2.0 unit:kAudioUnitParameterUnit_Generic];
    AUParameter *arpSeqOctBoost00AU = [AUParameter parameter:@"arpSeqOctBoost00" name:@"arpSeqOctBoost00" address:arpSeqOctBoost00 min:0.0 max:2.0 unit:kAudioUnitParameterUnit_Generic];
    AUParameter *arpSeqOctBoost01AU = [AUParameter parameter:@"arpSeqOctBoost01" name:@"arpSeqOctBoost01" address:arpSeqOctBoost01 min:0.0 max:2.0 unit:kAudioUnitParameterUnit_Generic];
    AUParameter *arpSeqOctBoost02AU = [AUParameter parameter:@"arpSeqOctBoost02" name:@"arpSeqOctBoost02" address:arpSeqOctBoost02 min:0.0 max:2.0 unit:kAudioUnitParameterUnit_Generic];
    AUParameter *arpSeqOctBoost03AU = [AUParameter parameter:@"arpSeqOctBoost03" name:@"arpSeqOctBoost03" address:arpSeqOctBoost03 min:0.0 max:2.0 unit:kAudioUnitParameterUnit_Generic];
    AUParameter *arpSeqOctBoost04AU = [AUParameter parameter:@"arpSeqOctBoost04" name:@"arpSeqOctBoost04" address:arpSeqOctBoost04 min:0.0 max:2.0 unit:kAudioUnitParameterUnit_Generic];
    AUParameter *arpSeqOctBoost05AU = [AUParameter parameter:@"arpSeqOctBoost05" name:@"arpSeqOctBoost05" address:arpSeqOctBoost05 min:0.0 max:2.0 unit:kAudioUnitParameterUnit_Generic];
    AUParameter *arpSeqOctBoost06AU = [AUParameter parameter:@"arpSeqOctBoost06" name:@"arpSeqOctBoost06" address:arpSeqOctBoost06 min:0.0 max:2.0 unit:kAudioUnitParameterUnit_Generic];
    AUParameter *arpSeqOctBoost07AU = [AUParameter parameter:@"arpSeqOctBoost07" name:@"arpSeqOctBoost07" address:arpSeqOctBoost07 min:0.0 max:2.0 unit:kAudioUnitParameterUnit_Generic];
    AUParameter *arpSeqOctBoost08AU = [AUParameter parameter:@"arpSeqOctBoost08" name:@"arpSeqOctBoost08" address:arpSeqOctBoost08 min:0.0 max:2.0 unit:kAudioUnitParameterUnit_Generic];
    AUParameter *arpSeqOctBoost09AU = [AUParameter parameter:@"arpSeqOctBoost09" name:@"arpSeqOctBoost09" address:arpSeqOctBoost09 min:0.0 max:2.0 unit:kAudioUnitParameterUnit_Generic];
    AUParameter *arpSeqOctBoost10AU = [AUParameter parameter:@"arpSeqOctBoost10" name:@"arpSeqOctBoost10" address:arpSeqOctBoost10 min:0.0 max:2.0 unit:kAudioUnitParameterUnit_Generic];
    AUParameter *arpSeqOctBoost11AU = [AUParameter parameter:@"arpSeqOctBoost11" name:@"arpSeqOctBoost11" address:arpSeqOctBoost11 min:0.0 max:2.0 unit:kAudioUnitParameterUnit_Generic];
    AUParameter *arpSeqOctBoost12AU = [AUParameter parameter:@"arpSeqOctBoost12" name:@"arpSeqOctBoost12" address:arpSeqOctBoost12 min:0.0 max:2.0 unit:kAudioUnitParameterUnit_Generic];
    AUParameter *arpSeqOctBoost13AU = [AUParameter parameter:@"arpSeqOctBoost13" name:@"arpSeqOctBoost13" address:arpSeqOctBoost13 min:0.0 max:2.0 unit:kAudioUnitParameterUnit_Generic];
    AUParameter *arpSeqOctBoost14AU = [AUParameter parameter:@"arpSeqOctBoost14" name:@"arpSeqOctBoost14" address:arpSeqOctBoost14 min:0.0 max:2.0 unit:kAudioUnitParameterUnit_Generic];
    AUParameter *arpSeqOctBoost15AU = [AUParameter parameter:@"arpSeqOctBoost15" name:@"arpSeqOctBoost15" address:arpSeqOctBoost15 min:0.0 max:2.0 unit:kAudioUnitParameterUnit_Generic];
    AUParameter *arpSeqNoteOn00AU = [AUParameter parameter:@"arpSeqNoteOn00" name:@"arpSeqNoteOn00" address:arpSeqNoteOn00 min:0.0 max:2.0 unit:kAudioUnitParameterUnit_Generic];
    AUParameter *arpSeqNoteOn01AU = [AUParameter parameter:@"arpSeqNoteOn01" name:@"arpSeqNoteOn01" address:arpSeqNoteOn01 min:0.0 max:2.0 unit:kAudioUnitParameterUnit_Generic];
    AUParameter *arpSeqNoteOn02AU = [AUParameter parameter:@"arpSeqNoteOn02" name:@"arpSeqNoteOn02" address:arpSeqNoteOn02 min:0.0 max:2.0 unit:kAudioUnitParameterUnit_Generic];
    AUParameter *arpSeqNoteOn03AU = [AUParameter parameter:@"arpSeqNoteOn03" name:@"arpSeqNoteOn03" address:arpSeqNoteOn03 min:0.0 max:2.0 unit:kAudioUnitParameterUnit_Generic];
    AUParameter *arpSeqNoteOn04AU = [AUParameter parameter:@"arpSeqNoteOn04" name:@"arpSeqNoteOn04" address:arpSeqNoteOn04 min:0.0 max:2.0 unit:kAudioUnitParameterUnit_Generic];
    AUParameter *arpSeqNoteOn05AU = [AUParameter parameter:@"arpSeqNoteOn05" name:@"arpSeqNoteOn05" address:arpSeqNoteOn05 min:0.0 max:2.0 unit:kAudioUnitParameterUnit_Generic];
    AUParameter *arpSeqNoteOn06AU = [AUParameter parameter:@"arpSeqNoteOn06" name:@"arpSeqNoteOn06" address:arpSeqNoteOn06 min:0.0 max:2.0 unit:kAudioUnitParameterUnit_Generic];
    AUParameter *arpSeqNoteOn07AU = [AUParameter parameter:@"arpSeqNoteOn07" name:@"arpSeqNoteOn07" address:arpSeqNoteOn07 min:0.0 max:2.0 unit:kAudioUnitParameterUnit_Generic];
    AUParameter *arpSeqNoteOn08AU = [AUParameter parameter:@"arpSeqNoteOn08" name:@"arpSeqNoteOn08" address:arpSeqNoteOn08 min:0.0 max:2.0 unit:kAudioUnitParameterUnit_Generic];
    AUParameter *arpSeqNoteOn09AU = [AUParameter parameter:@"arpSeqNoteOn09" name:@"arpSeqNoteOn09" address:arpSeqNoteOn09 min:0.0 max:2.0 unit:kAudioUnitParameterUnit_Generic];
    AUParameter *arpSeqNoteOn10AU = [AUParameter parameter:@"arpSeqNoteOn10" name:@"arpSeqNoteOn10" address:arpSeqNoteOn10 min:0.0 max:2.0 unit:kAudioUnitParameterUnit_Generic];
    AUParameter *arpSeqNoteOn11AU = [AUParameter parameter:@"arpSeqNoteOn11" name:@"arpSeqNoteOn11" address:arpSeqNoteOn11 min:0.0 max:2.0 unit:kAudioUnitParameterUnit_Generic];
    AUParameter *arpSeqNoteOn12AU = [AUParameter parameter:@"arpSeqNoteOn12" name:@"arpSeqNoteOn12" address:arpSeqNoteOn12 min:0.0 max:2.0 unit:kAudioUnitParameterUnit_Generic];
    AUParameter *arpSeqNoteOn13AU = [AUParameter parameter:@"arpSeqNoteOn13" name:@"arpSeqNoteOn13" address:arpSeqNoteOn13 min:0.0 max:2.0 unit:kAudioUnitParameterUnit_Generic];
    AUParameter *arpSeqNoteOn14AU = [AUParameter parameter:@"arpSeqNoteOn14" name:@"arpSeqNoteOn14" address:arpSeqNoteOn14 min:0.0 max:2.0 unit:kAudioUnitParameterUnit_Generic];
    AUParameter *arpSeqNoteOn15AU = [AUParameter parameter:@"arpSeqNoteOn15" name:@"arpSeqNoteOn15" address:arpSeqNoteOn15 min:0.0 max:2.0 unit:kAudioUnitParameterUnit_Generic];
    AUParameter *filterTypeAU = [AUParameter parameter:@"filterType" name:@"filterType" address:filterType min:0.0 max:2.0 unit:kAudioUnitParameterUnit_Generic];
    AUParameter *phaserMixAU = [AUParameter parameter:@"phaserMix" name:@"phaserMix" address:phaserMix min:0.0 max:1.0 unit:kAudioUnitParameterUnit_Generic];
    AUParameter *phaserRateAU = [AUParameter parameter:@"phaserRate" name:@"phaserRate" address:phaserRate min:24 max:300 unit:kAudioUnitParameterUnit_Generic];
    AUParameter *phaserFeedbackAU = [AUParameter parameter:@"phaserFeedback" name:@"phaserFeedback" address:phaserFeedback min:0.0 max:0.8 unit:kAudioUnitParameterUnit_Generic];
    AUParameter *phaserNotchWidthAU = [AUParameter parameter:@"phaserNotchWidth" name:@"phaserNotchWidth" address:phaserNotchWidth min:100 max:3000 unit:kAudioUnitParameterUnit_Generic];
    
    // Initialize the parameter values.
    index1AU.value = 0;
    index2AU.value = 0;
    morphBalanceAU.value = 0.5;
    morph1SemitoneOffsetAU.value = 0;
    morph2SemitoneOffsetAU.value = 0;
    morph1VolumeAU.value = 1;
    morph2VolumeAU.value = 1;
    subVolumeAU.value = 0;
    subOctaveDownAU.value = 1;
    subIsSquareAU.value = 0;
    fmVolumeAU.value = 0;
    fmAmountAU.value = 0;
    noiseVolumeAU.value = 0;
    lfo1IndexAU.value = 0;
    lfo1AmplitudeAU.value = 1;
    lfo1RateAU.value = 0;
    cutoffAU.value = 1000;
    resonanceAU.value = 0.5;
    filterMixAU.value = 1;
    filterADSRMixAU.value = 0.5;
    isMonoAU.value = 0;
    glideAU.value = 0;
    filterAttackDurationAU.value = 0.1;
    filterDecayDurationAU.value = 0.1;
    filterSustainLevelAU.value = 1.0;
    filterReleaseDurationAU.value = 0.1;
    attackDurationAU.value = 0.1;
    decayDurationAU.value = 0.1;
    sustainLevelAU.value = 1.0;
    releaseDurationAU.value = 0.1;
    morph2DetuningAU.value = 0.0;
    detuningMultiplierAU.value = 1.0;
    masterVolumeAU.value = 0.8;
    bitCrushDepthAU.value = 24;
    bitCrushSampleRateAU.value = 44100;
    autoPanAmountAU.value = 0;
    autoPanFrequencyAU.value = 0;
    reverbOnAU.value = 0;
    reverbFeedbackAU.value = 0;
    reverbHighPassAU.value = 1000;
    reverbMixAU.value = 0;
    delayOnAU.value = 0;
    delayFeedbackAU.value = 0;
    delayTimeAU.value = 0;
    delayMixAU.value = 0;
    lfo2IndexAU.value = 0;
    lfo2AmplitudeAU.value = 1;
    lfo2RateAU.value = 0;
    cutoffLFOAU.value = 0;
    resonanceLFOAU.value = 0;
    oscMixLFOAU.value = 0;
    sustainLFOAU.value = 0;
    decayLFOAU.value = 0;
    noiseLFOAU.value = 0;
    fmLFOAU.value = 0;
    detuneLFOAU.value = 0;
    filterEnvLFOAU.value = 0;
    pitchLFOAU.value = 0;
    bitcrushLFOAU.value = 0;
    autopanLFOAU.value = 0;
    arpDirectionAU.value = 0;
    arpIntervalAU.value = 0;
    arpIsOnAU.value = 0;
    arpOctaveAU.value = 0;
    arpRateAU.value = 120;
    arpIsSequencerAU.value = 0;
    arpTotalStepsAU.value = 8;
    arpSeqPattern00AU.value = 0;
    arpSeqPattern01AU.value = 0;
    arpSeqPattern02AU.value = 0;
    arpSeqPattern03AU.value = 0;
    arpSeqPattern04AU.value = 0;
    arpSeqPattern05AU.value = 0;
    arpSeqPattern06AU.value = 0;
    arpSeqPattern07AU.value = 0;
    arpSeqPattern08AU.value = 0;
    arpSeqPattern09AU.value = 0;
    arpSeqPattern10AU.value = 0;
    arpSeqPattern11AU.value = 0;
    arpSeqPattern12AU.value = 0;
    arpSeqPattern13AU.value = 0;
    arpSeqPattern14AU.value = 0;
    arpSeqPattern15AU.value = 0;
    arpSeqOctBoost00AU.value = 0;
    arpSeqOctBoost01AU.value = 0;
    arpSeqOctBoost02AU.value = 0;
    arpSeqOctBoost03AU.value = 0;
    arpSeqOctBoost04AU.value = 0;
    arpSeqOctBoost05AU.value = 0;
    arpSeqOctBoost06AU.value = 0;
    arpSeqOctBoost07AU.value = 0;
    arpSeqOctBoost08AU.value = 0;
    arpSeqOctBoost09AU.value = 0;
    arpSeqOctBoost10AU.value = 0;
    arpSeqOctBoost11AU.value = 0;
    arpSeqOctBoost12AU.value = 0;
    arpSeqOctBoost13AU.value = 0;
    arpSeqOctBoost14AU.value = 0;
    arpSeqOctBoost15AU.value = 0;
    arpSeqNoteOn00AU.value = 1;
    arpSeqNoteOn01AU.value = 1;
    arpSeqNoteOn02AU.value = 1;
    arpSeqNoteOn03AU.value = 1;
    arpSeqNoteOn04AU.value = 1;
    arpSeqNoteOn05AU.value = 1;
    arpSeqNoteOn06AU.value = 1;
    arpSeqNoteOn07AU.value = 1;
    arpSeqNoteOn08AU.value = 1;
    arpSeqNoteOn09AU.value = 1;
    arpSeqNoteOn10AU.value = 1;
    arpSeqNoteOn11AU.value = 1;
    arpSeqNoteOn12AU.value = 1;
    arpSeqNoteOn13AU.value = 1;
    arpSeqNoteOn14AU.value = 1;
    arpSeqNoteOn15AU.value = 1;
    filterTypeAU.value = 0;
    phaserMixAU.value = 0;
    phaserRateAU.value = 30;
    phaserFeedbackAU.value = 0;
    phaserNotchWidthAU.value = 500;

    _kernel.setParameter(index1, index1AU.value);
    _kernel.setParameter(index2, index2AU.value);
    _kernel.setParameter(morphBalance, morphBalanceAU.value);
    _kernel.setParameter(morph1SemitoneOffset, morph1SemitoneOffsetAU.value);
    _kernel.setParameter(morph2SemitoneOffset, morph2SemitoneOffsetAU.value);
    _kernel.setParameter(morph1Volume, morph1VolumeAU.value);
    _kernel.setParameter(morph2Volume, morph2VolumeAU.value);
    _kernel.setParameter(subVolume, subVolumeAU.value);
    _kernel.setParameter(subOctaveDown, subOctaveDownAU.value);
    _kernel.setParameter(subIsSquare, subIsSquareAU.value);
    _kernel.setParameter(fmVolume, fmVolumeAU.value);
    _kernel.setParameter(fmAmount, fmAmountAU.value);
    _kernel.setParameter(noiseVolume, noiseVolumeAU.value);
    _kernel.setParameter(lfo1Index, lfo1IndexAU.value);
    _kernel.setParameter(lfo1Amplitude, lfo1AmplitudeAU.value);
    _kernel.setParameter(lfo1Rate, lfo1RateAU.value);
    _kernel.setParameter(cutoff, cutoffAU.value);
    _kernel.setParameter(resonance, resonanceAU.value);
    _kernel.setParameter(filterMix, filterMixAU.value);
    _kernel.setParameter(filterADSRMix, filterADSRMixAU.value);
    _kernel.setParameter(isMono, isMonoAU.value);
    _kernel.setParameter(glide, glideAU.value);
    _kernel.setParameter(filterAttackDuration, filterAttackDurationAU.value);
    _kernel.setParameter(filterDecayDuration, filterDecayDurationAU.value);
    _kernel.setParameter(filterSustainLevel, filterSustainLevelAU.value);
    _kernel.setParameter(filterReleaseDuration, filterReleaseDurationAU.value);
    _kernel.setParameter(attackDuration, attackDurationAU.value);
    _kernel.setParameter(decayDuration, decayDurationAU.value);
    _kernel.setParameter(sustainLevel, sustainLevelAU.value);
    _kernel.setParameter(releaseDuration, releaseDurationAU.value);
    _kernel.setParameter(morph2Detuning, morph2DetuningAU.value);
    _kernel.setParameter(detuningMultiplier, detuningMultiplierAU.value);
    _kernel.setParameter(masterVolume, masterVolumeAU.value);
    _kernel.setParameter(bitCrushDepth, bitCrushDepthAU.value);
    _kernel.setParameter(bitCrushSampleRate, bitCrushSampleRateAU.value);
    _kernel.setParameter(autoPanAmount, autoPanAmountAU.value);
    _kernel.setParameter(autoPanFrequency, autoPanFrequencyAU.value);
    _kernel.setParameter(reverbOn, reverbOnAU.value);
    _kernel.setParameter(reverbFeedback, reverbFeedbackAU.value);
    _kernel.setParameter(reverbHighPass, reverbHighPassAU.value);
    _kernel.setParameter(reverbMix, reverbMixAU.value);
    _kernel.setParameter(delayOn, delayOnAU.value);
    _kernel.setParameter(delayFeedback, delayFeedbackAU.value);
    _kernel.setParameter(delayTime, delayTimeAU.value);
    _kernel.setParameter(delayMix, delayMixAU.value);
    _kernel.setParameter(lfo2Index, lfo2IndexAU.value);
    _kernel.setParameter(lfo2Amplitude, lfo2AmplitudeAU.value);
    _kernel.setParameter(lfo2Rate, lfo2RateAU.value);
    _kernel.setParameter(cutoffLFO, cutoffLFOAU.value);
    _kernel.setParameter(resonanceLFO, resonanceLFOAU.value);
    _kernel.setParameter(oscMixLFO, oscMixLFOAU.value);
    _kernel.setParameter(sustainLFO, sustainLFOAU.value);
    _kernel.setParameter(decayLFO, decayLFOAU.value);
    _kernel.setParameter(noiseLFO, noiseLFOAU.value);
    _kernel.setParameter(fmLFO, fmLFOAU.value);
    _kernel.setParameter(detuneLFO, detuneLFOAU.value);
    _kernel.setParameter(filterEnvLFO, filterEnvLFOAU.value);
    _kernel.setParameter(pitchLFO, pitchLFOAU.value);
    _kernel.setParameter(bitcrushLFO, bitcrushLFOAU.value);
    _kernel.setParameter(autopanLFO, autopanLFOAU.value);

    NSArray<AUParameter*>* asp = @[arpSeqPattern00AU, arpSeqPattern01AU, arpSeqPattern02AU, arpSeqPattern03AU, arpSeqPattern04AU, arpSeqPattern05AU, arpSeqPattern06AU, arpSeqPattern07AU, arpSeqPattern08AU, arpSeqPattern09AU, arpSeqPattern10AU, arpSeqPattern11AU, arpSeqPattern12AU, arpSeqPattern13AU, arpSeqPattern14AU, arpSeqPattern15AU];
    for(int i = 0; i<16; i++) {
        const int ak1p = i + arpSeqPattern00;
        AUParameter* p = asp[i];
        _kernel.setParameter(ak1p, p.value);
    }
    
    NSArray<AUParameter*>* asob = @[arpSeqOctBoost00AU, arpSeqOctBoost01AU, arpSeqOctBoost02AU, arpSeqOctBoost03AU, arpSeqOctBoost04AU, arpSeqOctBoost05AU, arpSeqOctBoost06AU, arpSeqOctBoost07AU, arpSeqOctBoost08AU, arpSeqOctBoost09AU, arpSeqOctBoost10AU, arpSeqOctBoost11AU, arpSeqOctBoost12AU, arpSeqOctBoost13AU, arpSeqOctBoost14AU, arpSeqOctBoost15AU];
    for(int i = 0; i<16; i++) {
        const int ak1p = i + arpSeqOctBoost00;
        AUParameter* p = asob[i];
        _kernel.setParameter(ak1p, p.value);
    }
    
    NSArray<AUParameter*>* asno = @[arpSeqNoteOn00AU, arpSeqNoteOn01AU, arpSeqNoteOn02AU, arpSeqNoteOn03AU, arpSeqNoteOn04AU, arpSeqNoteOn05AU, arpSeqNoteOn06AU, arpSeqNoteOn07AU, arpSeqNoteOn08AU, arpSeqNoteOn09AU, arpSeqNoteOn10AU, arpSeqNoteOn11AU, arpSeqNoteOn12AU, arpSeqNoteOn13AU, arpSeqNoteOn14AU, arpSeqNoteOn15AU];
    for(int i = 0; i<16; i++) {
        const int ak1p = i + arpSeqNoteOn00;
        AUParameter* p = asno[i];
        _kernel.setParameter(ak1p, p.value);
    }
    
    _kernel.setParameter(filterType, filterTypeAU.value);
    _kernel.setParameter(phaserMix, phaserMixAU.value);
    _kernel.setParameter(phaserRate, phaserRateAU.value);
    _kernel.setParameter(phaserFeedback, phaserFeedbackAU.value);
    _kernel.setParameter(phaserNotchWidth, phaserNotchWidthAU.value);

    // Create the parameter tree.
    _parameterTree = [AUParameterTree createTreeWithChildren:@[
        index1AU,                // 00
        index2AU,                // 01
        morphBalanceAU,          // 02
        morph1SemitoneOffsetAU,  // 03
        morph2SemitoneOffsetAU,  // 04
        morph1VolumeAU,          // 05
        morph2VolumeAU,          // 06
        subVolumeAU,             // 07
        subOctaveDownAU,         // 08
        subIsSquareAU,           // 09
        fmVolumeAU,              // 10
        fmAmountAU,              // 11
        noiseVolumeAU,           // 12
        lfo1IndexAU,             // 13
        lfo1AmplitudeAU,         // 14
        lfo1RateAU,              // 15
        cutoffAU,                // 16
        resonanceAU,             // 17
        filterMixAU,             // 18
        filterADSRMixAU,         // 19
        isMonoAU,                // 20
        glideAU,                 // 21
        filterAttackDurationAU,  // 22
        filterDecayDurationAU,   // 23
        filterSustainLevelAU,    // 24
        filterReleaseDurationAU, // 25
        attackDurationAU,        // 26
        decayDurationAU,         // 27
        sustainLevelAU,          // 28
        releaseDurationAU,       // 29
        morph2DetuningAU,        // 30
        detuningMultiplierAU,    // 31
        masterVolumeAU,          // 32
        bitCrushDepthAU,         // 33
        bitCrushSampleRateAU,    // 34
        autoPanAmountAU,         // 35
        autoPanFrequencyAU,      // 36
        reverbOnAU,              // 37
        reverbFeedbackAU,        // 38
        reverbHighPassAU,        // 39
        reverbMixAU,             // 40
        delayOnAU,               // 41
        delayFeedbackAU,         // 42
        delayTimeAU,             // 43
        delayMixAU,              // 44
        lfo2IndexAU,             // 45
        lfo2AmplitudeAU,         // 46
        lfo2RateAU,              // 47
        cutoffLFOAU,             // 48
        resonanceLFOAU,          // 49
        oscMixLFOAU,             // 50
        sustainLFOAU,            // 51
        decayLFOAU,             // 52
        noiseLFOAU,             // 53
        fmLFOAU,                 // 54
        detuneLFOAU,             // 55
        filterEnvLFOAU,          // 56
        pitchLFOAU,              // 57
        bitcrushLFOAU,           // 58
        autopanLFOAU,            // 59
        arpDirectionAU,          // 60
        arpIntervalAU,           // 61
        arpIsOnAU,               // 62
        arpOctaveAU,             // 63
        arpRateAU,               // 64
        arpIsSequencerAU,        // 65
        arpTotalStepsAU,         // 66
        arpSeqPattern00AU,       // 67
        arpSeqPattern01AU,       // 68
        arpSeqPattern02AU,       // 69
        arpSeqPattern03AU,       // 70
        arpSeqPattern04AU,       // 71
        arpSeqPattern05AU,       // 72
        arpSeqPattern06AU,       // 73
        arpSeqPattern07AU,       // 74
        arpSeqPattern08AU,       // 75
        arpSeqPattern09AU,       // 76
        arpSeqPattern10AU,       // 77
        arpSeqPattern11AU,       // 78
        arpSeqPattern12AU,       // 79
        arpSeqPattern13AU,       // 80
        arpSeqPattern14AU,       // 81
        arpSeqPattern15AU,       // 82
        arpSeqOctBoost00AU,      // 83
        arpSeqOctBoost01AU,      // 84
        arpSeqOctBoost02AU,      // 85
        arpSeqOctBoost03AU,      // 86
        arpSeqOctBoost04AU,      // 87
        arpSeqOctBoost05AU,      // 88
        arpSeqOctBoost06AU,      // 89
        arpSeqOctBoost07AU,      // 90
        arpSeqOctBoost08AU,      // 91
        arpSeqOctBoost09AU,      // 92
        arpSeqOctBoost10AU,      // 93
        arpSeqOctBoost11AU,      // 94
        arpSeqOctBoost12AU,      // 95
        arpSeqOctBoost13AU,      // 96
        arpSeqOctBoost14AU,      // 97
        arpSeqOctBoost15AU,      // 98
        arpSeqNoteOn00AU,        // 99
        arpSeqNoteOn01AU,        // 100
        arpSeqNoteOn02AU,        // 101
        arpSeqNoteOn03AU,        // 102
        arpSeqNoteOn04AU,        // 103
        arpSeqNoteOn05AU,        // 104
        arpSeqNoteOn06AU,        // 105
        arpSeqNoteOn07AU,        // 106
        arpSeqNoteOn08AU,        // 107
        arpSeqNoteOn09AU,        // 108
        arpSeqNoteOn10AU,        // 109
        arpSeqNoteOn11AU,        // 110
        arpSeqNoteOn12AU,        // 111
        arpSeqNoteOn13AU,        // 112
        arpSeqNoteOn14AU,        // 113
        arpSeqNoteOn15AU,        // 114
        filterTypeAU,            // 115
        phaserMixAU,             // 116
        phaserRateAU,            // 117
        phaserFeedbackAU,        // 118
        phaserNotchWidthAU       // 119
    ]];
}

- (BOOL)allocateRenderResourcesAndReturnError:(NSError **)outError {
    if (![super allocateRenderResourcesAndReturnError:outError]) {
        return NO;
    }
    _outputBusBuffer.allocateRenderResources(self.maximumFramesToRender);
    if (self.musicalContextBlock) { _musicalContext = self.musicalContextBlock; } else _musicalContext = nil;
    _kernel.init(self.outputBus.format.channelCount, self.outputBus.format.sampleRate);
    _kernel.reset();
    return YES;
}

- (void)deallocateRenderResources {
    _outputBusBuffer.deallocateRenderResources();
    [super deallocateRenderResources];
}

- (AUInternalRenderBlock)internalRenderBlock {
    __block AKSynthOneDSPKernel *state = &_kernel;
    return ^AUAudioUnitStatus(
                              AudioUnitRenderActionFlags *actionFlags,
                              const AudioTimeStamp       *timestamp,
                              AVAudioFrameCount           frameCount,
                              NSInteger                   outputBusNumber,
                              AudioBufferList            *outputData,
                              const AURenderEvent        *realtimeEventListHead,
                              AURenderPullInputBlock      pullInputBlock) {
        _outputBusBuffer.prepareOutputBufferList(outputData, frameCount, true);
        state->setBuffer(outputData);
        state->processWithEvents(timestamp, frameCount, realtimeEventListHead);
        double currentTempo;
        if ( _musicalContext ) {
            if (_musicalContext( &currentTempo, NULL, NULL, NULL, NULL, NULL ) ) {
                _kernel.handleTempoSetting(currentTempo);
            }
        }
        return noErr;
    };
}

// this breaks Conductor UI updates...see https://trello.com/c/BYJ81iI3
// need to create delegate in AudioUnitViewController for extension, then we can uncomment
- (void)paramDidChange:(AKSynthOneParameter)param value:(double)value {
    //[_delegate paramDidChange:param value:value];
}

- (void)arpBeatCounterDidChange {
    //[_delegate arpBeatCounterDidChange:_kernel.arpBeatCounter];
}

- (void)heldNotesDidChange {
    //[_delegate heldNotesDidChange];
}

- (void)playingNotesDidChange {
    //[_delegate playingNotesDidChange];
}

@end
