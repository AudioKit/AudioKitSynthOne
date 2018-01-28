//
//  AEMainThreadPoll.h
//  TheAmazingAudioEngine
//
//  Created by Michael Tyson on 29/04/2016.
//  Copyright © 2016 A Tasty Pixel. All rights reserved.
//
//  This software is provided 'as-is', without any express or implied
//  warranty.  In no event will the authors be held liable for any damages
//  arising from the use of this software.
//
//  Permission is granted to anyone to use this software for any purpose,
//  including commercial applications, and to alter it and redistribute it
//  freely, subject to the following restrictions:
//
//  1. The origin of this software must not be misrepresented; you must not
//     claim that you wrote the original software. If you use this software
//     in a product, an acknowledgment in the product documentation would be
//     appreciated but is not required.
//
//  2. Altered source versions must be plainly marked as such, and must not be
//     misrepresented as being the original software.
//
//  3. This notice may not be removed or altered from any source distribution.
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
 *  messages. It will be called on the main thread.
 *
 * @param data Message data (or NULL)
 * @param length Length of message
 */
typedef void (^AEMainThreadEndpointHandler)(void * _Nullable data, size_t length);

/*!
 * Main thread message endpoint
 *
 *  This class implements a mechanism to receive messages from the audio thread upon
 *  the main thread. Initialize an instance, and pass in a block to call to handle incoming
 *  messages. Then use AEMainThreadEndpointSend from the audio thread to send a message to 
 *  the main thread.
 *
 *  Use this utility to perform synchronization across the audio and main threads.
 *
 *  You can also use the AEAudioThreadEndpoint class to perform messaging in the reverse
 *  direction.
 */
@interface AEMainThreadEndpoint : NSObject

/*!
 * Default initializer
 *
 * @param handler The handler block to use for incoming messages
 */
- (instancetype _Nullable)initWithHandler:(AEMainThreadEndpointHandler _Nonnull)handler;

/*!
 * Initializer with custom buffer capacity
 *
 * @param handler The handler block to use for incoming messages
 * @param bufferCapacity The buffer capacity, in bytes (default is 8192 bytes).  Note that
 *  due to the underlying implementation, actual capacity may be larger.
 */
- (instancetype _Nullable)initWithHandler:(AEMainThreadEndpointHandler _Nonnull)handler bufferCapacity:(size_t)bufferCapacity;

/*!
 * Send a message to the main thread endpoint
 *
 *  Use this on the audio thread to send messages to the endpoint instance. It will be
 *  received and handled on the main thread.
 *
 * @param endpoint The endpoint instance
 * @param data Message data (or NULL) to copy
 * @param length Length of message data
 * @return YES if message sent successfully, NO if there was insufficient buffer space
 */
BOOL AEMainThreadEndpointSend(__unsafe_unretained AEMainThreadEndpoint * _Nonnull endpoint,
                              const void * _Nullable data, size_t length);

/*!
 * Prepare a new message
 *
 *  Use this function to gain access to a writable message buffer of the given length,
 *  to assemble the message in multiple parts. Then call AEMainThreadEndpointDispatchMessage to
 *  dispatch.
 *
 * @param endpoint The endpoint instance
 * @param length Length of message data
 * @return A pointer to message bytes ready for writing, or NULL if there was insufficient buffer space
 */
void * _Nullable AEMainThreadEndpointCreateMessage(__unsafe_unretained AEMainThreadEndpoint * _Nonnull endpoint, size_t length);

/*!
 * Dispatch a message created with AEMainThreadEndpointCreateMessage
 *
 * @param endpoint The endpoint instance
 */
void AEMainThreadEndpointDispatchMessage(__unsafe_unretained AEMainThreadEndpoint * _Nonnull endpoint);

@end

#ifdef __cplusplus
}
#endif
