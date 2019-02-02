//
//  S1Rate.hpp
//  AudioKitSynthOne
//
//  Created by AudioKit Contributors on 4/19/18.
//  Copyright © 2018 AudioKit. All rights reserved.
//

#ifndef S1Rate_h
#define S1Rate_h

#import "AKSynthOneRate.h"

// helper for main thread communication
typedef struct S1RateArgs {
    AKSynthOneRate rate;
    float value; // return value
    float value01;// [0,1] normalized index of enums for UI
} S1RateArgs;


class S1Rate {
    
public:
    
    S1Rate() {}
    ~S1Rate() = default;
    void init() {}
    
    std::string friendlyName(AKSynthOneRate rate) {
        switch(rate) {
            case eightBars:             return "8 bars";        break;
            case sixBars:               return "6 bars";        break;
            case fourBars:              return "4 bars";        break;
            case threeBars:             return "3 bars";        break;
            case twoBars:               return "2 bars";        break;
            case bar:                   return "1 bar";         break;
            case barTriplet:            return "1 bar triplet"; break;
            case half:                  return "1/2 note";      break;
            case halfTriplet:           return "1/2 triplet";   break;
            case quarter:               return "1/4 note";      break;
            case quarterTriplet:        return "1/4 triplet";   break;
            case eighth:                return "1/8 note";      break;
            case eighthTriplet:         return "1/8 triplet";   break;
            case sixteenth:             return "1/16 note";     break;
            case sixteenthTriplet:      return "1/16 triplet";  break;
            case thirtySecondth:        return "1/32 note";     break;
            case thirtySecondthTriplet: return "1/32 triplet";  break;
            case sixtyFourth:           return "1/64 note";     break;
            case sixtyFourthTriplet:    return "1/64 triplet";  break;
            default: return "ERROR"; break;
        }
    }
    
    inline S1RateArgs nearestFrequency(float inputFrequency, float inputTempoBPM, float min, float max) {
        int closestRate = eightBars;
        float closestFrequency = frequency(inputTempoBPM, (AKSynthOneRate)closestRate);
        float smallestDifference = 1000000000.f;
        for(int i = eightBars; i < AKSynthOneRate::AKSynthOneRateCount; i++) {
            float tempoAsFrequency = frequency(inputTempoBPM, (AKSynthOneRate)i);
            if (tempoAsFrequency < min || tempoAsFrequency > max)
                continue;
            float difference = abs(tempoAsFrequency - inputFrequency);
            if (difference < smallestDifference) {
                smallestDifference = difference;
                closestRate = i;
                closestFrequency = tempoAsFrequency;
            }
        }
        S1RateArgs retVal = {(AKSynthOneRate)closestRate, closestFrequency, (float)closestRate/(float)(AKSynthOneRate::AKSynthOneRateCount-1.f)};
        return retVal;
    }
    
    // special case for delay excludes 8, 6, 4, 3 bar enums
    inline S1RateArgs nearestTime(float inputTime, float inputTempoBPM, float min, float max) {
        int closestRate = sixtyFourthTriplet;
        float closestTime = time(inputTempoBPM, (AKSynthOneRate)closestRate);
        float smallestDifference = 1000000000.f;
        for(int i = sixtyFourthTriplet; i >= twoBars; i--) {
            float tempoTime = time(inputTempoBPM, (AKSynthOneRate)i);
            if (tempoTime < min || tempoTime > max)
                continue;
            float difference = abs(tempoTime - inputTime);
            if (difference < smallestDifference) {
                smallestDifference = difference;
                closestRate = i;
                closestTime = tempoTime;
            }
        }
        const float outputRate01 = (float)(closestRate - twoBars) / (float)(AKSynthOneRate::AKSynthOneRateCount - 1.f - twoBars);
        S1RateArgs retVal = {(AKSynthOneRate)closestRate, closestTime, outputRate01};
        return retVal;
    }

    inline S1RateArgs nearestFactor(float inputFactor) {
        int closestRate = sixtyFourthTriplet;
        float closestFactor = factorForRate((AKSynthOneRate)closestRate);
        float smallestDifference = 1000000000.f;
        for(int i = sixtyFourthTriplet; i >= eightBars; i--) {
            const float factor = factorForRate((AKSynthOneRate)i);
            float difference = abs(factor - inputFactor);
            if (difference < smallestDifference) {
                smallestDifference = difference;
                closestRate = i;
                closestFactor = factor;
            }
        }
        const float outputRate01 = (float)(closestRate - eightBars) / (float)(AKSynthOneRate::AKSynthOneRateCount - 1.f - eightBars);
        S1RateArgs retVal = {(AKSynthOneRate)closestRate, closestFactor, outputRate01};
        return retVal;
    }

