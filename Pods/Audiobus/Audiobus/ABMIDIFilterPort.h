//
//  ABMIDIFilterPort.h
//  Audiobus SDK
//
//  Created by Gabriel Gatzsche on 21.01.16.
//  Copyright © 2016 Audiobus Pty. Ltd. All rights reserved.
//

#ifdef __cplusplus
extern "C" {
#endif
    
#import "ABMIDIPort.h"

@class ABMIDIFilterPort;

/*!
 * Block to handle incoming MIDI messages
 *
 *  Upon receiving MIDI messages, a MIDI Filter port should generate new
 *  MIDIPacketLists as required, and then send them on using
 *  ABMIDIPortSendPacketList.
 *
 *  Note: this will be called on the realtime MIDI receive thread,
 *  so be careful not to do anything that could cause priority inversion,
 *  like calling Objective-C, allocating memory, or holding locks.
 *
 * @param source The source port
 * @param packetList The MIDI packets
 */
typedef void (^ABMIDIFilterPortMIDIReceiverBlock)(__unsafe_unretained ABPort * _Nonnull source,
                                              const MIDIPacketList * _Nonnull packetList);

/*!
 * Block to handle instance connection or disconnection
 *
 *  Use this with the multi-instance port initializer. It will be called on the main thread.
 *  You may assign a new MIDIReceiverBlock value for the new instance when this block is called,
 *  and it will replace the one you provided to the ABMIDIFilterPort initializer.
 *
 * @param instance The instance
 */
typedef void (^ABMIDIFilterPortInstanceConnectionBlock)(ABMIDIFilterPort * _Nonnull instance);

/*!
 * ABMIDIFilterPort transforms MIDI messages.
 * 
 * MIDI messages are received from the sources, transformed and forwarded 
 * to its destinations. MIDI FX ports will appear in the Note Filter section
 * of Audiobus.
 *
 * The main things of ABMIDIFilterPort is implemented in its base class
 * ABMIDIPort. So look into the documentation of this class.
 */
@interface ABMIDIFilterPort : ABMIDIPort

/*!
 * Initialize
 *
 * Initializes a new MIDI Filter Port.
 *
 * @param name Name of port, for internal use
 * @param title Title of port, shown to the user
 * @param receiverBlock The block for receiving incoming MIDI
 */
- (instancetype _Nullable)initWithName:(NSString * _Nonnull)name
                                 title:(NSString * _Nonnull)title
                         receiverBlock:(ABMIDIFilterPortMIDIReceiverBlock _Nonnull)receiverBlock;

/*!
 * Initializes the MIDI Port as an multi instance port.
 *
 * Initializes a new MIDI Port. 
 *
 * @param name Name of port, for internal use
 * @param title Title of port, shown to the user
 * @param instanceConnectedBlock This block is called when a port instance has been connected.
 * @param instanceDisconnectedBlock This block is called when a port instance has been disconnected.
 */
- (instancetype _Nullable)initWithName:(NSString * _Nonnull)name
                                 title:(NSString * _Nonnull)title
                instanceConnectedBlock:(ABMIDIFilterPortInstanceConnectionBlock _Nonnull)instanceConnectedBlock
             instanceDisconnectedBlock:(ABMIDIFilterPortInstanceConnectionBlock _Nonnull)instanceDisconnectedBlock;

/*!
 * Currently-connected sources
 *
 *  This is an array of ABPort.
 */
@property (nonatomic, strong, readonly) NSArray * _Nonnull sources;

/*!
 * The block which is called when MIDI is received for the port.
 *
 *  Note: this will be called on the realtime MIDI receive thread,
 *  so be careful not to do anything that could cause priority inversion,
 *  like calling Objective-C, allocating memory, or holding locks.
 */
@property (nonatomic, copy) ABMIDIFilterPortMIDIReceiverBlock _Nullable MIDIReceiverBlock;


/*!
 * A title representing the sources connected to the port.
 */
@property (nonatomic, readonly) NSString * _Nullable sourcesTitle;

/*!
 * An icon representing the sources connected to the port.
 */
@property (nonatomic, readonly) UIImage * _Nullable sourcesIcon;

/*!
 * A title representing the destinations the port is connected to.
 */
@property (nonatomic, readonly) NSString * _Nullable destinationsTitle;

/*!
 * An icon representing the destinations the port is connected to.
 */
@property (nonatomic, readonly) UIImage * _Nullable destinationsIcon;


@end
    
    
#ifdef __cplusplus
}
#endif
