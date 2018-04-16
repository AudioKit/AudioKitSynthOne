//
//  ABLocalPort.h
//  Audiobus
//
//  Created by Michael Tyson on 14/09/2014.
//  Copyright (c) 2014 Audiobus. All rights reserved.
//

#ifdef __cplusplus
extern "C" {
#endif

#import <Foundation/Foundation.h>

@class ABAudiobusController;
    
/*!
 * Local port protocol
 *
 * Defines some common interface methods for local port classes
 */
@protocol ABLocalPort <NSObject>
    
/*!
 * Whether the port is connected (via IAA or Audiobus)
 */
@property (nonatomic, readonly) BOOL connected;

/*!
 * Whether the port is connected via Audiobus
 */
@property (nonatomic, readonly) BOOL audiobusConnected;

/*!
 * The Audiobus controller
 *
 *  A reference to the Audiobus controller, for convenience
 */
@property (nonatomic, weak, readonly) ABAudiobusController *audiobusController;
    
@optional
    
/*!
 * Whether the port is connected via Inter-App Audio
 *
 * Note that this property will also return YES when connected to
 * Audiobus peers using the 2.1 SDK.
 */
@property (nonatomic, readonly) BOOL interAppAudioConnected;

/*!
 * Currently-connected sources
 *
 *  This is an array of @link ABPort ABPorts @endlink.
 */
@property (nonatomic, strong, readonly) NSArray *sources;

/*!
 * Currently-connected destinations
 *
 *  This is an array of @link ABPort ABPorts @endlink.
 */
@property (nonatomic, strong, readonly) NSArray *destinations;

   
@end

#ifdef __cplusplus
}
#endif