//
//  ABMultiStreamBuffer.h
//  Audiobus
//
//  Created by Michael Tyson on 12/12/2012.
//  Copyright (c) 2011-2014 Audiobus. All rights reserved.
//

#ifdef __cplusplus
extern "C" {
#endif

#import <Foundation/Foundation.h>
#import <AudioToolbox/AudioToolbox.h>

/*!
 * A source identifier, for use with [ABMultiStreamBufferSource](@ref ABMultiStreamBuffer::ABMultiStreamBufferSource).
 *
 * This can be anything you like, as long as it is not NULL, and is unique to each source.
 */
typedef void* ABMultiStreamBufferSource;

/*!
 * Multi-stream buffer
 *
 *  This class performs buffering and synchronization of multiple audio streams,
 *  allowing you to enqueue and buffer disparate audio streams, then dequeue the
 *  synchronized audio streams for further processing.
 *
 *  This is primarily for use with @link ABAudioReceiverPort @endlink when receiving audio
 *  as separate streams, while also receiving audio from the device audio input. In
 *  this case, all audio streams may need to be synchronized for recording or processing
 *  in your app.
 *
 *  See the section in the Audiobus programming guide on
 *  [Receiving Separate Streams Alongside Core Audio Input](@ref Receiving-Separate-Streams-With-Core-Audio-Input)
 *  for discussion on using this class.
 *
 *  To use the class, initialize it with the client audio format you intend to use.
 *
 *  Then, at each time interval (such as within a Core Audio input callback), enqueue 
 *  each of your input sources - for example, first, an audio buffer from the system audio 
 *  input, followed by audio from each of the connected audio sources, retrieved using
 *  [ABAudioReceiverPortReceive](@ref ABAudioReceiverPort::ABAudioReceiverPortReceive).
 *
 *  Each time you enqueue a source, you must pass an identifier for that source as the
 *  second argument to @link ABMultiStreamBufferEnqueue @endlink. This can be any value
 *  you choose - the most sensible when enqueueing ports would be a pointer to the port
 *  itself. To identify the system audio source, you may choose to use a pointer to a
 *  static variable, like so:
 *
 *      static ABMultiStreamBufferSource kSystemAudioInput = &kSystemAudioInput;
 *      ...
 *      ABMultiStreamBufferEnqueue(buffer, kSystemAudioInput, ...)
 *
 *  Next, you dequeue audio for each source using @link ABMultiStreamBufferDequeue @endlink
 *  - the dequeued audio will be synchronized. To dequeue, you pass in the source 
 *  identifiers you used while enqueuing each source.
 *
 *  Note that you may receive less audio than you originally requested, and you must therefore
 *  deal with this scenario appropriately.
 *
 *  Finally, to end the time step, you must call @link ABMultiStreamBufferEndTimeInterval @endlink,
 *  which will prepare the buffer for the next time interval.
 *
 *  Note that you may use ABMultiStreamBufferEnqueue on a different thread from
 *  ABMultiStreamBufferDequeue.
 */
@interface ABMultiStreamBuffer : NSObject

/*!
 * Initialiser
 *
 * @param clientFormat  The AudioStreamBasicDescription defining the audio format used
 */
- (id)initWithClientFormat:(AudioStreamBasicDescription)clientFormat;

/*!
 * Enqueue audio
 *
 *  Feed the buffer with audio blocks. Identify each source via the `source` parameter. You
 *  may use any identifier you like - pointers, numbers, etc (just cast to ABMultiStreamBufferSource).
 *
 *  When you enqueue audio from a new source (that is, the `source` value is one that hasn't been
 *  seen before, this class will automatically reconfigure itself to start using the new source.
 *  However, this will happen at some point in the near future, not immediately, so one or two buffers
 *  may be lost. If this is a problem, then call this function first on the main thread, for each source,
 *  with a NULL audio buffer, and a lengthInFrames value of 0.
 *
 *  This function can safely be used in a different thread from the dequeue function. It can also be used
 *  in a different thread from other calls to enqueue, given two conditions: No two threads enqueue the
 *  same source, and no two threads call enqueue for a new source simultaneously.
 *
 * @param multiStreamBuffer  The multi stream buffer.
 * @param source         The audio source. This can be anything you like, as long as it is not NULL, and is unique to each source.
 * @param audio          The audio buffer list.
 * @param lengthInFrames The length of audio.
 * @param timestamp      The timestamp associated with the audio.
 */
void ABMultiStreamBufferEnqueue(ABMultiStreamBuffer *multiStreamBuffer, ABMultiStreamBufferSource source, AudioBufferList *audio, UInt32 lengthInFrames, const AudioTimeStamp *timestamp);

/*!
 * Dequeue single, mixed audio stream
 *
 *  Call this function to receive synchronized and mixed audio.
 *
 *  Do not use this function together with ABMultiStreamBufferDequeueSingleSource.
 *
 *  This can safely be used in a different thread from the enqueue function.
 *
 * @param multiStreamBuffer The multi stream buffer.
 * @param bufferList        The buffer list to write audio to. The mData pointers
 *                          may be NULL, in which case an internal buffer will be provided.
 *                          You may also pass a NULL value, which will simply discard the given
 *                          number of frames.
 * @param ioLengthInFrames  On input, the number of frames of audio to dequeue. On output,
 *                          the number of frames returned.
 * @param outTimestamp      On output, the timestamp of the first audio sample
 */
void ABMultiStreamBufferDequeue(ABMultiStreamBuffer *multiStreamBuffer, AudioBufferList *bufferList, UInt32 *ioLengthInFrames, AudioTimeStamp *outTimestamp);

/*!
 * Dequeue an individual source
 *
 *  Call this function, passing in a source identifier, to receive separate, synchronized audio streams.
 *
 *  Do not use this function together with ABMultiStreamBufferDequeue.
 *
 *  This can safely be used in a different thread from the enqueue function.
 *
 * @param multiStreamBuffer The multi stream buffer.
 * @param source            The audio source.
 * @param bufferList        The buffer list to write audio to. The mData pointers
 *                          may be NULL, in which case an internal buffer will be provided.
 * @param ioLengthInFrames  On input, the number of frames of audio to dequeue. On output,
 *                          the number of frames returned.
 * @param outTimestamp      On output, the timestamp of the first audio sample
 */
void ABMultiStreamBufferDequeueSingleSource(ABMultiStreamBuffer *multiStreamBuffer, ABMultiStreamBufferSource source, AudioBufferList *bufferList, UInt32 *ioLengthInFrames, AudioTimeStamp *outTimestamp);

/*!
 * Peek the audio buffer
 *
 *  Use this to determine how much audio is currently buffered, and the corresponding next timestamp.
 *
 * @param multiStreamBuffer The multi stream buffer
 * @param outNextTimestamp  If not NULL, the timestamp of the next available audio
 * @return Number of frames of available audio, in the specified audio format.
 */
UInt32 ABMultiStreamBufferPeek(ABMultiStreamBuffer *multiStreamBuffer, AudioTimeStamp *outNextTimestamp);

/*!
 * Mark end of time interval
 *
 *  When receiving each audio source separately via ABMultiStreamBufferDequeueSingleSource (instead of mixed
 *  with ABMultiStreamBufferDequeue), you must call this function at the end of each time interval in order
 *  to inform the mixer that you are finished with that audio segment. Any sources that have not
 *  been dequeued will have their audio discarded in order to retain synchronization.
 *
 * @param multiStreamBuffer The multi stream buffer.
 */
void ABMultiStreamBufferEndTimeInterval(ABMultiStreamBuffer *multiStreamBuffer);

/*!
 * Mark the given source as idle
 *
 *  Normally, if the multi stream buffer doesn't receive any audio for a given source within
 *  the time interval given by the sourceIdleThreshold property, the buffer will wait,
 *  allowing no frames to be dequeued until either further audio is received for the
 *  source, or the sourceIdleThreshold limit is met.
 *
 *  To avoid this delay and immediately mark a given source as idle, use this function.
 *
 * @param multiStreamBuffer The multi stream buffer
 * @param source            The source to mark as idle
 */
void ABMultiStreamBufferMarkSourceIdle(ABMultiStreamBuffer *multiStreamBuffer, ABMultiStreamBufferSource source);

/*!
 * Set volume for source
 *
 *  Note that this will only apply when using ABMultiStreamBufferDequeue, not
 *  ABMultiStreamBufferDequeueSingleSource
 */
- (void)setVolume:(float)volume forSource:(ABMultiStreamBufferSource)source;

/*!
 * Get volume for source
 */
- (float)volumeForSource:(ABMultiStreamBufferSource)source;

/*!
 * Set pan for source
 *
 *  Note that this will only apply when using ABMultiStreamBufferDequeue, not
 *  ABMultiStreamBufferDequeueSingleSource
 */
- (void)setPan:(float)pan forSource:(ABMultiStreamBufferSource)source;

/*!
 * Get pan for source
 */
- (float)panForSource:(ABMultiStreamBufferSource)source;

/*!
 * Set a different AudioStreamBasicDescription for a source
 *
 *  Important: Do not change this property while using enqueue/dequeue.
 *  You must stop enqueuing or dequeuing audio first.
 */
- (void)setAudioDescription:(AudioStreamBasicDescription)audioDescription forSource:(ABMultiStreamBufferSource)source;

/*!
 * Force the mixer to unregister a source
 *
 *  After this function is called, the mixer will have reconfigured to stop
 *  mixing the given source. If callbacks for the source were provided, these
 *  will never be called again after this function returns.
 *
 *  Use of this function is entirely optional - the multi stream buffer will automatically
 *  unregister sources it is no longer receiving audio for, and will clean up when
 *  deallocated.
 *
 * @param source            The audio source.
 */
- (void)unregisterSource:(ABMultiStreamBufferSource)source;

/*!
 * Client audio format
 *
 *  Important: Do not change this property while using enqueue/dequeue.
 *  You must stop enqueuing or dequeuing audio first.
 */
@property (nonatomic, assign) AudioStreamBasicDescription clientFormat;

@end

#ifdef __cplusplus
}
#endif
