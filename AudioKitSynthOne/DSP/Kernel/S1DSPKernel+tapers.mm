//
//  S1DSPKernel+tapers.mm
//  AudioKitSynthOne
//
//  Created by Aurelius Prochazka on 6/4/18.
//  Copyright © 2018 AudioKit. All rights reserved.
//

#import "S1DSPKernel.hpp"

// algebraic and exponential taper and inverse generalized for all ranges
inline float S1DSPKernel::taper(float inputValue01, float min, float max, float taper) {
    if ( (min == 0.f || max == 0.f) && (taper < 0.f) ) {
        printf("can have a negative taper with a range that includes 0\n");
        return min;
    }

    if (taper > 0.f) {
        // algebraic taper
        return powf((inputValue01 - min )/(max - min), 1.f / taper);
    } else {
        // exponential taper
        return min * expf(logf(max/min) * inputValue01);
    }
}

inline float S1DSPKernel::taperInverse(float inputValue01, float min, float max, float taper) {
    if ((min == 0.f || max == 0.f) && taper < 0.f) {
        printf("can have a negative taper with a range that includes 0\n");
        return min;
    }

    // Avoiding division by zero in this trivial case
    if ((max - min) < FLT_EPSILON) {
        return min;
    }

    if (taper > 0.f) {
        // algebraic taper
        return min + (max - min) * pow(inputValue01, taper);
    } else {
        // exponential taper
        float adjustedMinimum = 0.0;
        float adjustedMaximum = 0.0;
        if (min == 0.f) { adjustedMinimum = FLT_EPSILON; }
        if (max == 0.f) { adjustedMaximum = FLT_EPSILON; }
        return logf(inputValue01 / adjustedMinimum) / logf(adjustedMaximum / adjustedMinimum);
    }
}
