//
//  S1DSPHorizon.hpp
//  AudioKitSynthOne
//
//  Created by Carlos Gómez on 12/6/21.
//  Copyright © 2021 AudioKit. All rights reserved.
//

#ifndef S1DSPHorizon_hpp
#define S1DSPHorizon_hpp

class S1DSPHorizon {
private:
    int defaultFrameCount = 480001; // 48000 * 10 + 1. Just a somewhat arbitrary default value.
    
public:
    S1DSPHorizon(double sampleRate, double bitCrushMinSampleRate);
    void updateSampleRate(double sampleRate);
    
    // Next are the horizon sizes in number of frames for each operation. Among the
    // included operations, osc, buthp, and widen are rather simple computationally, so
    // there might not be much advantage in optimizing them out of the process function.
    int bitCrushFrameCount = defaultFrameCount;
    int pan2FrameCount = defaultFrameCount;
    int oscFrameCount = defaultFrameCount; // pan2 oscilator
    int phaserFrameCount = 47;
    int moogladderFrameCount = 8;
    int vdelayFrameCount = defaultFrameCount;
    int buthpFrameCount = 8;
    int compressorFrameCount = defaultFrameCount;
    int revscFrameCount = defaultFrameCount;
    int widenFrameCount = defaultFrameCount;
    int totalDelayFrameCount = defaultFrameCount;
    int totalReverbFrameCount = defaultFrameCount;
    int totalMasterFrameCount = defaultFrameCount;
    
private:
    // Some horizons can only be specified as a duration in seconds and transformed to frames at runtime (when sample rate is known).
    double pan2Duration = 10;
    double oscDuration = pan2Duration;
    double vdelayDuration = 10;
    double compressorDuration = 0.5;
    double revscDuration = 5;
    double widenDuration = 0.05;
    
    double bitCrushMinSampleRate;
    
    void calculateFrameCounts(double sampleRate);
    int durationToFrameCount(double sampleRate, double duration);
};

#endif /* S1DSPHorizon_hpp */
