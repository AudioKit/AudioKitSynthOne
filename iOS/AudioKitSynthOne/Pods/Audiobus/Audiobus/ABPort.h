//
//  ABPort.h
//  Audiobus
//
//  Created by Michael Tyson on 02/04/2012.
//  Copyright (c) 2011-2014 Audiobus. All rights reserved.
//


#ifdef __cplusplus
extern "C" {
#endif

#import <UIKit/UIKit.h>
#import "ABCommon.h"

/*!
 * Port types
 */
typedef enum {
    
    ABPortTypeAudioSender   = 2,
    ABPortTypeAudioFilter   = 1,
    ABPortTypeAudioReceiver = 0,
    
    ABPortTypeMIDISender    = 3,
    ABPortTypeMIDIFilter    = 4,
    ABPortTypeMIDIReceiver  = 5,
    
    ABPortTypeUnknown       = 0xFF,
    
    ABPortTypeSender __deprecated_enum_msg("Use ABPortTypeAudioSender")     = ABPortTypeAudioSender,
    ABPortTypeReceiver __deprecated_enum_msg("Use ABPortTypeAudioReceiver") = ABPortTypeAudioReceiver,
    ABPortTypeFilter __deprecated_enum_msg("Use ABPortTypeAudioFilter")     = ABPortTypeAudioFilter,
    
} ABPortType;
    
/*
 * This notification is emitted if this port is about to be launched in 
 * Audiobus or an compatible app.
 * 
 * Listen to this notification when your app offers multiple port and you 
 * want to know when a certain port has been activated in Audiobus. 
 * The object connectd with the notification provides a dictionary containing 
 * the name and the uniqueIdentifier of the port to be launched.
 */
extern NSString * const ABPortWillLaunchPortNotification;
    
    
@class ABPeer;

/*!
 * Port
 *
 *  Ports are the source or destination points for Audiobus connections. Ports can
 *  send audio, receive audio, or filter audio.  You can define multiple ports of each
 *  type in your app to define different audio routes.  For example, a multi-track recorder 
 *  could define additional ports for each track, so each track can be routed to a different place,
 *  or recorded to individually.
 *
 *  This class represents a port on another peer.
 */
@interface ABPort : NSObject

#pragma mark - The port itself

/*!
 * The peer this port is on
 */
@property (nonatomic, weak, readonly) ABPeer *peer;

/*!
 * The internal port name
 */
@property (nonatomic, strong, readonly) NSString *name;


/*!
 * The title of the port, for display to the user
 */
@property (nonatomic, strong, readonly) NSString *title;

/*!
 * The port icon (a 64x64 image)
 */
@property (nonatomic, strong, readonly) UIImage *icon;



/*!
 * The type of the port
 */
@property (nonatomic, readonly) ABPortType type;

/*!
 * The attributes of this port
 */
@property (nonatomic, readonly) uint8_t attributes;

/*!
 * Use this property to associate some user defined context with the port
 */
@property (nonatomic, weak) id context;

/*!
 * An port identifier that is unique for the peer itself but also for other
 * peers.
 */
@property (nonatomic, readonly) uint32_t uniqueIdentifier;

/*!
 * Whether the port is connected
 */
@property (nonatomic, readonly) BOOL connected;


/*!
 * Launches the app belonging to the port and triggers ABPortWillLaunchPortNotification
 * in the appropriate app.
 */
- (void)launch;

#pragma mark - Sources

/*!
 * A title representing the sources connected to the port.
 */
@property (nonatomic, readonly) NSString * sourcesTitle;

/*!
 * An icon representing the sources connected to the port.
 */
@property (nonatomic, readonly) UIImage * sourcesIcon;

/*!
 * Returns direct and indirect sources of the port in the pipeline.
 *
 * The sources are ordered in the way senders - filters.
 */
@property (nonatomic, readonly) NSArray *sourcesRecursive;

#pragma mark - Destinations

/*!
 * A title representing the destinations the port is connected to.
 */
@property (nonatomic, readonly) NSString * destinationsTitle;

/*!
 * An icon representing the destinations the port is connected to.
 */
@property (nonatomic, readonly) UIImage * destinationsIcon;


/*!
 * Returns direct and indirect destinations of the port in the pipeline.
 *
 * The sources are ordered in the way filters - receivers.
 */
@property (nonatomic, readonly) NSArray *destinationsRecursive;


/*!
 * Returns a list of id<NSCopying>. Each value is
 * the ID of the Audio pipeline the port is assigned to.
 *
 * A pipeline is one of the "channels" or "tracks" you are seeing in Audiobus. 
 * Pipeline ID 0 states, that the port is not assigned to a pipeline.
 */
@property (nonatomic, readonly) NSArray *audioPipelineIDs;


/*!
 * Like audioPipelineIDs. The only difference is that the IDs represent 
 * MIDI connectionPipelineIds.
 */
@property (nonatomic, readonly) NSArray *MIDIPipelineIDs;



@end

#ifdef __cplusplus
}
#endif
