//
//  AKSynthOneRate.h
//  AudioKitSynthOne
//
//  Created by Marcus W. Hobbs on 4/19/18.
//  Copyright © 2018 AudioKit. All rights reserved.
//

#ifndef AKSynthOneRate_h
#define AKSynthOneRate_h

#import "AudioKit/AKInterop.h"

#pragma once

typedef AK_ENUM(AKSynthOneRate) {
    eightBars = 0,
    sixBars = 1,
    fourBars = 2,
    threeBars = 3,
    twoBars = 4,
    bar = 5,
    barTriplet = 6,
    half = 7,
    halfTriplet = 8,
    quarter = 9,
    quarterTriplet = 10,
    eighth = 11,
    eighthTriplet = 12,
    sixteenth = 13,
    sixteenthTriplet = 14,
    thirtySecondth = 15,
    thirtySecondthTriplet = 16,
    sixtyFourth = 17,
    sixtyFourthTriplet = 18,
    AKSynthOneRateCount = 19
} AKSynthOneRate;

#endif /* AKSynthOneRate_h */
