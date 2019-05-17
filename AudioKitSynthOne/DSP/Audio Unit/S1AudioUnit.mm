//
//  S1AudioUnit.mm
//  AudioKit
//
//  Created by AudioKit Contributors, revision history on Github.
//  Join us at AudioKitPro.com, github.com/audiokit
//

#import "S1AudioUnit.h"
#import "S1DSPKernel.hpp"
#import "AEMessageQueue.h"
#import "AudioKit/BufferedAudioBus.hpp"
#import <AudioKit/AudioKit-swift.h>

@implementation S1AudioUnit {
    // C++ members need to be ivars; they would be copied on access if they were properties.
    std::unique_ptr<S1DSPKernel> _kernel;
    BufferedOutputBus _outputBusBuffer;
    AUHostMusicalContextBlock _musicalContext;
}

@synthesize parameterTree = _parameterTree;
@synthesize s1Delegate = _s1Delegate;

- (float)getSynthParameter:(S1Parameter)param {
    return _kernel->getSynthParameter(param);
}

- (void)setSynthParameter:(S1Parameter)param value:(float)value {
    _kernel->setSynthParameter(param, value);
}

- (float)getDependentParameter:(S1Parameter)param {
    return _kernel->getDependentParameter(param);
}

- (void)setDependentParameter:(S1Parameter)param value:(float)value payload:(int)payload {
    _kernel->setDependentParameter(param, value, payload);
}

///auv3
- (void)setParameter:(AUParameterAddress)address value:(AUValue)value {
    _kernel->setSynthParameter((S1Parameter)address, value);
}

///auv3
- (AUValue)getParameter:(AUParameterAddress)address {
    return _kernel->getSynthParameter((S1Parameter)address);
}

- (float)getMinimum:(S1Parameter)param {
    return _kernel->minimum(param);
}

- (float)getMaximum:(S1Parameter)param {
    return _kernel->maximum(param);
}

- (float)getDefault:(S1Parameter)param {
    return _kernel->defaultValue(param);
}

///Deprecated:calling this method to access even a single element of this array results in creating the entire array
- (NSArray<NSNumber*> *)parameters {
    NSMutableArray *temp = [NSMutableArray arrayWithCapacity:S1Parameter::S1ParameterCount];
    for (int i = 0; i < S1Parameter::S1ParameterCount; i++) {
        [temp setObject:[NSNumber numberWithFloat:_kernel->parameters[i]] atIndexedSubscript:i];
    }
    return [NSArray arrayWithArray:temp];
}

///deprecated
- (void)setParameters:(NSArray<NSNumber*> *)parameters {
    float params[S1Parameter::S1ParameterCount];
    for (int i = 0; i < parameters.count; i++) {
        params[i] = [parameters[i] floatValue];
    }
    _kernel->setParameters(params);
}

- (void)resetSequencer {
    _kernel->resetSequencer();
}

- (BOOL)isSetUp {
    return _kernel->resetted;
}

- (void)stopNote:(uint8_t)note {
    _kernel->stopNote(note);
}

- (void)startNote:(uint8_t)note velocity:(uint8_t)velocity {
    _kernel->startNote(note, velocity);
}

- (void)startNote:(uint8_t)note velocity:(uint8_t)velocity frequency:(float)frequency {
    _kernel->startNote(note, velocity, frequency);
}

- (void)setupWaveform:(UInt32)tableIndex size:(int)size {
    _kernel->setupWaveform(tableIndex, (uint32_t)size);
}

- (void)setWaveform:(UInt32)tableIndex withValue:(float)value atIndex:(UInt32)sampleIndex {
    _kernel->setWaveformValue(tableIndex, sampleIndex, value);
}

- (void)setBandlimitFrequency:(UInt32)blIndex withFrequency:(float)frequency {
    _kernel->setBandlimitFrequency(blIndex, frequency);
}

- (void)reset {
    _kernel->reset();
}

///Puts all notes in Release...a kinder, gentler "reset".
- (void)stopAllNotes {
    _kernel->stopAllNotes();
}

///Resets DSP
- (void)resetDSP {
    _kernel->resetDSP();
}



// S1TuningTable protocol
- (void)setTuningTable:(float)frequency index:(int)index {
    _kernel->setTuningTable(frequency, index);
}

- (float)getTuningTableFrequency:(int)index {
    return _kernel->getTuningTableFrequency(index);
}

- (void)setTuningTableNPO:(int)npo {
    _kernel->setTuningTableNPO(npo);
}


