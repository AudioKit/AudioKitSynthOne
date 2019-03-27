//
//  S1DSPCompressor.hpp
//  AudioKitSynthOne
//
//  Created by Matthias Frick on 11/03/2019.
//  Copyright © 2019 AudioKit. All rights reserved.
//

#import "AudioKit/AKSoundpipeKernel.hpp"
#import "S1Parameter.h"

#ifndef S1DSPCompressor_h
#define S1DSPCompressor_h
using DSPParameters = std::array<float, S1Parameter::S1ParameterCount>;

struct SPCompressorDeleter {
    void operator()(sp_compressor* compInst) const {
        sp_compressor_destroy(&compInst);
    }
};

struct SPCompressorAllocator {
    static auto allocate() -> sp_compressor* {
        sp_compressor* compPtr;
        sp_compressor_create(&compPtr);
        return compPtr;
    }
};

template<int RatioP, int ThresholdP, int AttP, int RelP, int MakeupP = -1>
struct S1Compressor {

    S1Compressor() = delete;
    S1Compressor(S1Compressor&&) = delete;
    S1Compressor(const S1Compressor&) = delete;

    S1Compressor(sp_data* sp, DSPParameters* params) :
        mSp(sp),
        mParams(params),
        mCompressorL(SPCompressorAllocator::allocate()),
        mCompressorR(SPCompressorAllocator::allocate())
    {
        sp_compressor_init(mSp, mCompressorR.get());
        sp_compressor_init(mSp, mCompressorL.get());
    }

    void compute(float &inL, float &inR, float &outL, float &outR) {
        configure(mCompressorR.get());
        configure(mCompressorL.get());
        compute(mCompressorR.get(), inR, outR);
        compute(mCompressorL.get(), inL, outL);
        if (MakeupP != -1) {
            outR *= (*mParams)[MakeupP];
            outL *= (*mParams)[MakeupP];
        }
    }

private:

    void configure(sp_compressor *comp) {
        *comp->atk = (*mParams)[AttP];
        *comp->rel = (*mParams)[RelP];
        *comp->thresh = (*mParams)[ThresholdP];
        *comp->ratio = (*mParams)[RatioP];
    }

    void compute(sp_compressor *comp, float &in, float &out) {
        sp_compressor_compute(mSp, comp, &in, &out);
    }

    // Parameter Reference
    DSPParameters* mParams;

    // DSP Internals
    std::unique_ptr<sp_compressor, SPCompressorDeleter> mCompressorR;
    std::unique_ptr<sp_compressor, SPCompressorDeleter> mCompressorL;
    sp_data* mSp;
};

#endif /* S1DSPCompressor_h */
