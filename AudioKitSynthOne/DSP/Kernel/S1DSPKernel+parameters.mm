//
//  S1DSPKernel+parameters.mm
//  AudioKitSynthOne
//
//  Created by Aurelius Prochazka on 6/4/18.
//  Copyright © 2018 AudioKit. All rights reserved.
//

#import "S1DSPKernel.hpp"

///parameter min
float S1DSPKernel::minimum(S1Parameter i) {
    return s1p[i].minimum;
}

///parameter max
float S1DSPKernel::maximum(S1Parameter i) {
    return s1p[i].maximum;
}

///parameter defaults
float S1DSPKernel::defaultValue(S1Parameter i) {
    return clampedValue(i, s1p[i].defaultValue);
}

AudioUnitParameterUnit S1DSPKernel::parameterUnit(S1Parameter i) {
    return s1p[i].unit;
}

///return clamped value
float S1DSPKernel::clampedValue(S1Parameter i, float inputValue) {
    const float minimum = s1p[i].minimum;
    const float maximum = s1p[i].maximum;
    const float clampedValue = std::min(std::max(inputValue, minimum), maximum);
    return clampedValue;
}

///parameter friendly name as c string
const char* S1DSPKernel::cString(S1Parameter i) {
    return s1p[i].friendlyName.c_str();
}

///parameter friendly name
std::string S1DSPKernel::friendlyName(S1Parameter i) {
    return s1p[i].friendlyName;
}

///parameter presetKey
std::string S1DSPKernel::presetKey(S1Parameter i) {
    return s1p[i].presetKey;
}

void S1DSPKernel::setParameters(float params[]) {
    for (int i = 0; i < S1Parameter::S1ParameterCount; i++) {
        setSynthParameter((S1Parameter)i, params[i]);
    }
}

void S1DSPKernel::setParameter(AUParameterAddress address, AUValue value) {
    const int i = (S1Parameter)address;
    setSynthParameter((S1Parameter)i, value);
}

AUValue S1DSPKernel::getParameter(AUParameterAddress address) {
    const int i = (S1Parameter)address;
    return parameters[i];
}

void S1DSPKernel::startRamp(AUParameterAddress address, AUValue value, AUAudioFrameCount duration) {}

void S1DSPKernel::updatePortamento(float halfTime) {
    const float ht = clampedValue(portamentoHalfTime, halfTime);
    for(int i = 0; i< S1Parameter::S1ParameterCount; i++) {
        if (s1p[i].usePortamento) {
            s1p[i].portamento->htime = ht;
        }
    }
}

//TODO:set s1 param arpRate
void S1DSPKernel::handleTempoSetting(float currentTempo) {
    if (currentTempo != tempo) {
        tempo = currentTempo;
        // TODO: reset secPerBeat here?
    }
}
