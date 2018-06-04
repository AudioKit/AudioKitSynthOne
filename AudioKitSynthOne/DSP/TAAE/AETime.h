//
//  AETime.h
//  TheAmazingAudioEngine
//
//  Created by Michael Tyson on 24/03/2016.
//  Copyright © 2016 A Tasty Pixel. All rights reserved.
//
//  This software is provided 'as-is', without any express or implied
//  warranty.  In no event will the authors be held liable for any damages
//  arising from the use of this software.
//
//  Permission is granted to anyone to use this software for any purpose,
//  including commercial applications, and to alter it and redistribute it
//  freely, subject to the following restrictions:
//
//  1. The origin of this software must not be misrepresented; you must not
//     claim that you wrote the original software. If you use this software
//     in a product, an acknowledgment in the product documentation would be
//     appreciated but is not required.
//
//  2. Altered source versions must be plainly marked as such, and must not be
//     misrepresented as being the original software.
//
//  3. This notice may not be removed or altered from any source distribution.
//

#ifdef __cplusplus
extern "C" {
#endif

#import <Foundation/Foundation.h>
#import <AudioToolbox/AudioToolbox.h>

typedef uint64_t AEHostTicks;
typedef double AESeconds;
    
extern const AudioTimeStamp AETimeStampNone; //!< An empty timestamp
    
/*!
 * Initialize
 */
void AETimeInit(void);

/*!
 * Get current global timestamp, in host ticks
 */
AEHostTicks AECurrentTimeInHostTicks(void);

/*!
 * Get current global timestamp, in seconds
 */
AESeconds AECurrentTimeInSeconds(void);

/*!
 * Convert time in seconds to host ticks
 *
 * @param seconds The time in seconds
 * @return The time in host ticks
 */
AEHostTicks AEHostTicksFromSeconds(AESeconds seconds);

/*!
 * Convert time in host ticks to seconds
 *
 * @param ticks The time in host ticks
 * @return The time in seconds
 */
AESeconds AESecondsFromHostTicks(AEHostTicks ticks);
    
/*!
 * Create an AudioTimeStamps with a host ticks value
 *
 *  If a zero value is provided, then AETimeStampNone will be returned.
 *
 * @param ticks The time in host ticks
 * @return The timestamp
 */
AudioTimeStamp AETimeStampWithHostTicks(AEHostTicks ticks);

/*!
 * Create an AudioTimeStamps with a sample time value
 *
 * @param samples The time in samples
 * @return The timestamp
 */
AudioTimeStamp AETimeStampWithSamples(Float64 samples);

#ifdef __cplusplus
}
#endif
