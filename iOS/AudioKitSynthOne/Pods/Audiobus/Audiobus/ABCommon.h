//
//  ABCommon.h
//  Audiobus
//
//  Created by Michael Tyson on 27/01/2012.
//  Copyright (c) 2011-2014 Audiobus. All rights reserved.
//

#ifdef __cplusplus
extern "C" {
#endif

#import <Foundation/Foundation.h>
#import <AudioToolbox/AudioToolbox.h>

/*!
 * Connection panel position
 *
 *  Defines the positioning of the connection panel in your app, when it is visible.
 */
typedef enum {
    ABConnectionPanelPositionRight,
    ABConnectionPanelPositionLeft,
    ABConnectionPanelPositionBottom,
    ABConnectionPanelPositionTop
} ABConnectionPanelPosition;

/*!
 * Peer resource identifier
 */
typedef uint32_t ABPeerResourceID;

int _ABAssert(BOOL condition, const char* msg, char* file, int line);
    
typedef void(^ABCompletion)(NSError* error);

/**
 * Returns true if the audio component description belongs to one of the 
 * Intermediate sender ports of Audiobus. You should hide these ports because
 * they are only used by the Audiobus SDK.
 */
BOOL ABIsHiddenAudiobusPort(AudioComponentDescription);
        

#define ABAssert(condition,msg) (_ABAssert((BOOL)(condition),(msg),strrchr(__FILE__, '/')+1,__LINE__))

    
#ifdef __cplusplus
}
#endif
