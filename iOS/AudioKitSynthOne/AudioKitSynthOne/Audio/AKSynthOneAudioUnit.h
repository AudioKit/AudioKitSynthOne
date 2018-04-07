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

// helper for midi/render thread communication: held, playing notes
typedef struct NoteNumber {
    int noteNumber;
} NoteNumber;

// helper for main+render thread communication: array of playing notes
typedef struct PlayingNotes {
    NoteNumber playingNotes[AKS1_MAX_POLYPHONY];
} PlayingNotes;

// helper for main+render thread communication: array of playing notes
typedef struct HeldNotes {
    bool heldNotes[AKS1_NUM_MIDI_NOTES];
} HeldNotes;

@protocol AKSynthOneProtocol
-(void)paramDidChange:(AKSynthOneParameter)param value:(double)value;
-(void)arpBeatCounterDidChange:(NSInteger)beat;
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

- (void)setAK1Parameter:(AKSynthOneParameter)param value:(float)value;
- (float)getAK1Parameter:(AKSynthOneParameter)param;
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

// Called by DSP only
- (void)paramDidChange:(AKSynthOneParameter)param value:(double)value;
- (void)arpBeatCounterDidChange;
- (void)heldNotesDidChange:(HeldNotes)heldNotes;
- (void)playingNotesDidChange:(PlayingNotes)playingNotes;

@end

