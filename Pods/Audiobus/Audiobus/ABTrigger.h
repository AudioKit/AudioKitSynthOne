//
//  ABTrigger.h
//  Audiobus
//
//  Created by Michael Tyson on 16/05/2012.
//  Copyright (c) 2011-2014 Audiobus. All rights reserved.
//

#ifdef __cplusplus
extern "C" {
#endif

#import <Foundation/Foundation.h>
#import "ABCommon.h"

extern NSString * const ABTriggerAttributeChangedNotification;

@class ABTrigger;

/*!
 * Trigger perform block
 *
 * @param trigger The trigger being performed
 * @param ports   The port(s) of your app that the triggering peer is connected to. May be an empty set if triggered from the Audiobus app.
 */
typedef void (^ABTriggerPerformBlock)(ABTrigger *trigger, NSSet *ports);

/*!
 * @enum ABTriggerSystemType System trigger types
 *
 * @var ABTriggerTypeRecordToggle
 *      
 *  Toggle record. Appears as a circular button with the engraved word "REC", and
 *  turns red when in state ABTriggerStateSelected. When in state ABTriggerStateAlternate,
 *  appears with a green colour to indicate a 'primed' state.
 *
 * @var ABTriggerTypePlayToggle
 *
 *  Toggle playback. Appears as a triangle (standard transport play symbol) when
 *  in state ABTriggerStateNormal, and two vertical bars (pause symbol) when in
 *  state ABTriggerStateSelected.
 *
 * @var ABTriggerTypeRewind
 *
 *  Rewind button. Appears as a triangle pointing to the left, with a vertical bar
 *  at the apex.
 *
 * @var ABTriggerTypeSkip
 *
 *  Skip button. Appears as a triangle pointing to the right, with a vertical bar
 *  at the apex.
 */
typedef enum {
    ABTriggerTypeRecordToggle = 1,
    ABTriggerTypePlayToggle,
    ABTriggerTypeRewind,
    ABTriggerTypeSkip,
    
    kABTotalTriggerTypes
} ABTriggerSystemType;

/*!
 * @enum ABTriggerState Trigger states
 */
typedef enum {
    ABTriggerStateNormal,
    ABTriggerStateSelected,
    ABTriggerStateDisabled,
    ABTriggerStateAlternate
} ABTriggerState;

    
NSString* ABTriggerStateToString(ABTriggerState);
    
/*!
 *  Trigger
 *
 *  This class defines actions that can be performed on your app by other Audiobus apps.
 *  Triggers you define and add to the Audiobus controller via 
 *  @link ABAudiobusController::addTrigger: addTrigger: @endlink
 *  will be displayed within the Audiobus Connection Panel for other apps.
 *
 *  You can use a [system trigger type](@ref ABTriggerSystemType), or define your own
 *  custom triggers.
 */
@interface ABTrigger : NSObject

/*!
 * Create a trigger with a system type
 *
 * You should use this method as much as possible. Only use 
 * ABButtonTrigger if it is *absolutely* necessary that you create a custom trigger type.
 *
 * System triggers are automatically ordered in the connection panel as follows:
 * ABTriggerTypeRewind, ABTriggerTypePlayToggle, ABTriggerTypeRecordToggle.
 *
 * @param type One of the system type identifiers
 * @param block Block to be called when trigger is activated
 */
+ (ABTrigger*)triggerWithSystemType:(ABTriggerSystemType)type block:(ABTriggerPerformBlock)block;

/*!
 * Create a custom trigger
 *
 * @deprecated Deprecated in Version 2.0 - Use @link ABButtonTrigger::buttonTriggerWithTitle:icon:block: +[ABButtonTrigger buttonTriggerWithTitle:icon:block:] @endlink instead.
 * @param title A user-readable title (used for accessibility)
 * @param icon A icon of maximum dimensions 80x80, to use to draw the trigger button. This icon will be used
 *             as a mask to render the inset button effect. Icon size should be divisible by 2.
 * @param block Block to be called when trigger is activated
 */
+ (ABTrigger*)triggerWithTitle:(NSString*)title icon:(UIImage*)icon block:(ABTriggerPerformBlock)block __attribute__((deprecated));

/*!
 * Trigger state
 *
 *  Updates to this property will affect the corresponding UI in connected applications.
 */
@property (nonatomic, assign) ABTriggerState state;

/*!
 * Block to be performed on trigger activation/update
 */
@property (nonatomic, copy) ABTriggerPerformBlock block;

/*!
 * A numeric (or fourcc) identifier for the trigger, such as 'trig'
 *
 *  This must be a unique value. If unset, a unique value will
 *  be chosen automatically, but this value is not guaranteed to
 *  remain the same across multiple sessions.
 */
@property (nonatomic, assign) uint32_t numericIdentifier;

@end

#ifdef __cplusplus
}
#endif
