//
//  ABAudiobusController.h
//  Audiobus
//
//  Created by Michael Tyson on 09/12/2011.
//  Copyright (c) 2011-2014 Audiobus. All rights reserved.
//

#ifdef __cplusplus
extern "C" {
#endif

#import <Foundation/Foundation.h>
#import "ABCommon.h"
#import "ABAudioFilterPort.h"

@class ABMIDISenderPort;
@class ABMIDIReceiverPort;    
@class ABMIDIFilterPort;

#pragma mark Notifications
/** @name Notifications */
///@{

/*!
 * Peer appeared
 *
 *  Sent when an Audiobus peer appears for the first time.
 *  Peer is accessible in the notification userinfo via the `ABPeerKey'.
 */
extern NSString * const ABPeerAppearedNotification;

/*!
 * Peer disappeared
 *
 *  Sent when an Audiobus peer disappears.
 *  Peer is accessible in the notification userinfo via the `ABPeerKey'.
 */
extern NSString * const ABPeerDisappearedNotification;

/*!
 * Connections changed
 *
 *  Sent when the local app's connections have changed, caused by connections
 *  or disconnections from within the Audiobus app.
 *
 *  Note that due to the asynchronous nature of Inter-App Audio connections
 *  within Audiobus when connected to peers using the 2.1 Audiobus SDK or above, 
 *  you may see several of these notifications during a connection or disconnection.
 */
extern NSString * const ABConnectionsChangedNotification;

/*!
 * Connected
 *
 *  Sent when the app state transitioned from disconnected, to connected.
 *
 *  Note that due to the asynchronous nature of Inter-App Audio connections
 *  within Audiobus when connected to peers using the 2.1 Audiobus SDK or above, 
 *  you may see this notification before the 
 *  @link ABAudiobusController::interAppAudioConnected interAppAudioConnected @endlink or
 *  @link ABAudiobusController::audiobusConnected audiobusConnected @endlink 
 *  properties change to YES.
 */
extern NSString * const ABConnectedNotification;

/*!
 * Disconnected
 *
 *  Sent when the app state transitioned from connected, to disconnected.
 */
extern NSString * const ABDisconnectedNotification;
    
    
/*!
 * Peer attributes changed
 *
 *  Sent when one or more attributes of a peer changes.
 */
extern NSString * const ABPeerAttributesChangedNotification;

/*!
 * Connection Panel was shown
 *
 *  Sent whenever the connection panel appears, either when a new session begins,
 *  or when the user drags the connection panel back out after hiding it.
 */
extern NSString * const ABConnectionPanelShownNotification;

/*!
 * Connection Panel was hidden
 *
 *  Sent whenever the connection panel is hidden, either when the session ends,
 *  or when the user drags the connection panel off the screen.
 */
extern NSString * const ABConnectionPanelHiddenNotification;

/*!
 * Application is about to terminate
 *
 *  When Audiobus isn't able to instantiate a remote Audio Unit, then it will
 *  send an exit request to this app. Before executing exit this notification
 *  will be sent out.
 */
extern NSString * const ABApplicationWillTerminateNotification;
    


#pragma mark State IO Protocol
/** @name State IO Protocol */
///@{
  
/*!
 * State input/output delegate protocol
 *
 *  This protocol is used to provide app-specific state data when a preset
 *  is saved within Audiobus. This state data will then be presented back to
 *  your app when the user loads the saved preset within Audiobus, so your 
 *  app can restore the prior state.
 *
 *  The nature of the state information to be saved and restored is up to you.
 *  It should be enough to put your app into the same operating state as when
 *  the preset was saved, but should not necessarily contain the user's content.
 *  Presets should represent workspaces, rather than complete projects.
 *
 *  To assist in streamlining your app initialization, when your app is being
 *  launched from a preset within Audiobus, Audiobus will launch your app by
 *  providing the string "incoming-preset" to the host part of the app launch
 *  URL. For example, if your Audiobus launch URL is "myapp.audiobus://", launching
 *  your app from within an Audiobus preset will cause the app to be launched
 *  with the URL "myapp.audiobus://incoming-preset". You can then detect this
 *  condition from within `application:openURL:sourceApplication:annotation:`
 */
@protocol ABAudiobusControllerStateIODelegate <NSObject>

/*!
 * Provide a dictionary to represent the current app state
 *
 *  This dictionary can represent any state you deem relevant to the saved
 *  preset, for later restoration in 
 *  @link loadStateFromAudiobusStateDictionary:responseMessage: @endlink.
 *  It may only contain values that can be represented in a Property List
 *  (See Apple's "Property List Types and Objects" documentation).
 *
 *  You may include NSData objects representing larger resources, if
 *  appropriate, such as audio data for a sampler. To avoid loading large
 *  files into memory all at once, you can request that the NSData use
 *  memory-mapping via the NSDataReadingMappedIfSafe hint.
 *
 *  Note: You should not spend more than a couple hundred milliseconds
 *  (at most) gathering state information in this method.
 *
 * @return A dictionary containing state information for your app.
 */
- (NSDictionary*)audiobusStateDictionaryForCurrentState;
    
/*!
 * Load state from previously-created state dictionary
 *
 *  This method is called when the user loads a preset from within Audiobus.
 *  You will receive the state dictionary originally provided via
 *  @link audiobusStateDictionaryForCurrentState @endlink, and should apply this state
 *  information to restore your app to the state it was in when saved.
 *
 *  If you wish, you may provide a message to be displayed to the user within 
 *  Audiobus, via the 'outResponseMessage' parameter. This can be used to notify
 *  the user of any issues with the state load, like the case where the state
 *  relies on some In-App Purchase content the user hasn't bought yet.
 *
 * @param dictionary The state dictionary, as originally provided via
 *      @link audiobusStateDictionaryForCurrentState @endlink. In addition to the keys
 *      you provided, the value of the key ABStateDictionaryPresetNameKey will contain
 *      the name of the preset, as set by the user.
 * @param outResponseMessage Response message to be displayed to the user (optional)
 */
- (void)loadStateFromAudiobusStateDictionary:(NSDictionary*)dictionary responseMessage:(NSString**)outResponseMessage;

@end

extern NSString * const ABStateDictionaryPresetNameKey;
    
#pragma mark -
///@}

/*!
 * Peer key, used with notifications
 */
extern NSString * const ABPeerKey;

@class ABAudioReceiverPort;
@class ABAudioSenderPort;
@class ABAudioFilterPort;
@class ABPeer;
@class ABPort;
@class ABTrigger;

/*!
 * Audiobus Controller
 *
 *  The main Audiobus class.  Create an instance of this then
 *  create and add receiver, sender and/or filter ports as required.
 */
@interface ABAudiobusController : NSObject

/*!
 * Reset all peered Audiobus controllers
 *
 *  Call this to forget all established connections with instances of the Audiobus app.
 *
 *  The first time there is an incoming connection from the Audiobus app, the Audiobus
 *  library will prompt the user for permission to allow the connection. Calling this method
 *  will forgot all granted permissions, so that the next incoming Audiobus connection will
 *  cause another prompt to accept or deny the connection.
 */
+(void)resetAllPeeredConnections;

/*!
 * Initializer
 *
 * @param apiKey Your app's API key (find this at the bottom of your app's details screen accessible from https://developer.audiob.us/apps)
 */
- (id)initWithApiKey:(NSString*)apiKey;

#pragma mark - Triggers
/** @name Triggers */
///@{

/*!
 * Add a trigger
 *
 *  This method allows you to define and add triggers that the user can invoke from outside your 
 *  app, in order to make your app perform some function, such as toggling recording.
 *
 *  Calling this method more than once with the same trigger will have no effect the subsequent times.
 *
 * @param trigger       The trigger
 */
- (void)addTrigger:(ABTrigger*)trigger;


/*!
 * Same as addTrigger whith the difference that the trigger is not shown in 
 * AB Remote.
 */
-(void)addLocalOnlyTrigger:(ABTrigger*)trigger;

/*!
 * Add a trigger which is only shown in Audiobus Remote.
 *
 *  Triggers added by this method are only shown within Audiobus Remote. Use this method
 *  and @link addRemoteTriggerMatrix:rows:cols: @endlink to provide extended functionality
 *  for your app which can be used from within Audiobus Remote.
 *
 * @param trigger       The trigger
 */
-(void)addRemoteTrigger:(ABTrigger*)trigger;




/*!
 * Add a grid matrix of triggers for Audiobus Remote
 *
 *  Triggers added by this method appear within Audiobus Remote as a grid of buttons.
 *  We recommend using this facility when a matrix layout is important to the user
 *  experience, such as with drum sample pads.
 *
 *  Please use this facility only if your button layout needs an explicit
 *  grid order. Otherwise, use @link addRemoteTrigger: @endlink, which allows
 *  Audiobus Remote to make better use of screen space.
 *
 * @param triggers An array of triggers. Size of the array must be rows * cols.
 * @param rows Number of rows; limited to 6 rows maximum.
 * @param cols Number of columns; limited to 6 cols maximum.
 * @param transposable If transposable is true the matrix is transposed if 
 * space can be saved.
 */
- (void)addRemoteTriggerMatrix:(NSArray*) triggers
                          rows:(NSUInteger) rows
                          cols:(NSUInteger) cols
                  transposable:(BOOL) transposable;


- (void)addRemoteTriggerMatrix:(NSArray*) triggers
                          rows:(NSUInteger) rows
                          cols:(NSUInteger) cols __attribute__((deprecated("Use 'addRemoteTriggerMatrix:rows:cols:transposable' instead")));


/*!
 * Remove a trigger
 *
 *  Calling this method more than once with the same trigger will have no effect the subsequent times.
 *
 * @param trigger       Trigger to remove
 */
- (void)removeTrigger:(ABTrigger*)trigger;

#pragma mark - All ports

/*!
 * Returns the port with a given unique ID or Nil when not found.
 */
- (ABPort*) portWithUniqueID:(uint32_t)uniqueID;


/*!
 * Returns the port with a given name or Nil when not found.
 */
- (ABPort*) portWithName:(NSString*)name;

/*!
 * Returns an array of objects of type ABPort*.
 */
- (NSArray*) allPorts;


///@}
#pragma mark - Audio sender ports
/** @name Audio ports */
///@{

/*!
 * Add a sender port
 *
 *  Sender ports let your app send audio to other apps.
 *
 *  You can create several sender ports to offer several separate audio streams. For example, a multi-track
 *  recorder could define additional sender ports for each track, so each track can be routed to a different place.
 *
 *  Ideally, the first port you create should perform some sensible default behaviour: This will be the port
 *  that is selected by default when the user taps your app in the Audiobus port picker.
 *
 * @param port The port to add
 */
- (void)addAudioSenderPort:(ABAudioSenderPort*)port;

/*!
 * Deprecated. Use addAudioSenderPort instead.
 */
- (void)addSenderPort:(ABAudioSenderPort*)port __deprecated_msg("Use addAudioSenderPort instead");

/*!
 * Access a sender port
 *
 *  If you are sending audio from a Core Audio thread, then you should not use this method from within
 *  the thread.  Instead, obtain a reference to the sender object ahead of time, on the main thread, then store 
 *  the pointer in a context directly accessible in the Core Audio thread, to avoid making any Objective-C calls from within
 *  the thread.
 *
 * @param name Name of port
 * @return Sender port
 */
- (ABAudioSenderPort*)audioSenderPortNamed:(NSString*)name;

/*!
 * Deprecated. Use addAudioSenderPort instead.
 */
- (ABAudioSenderPort*)senderPortNamed:(NSString*)name __deprecated_msg("Use audioSenderPortNamed instead");

/*!
 * Remove a sender port
 *
 *  It is your responsibility to make sure you stop accessing the port prior to calling this method.
 *
 * @param port The port to remove
 */
- (void)removeAudioSenderPort:(ABAudioSenderPort*)port;

/*!
 * Deprecated. Use addAudioSenderPort instead.
 */
- (void)removeSenderPort:(ABAudioSenderPort*)port __deprecated_msg("Use removeAudioSenderPort instead");

/*!
 * Sort the sender ports
 *
 *  This method allows you to assign an order to the sender ports. This is the
 *  order in which the ports will appear within Audiobus.
 *
 * @param cmptr Comparitor block used to provide the order
 */
- (void)sortAudioSenderPortsUsingComparitor:(NSComparator)cmptr;

/*!
 * Deprecated. Use sortAudioSenderPortsUsingComparitor instead.
 */
- (void)sortSenderPortsUsingComparitor:(NSComparator)cmptr __deprecated_msg("Use sortAudioSenderPortsUsingComparitor instead");


/*!
 * Currently defined sender ports
 *
 *  The sender ports you have registered with @link addSenderPort: @endlink, as an
 *  array of ABAudioSenderPort.
 */
@property (nonatomic, readonly) NSArray *audioSenderPorts;

/*!
 * Deprecated. Use audioSenderPorts instead.
 */
@property (nonatomic, readonly) NSArray *senderPorts __deprecated_msg("Use audioSenderPorts instead!");


#pragma mark - Audio filter ports

/*!
 * Add a filter port
 *
 *  Filter ports expose audio processing functionality to the Audiobus ecosystem, allowing users to use your
 *  app as an audio filtering node.
 *
 *  When you create a filter port, you pass in a block to be used to process the audio as it comes in.
 *
 * @param port The filter port
 */
- (void)addAudioFilterPort:(ABAudioFilterPort*)port;

/*!
 * Deprecated. Use addAudioFilterPort instead.
 */
- (void)addFilterPort:(ABAudioFilterPort*)port __deprecated_msg("Use addAudioFilterPort instead");

/*!
 * Get the filter port
 *
 *  This is used to access the attributes of the connected ports. Note that the actual process of
 *  receiving and sending audio is handled automatically.
 *
 * @param name The name of the filter port
 * @return Filter port
 */
- (ABAudioFilterPort*)audioFilterPortNamed:(NSString*)name;

/*!
 * Deprecated. Use audioFilterPortNamed instead.
 */
- (ABAudioFilterPort*)filterPortNamed:(NSString*)name __deprecated_msg("Use audioFilterPortNamed instead");

/*!
 * Remove a filter port
 *
 * @param port The port to remove
 */
- (void)removeAudioFilterPort:(ABAudioFilterPort*)port;

/*!
 * Deprecated. Use removeAudioFilterPort instead.
 */
- (void)removeFilterPort:(ABAudioFilterPort*)port __deprecated_msg("Use removeAudioFilterPort instead");

/*!
 * Sort the filter ports
 *
 *  This method allows you to assign an order to the fiter ports. This is the
 *  order in which the ports will appear within Audiobus.
 *
 * @param cmptr Comparitor block used to provide the order
 */
- (void)sortAudioFilterPortsUsingComparitor:(NSComparator)cmptr;

/*!
 * Deprecated. Use sortAudioFilterPortsUsingComparitor instead.
 */
- (void)sortFilterPortsUsingComparitor:(NSComparator)cmptr __deprecated_msg("Use sortAudioFilterPortsUsingComparitor instead");


/*!
 * Currently defined filter ports
 *
 *  The filter ports you have registered with @link addFilterPort: @endlink, as an
 *  array of ABAudioFilterPort.
 */
@property (nonatomic, readonly) NSArray *audioFilterPorts;


/*!
 * Deprecated. Use audioFilterPorts instead.
 */
@property (nonatomic, readonly) NSArray *filterPorts __deprecated_msg("Use audioFilterPorts instead!");



#pragma mark - Audio receiver ports

/*!
 * Add a receiver port
 *
 *  Receiver ports allow your app to receive audio from other apps.
 *
 *  MIDI that any receiver port can receive inputs from any number of sources. You do not need to
 *  create additional receiver ports to receive audio from multiple sources.
 *
 *  Ideally, the first port you create should perform some sensible default behaviour: This will be the port
 *  that is selected by default when the user taps your app icon in the Audiobus port picker.
 *
 * @param port The receiver port
 */
- (void)addAudioReceiverPort:(ABAudioReceiverPort*)port;

/*!
 * Deprecated. Use addAudioReceiverPort instead.
 */
- (void)addReceiverPort:(ABAudioReceiverPort*)port __deprecated_msg("Use addAudioReceiverPort instead");

/*!
 * Access a receiver port
 *
 *  If you are receiving audio from a Core Audio thread, then you should not use this method from within
 *  the thread.  Instead, obtain a reference to the receiver object ahead of time, on the main thread, then store 
 *  the pointer in a context directly accessible in the Core Audio thread, to avoid making any Objective-C calls from within
 *  the thread.
 *
 * @param name Name of port.
 * @return Receiver port
 */
- (ABAudioReceiverPort*)audioReceiverPortNamed:(NSString*)name;

/*!
 * Deprecated. Use audioReceiverPortNamed instead.
 */
- (ABAudioReceiverPort*)receiverPortNamed:(NSString*)name __deprecated_msg("Use audioReceiverPortNamed instead");


/*!
 * Remove a receiver port
 *
 *  It is your responsibility to make sure you stop accessing the port prior to calling this method.
 *
 * @param port The port to remove
 */
- (void)removeAudioReceiverPort:(ABAudioReceiverPort*)port;

/*!
 * Deprecated. Use removeAudioReceiverPort instead.
 */
- (void)removeReceiverPort:(ABAudioReceiverPort*)port __deprecated_msg("Use removeAudioReceiverPort instead");


/*!
 * Sort the receiver ports
 *
 *  This method allows you to assign an order to the receiver ports. This is the
 *  order in which the ports will appear within Audiobus.
 *
 * @param cmptr Comparitor block used to provide the order
 */
- (void)sortAudioReceiverPortsUsingComparitor:(NSComparator)cmptr;

/*!
 * Deprecated. Use sortAudioReceiverPortsUsingComparitor instead.
 */
- (void)sortReceiverPortsUsingComparitor:(NSComparator)cmptr __deprecated_msg("Use sortAudioReceiverPortsUsingComparitor instead");


/*!
 * Currently defined receiver ports
 *
 *  The receiver ports you have registered with @link addReceiverPort: @endlink, as an
 *  array of ABAudioReceiverPort.
 */
@property (nonatomic, readonly) NSArray *audioReceiverPorts;

/*!
 * Deprecated. Use audioReceiverPorts instead.
 */
@property (nonatomic, readonly) NSArray *receiverPorts __deprecated_msg("Use audioReceiverPorts instead!");





#pragma mark - MIDI sender ports


/*!
 * Add a MIDI port
 *
 *  Sender ports let your app send MIDI to other apps.
 *
 * You can create several MIDI ports to offer several separate MIDI streams.
 * For example, a multi-track MIDI sequencer could define additional MIDI ports
 * for each track, so each track can be routed to a different place.
 *
 * @param port The port to add
 */
- (void)addMIDISenderPort:(ABMIDISenderPort*)port;

/*!
 * Remove a MIDI port
 *
 *  It is your responsibility to make sure you stop accessing the port prior to calling this method.
 *
 * @param port The port to remove
 */
-(void)removeMIDISenderPort:(ABMIDISenderPort*)port;

/*!
 * Sort the MIDI ports
 *
 *  This method allows you to assign an order to the sender ports. This is the
 *  order in which the MIDI ports will appear within Audiobus.
 *
 * @param cmptr Comparitor block used to provide the order
 */
-(void)sortMIDISenderPortsUsingComparitor:(NSComparator)cmptr;

/*!
 * Get the MIDI Port
 *
 *  This is used to access the attributes of the connected ports.
 *
 * @param name The name of the MIDI port
 * @return MIDI port.
 */
-(ABMIDISenderPort *)MIDISenderPortNamed:(NSString *)name;


/*!
 * Currently defined MIDI ports
 *
 * The sender ports you have registered with @link addMIDISenderPort: @endlink,
 * as an array of ABMIDISenderPorts.
 */
@property (nonatomic, readonly) NSArray *MIDISenderPorts;

#pragma mark - MIDI Filter ports

/*!
 * Add a MIDI Filter port
 *
 *  Filter ports let your app transform MIDI received from other apps.
 *
 * You can create several MIDI Filter ports to process several separate MIDI streams.
 * For example, a multi-track MIDI arpeggiator could define additional MIDI Filter ports
 * for each track, so each track can be routed to a different place.
 *
 * @param port The port to add
 */
- (void)addMIDIFilterPort:(ABMIDIFilterPort*)port;

/*!
 * Remove a MIDI Filter port
 *
 *  It is your responsibility to make sure you stop accessing the port prior to calling this method.
 *
 * @param port The port to remove
 */
-(void)removeMIDIFilterPort:(ABMIDIFilterPort*)port;

/*!
 * Sort the MIDI Filter ports
 *
 *  This method allows you to assign an order to the filter ports. This is the
 *  order in which the MIDI ports will appear within Audiobus.
 *
 * @param cmptr Comparitor block used to provide the order
 */
-(void)sortMIDIFilterPortsUsingComparitor:(NSComparator)cmptr;

/*!
 * Get the MIDI Filter port
 *
 *  This is used to access the attributes of the connected ports.
 *
 * @param name The name of the MIDI Filter port
 * @return MIDI Filter port.
 */
-(ABMIDIFilterPort *)MIDIFilterPortNamed:(NSString *)name;


/*!
 * Currently defined MIDI Filter ports
 *
 * The filter ports you have registered with @link addMIDIFilterPort: @endlink,
 * as an array of ABMIDIFilterPorts.
 */
@property (nonatomic, readonly) NSArray *MIDIFilterPorts;



#pragma mark - MIDI Receiver ports

/*!
 * Add a MIDI Receiver port
 *
 *  Filter ports let your app receive MIDI from other apps.
 *
 * You can create several MIDI Receiver ports to process several separate MIDI streams.
 * For example, a multi-track MIDI recorder could define additional MIDI Filter ports
 * for each track, so each track can be routed to a different place.
 *
 * @param port The port to add
 */
- (void)addMIDIReceiverPort:(ABMIDIReceiverPort*)port;

/*!
 * Remove a MIDI Receiver port
 *
 *  It is your responsibility to make sure you stop accessing the port prior to calling this method.
 *
 * @param port The port to remove
 */
-(void)removeMIDIReceiverPort:(ABMIDIReceiverPort*)port;

/*!
 * Sort the MIDI Receiver ports
 *
 *  This method allows you to assign an order to the filter ports. This is the
 *  order in which the MIDI ports will appear within Audiobus.
 *
 * @param cmptr Comparitor block used to provide the order
 */
-(void)sortMIDIReceiverPortsUsingComparitor:(NSComparator)cmptr;

/*!
 * Get the MIDI Receiver port
 *
 *  This is used to access the attributes of the connected ports.
 *
 * @param name The name of the MIDI Receiver port
 * @return MIDI Receiver port.
 */
-(ABMIDIReceiverPort *)MIDIReceiverPortNamed:(NSString *)name;


/*!
 * Currently defined MIDI Receiver ports
 *
 * The filter ports you have registered with @link addMIDIReceiverPort: @endlink,
 * as an array of ABMIDIReceiverPorts.
 */
@property (nonatomic, readonly) NSArray *MIDIReceiverPorts;



///@}
#pragma mark - Properties
/** @name Properties */
///@{

/*!
 * Whether to allow this app to connect its input to its own output
 *
 *  If you set this to YES, then Audiobus will allow users to add your app in the input
 *  and output positions simultaneously, allowing the app's output to be piped back into
 *  its input.
 *
 *  If you wish to support this functionality, you must either (a) pass NULL for the audioUnit
 *  parameter of ABAudioSenderPort's initialiser, which will cause the port to create its own
 *  separate audio unit for the connection, and explicitly use
 *  @link ABAudioSenderPort::ABAudioSenderPortSend ABAudioSenderPortSend @endlink to send audio,
 *  or (b) ensure the audioUnit parameter is distinct from your app's main audio unit (the one
 *  from which you call ABAudioReceiverPortReceive.
 *
 *  If you do not do this, your app's audio system will stop running once a connection to self
 *  is established, due to a loop in the audio unit connections. Note that this requirement has
 *  been newly introduced with Audiobus 3, for technical reasons. See the AB Receiver sample app
 *  for a demonstration of this functionality.
 *
 *  By default, this is disabled, as some apps may not function properly if their
 *  audio pipeline is traversed multiple times in the same time step.
 */
@property (nonatomic, assign) BOOL allowsConnectionsToSelf;

/*!
 * Connection panel position
 *
 *  This defines where the connection panel appears within your app, when necessary.
 *
 *  You can set this at any time, and the panel, if visible, will animate to the new location.
 */
@property (nonatomic, assign) ABConnectionPanelPosition connectionPanelPosition;

/*!
 * All available @link ABPeer peers @endlink
 */
@property (nonatomic, strong, readonly) NSSet *peers;

/*!
 * All @link ABPeer peers @endlink that are connected as part of the current session
 */
@property (nonatomic, strong, readonly) NSSet *connectedPeers;

/*!
 * All @link ABPort ports @endlink that are connected as part of the current session
 */
@property (nonatomic, strong, readonly) NSSet *connectedPorts;

/*!
 * Whether the app is connected to anything via Audiobus or Inter-App Audio
 *
 *  Note that due to the asynchronous nature of Inter-App Audio connections
 *  within Audiobus when connected to peers using the 2.1 Audiobus SDK or above,
 *  you may see this property change to YES before the @link audiobusConnected @endlink
 *  and @link interAppAudioConnected @endlink are both YES.
 */
@property (nonatomic, readonly) BOOL connected;

/*!
 * Whether the app is connected to anything via Audiobus specifically (not Inter-App Audio)
 *
 *  Note that due to the asynchronous nature of Inter-App Audio connections
 *  within Audiobus when connected to peers using the 2.1 Audiobus SDK or above, you may see
 *  this property change to YES before the @link interAppAudioConnected @endlink property 
 *  changes to YES, or vice versa.
 *
 */
@property (nonatomic, readonly) BOOL audiobusConnected;


/*!
 * Whether your app is connected to anything via Audiobus 2 specifically (not Inter-App Audio)
 *
 * Same as audiobusConnected but with the difference that the property becomes
 * only true when your app is connected to Audiobus 2.
 */
@property (nonatomic, readonly) BOOL audiobus2Connected;

/*!
 * Whether your app is connected to anything via Audiobus 3 specifically (not Inter-App Audio)
 *
 * Same as audiobusConnected but with the difference that the property becomes
 * only true when your app is connected to Audiobus 3.
 */
@property (nonatomic, readonly) BOOL audiobus3AndHigherConnected;

/*!
 * Whether the port is connected via Inter-App Audio
 *
 *  Note that this property will also return YES when connected to
 *  Audiobus peers using the 2.1 SDK.
 *
 *  Note that due to the asynchronous nature of Inter-App Audio connections
 *  within Audiobus when connected to peers using the 2.1 Audiobus SDK or above, you may see
 *  this property change to YES before the @link audiobusConnected @endlink property
 *  changes to YES, or vice versa.
 */
@property (nonatomic, readonly) BOOL interAppAudioConnected;


/*!
 * Whether the MIDI port is connected to Audiobus.
 *
 *  When your app provides at least one MIDI port this property reflects
 *  wether this port is connected to some other inter app audio instrument. 
 *
 */
@property (nonatomic, readonly) BOOL audiobusMIDIPortConnected;

/*!
 * Whether the app is part of an active Audiobus session
 *
 *  This property reflects whether your app is currently part of an active Audiobus session,
 *  which means the app has been used with Audiobus before, and the Audiobus app is still running.
 *
 *  You should observe this property in order to manage your app's lifecycle: If your
 *  app moves to the background and this property is YES, the app should remain active
 *  in the background and continue monitoring this property. If the Audiobus session ends,
 *  and this property changes to NO, your app should immediately stop its audio engine
 *  and suspend, where appropriate.
 *
 *  See the [Lifecycle](@ref Lifecycle) section of the integration guide for
 *  futher discussion, or see the sample applications in the SDK distribution for example
 *  implementations.
 */
@property (nonatomic, readonly) BOOL memberOfActiveAudiobusSession;

/*!
 * Whether the Audiobus app is running on this device
 */
@property (nonatomic, readonly) BOOL audiobusAppRunning;

/*!
 * State input/output delegate
 *
 *  This delegate provides methods to save and load state specific to your
 *  app, in response to preset save and load operations from within Audiobus.
 *
 *  This feature is optional but recommended, as it allows your users to save
 *  and restore the state of your app as part of their workspace.
 */
@property (nonatomic, assign) id<ABAudiobusControllerStateIODelegate> stateIODelegate;


/*!
 * In some cases the status bar is managed by Audiobus. Call this function 
 * when the status bar needs an update.
 *
 */
- (void) setNeedsStatusBarAppearanceUpdate;

#pragma mark - Switch between Audiobus and other Technologies

/*!
 * Set this block to be informed wether your app should show or hide its 
 * Inter-App audio transport panel.
 *
 * When your app is connected to Audiobus the Inter-App audio transport panel 
 * needs to be hidden. Set a block here which shows / hides the panel depending
 * on the parameter "hidePanel".
 */
@property (nonatomic, copy) void(^showInterAppAudioTransportPanelBlock)(BOOL showPanel) ;



/*!
 * For apps with MIDI Receiver ports: Set this block to prevent receiving Core 
 * MIDI events twice.
 *
 * Audiobus will collect Core MIDI events and route it to your synth app.
 * Thus your app might not want to receive these Core MIDI events directly
 * from Core MIDI sources.
 * Assign a block to this property which enables or disables Core MIDI receiving
 * depending on the parameter "receivingEnabled".
 */
@property (nonatomic, copy) void(^enableReceivingCoreMIDIBlock)(BOOL receivingEnabled);


/*!
 * For Apps with MIDI sender ports: Set this block to prevent double MIDI routings
 *
 * Assign a block to this property which enables or disables Core MIDI
 * receiving depending on the parameter "sendingEnabled". Audiobus will call
 * this block if it starts and stops receiving MIDI from your app. Thus we 
 * will prevent that apps connected to Audiobus receive MIDI twice from 
 * your MIDI controller: One time from via Audiobus and a second time directly.
 */
@property (nonatomic, copy) void(^enableSendingCoreMIDIBlock)(BOOL sendingEnabled);

@end

#ifdef __cplusplus
}
#endif
