//
//  AEAudioThreadEndpoint.h
//  TheAmazingAudioEngine
//
//  Created by Michael Tyson on 29/04/2016.
//  Copyright © 2016 A Tasty Pixel. All rights reserved.
//

#ifdef __cplusplus
extern "C" {
#endif

#import <Foundation/Foundation.h>
#import "AETime.h"

/*!
 * Handler block
 *
 *  Provide a block matching this description to the initializer to handle incoming
 *  messages. It will be called on the audio thread.
 *
 * @param data Message data (or NULL)
 * @param length Length of message
 */
typedef void (^AEAudioThreadEndpointHandler)(const void * _Nullable data, size_t length);

/*!
 * Audio thread message endpoint
 *
 *  This class implements a mechanism to poll for messages from the main thread upon
 *  the audio thread. Initialize an instance and begin calling AEAudioThreadEndpointPoll
 *  from your render loop. Then use sendBytes:length: from the main thread to send a message
 *  to the audio thread.
 *
 *  Use this utility to perform synchronization across the audio and main threads.
 *
 *  You can also use the AEMainThreadEndpoint class to perform messaging in the reverse
 *  direction.
 */
@interface AEAudioThreadEndpoint : NSObject

/*!
 * Default initializer
 *
 * @param handler The handler block to use for incoming messages
 */
- (instancetype _Nullable)initWithHandler:(AEAudioThreadEndpointHandler _Nonnull)handler;

/*!
 * Initializer with custom buffer capacity
 *
 * @param handler The handler block to use for incoming messages
 * @param bufferCapacity The buffer capacity, in bytes (default is 8192 bytes).  Note that 
 *  due to the underlying implementation, actual capacity may be larger.
 */
- (instancetype _Nullable)initWithHandler:(AEAudioThreadEndpointHandler _Nonnull)handler bufferCapacity:(size_t)bufferCapacity;

/*!
 * Poll for messages
 *
 *  Call this regularly from your render loop on the audio thread to check for incoming
 *  messages.
 *
 * @param endpoint The endpoint instance
 */
void AEAudioThreadEndpointPoll(__unsafe_unretained AEAudioThreadEndpoint * _Nonnull endpoint);

/*!
 * Send a message to the audio thread endpoint
 *
 *  Use this on the main thread to send messages to the endpoint instance. It will be
 *  received and handled on the audio thread at the next poll interval.
 *
 * @param bytes Message data (or NULL) to copy
 * @param length Length of message data
 * @return YES if message sent successfully, NO if there was insufficient buffer space
 */
- (BOOL)sendBytes:(const void * _Nullable)bytes length:(size_t)length;

/*!
 * Prepare a new message
 *
 *  Use this method to gain access to a writable message buffer of the given length,
 *  to assemble the message in multiple parts. Then call dispatchMessage to
 *  dispatch.
 *
 * @param length Length of message data
 * @return A pointer to message bytes ready for writing, or NULL if there was insufficient buffer space
 */
- (void * _Nullable)createMessageWithLength:(size_t)length;

/*!
 * Dispatch a message created with createMessageWithLength:
 */
- (void)dispatchMessage;

/*!
 * Begins a group of messages to be performed consecutively.
 *
 *  Messages sent using sendBytes:length: between calls to this method and endMessageGroup
 *  will be performed consecutively on the main thread during a single poll interval.
 */
- (void)beginMessageGroup;

/*!
 * Ends a consecutive group of messages
 */
- (void)endMessageGroup;

@end

#ifdef __cplusplus
}
#endif
