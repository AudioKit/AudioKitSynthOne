//
//  ABSenderPort.h
//  Audiobus SDK
//
//  Created by Gabriel Gatzsche on 11.07.16.
//  Copyright © 2016 Audiobus Pty. Ltd. All rights reserved.
//

#import "ABAudioSenderPort.h"

#ifdef __cplusplus
extern "C" {
#endif
    
__deprecated_msg("Use ABSenderPortConnectionsChangedNotification instead")
extern NSString * const ABSenderPortConnectionsChangedNotification;

__deprecated_msg("Use ABAudioSenderPort instead")
@interface ABSenderPort : ABAudioSenderPort

__deprecated_msg("Use ABAudioSenderPortSend instead")
void ABSenderPortSend(ABAudioSenderPort* senderPort, const AudioBufferList *audio, UInt32 lengthInFrames, const AudioTimeStamp *timestamp);

__deprecated_msg("Use ABAudioSenderPortIsConnected instead")
BOOL ABSenderPortIsConnected(ABAudioSenderPort* senderPort);

__deprecated_msg("Use ABAudioSenderPortIsConnectedToSelf instead")
BOOL ABSenderPortIsConnectedToSelf(ABAudioSenderPort* senderPort);

__deprecated_msg("Use ABAudioSenderPortIsMuted instead")
BOOL ABSenderPortIsMuted(ABAudioSenderPort *senderPort);

__deprecated_msg("Use ABAudioSenderPortGetAverageLatency instead")
NSTimeInterval ABSenderPortGetAverageLatency(ABAudioSenderPort *senderPort) __deprecated;

@end
    

#ifdef __cplusplus
}
#endif
