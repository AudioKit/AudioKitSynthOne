//
//  AKSynthOneAudioUnit.h
//  AudioKit
//
//  Created by Aurelius Prochazka, revision history on Github.
//  Copyright © 2017 Aurelius Prochazka. All rights reserved.
//

#pragma once

#import <AudioKit/AKAudioUnit.h>
#import "AKSynthOneParameter.h"

#define AKS1_MAX_POLYPHONY (6)
#define AKS1_NUM_MIDI_NOTES (128)

@class AEMessageQueue;

// helper for midi/render thread communication: held+playing notes
typedef struct NoteNumber {
    int noteNumber;
} NoteNumber;

// helper for render/main thread communication:
// DSP updates UI elements lfo1Rate, lfo2Rate, autoPanRate, delayTime when arpOn/tempoSyncArpRate update
// DSP updates lfo1Rate, lfo2Rate, autoPanRate, delayTime based on current arpOn/tempoSyncArpRate
typedef struct DependentParam {
    AKSynthOneParameter param;
    float value01;// [0,1] for ui
    float value;
    int payload;
} DependentParam;

// helper for main+render thread communication: array of playing notes
typedef struct PlayingNotes {
    NoteNumber playingNotes[AKS1_MAX_POLYPHONY];
} PlayingNotes;

// helper for main+render thread communication: array of held notes
typedef struct HeldNotes {
    int heldNotesCount;
    bool heldNotes[AKS1_NUM_MIDI_NOTES];
} HeldNotes;

// helper for main+render thread communcation: arp beat counter, and number of held notes
typedef struct AKS1ArpBeatCounter {
    int beatCounter;
    int heldNotesCount;
} AKS1ArpBeatCounter;


@protocol AKSynthOneProtocol
-(void)dependentParamDidChange:(DependentParam)dependentParam;
-(void)arpBeatCounterDidChange:(AKS1ArpBeatCounter)arpBeatCounter;
-(void)heldNotesDidChange:(HeldNotes)heldNotes;
-(void)playingNotesDidChange:(PlayingNotes)playingNotes;
@end

@interface AKSynthOneAudioUnit : AKAudioUnit
{
    @public
    AEMessageQueue  *_messageQueue;
}

@property (nonatomic) NSArray *parameters;
@property (nonatomic, weak) id<AKSynthOneProtocol> aks1Delegate;

///auv3, not yet used
- (void)setParameter:(AUParameterAddress)address value:(AUValue)value;
- (AUValue)getParameter:(AUParameterAddress)address;
- (void)createParameters;

- (float)getAK1Parameter:(AKSynthOneParameter)param;
- (void)setAK1Parameter:(AKSynthOneParameter)param value:(float)value;
- (float)getAK1DependentParameter:(AKSynthOneParameter)param;
- (void)setAK1DependentParameter:(AKSynthOneParameter)param value:(float)value payload:(int)payload;

- (float)getParameterMin:(AKSynthOneParameter)param;
- (float)getParameterMax:(AKSynthOneParameter)param;
- (float)getParameterDefault:(AKSynthOneParameter)param;

- (void)setupWaveform:(UInt32)waveform size:(int)size;
- (void)setWaveform:(UInt32)waveform withValue:(float)value atIndex:(UInt32)index;

- (void)stopNote:(uint8_t)note;
- (void)startNote:(uint8_t)note velocity:(uint8_t)velocity;
- (void)startNote:(uint8_t)note velocity:(uint8_t)velocity frequency:(float)frequency;

- (void)reset;
- (void)stopAllNotes;
- (void)resetDSP;
- (void)resetSequencer;

// protected passthroughs for AKSynthOneProtocol called by DSP on main thread
- (void)dependentParamDidChange:(DependentParam)param;
- (void)arpBeatCounterDidChange:(AKS1ArpBeatCounter)arpBeatcounter;
- (void)heldNotesDidChange:(HeldNotes)heldNotes;
- (void)playingNotesDidChange:(PlayingNotes)playingNotes;

@end

