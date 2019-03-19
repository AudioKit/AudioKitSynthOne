//
//  S1DSPKernel+destroy.cpp
//  AudioKitSynthOne
//
//  Created by Aurelius Prochazka on 6/4/18.
//  Copyright © 2018 AudioKit. All rights reserved.
//

#import "S1DSPKernel.hpp"

void S1DSPKernel::destroy() {
    for(int i = 0; i< S1Parameter::S1ParameterCount; i++) {
        sp_port_destroy(&s1p[i].portamento);
    }
    sp_port_destroy(&monoFrequencyPort);

    sp_ftbl_destroy(&sine);
    sp_phasor_destroy(&lfo1Phasor);
    sp_phasor_destroy(&lfo2Phasor);
    sp_phaser_destroy(&phaser0);
    sp_osc_destroy(&panOscillator);
    sp_pan2_destroy(&pan);
    sp_moogladder_destroy(&loPassInputDelayL);
    sp_moogladder_destroy(&loPassInputDelayR);
    sp_vdelay_destroy(&delayL);
    sp_vdelay_destroy(&delayR);
    sp_vdelay_destroy(&delayRR);
    sp_vdelay_destroy(&delayFillIn);
    sp_delay_destroy(&widenDelay);
    sp_crossfade_destroy(&delayCrossfadeL);
    sp_crossfade_destroy(&delayCrossfadeR);
    sp_revsc_destroy(&reverbCostello);
    sp_buthp_destroy(&butterworthHipassL);
    sp_buthp_destroy(&butterworthHipassR);
    sp_crossfade_destroy(&revCrossfadeL);
    sp_crossfade_destroy(&revCrossfadeR);
}


