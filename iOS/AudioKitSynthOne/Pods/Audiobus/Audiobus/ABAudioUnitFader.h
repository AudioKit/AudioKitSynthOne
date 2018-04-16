//
//  ABAudioUnitFader.h
//  Audiobus
//
//  Created by Michael Tyson on 29/10/2014.
//  Copyright (c) 2014 Audiobus. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AudioToolbox/AudioToolbox.h>

typedef void (^ABAudioUnitFaderBlock)(void);

/*!
 * Audio Unit Fader
 *
 *  This class provides an easy-to-use facility for starting a Remote IO audio unit,
 *  then fading in, or fading out then stopping a Remote IO audio unit. This allows your
 *  app to transition smoothly between running and stopped states without any
 *  unpleasant clicks.
 *
 *  Use this class in place of calling AudioOutputUnitStart or AudioOutputUnitStop,
 *  and it will perform a smooth fade in or out, and either call the appropriate start/stop
 *  routines itself, or invoke a completion block you provide, to perform your own shutdown
 *  or setup.
 */
@interface ABAudioUnitFader : NSObject

/*!
 * Fade out, then stop audio unit
 *
 *  This method will apply a fade-out ramp on the provided Remote IO audio unit,
 *  then call AudioOutputUnitStop, to halt the audio unit's render pipeline.
 *
 *  Calling this method cancels any other transitions.
 *
 * @param audioUnit A reference to a Remote IO audio unit (kAudioUnitSubType_RemoteIO)
 */
+ (void)fadeOutAndStopAudioUnit:(AudioUnit)audioUnit;

/*!
 * Fade out audio unit, then call completion block
 *
 *  This method will apply a fade-out ramp on the provided Remote IO audio unit,
 *  then call the provided completion block. You should stop your audio output's render
 *  pipeline from within this completion block, by either calling AudioOutputUnitStop,
 *  or if you're using an AudioGraph, AUGraphStop.
 *
 *  Calling this method cancels any other transitions.
 *
 * @param audioUnit A reference to a Remote IO audio unit (kAudioUnitSubType_RemoteIO)
 * @param block Block to call on completion of fade-out
 */
+ (void)fadeOutAudioUnit:(AudioUnit)audioUnit completionBlock:(ABAudioUnitFaderBlock)block;

/*!
 * Start, then fade in audio unit
 *
 *  This method will call AudioOutputUnitStart on the provided audio unit, then 
 *  apply a fade-in ramp on the provided Remote IO audio unit.
 *
 *  Calling this method cancels any other transitions.
 *
 * @param audioUnit A reference to a Remote IO audio unit (kAudioUnitSubType_RemoteIO)
 */
+ (void)startAndFadeInAudioUnit:(AudioUnit)audioUnit;

/*!
 * Fade in audio unit, then call completion block
 *
 *  This method will apply a fade-in ramp on the provided Remote IO audio unit,
 *  initialising then calling the provided beginBlock, which should start the audio
 *  unit by either calling AudioOutputUnitStart, or if you're using an AudioGraph, 
 *  AUGraphStart. Upon completion, the provided optional completion block will be called.
 *
 *  If you do not need to be notified on completion of the fade-in transition, pass
 *  nil for the 'completionBlock' parameter.
 *
 *  Calling this method cancels any other transitions.
 *
 * @param audioUnit A reference to a Remote IO audio unit (kAudioUnitSubType_RemoteIO)
 * @param beginBlock Block to call at beginning of process, after initialisation
 * @param completionBlock Block to call on completion of fade-in
 */
+ (void)fadeInAudioUnit:(AudioUnit)audioUnit beginBlock:(ABAudioUnitFaderBlock)beginBlock completionBlock:(ABAudioUnitFaderBlock)completionBlock;

/*!
 * Determine if there are any running transitions
 */
+ (BOOL)transitionsRunning;

/*!
 * Cancel any current transitions
 */
+ (void)cancel;

@end
