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
#import <AudioKit/AudioKit-swift.h>

@implementation AKSynthOneAudioUnit {
    // C++ members need to be ivars; they would be copied on access if they were properties.
    AKSynthOneDSPKernel _kernel;
    BufferedOutputBus _outputBusBuffer;
    AUHostMusicalContextBlock _musicalContext;
    AUParameterObserverToken _parameterObserverToken;
}

@synthesize parameterTree = _parameterTree;

- (void)setAK1Parameter:(AKSynthOneParameter)param value:(float)value {
    _kernel.setAK1Parameter(param, value);
}

- (float)getAK1Parameter:(AKSynthOneParameter)inAKSynthOneParameterEnum {
    return _kernel.getAK1Parameter(inAKSynthOneParameterEnum);
}

///auv3
- (void)setParameter:(AUParameterAddress)address value:(AUValue)value {
    _kernel.setAK1Parameter((AKSynthOneParameter)address, value);
}

///auv3
- (AUValue)getParameter:(AUParameterAddress)address {
    return _kernel.getAK1Parameter((AKSynthOneParameter)address);
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

///Deprecated:calling this method to access even a single element of this array results in creating the entire array
- (NSArray<NSNumber*> *)parameters {
    NSMutableArray *temp = [NSMutableArray arrayWithCapacity:AKSynthOneParameter::AKSynthOneParameterCount];
    for (int i = 0; i < AKSynthOneParameter::AKSynthOneParameterCount; i++) {
        [temp setObject:[NSNumber numberWithFloat:_kernel.p[i]] atIndexedSubscript:i];
    }
    return [NSArray arrayWithArray:temp];
}

///deprecated
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
    
    // Create parameter tree
    AudioUnitParameterOptions flags = kAudioUnitParameterFlag_IsWritable | kAudioUnitParameterFlag_IsReadable;
    NSMutableArray<AUParameter*>* tree = [NSMutableArray array];
    for(NSInteger i = AKSynthOneParameter::index1; i < AKSynthOneParameter::AKSynthOneParameterCount; i++) {
        const AKSynthOneParameter p = (AKSynthOneParameter)i;
        const AUValue minValue = _kernel.parameterMin(p);
        const AUValue maxValue = _kernel.parameterMax(p);
        const AUValue defaultValue = _kernel.parameterDefault(p);
        const AudioUnitParameterUnit unit = _kernel.parameterUnit(p);
        NSString* friendlyName = [NSString stringWithCString:_kernel.parameterCStr(p) encoding:[NSString defaultCStringEncoding]];
        NSString* keyName = [NSString stringWithCString:_kernel.parameterPresetKey(p).c_str() encoding:[NSString defaultCStringEncoding]];
        AUParameter *param = [AUParameterTree createParameterWithIdentifier:keyName name:friendlyName address:p min:minValue max:maxValue unit:unit unitName:nil flags:flags valueStrings:nil dependentParameters:nil];
        param.value = defaultValue;
        _kernel.setAK1Parameter(p, defaultValue);
        [tree addObject:param];
    }
    
    _parameterTree = [AUParameterTree createTreeWithChildren:tree];
    
    __weak AKSynthOneAudioUnit* weakSelf = self;
    _parameterObserverToken = [_parameterTree tokenByAddingParameterObserver:^(AUParameterAddress address, AUValue value) {
        __strong AKSynthOneAudioUnit *strongSelf = weakSelf;
        dispatch_async(dispatch_get_main_queue(), ^{
            strongSelf->_kernel.setAK1Parameter((AKSynthOneParameter)address, value);
        });
    }];

    _parameterTree.implementorValueObserver = ^(AUParameter *param, AUValue value) {
        dispatch_async(dispatch_get_main_queue(), ^{
            const AKSynthOneParameter p = (AKSynthOneParameter)param.address;
            blockKernel->setAK1Parameter(p, value);
        });
    };
    
    _parameterTree.implementorValueProvider = ^(AUParameter *param) {
        const AKSynthOneParameter p = (AKSynthOneParameter)param.address;
        return blockKernel->getAK1Parameter(p);
    };
    
    _parameterTree.implementorStringFromValueCallback = ^(AUParameter *param, const AUValue *__nullable valuePtr) {
        AUValue value = valuePtr == nil ? param.value : *valuePtr;
        return [NSString stringWithFormat:@"%.4f", value];
    };
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

- (void)dealloc {
    if (_parameterObserverToken) {
        [_parameterTree removeParameterObserver:_parameterObserverToken];
        _parameterObserverToken = 0;
    }
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
