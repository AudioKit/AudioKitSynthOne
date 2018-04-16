//
//  ABMIDISenderPort.h
//  Audiobus SDK
//
//  Created by Gabriel Gatzsche on 21.01.16.
//  Copyright © 2016 Audiobus Pty. Ltd. All rights reserved.
//

#ifdef __cplusplus
extern "C" {
#endif
    
#import "ABMIDIPort.h"

@class ABMIDISenderPort;

/*!
 * Block to handle instance connection or disconnection
 *
 *  Use this with the the @link ABMIDISenderPort::initWithName:title:instanceConnectedBlock:instanceDisconnectedBlock: initWithName:title:instanceConnectedBlock:instanceDisconnectedBlock: @endlink initializer. It will be called
 *  on the main thread.
 *
 * @param instance The instance
 */
typedef void (^ABMIDISenderPortInstanceConnectionBlock)(ABMIDISenderPort * _Nonnull instance);
    
/*!
 * ABMIDISenderPort generates MIDI messages.
 *
 *  This class is used to send MIDI messages.
 *
 *  MIDI messages sent via a MIDI Sender port are forwarded to the
 *  destinations connected via Audiobus. Apps that have MIDI Sender ports
 *  appear in the Notes section of Audiobus.
 *
 *  The features of ABMIDISenderPort are implemented in its base class, ABMIDIPort.
 *  See ABMIDIPort for documentation.
 */
@interface ABMIDISenderPort : ABMIDIPort

/*!
 * Initialize
 *
 * Initializes a new MIDI Sender port. Use @link ABMIDIPortSendPacketList @endlink to send MIDI data.
 *
 * @param name Name of port, for internal use
 * @param title Title of port, shown to the user
 */
- (instancetype _Nullable)initWithName:(NSString * _Nonnull)name title:(NSString * _Nonnull)title;

/*!
 * Initializes the MIDI Sender port as an multi instance port.
 *
 * Initializes a new MIDI Sender port. Use @link ABMIDIPortSendPacketList @endlink
 * to send MIDI data.
 *
 * @param name Name of port, for internal use
 * @param title Title of port, shown to the user
 * @param instanceConnectedBlock This block is called when a port instance has been connected.
 * @param instanceDisconnectedBlock This block is called when a port instance has been disconnected.
 */
- (instancetype _Nullable)initWithName:(NSString * _Nonnull)name
                                 title:(NSString * _Nonnull)title
                instanceConnectedBlock:(ABMIDISenderPortInstanceConnectionBlock _Nonnull)instanceConnectedBlock
             instanceDisconnectedBlock:(ABMIDISenderPortInstanceConnectionBlock _Nonnull)instanceDisconnectedBlock;


/*!
 * Defines if your synth should be controlled by its own UI or only via MIDI.
 *
 * If your app is also a sound generator then this property tells you if your synth
 * should be directly controlled by your app's UI or only via MIDI.
 *
 * localOn == YES means, that your apps sound generator should be directly
 * controlled by the user interface of your app.
 *
 * localOn == NO means, that your app should not create sound due to user
 * interaction on the UI. Your interface is creating MIDI events which are
 * sent to a MIDI filter app an routed back to your app:
 *
 * @code
 *     +----------+      +-------------+      +----------+
 *     | Your APP | +--> | MIDI Filter | +--> | Your APP |
 *     +----------+      +-------------+      +----------+
 * @endcode
 *
 * In the case that your app is also reacting to internal MIDI events it will
 * receive MIDI events twice, a first time directly from your app's UI
 * and a second time from MIDI events received from the MIDI Filter.
 * To prevent this, observe this localOn property and disable internal MIDI
 * event processing when localOn is set to NO.
 *
 * There are also other cases where localOn is set to NO, e.g. if your APP
 * is only sitting in the MIDI input or in the MIDI filter but not in the
 * MIDI output.
 */
@property (nonatomic, readonly) BOOL localOn;

/*!
 * Like property localOn, but for usage in realtime context.
 */
BOOL ABMIDISenderPortIsLocalOn(__unsafe_unretained ABMIDISenderPort * _Nonnull port);


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
