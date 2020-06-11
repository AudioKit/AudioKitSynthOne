//
//  S1MessageQueues.h
//  AudioKitSynthOne
//
//  Created by Marcus W. Hobbs on 2/14/20.
//  Copyright © 2020 AudioKit. All rights reserved.
//

#ifndef S1MessageQueues_h
#define S1MessageQueues_h

#import "AEMessageQueue.h"

@interface AEMessageQueueDependentParameter: AEMessageQueue
@end

@interface AEMessageQueueBeatCounter: AEMessageQueue
@end

@interface AEMessageQueuePlayingNotes: AEMessageQueue
@end

@interface AEMessageQueueHeldNotes: AEMessageQueue
@end

#endif /* S1MessageQueues_h */
