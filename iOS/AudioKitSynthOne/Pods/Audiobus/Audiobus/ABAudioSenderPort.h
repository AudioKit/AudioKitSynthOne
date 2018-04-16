//
//  ABAudioSenderPort.h
//  Audiobus
//
//  Created by Michael Tyson on 25/11/2011.
//  Copyright (c) 2011-2014 Audiobus. All rights reserved.
//

#ifdef __cplusplus
extern "C" {
#endif

#import <UIKit/UIKit.h>
#import <AudioToolbox/AudioToolbox.h>
#import "ABCommon.h"
#import "ABPort.h"
#import "ABLocalPort.h"
    
/*!
 * Sender port connections changed
 *
 *  Sent when the port's connections have changed, caused by connections
 *  or disconnections from within the Audiobus app.
 *
 *  > If you work with floating-point audio in your app we strongly recommend
 *  > you restrict values to the range -1.0 to 1.0, as a courtesy to
 *  > developers of downstream apps.
 */
extern NSString * const ABAudioSenderPortConnectionsChangedNotification;

/*!
 * Flag to suppress the warning when adding an audio sender port which allows connections to self and has an audio unit
 */
extern BOOL ABAudioSenderPortSuppressConnectionToSelfWarning;

/*!
 * Sender port
 *
 *  This class is used to transmit audio.
 *
 *  See the integration guide on using the [Sender Port](@ref Create-Audio-Sender-Port)
 *  for discussion.
 */
@interface ABAudioSenderPort : ABPort <ABLocalPort>

/*!
 * Initialize
 *
 *  Initializes a new sender port. Use @link ABAudioSenderPortSend @endlink to send audio.
 *
 *  Note that unlike the @link initWithName:title:audioComponentDescription:audioUnit: @endlink
 *  initializer, audio sent via sender ports initialized with this version will incur a
 *  small latency penalty equal to the current hardware buffer duration (e.g. 5 ms) due to necessary
 *  buffering. Initialize with an audio unit to avoid this.
 *
 * @param name Name of port, for internal use
 * @param title Title of port, show to the user
 * @param description The AudioComponentDescription that identifiers this port.
 *          This must match the entry in the AudioComponents dictionary of your Info.plist, and must be
 *          of type kAudioUnitType_RemoteGenerator or kAudioUnitType_RemoteInstrument.
 */
- (id)initWithName:(NSString *)name title:(NSString*)title audioComponentDescription:(AudioComponentDescription)description;

/*!
 * Initialize, with an audio unit
 *
 *  Initializes a new sender port, with an audio unit to be used for generating audio.
 *
 *  Note: The audio unit you pass here must be an output unit (kAudioUnitSubType_RemoteIO). If you wish
 *  to use a different kind of audio unit, you'll need to use the 
 *  @link initWithName:title:audioComponentDescription: non-AudioUnit initialiser @endlink and call
 *  @link ABAudioSenderPortSend @endlink with the output from that audio unit.
 *
 * @param name Name of port, for internal use
 * @param title Title of port, show to the user
 * @param description The AudioComponentDescription that identifiers this port.
 *          This must match the entry in the AudioComponents dictionary of your Info.plist, and must be
 *          of type kAudioUnitType_RemoteGenerator or kAudioUnitType_RemoteInstrument.
 * @param audioUnit The output audio unit to use for sending audio. The audio unit's output will be transmitted.
 */
- (id)initWithName:(NSString *)name title:(NSString*)title audioComponentDescription:(AudioComponentDescription)description audioUnit:(AudioUnit)audioUnit;

/*!
 * Register additional AudioComponentDescriptions that identify your audio unit
 *
 *  Sometimes under Inter-App Audio you may wish to publish your audio unit with an additional 
 *  AudioComponentDescription, such as providing both kAudioUnitType_RemoteInstrument and
 *  kAudioUnitType_RemoteGenerator types.
 *
 *  If you wish to do so, you can use this method to register the additional descriptions 
 *  (additional to the one passed via the init method). Note that this method will not publish
 *  your audio unit with the given description: you'll need to do that yourself.
 *
 *  This will cause the port to correctly recognize incoming connections from the other
 *  descriptions.
 *
 * @param description The additional AudioComponentDescription to add
 */
- (void)registerAdditionalAudioComponentDescription:(AudioComponentDescription)description;

/*!
 * Send audio
 *
 *  This C function is used to send audio. It's suitable for use within a realtime thread, as it does not hold locks,
 *  allocate memory or call Objective-C methods.  You should keep a local pointer to the ABAudioSenderPort instance, to be
 *  passed as the first parameter.
 *
 *  Note: If you provided an audio unit when you initialized this class, you cannot use this function.
 *
 * @param senderPort        Sender port.
 * @param audio             Audio buffer list to send, in the @link clientFormat client format @endlink.
 * @param lengthInFrames    Length of the audio, in frames.
 * @param timestamp         The timestamp of the audio.
 */
void ABAudioSenderPortSend(ABAudioSenderPort* senderPort, const AudioBufferList *audio, UInt32 lengthInFrames, const AudioTimeStamp *timestamp);

/*!
 * Determine if the sender port is currently connected to any destinations
 *
 *  This function is suitable for use from within a realtime Core Audio context.
 *
 * @param senderPort        Sender port.
 * @return YES if there are currently destinations connected; NO otherwise.
 */
BOOL ABAudioSenderPortIsConnected(ABAudioSenderPort* senderPort);

/*!
 * Whether the port is connected to another port from the same app
 *
 *  This returns YES when the sender port is connected to a receiver port also belonging to your app.
 *
 *  If your app supports connections to self (ABAudiobusController's
 *  @link ABAudiobusController::allowsConnectionsToSelf allowsConnectionsToSelf @endlink
 *  is set to YES), then you should take care to avoid feedback issues when the app's input is being fed from
 *  its own output.
 *
 *  Primarily, this means not sending output derived from the input through the sender port.
 *
 *  You can use @link ABAudioSenderPortIsConnectedToSelf @endlink and the equivalent ABAudioReceiverPort function,
 *  @link ABAudioReceiverPort::ABAudioReceiverPortIsConnectedToSelf ABAudioReceiverPortIsConnectedToSelf @endlink 
 *  to determine this state from the Core Audio realtime thread, and perform muting/etc as appropriate.
 *
 * @param senderPort        Sender port.
 * @return YES if one of this port's destinations belongs to this app
 */
BOOL ABAudioSenderPortIsConnectedToSelf(ABAudioSenderPort* senderPort);

/*!
 * Determine whether output should be muted
 *
 *  This C function allows you to determine whether your output should be muted.
 *
 *  If the return value of this function is YES, then you must silence your app's corresponding audio output
 *  to avoid doubling up the audio (which is being output at the other end), and to enable your app to
 *  go silent when disconnected from Audiobus.  You can do this by zeroing your buffers using memset,
 *  and/or setting the `kAudioUnitRenderAction_OutputIsSilence` flag on the ioActionFlags variable in a render callback.
 *
 *  MIDI that this muting is handled for you automatically if you are using an audio unit with the port, but either way
 *  you may be able to save some rendering time by not running your audio processing routines when this function returns YES.
 *
 *  The @link muted @endlink property provides a key-value observable version of this method, which should
 *  only be used outside of the Core Audio realtime thread.
 *
 * @param senderPort Sender port.
 * @return Whether the output should be muted
 */
BOOL ABAudioSenderPortIsMuted(ABAudioSenderPort *senderPort);


/*!
 * Currently-connected destinations
 *
 *  This is an array of @link ABPort ABPorts @endlink.
 */
@property (nonatomic, strong, readonly) NSArray *destinations;

/*!
 * Whether the port is connected (via IAA or Audiobus)
 */
@property (nonatomic, readonly) BOOL connected;

/*!
 * Whether the port is connected via Inter-App Audio
 *
 * Note that this property will also return YES when connected to
 * Audiobus peers using the 2.1 SDK.
 */
@property (nonatomic, readonly) BOOL interAppAudioConnected;

/*!
 * Whether the port is connected via Audiobus
 */
@property (nonatomic, readonly) BOOL audiobusConnected;

/*!
 * Whether the port is muted
 *
 *  See discussion for @link ABAudioSenderPortIsMuted @endlink for details.
 *
 *  This property is observable.
 */
@property (nonatomic, readonly) BOOL muted;

/*!
 * Client format
 *
 *  Use this to specify what audio format your app uses. Audio will be automatically
 *  converted to the Audiobus line format.
 *
 *  Note: If you provided an audio unit when you initialized this class, you cannot use this property.
 *
 *  The default value is non-interleaved stereo floating-point PCM.
 */
@property (nonatomic, assign) AudioStreamBasicDescription clientFormat;

/*!
 * Whether the port's audio is derived from a live audio source
 *
 *  If this sender port's audio comes from the system audio input (such as a microphone),
 *  then you should set this property to YES to allow apps downstream to react accordingly.
 *  For example, an app that provides audio monitoring might want to disable monitoring by
 *  default when connected to a live audio source in order to prevent feedback.
 */
@property (nonatomic, assign) BOOL derivedFromLiveAudioSource;

/*!
 * Audio unit
 *
 *  The output audio unit to use for sending audio. The audio unit's output will be transmitted.
 *  If you uninitialize the audio unit passed to this class's initializer, be sure to set this
 *  property to NULL immediately beforehand.
 *
 *  If you did not provide an audio unit when initializing the port, this property will allow 
 *  you to gain access to the internal audio unit used for audio transport, for the purposes of 
 *  custom Inter-App Audio interactions such as transport control or MIDI exchange.
 */
@property (nonatomic, assign) AudioUnit audioUnit;

/*!
 * The AudioComponentDescription, of type kAudioUnitType_RemoteGenerator, which identifies this
 * port's published audio unit
 */
@property (nonatomic, readonly) AudioComponentDescription audioComponentDescription;

/*!
 * Whether the port is connected to another port from the same app
 *
 *  This is a key-value-observable property equivalent of ABAudioSenderPortIsConnectedToSelf. See
 *  the documentation for ABAudioSenderPortIsConnectedToSelf for details.
 */
@property (nonatomic, readonly) BOOL connectedToSelf;

/*!
 * The constant latency of this sender, in frames
 *
 *  If your audio generation code adds a constant amount of latency to the audio stream
 *  (such as an FFT or lookahead operation), you should specify that here in order
 *  to have Audiobus automatically account for it.
 *
 *  This is important when users have the same input signal going through different
 *  paths, so that Audiobus can synchronize these properly at the output. If you don't
 *  specify the correct latency, the user will hear phasing due to incorrectly aligned
 *  signals at the output.
 *
 *  Default: 0
 */
@property (nonatomic, assign) UInt32 latency;

/*!
 * The title of the port, for display to the user.
 */
@property (nonatomic, strong, readwrite) NSString *title;

/*!
 * The port icon (a 32x32 image)
 *
 *  This is optional if your app only has one sender port, but if your app
 *  defines multiple sender ports, it is highly recommended that you provide icons
 *  for each, for easy identification by the user.
 */
@property (nonatomic, strong, readwrite) UIImage *icon;


/*!
 * Prevents showing the port in Audiobus' sender port picker view.
 *
 * If this property is true, the port is created but not shown in the list 
 * of sender ports. Set this property to true in the case that the port is
 * only used for inter app audio launching and background launching of your
 * app.
 */
@property (nonatomic, assign) BOOL isHidden;

/*!
 * A title representing the destinations the port is connected to.
 */
@property (nonatomic, readonly) NSString * destinationsTitle;

/*!
 * An icon representing the destinations the port is connected to.
 */
@property (nonatomic, readonly) UIImage * destinationsIcon;


@end

#ifdef __cplusplus
}
#endif