    AKSynthOneRate rateFromFrequency01(float inputValue01) {
        const int x = inputValue01 * (float)(AKSynthOneRate::AKSynthOneRateCount - 1.f);
        return (AKSynthOneRate)x;
    }
    
    AKSynthOneRate rateFromTime01(float inputValue01) {
        const int x = twoBars + inputValue01 * (float)(AKSynthOneRate::AKSynthOneRateCount - 1.f  - twoBars);
        return (AKSynthOneRate)x;
    }

    float factorForRate(AKSynthOneRate rate) {
        switch(rate) {
            case eightBars:             return 8.f; break;
            case sixBars:               return 6.f; break;
            case fourBars:              return 4.f; break;
            case threeBars:             return 3.f; break;
            case twoBars:               return 2.f; break;
            case bar:                   return 1.f; break;
            case barTriplet:            return 1.f / 1.5f; break;
            case half:                  return 1.f / 2.f; break;
            case halfTriplet:           return 1.f / 2.f / 1.5f; break;
            case quarter:               return 1.f / 4.f; break;
            case quarterTriplet:        return 1.f / 4.f / 1.5f; break;
            case eighth:                return 1.f / 8.f; break;
            case eighthTriplet:         return 1.f / 8.f / 1.5f; break;
            case sixteenth:             return 1.f / 16.f; break;
            case sixteenthTriplet:      return 1.f / 16.f / 1.5f; break;
            case thirtySecondth:        return 1.f / 32.f; break;
            case thirtySecondthTriplet: return 1.f / 32.f / 1.5f; break;
            case sixtyFourth:           return 1.f / 64.f; break;
            case sixtyFourthTriplet:    return 1.f / 64.f / 1.5f; break;
            default: return 1.f; break;
        }
    }

    AKSynthOneRate rateFromFactor01(float inputValue01) {
        const int x = eightBars + inputValue01 * (float)(AKSynthOneRate::AKSynthOneRateCount - 1.0f);
        return (AKSynthOneRate)x;
    }

    inline float frequency(float tempoBPM, AKSynthOneRate rate) {
        return 1.f / time(tempoBPM, rate);
    }
    
    inline float time(float tempoBPM, AKSynthOneRate rate) {
        switch(rate) {
            case eightBars:             return seconds(tempoBPM, 8.f      , false); break;
            case sixBars:               return seconds(tempoBPM, 6.f      , false); break;
            case fourBars:              return seconds(tempoBPM, 4.f      , false); break;
            case threeBars:             return seconds(tempoBPM, 3.f      , false); break;
            case twoBars:               return seconds(tempoBPM, 2.f      , false); break;
            case bar:                   return seconds(tempoBPM, 1.f      , false); break;
            case barTriplet:            return seconds(tempoBPM, 1.f      , true);  break;
            case half:                  return seconds(tempoBPM, 1.f/2.f  , false); break;
            case halfTriplet:           return seconds(tempoBPM, 1.f/2.f  , true);  break;
            case quarter:               return seconds(tempoBPM, 1.f/4.f  , false); break;
            case quarterTriplet:        return seconds(tempoBPM, 1.f/4.f  , true);  break;
            case eighth:                return seconds(tempoBPM, 1.f/8.f  , false); break;
            case eighthTriplet:         return seconds(tempoBPM, 1.f/8.f  , true);  break;
            case sixteenth:             return seconds(tempoBPM, 1.f/16.f , false); break;
            case sixteenthTriplet:      return seconds(tempoBPM, 1.f/16.f , true);  break;
            case thirtySecondth:        return seconds(tempoBPM, 1.f/32.f , false); break;
            case thirtySecondthTriplet: return seconds(tempoBPM, 1.f/32.f , true);  break;
            case sixtyFourth:           return seconds(tempoBPM, 1.f/64.f , false); break;
            case sixtyFourthTriplet:    return seconds(tempoBPM, 1.f/64.f , true);  break;
            default: return 1.f; break;
        }
    }
    
    inline int lfoAutoPanNumRates() {
        return AKSynthOneRateCount;
    }
    
    inline int delayNumRates() {
        return AKSynthOneRateCount - twoBars;
    }

private:
    
    float seconds(float tempoBPM, float bars, bool triplet) {
        const float minutesPerSecond = 1.f / 60.f;
        const float beatsPerBar = 4.f;
        return (beatsPerBar * bars) / (tempoBPM * minutesPerSecond) / (triplet ? 1.5f : 1.f);
    }
};

#endif /* S1Rate_h */
