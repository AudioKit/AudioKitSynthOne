//
//  ABFilterPort.h
//  Audiobus SDK
//
//  Created by Gabriel Gatzsche on 11.07.16.
//  Copyright © 2016 Audiobus Pty. Ltd. All rights reserved.
//

#import "ABAudioFilterPort.h"

#ifdef __cplusplus
extern "C" {
#endif
    
__deprecated_msg("Use ABAudioFilterPortConnectionsChangedNotification instead")
extern NSString * const ABFilterPortConnectionsChangedNotification;

__deprecated_msg("Use ABAudioFilterPort instead")
@interface ABFilterPort : ABAudioFilterPort
@end

__deprecated_msg("Use ABAudioFilterPortIsConnected instead")
BOOL ABFilterPortIsConnected(ABAudioFilterPort *filterPort);
    
#ifdef __cplusplus
}
#endif