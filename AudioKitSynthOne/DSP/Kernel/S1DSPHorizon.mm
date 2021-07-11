//
//  S1DSPHorizon.mm
//  AudioKitSynthOne
//
//  Created by Carlos Gómez on 12/6/21.
//  Copyright © 2021 AudioKit. All rights reserved.
//

#import <cmath>
#import "S1DSPHorizon.hpp"

S1DSPHorizon::S1DSPHorizon(double sampleRate, double bitCrushMinSampleRate) : bitCrushMinSampleRate(bitCrushMinSampleRate) {
    calculateFrameCounts(sampleRate);
}

void S1DSPHorizon::calculateFrameCounts(double sampleRate) {
    vdelayFrameCount = durationToFrameCount(sampleRate, vdelayDuration);
    pan2FrameCount = durationToFrameCount(sampleRate, pan2Duration);
    oscFrameCount = durationToFrameCount(sampleRate, oscDuration);
    compressorFrameCount = durationToFrameCount(sampleRate, compressorDuration);
    revscFrameCount = durationToFrameCount(sampleRate, revscDuration);
    widenFrameCount = durationToFrameCount(sampleRate, widenDuration);
    bitCrushFrameCount = std::ceil(sampleRate / bitCrushMinSampleRate) + 1;
    
    totalDelayFrameCount = moogladderFrameCount + 2*vdelayFrameCount + vdelayFrameCount;
    totalReverbFrameCount = buthpFrameCount + compressorFrameCount + revscFrameCount + compressorFrameCount;
    totalMasterFrameCount = compressorFrameCount + widenFrameCount;
}

void S1DSPHorizon::updateSampleRate(double sampleRate) {
    calculateFrameCounts(sampleRate);
}

int S1DSPHorizon::durationToFrameCount(double sampleRate, double duration) {
    // Add 1 to accommodate for rounding errors (see sp_vdelay_init)
    return std::ceil(duration * sampleRate) + 1;
}
