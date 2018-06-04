//
//  ABMIDIPort.h
//  Audiobus SDK
//
//  Created by Gabriel Gatzsche on 19.05.16.
//  Copyright © 2016 Audiobus Pty. Ltd. All rights reserved.
//


#ifdef __cplusplus
extern "C" {
#endif
  
#import "ABPort.h"
#import "ABLocalPort.h"
    
@class ABMIDIPort;

/*!
 * ABMIDIPort is the base class of ABMIDISenderPort, ABMIDIFilterPort 
 * and ABMIDIReceiverPort.
 *
 * It implements common features of both classes.
 *
 * Do not instantiate this class directly.
 */
@interface ABMIDIPort : ABPort<ABLocalPort>

/*!
 * Send a MIDIPacketList. Use this function when you want to send MIDI events.
 *
 *  Note: For MIDI Filter Ports, this operates independently of MIDI received via ABMIDIFilterBlock.
 *
 * @param MIDIPort The MIDI port from which the bytes are sent
 * @param MIDIPacketList The MIDI packet list to be sent
 */
void ABMIDIPortSendPacketList(__unsafe_unretained ABMIDIPort *  _Nonnull MIDIPort,
                              const MIDIPacketList * _Nonnull MIDIPacketList);

/*!
 * Whether this port allows multiple instance
 *
 * YES if multiple instances of this prototype port can be created
 * (see initWithName:title:instanceConnectedBlock:instanceDisconnectedBlock:)
 */
@property (nonatomic, readonly) BOOL allowsMultipleInstances;

/*!
 * Currently-connected destinations
 *
 *  This is an array of ABPort.
 */
@property (nonatomic, strong, readonly) NSArray * _Nonnull destinations;

/*!
 * Whether the port is connected
 */
@property (nonatomic, readonly) BOOL connected;

/*!
 * Like property connected, but for usage in realtime context.
 */
BOOL ABMIDIPortIsConnected(__unsafe_unretained ABMIDIPort * _Nonnull port);


/*!
 * This is the buffer size reserved for output MIDI Packet lists. This value
 * defaults to 16 kBytes. Increase this value when you need more or less.
 */
@property (nonatomic, readwrite) ByteCount outPacketListMaxSize;

@end

#ifdef __cplusplus
}
#endif
