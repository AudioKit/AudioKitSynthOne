//
//  ABReceiverPort.h
//  Audiobus SDK
//
//  Created by Gabriel Gatzsche on 11.07.16.
//  Copyright © 2016 Audiobus Pty. Ltd. All rights reserved.
//

#import "ABAudioReceiverPort.h"

#ifdef __cplusplus
extern "C" {
#endif
    
__deprecated_msg("Use ABAudioReceiverPortConnectionsChangedNotification instead")
extern NSString * const ABReceiverPortConnectionsChangedNotification;

__deprecated_msg("Use ABAudioReceiverPortPortAddedNotification instead")
extern NSString * const ABReceiverPortPortAddedNotification;

__deprecated_msg("Use ABAudioReceiverPortPortRemovedNotification instead")
extern NSString * const ABReceiverPortPortRemovedNotification;

__deprecated_msg("Use ABAudioReceiverPortPortInterAppAudioUnitWillInitializeNotification instead")
extern NSString * const ABReceiverPortPortInterAppAudioUnitWillInitializeNotification;

__deprecated_msg("Use ABAudioReceiverPortPortInterAppAudioUnitConnectedNotification instead")
extern NSString * const ABReceiverPortPortInterAppAudioUnitConnectedNotification;

__deprecated_msg("Use ABAudioReceiverPortPortInterAppAudioUnitDisconnectedNotification instead")
extern NSString * const ABReceiverPortPortInterAppAudioUnitDisconnectedNotification;

__deprecated_msg("Use ABAudioReceiverPortPortKey instead")
extern NSString * const ABReceiverPortPortKey;

/*!
 * Create a AB Sender port
 *
 * @deprecated in Audiobus 3.x Use ABAudioReceiverPort instead
 */
__deprecated_msg("Use ABAudioReceiverPort instead")
@interface ABReceiverPort : ABAudioReceiverPort

__deprecated_msg("Use ABAudioReceiverPortReceive instead")
void ABReceiverPortReceive(ABAudioReceiverPort *receiverPort, ABPort *sourcePortOrNil, AudioBufferList *audio, UInt32 lengthInFrames, AudioTimeStamp *ioTimestamp);

__deprecated_msg("Use ABAudioReceiverPortEndReceiveTimeInterval instead")
void ABReceiverPortEndReceiveTimeInterval(ABAudioReceiverPort *receiverPort);

__deprecated_msg("Use ABAudioReceiverPortReceiveAQ instead")
void ABReceiverPortReceiveAQ(ABAudioReceiverPort *receiverPort, ABPort *sourcePortOrNil, AudioQueueBufferRef bufferList, UInt32 lengthInFrames, AudioTimeStamp *ioTimestamp);

__deprecated_msg("Use ABAudioReceiverPortIsConnected instead")
BOOL ABReceiverPortIsConnected(ABAudioReceiverPort *receiverPort);

__deprecated_msg("Use ABAudioReceiverPortIsConnectedToSelf instead")
BOOL ABReceiverPortIsConnectedToSelf(ABAudioReceiverPort *receiverPort);
@end
    

#ifdef __cplusplus
}
#endif
