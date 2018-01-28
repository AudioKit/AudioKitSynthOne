//
//  AETime.m
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

#import "AETime.h"
#import <mach/mach_time.h>

static double __hostTicksToSeconds = 0.0;
static double __secondsToHostTicks = 0.0;

const AudioTimeStamp AETimeStampNone = {};

void AETimeInit() {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        mach_timebase_info_data_t tinfo;
        mach_timebase_info(&tinfo);
        __hostTicksToSeconds = ((double)tinfo.numer / tinfo.denom) * 1.0e-9;
        __secondsToHostTicks = 1.0 / __hostTicksToSeconds;
    });
}

AEHostTicks AECurrentTimeInHostTicks(void) {
    return mach_absolute_time();
}

AESeconds AECurrentTimeInSeconds(void) {
    if ( !__hostTicksToSeconds ) AETimeInit();
    return mach_absolute_time() * __hostTicksToSeconds;
}

AEHostTicks AEHostTicksFromSeconds(AESeconds seconds) {
    if ( !__secondsToHostTicks ) AETimeInit();
    assert(seconds >= 0);
    return round(seconds * __secondsToHostTicks);
}

AESeconds AESecondsFromHostTicks(AEHostTicks ticks) {
    if ( !__hostTicksToSeconds ) AETimeInit();
    return ticks * __hostTicksToSeconds;
}

AudioTimeStamp AETimeStampWithHostTicks(AEHostTicks ticks) {
    if ( !ticks ) return AETimeStampNone;
    return (AudioTimeStamp) { .mFlags = kAudioTimeStampHostTimeValid, .mHostTime = ticks };
}

AudioTimeStamp AETimeStampWithSamples(Float64 samples) {
    return (AudioTimeStamp) { .mFlags = kAudioTimeStampSampleTimeValid, .mSampleTime = samples };
}