- (void)createParameters {

    _messageQueue = [[AEMessageQueue alloc] init];

    self.rampDuration = AKSettings.rampDuration;
    self.defaultFormat = [[AVAudioFormat alloc] initStandardFormatWithSampleRate:AKSettings.sampleRate
                                                                        channels:AKSettings.channelCount];
    _kernel = std::make_unique<S1DSPKernel>(self.defaultFormat.channelCount, self.defaultFormat.sampleRate);
    _outputBusBuffer.init(self.defaultFormat, 2);
    self.outputBus = _outputBusBuffer.bus;
    self.outputBusArray = [[AUAudioUnitBusArray alloc] initWithAudioUnit:self
                                                                 busType:AUAudioUnitBusTypeOutput
                                                                  busses:@[self.outputBus]];
    _kernel->audioUnit = self;
    __block S1DSPKernel *blockKernel = _kernel.get();
    
    // Create parameter tree
    AudioUnitParameterOptions flags = kAudioUnitParameterFlag_IsWritable | kAudioUnitParameterFlag_IsReadable;
    NSMutableArray<AUParameter*>* tree = [NSMutableArray array];
    for(NSInteger i = S1Parameter::index1; i < S1Parameter::S1ParameterCount; i++) {
        const S1Parameter p = (S1Parameter)i;
        const AUValue minValue = _kernel->minimum(p);
        const AUValue maxValue = _kernel->maximum(p);
        const AUValue defaultValue = _kernel->defaultValue(p);
        const AudioUnitParameterUnit unit = _kernel->parameterUnit(p);
        NSString* friendlyName = [NSString stringWithCString:_kernel->cString(p) encoding:[NSString defaultCStringEncoding]];
        NSString* keyName = [NSString stringWithCString:_kernel->presetKey(p).c_str() encoding:[NSString defaultCStringEncoding]];
        AUParameter *param = [AUParameterTree createParameterWithIdentifier:keyName name:friendlyName address:p min:minValue max:maxValue unit:unit unitName:nil flags:flags valueStrings:nil dependentParameters:nil];
        param.value = defaultValue;
        //_kernel->setSynthParameter(p, defaultValue);
        [tree addObject:param];
    }
    
    _parameterTree = [AUParameterTree createTreeWithChildren:tree];
    
    _parameterTree.implementorValueObserver = ^(AUParameter *param, AUValue value) {
        const S1Parameter p = (S1Parameter)param.address;
        blockKernel->setSynthParameter(p, value);
    };
    _parameterTree.implementorValueProvider = ^(AUParameter *param) {
        const S1Parameter p = (S1Parameter)param.address;
        return blockKernel->getSynthParameter(p);
    };
}

- (BOOL)allocateRenderResourcesAndReturnError:(NSError **)outError {
    if (![super allocateRenderResourcesAndReturnError:outError]) {
        return NO;
    }
    _outputBusBuffer.allocateRenderResources(self.maximumFramesToRender);
    if (self.musicalContextBlock) { _musicalContext = self.musicalContextBlock; }
    auto parameters = _kernel->parameters;
    _kernel->init(self.outputBus.format.channelCount, self.outputBus.format.sampleRate);
    _kernel->reset();
    _kernel->restoreValues(parameters);
    _kernel->updateWavetableIncrementValuesForCurrentSampleRate();
    
    return YES;
}

- (void)deallocateRenderResources {
    _outputBusBuffer.deallocateRenderResources();
    [super deallocateRenderResources];
    _musicalContext = nil;
    _kernel->destroy();
}

- (AUInternalRenderBlock)internalRenderBlock {
    __block S1DSPKernel *state = _kernel.get();
    return ^AUAudioUnitStatus(
                              AudioUnitRenderActionFlags *actionFlags,
                              const AudioTimeStamp       *timestamp,
                              AVAudioFrameCount           frameCount,
                              NSInteger                   outputBusNumber,
                              AudioBufferList            *outputData,
                              const AURenderEvent        *realtimeEventListHead,
                              AURenderPullInputBlock      pullInputBlock) {
        self->_outputBusBuffer.prepareOutputBufferList(outputData, frameCount, true);
        state->setBuffer(outputData);
        state->processWithEvents(timestamp, frameCount, realtimeEventListHead);
        double currentTempo;
        if (self->_musicalContext) {
            if (self->_musicalContext( &currentTempo, NULL, NULL, NULL, NULL, NULL ) ) {
                //TODO:AURE: midi clock
                self->_kernel->handleTempoSetting(currentTempo);
            }
        }
        return noErr;
    };
}


// passthroughs for S1Protocol called by DSP on main thread
- (void)dependentParameterDidChange:(DependentParameter)param {
    [_s1Delegate dependentParameterDidChange:param];
}

- (void)arpBeatCounterDidChange:(S1ArpBeatCounter)arpBeatCounter {
    [_s1Delegate arpBeatCounterDidChange:arpBeatCounter];
}

- (void)heldNotesDidChange:(HeldNotes)heldNotes {
    [_s1Delegate heldNotesDidChange:heldNotes];
}

- (void)playingNotesDidChange:(PlayingNotes)playingNotes {
    [_s1Delegate playingNotesDidChange:playingNotes];
}

@end
