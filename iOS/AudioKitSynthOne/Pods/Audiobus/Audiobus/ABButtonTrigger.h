//
//  ABButtonTrigger.h
//  Audiobus
//
//  Created by Michael Tyson on 30/08/2013.
//  Copyright (c) 2011-2014 Audiobus. All rights reserved.
//

#import "ABTrigger.h"
#import <UIKit/UIKit.h>

/*!
 * Button trigger
 *
 *  This class implements a kind of [trigger](@ref ABTrigger) that appears as a button.
 */
@interface ABButtonTrigger : ABTrigger

/*!
 * Create a button trigger
 *
 * @param title A user-readable title (used for accessibility)
 * @param icon A icon of maximum dimensions 80x80, to use to draw the trigger button. This icon will be used
 *             as a mask to render the inset button effect. Icon size should be divisible by 2.
 * @param block Block to be called when trigger is activated
 */
+ (ABButtonTrigger*)buttonTriggerWithTitle:(NSString*)title icon:(UIImage*)icon block:(ABTriggerPerformBlock)block;

/*!
 * Designated initializer
 */
-(id)init;

/*!
 * Set the title for a given state
 *
 * @param title User-readable title (used for accessibility)
 * @param state State to apply title to
 */
- (void)setTitle:(NSString*)title forState:(ABTriggerState)state;

/*!
 * Get title for the given state
 *
 * @param state A state
 * @return Title for state
 */
- (NSString*)titleForState:(ABTriggerState)state;

/*!
 * Set the icon for a given state
 *
 * @param icon A icon of maximum dimensions 80x80, to use to draw the trigger button. This icon will be used
 *             as a mask to render the inset button effect. Icon size should be divisible by 2.
 * @param state State to apply icon to
 */
- (void)setIcon:(UIImage*)icon forState:(ABTriggerState)state;

/*!
 * Get icon for the given state
 *
 * @param state A state
 * @return Icon for state
 */
- (UIImage*)iconForState:(ABTriggerState)state;

/*!
 * Set the color for a given state
 *
 *  By default, normal state icons are drawn in 50% grey, selected icons are drawn in 20% grey
 *  unless a custom selected state icon is provided, in which case it is also drawn in 50% grey.
 *  Alternate state icons are drawn in green. Triggers with system state ABTriggerTypeRecordToggle
 *  are drawn in red.
 *
 * @param color The color to use to render the icon for the given state
 * @param state State to apply color to
 */
- (void)setColor:(UIColor*)color forState:(ABTriggerState)state;

/*!
 * Get color for the given state
 *
 * @param state A state
 * @return Color for state
 */
- (UIColor*)colorForState:(ABTriggerState)state;

/*!
 * Add a block to be called in response to events within Audiobus Remote
 *
 *  This method allows your app to react to UIControlEventTouchDown, UIControlEventTouchUpInside
 *  UIControlEventTouchUpOutside, UIControlEventTouchCancel events originating from Audiobus Remote.
 *
 *  This method must only used with triggers that have been added using ABAudiobusController's
 *  @link ABAudiobusController::addRemoteTrigger: addRemoteTrigger: @endlink and
 *  @link ABAudiobusController::addRemoteTriggerMatrix:rows:cols: addRemoteTriggerMatrix:rows:cols: @endlink
 *  methods.
 *
 * @param block The block executed if control event occurs.
 * @param controlEvents The UIControlEvents for which the block shall be executed.
 */
- (void)addBlock:(ABTriggerPerformBlock)block forRemoteControlEvents:(UIControlEvents)controlEvents;

@end
