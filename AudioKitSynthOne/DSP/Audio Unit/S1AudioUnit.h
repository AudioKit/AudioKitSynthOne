//
//  S1AudioUnit.h
//  AudioKit
//
//  Created by AudioKit Contributors, revision history on Github.
//  Join us at AudioKitPro.com, github.com/audiokit
//

#pragma once

#import <AudioKit/AKAudioUnit.h>
#import "S1Parameter.h"

#define S1_MAX_POLYPHONY (6)
#define S1_NUM_MIDI_NOTES (128)

@class AEMessageQueue;

// helper for midi/render thread communication: held+playing notes
typedef struct NoteNumber {
    int noteNumber;
    int transpose;
    int velocity;
    float amp;
} NoteNumber;

// helper for render/main thread communication:
// DSP updates UI elements lfo1Rate, lfo2Rate, autoPanRate, delayTime when arpOn/tempoSyncArpRate update
// DSP updates lfo1Rate, lfo2Rate, autoPanRate, delayTime based on current arpOn/tempoSyncArpRate
typedef struct DependentParameter {
    S1Parameter parameter;
    float normalizedValue;// [0,1] for ui
    float value;
    int payload;
} DependentParameter;

// helper for main+render thread communication: array of playing notes
typedef struct PlayingNotes {
    int polyphony;
    NoteNumber playingNotes[S1_MAX_POLYPHONY];
} PlayingNotes;

// helper for main+render thread communication: array of held notes
typedef struct HeldNotes {
    int heldNotesCount;
    bool heldNotes[S1_NUM_MIDI_NOTES];
} HeldNotes;

// helper for main+render thread communcation: arp beat counter, and number of held notes
typedef struct S1ArpBeatCounter {
    int beatCounter;
    int heldNotesCount;
} S1ArpBeatCounter;


@protocol S1Protocol

-(void)dependentParameterDidChange:(DependentParameter)dependentParam;

-(void)arpBeatCounterDidChange:(S1ArpBeatCounter)arpBeatCounter;

-(void)heldNotesDidChange:(HeldNotes)heldNotes;

-(void)playingNotesDidChange:(PlayingNotes)playingNotes;

@end

@interface S1AudioUnit : AKAudioUnit
{
    @public
    AEMessageQueue  *_messageQueue;
}

@property (nonatomic) NSArray *parameters;
@property (nonatomic, weak) id<S1Protocol> s1Delegate;


- (float)getSynthParameter:(S1Parameter)param;
- (void)setSynthParameter:(S1Parameter)param value:(float)value;
- (float)getDependentParameter:(S1Parameter)param;
- (void)setDependentParameter:(S1Parameter)param value:(float)value payload:(int)payload;

- (float)getMinimum:(S1Parameter)param;
- (float)getMaximum:(S1Parameter)param;
- (float)getDefault:(S1Parameter)param;

- (void)setupWaveform:(UInt32)tableIndex size:(int)size;
- (void)setWaveform:(UInt32)tableIndex withValue:(float)value atIndex:(UInt32)sampleIndex;
- (void)setBandlimitFrequency:(UInt32)blIndex withFrequency:(float)frequency;

- (void)stopNote:(uint8_t)note;
- (void)startNote:(uint8_t)note velocity:(uint8_t)velocity;
- (void)startNote:(uint8_t)note velocity:(uint8_t)velocity frequency:(float)frequency;

- (void)reset;
- (void)stopAllNotes;
- (void)resetDSP;
- (void)resetSequencer;

// S1TuningTable protocol
- (void)setTuningTable:(float)frequency index:(int)index;
- (float)getTuningTableFrequency:(int)index;
- (void)setTuningTableNPO:(int)npo;

///auv3, not yet used
- (void)setParameter:(AUParameterAddress)address value:(AUValue)value;
- (AUValue)getParameter:(AUParameterAddress)address;
- (void)createParameters;

// protected passthroughs for S1Protocol called by DSP on main thread
- (void)dependentParameterDidChange:(DependentParameter)param;
- (void)arpBeatCounterDidChange:(S1ArpBeatCounter)arpBeatcounter;
- (void)heldNotesDidChange:(HeldNotes)heldNotes;
- (void)playingNotesDidChange:(PlayingNotes)playingNotes;

@end

