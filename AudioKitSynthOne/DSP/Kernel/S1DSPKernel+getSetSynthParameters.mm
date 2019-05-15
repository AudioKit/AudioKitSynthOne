//
//  S1DSPKernel+getSetSynthParameters.mm
//  AudioKitSynthOne
//
//  Created by Aurelius Prochazka on 6/4/18.
//  Copyright © 2018 AudioKit. All rights reserved.
//

#import <AudioKit/AudioKit-Swift.h>
#import "S1DSPKernel.hpp"


float S1DSPKernel::getSynthParameter(S1Parameter param) {
    S1ParameterInfo& s = s1p[param];
    if (s.usePortamento)
        return s.portamentoTarget;
    else
        return parameters[param];
}

void S1DSPKernel::_setSynthParameter(S1Parameter param, float inputValue) {
    const float value = clampedValue(param, inputValue);
    S1ParameterInfo& s = s1p[param];
    if (s.usePortamento) {
        s.portamentoTarget = value;
    } else {
        parameters[param] = value;
    }
}

void S1DSPKernel::setSynthParameter(S1Parameter param, float inputValue) {
    _setSynthParameterHelper(param, inputValue, true, 0);
}

void S1DSPKernel::_rateHelper(S1Parameter parameter, float inputValue, bool notifyMainThread, int payload) {

    // pitchbend
    if (parameter == pitchbend) {
        const float val = clampedValue(parameter, inputValue);
        const float val01 = (val - minimum(pitchbend)) / (maximum(pitchbend) - minimum(pitchbend));
        _pitchbend = {parameter, val01, val, payload};
        _setSynthParameter(parameter, val);
        if (notifyMainThread) {
            dependentParameterDidChange(_pitchbend);
        }
        return;
    }

    // arpSeqTempoMultiplier
    if (parameter == arpSeqTempoMultiplier) {
        const float value = clampedValue(parameter, inputValue);
        S1RateArgs syncdValue = _rate.nearestFactor(value);
        _setSynthParameter(parameter, syncdValue.value);
        _arpSeqTempoMultiplier = {parameter, 1.f - syncdValue.value01, syncdValue.value, payload};
        if (notifyMainThread) {
            dependentParameterDidChange(_arpSeqTempoMultiplier);
        }
        return;
    }

    // lfo1Rate, lfo2Rate, autoPanFrequency
    if (parameters[tempoSyncToArpRate] > 0.f) {
        // tempo sync
        if (parameter == lfo1Rate || parameter == lfo2Rate || parameter == autoPanFrequency) {
            const float value = clampedValue(parameter, inputValue);
            S1RateArgs syncdValue = _rate.nearestFrequency(value, parameters[arpRate], minimum(parameter), maximum(parameter));
            _setSynthParameter(parameter, syncdValue.value);
            DependentParameter outputDP = {S1Parameter::S1ParameterCount, 0.f, 0.f, 0};
            switch(parameter) {
                case lfo1Rate:
                    outputDP = _lfo1Rate = {parameter, syncdValue.value01, syncdValue.value, payload};
                    break;
                case lfo2Rate:
                    outputDP = _lfo2Rate = {parameter, syncdValue.value01, syncdValue.value, payload};
                    break;
                case autoPanFrequency:
                    outputDP = _autoPanRate = {parameter, syncdValue.value01, syncdValue.value, payload};
                    break;
                default:
                    break;
            }
            if (notifyMainThread) {
                dependentParameterDidChange(outputDP);
            }
        } else if (parameter == delayTime) {
            const float value = clampedValue(parameter, inputValue);
            S1RateArgs syncdValue = _rate.nearestTime(value, parameters[arpRate], minimum(parameter), maximum(parameter));
            _setSynthParameter(parameter, syncdValue.value);
            _delayTime = {parameter, 1.f - syncdValue.value01, syncdValue.value, payload};
            if (notifyMainThread) {
                dependentParameterDidChange(_delayTime);
            }
        }
    } else {
        // no tempo sync
        _setSynthParameter(parameter, inputValue);
        const float val = parameters[parameter];
        const float min = minimum(parameter);
        const float max = maximum(parameter);
        const float val01 = clamp((val - min) / (max - min), 0.f, 1.f);
        if (parameter == lfo1Rate || parameter == lfo2Rate || parameter == autoPanFrequency || parameter == delayTime) {
            DependentParameter outputDP = {S1Parameter::S1ParameterCount, 0.f, 0.f, 0};
            switch(parameter) {
                case lfo1Rate:
                    outputDP = _lfo1Rate = {parameter, val01, val, payload};
                    break;
                case lfo2Rate:
                    outputDP = _lfo2Rate = {parameter, val01, val, payload};
                    break;
                case autoPanFrequency:
                    outputDP = _autoPanRate = {parameter, val01, val, payload};
                    break;
                case delayTime:
                    outputDP = _delayTime = {parameter, val01, val, payload};
                    break;
                default:
                    break;
            }
            if (notifyMainThread) {
                outputDP = {parameter, taper01Inverse(outputDP.normalizedValue, S1_DEPENDENT_PARAM_TAPER), outputDP.value, payload};
                dependentParameterDidChange(outputDP);
            }
        }
    }
}

void S1DSPKernel::_setSynthParameterHelper(S1Parameter parameter, float inputValue, bool notifyMainThread, int payload) {
    if (parameter == tempoSyncToArpRate || parameter == arpRate) {
        _setSynthParameter(parameter, inputValue);
        _rateHelper(lfo1Rate, getSynthParameter(lfo1Rate), notifyMainThread, payload);
        _rateHelper(lfo2Rate, getSynthParameter(lfo2Rate), notifyMainThread, payload);
        _rateHelper(autoPanFrequency, getSynthParameter(autoPanFrequency), notifyMainThread, payload);
        _rateHelper(delayTime, getSynthParameter(delayTime), notifyMainThread, payload);
    } else if (parameter == lfo1Rate ||
               parameter == lfo2Rate ||
               parameter == autoPanFrequency ||
               parameter == delayTime ||
               parameter == pitchbend ||
               parameter == arpSeqTempoMultiplier) {
        // dependent params
        _rateHelper(parameter, inputValue, notifyMainThread, payload);
    } else {
        // special case for updating the tuning table based on frequency at A4.
        // see https://en.wikipedia.org/wiki/A440_(pitch_standard)
        if (parameter == frequencyA4) {
            _setSynthParameter(parameter, truncf(inputValue));
        } else if (parameter == portamentoHalfTime) {
            _setSynthParameter(parameter, inputValue);
            const float actualValue = getParameter(portamentoHalfTime);
            updatePortamento(actualValue);
        } else {
            // all remaining independent params
            _setSynthParameter(parameter, inputValue);
        }
    }
}

