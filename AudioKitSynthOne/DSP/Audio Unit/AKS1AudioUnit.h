//
//  AKS1AudioUnit.h
//  AudioKit
//
//  Created by AudioKit Contributors, revision history on Github.
//  Join us at AudioKitPro.com, github.com/audiokit
//

#pragma once

#import <AudioKit/AKAudioUnit.h>
#import "AKS1Parameter.h"

#define AKS1_MAX_POLYPHONY (6)
#define AKS1_NUM_MIDI_NOTES (128)

@class AEMessageQueue;

// helper for midi/render thread communication: held+playing notes
typedef struct NoteNumber {
    int noteNumber;
    float amp;
} NoteNumber;

// helper for render/main thread communication:
// DSP updates UI elements lfo1Rate, lfo2Rate, autoPanRate, delayTime when arpOn/tempoSyncArpRate update
// DSP updates lfo1Rate, lfo2Rate, autoPanRate, delayTime based on current arpOn/tempoSyncArpRate
typedef struct DependentParam {
    AKS1Parameter param;
    float value01;// [0,1] for ui
    float value;
    int payload;
} DependentParam;

// helper for main+render thread communication: array of playing notes
typedef struct PlayingNotes {
    int polyphony;
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


@protocol AKS1Protocol
-(void)dependentParamDidChange:(DependentParam)dependentParam;
-(void)arpBeatCounterDidChange:(AKS1ArpBeatCounter)arpBeatCounter;
-(void)heldNotesDidChange:(HeldNotes)heldNotes;
-(void)playingNotesDidChange:(PlayingNotes)playingNotes;
@end

@interface AKS1AudioUnit : AKAudioUnit
{
    @public
    AEMessageQueue  *_messageQueue;
}

@property (nonatomic) NSArray *parameters;
@property (nonatomic, weak) id<AKS1Protocol> aks1Delegate;

///auv3, not yet used
- (void)setParameter:(AUParameterAddress)address value:(AUValue)value;
- (AUValue)getParameter:(AUParameterAddress)address;
- (void)createParameters;

- (float)getSynthParameter:(AKS1Parameter)param;
- (void)setSynthParameter:(AKS1Parameter)param value:(float)value;
- (float)getDependentParameter:(AKS1Parameter)param;
- (void)setDependentParameter:(AKS1Parameter)param value:(float)value payload:(int)payload;

- (float)getMinimum:(AKS1Parameter)param;
- (float)getMaximum:(AKS1Parameter)param;
- (float)getDefault:(AKS1Parameter)param;

- (void)setupWaveform:(UInt32)waveform size:(int)size;
- (void)setWaveform:(UInt32)waveform withValue:(float)value atIndex:(UInt32)index;

- (void)stopNote:(uint8_t)note;
- (void)startNote:(uint8_t)note velocity:(uint8_t)velocity;
- (void)startNote:(uint8_t)note velocity:(uint8_t)velocity frequency:(float)frequency;

- (void)reset;
- (void)stopAllNotes;
- (void)resetDSP;
- (void)resetSequencer;

// protected passthroughs for AKS1Protocol called by DSP on main thread
- (void)dependentParamDidChange:(DependentParam)param;
- (void)arpBeatCounterDidChange:(AKS1ArpBeatCounter)arpBeatcounter;
- (void)heldNotesDidChange:(HeldNotes)heldNotes;
- (void)playingNotesDidChange:(PlayingNotes)playingNotes;

@end

