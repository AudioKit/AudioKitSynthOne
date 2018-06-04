//
//  AKSynthOneProtocol.h
//  AudioKitSynthOne
//
//  Created by Marcus W. Hobbs on 3/10/18.
//  Copyright © 2018 AudioKit. All rights reserved.
//


#pragma once

#import "AKSynthOneAudioUnit.h"

// 3 correlated protocols: AKSynthOneProtocol
// AKSynthOneDSP2AUProtocol   C++ DSP kernel layer to ObjC++ audiounit layer: Pass struct of array of structs to AU
// AKSynthOneAU2AppProtocol   ObjC++ audiounit layer to Swift (conductor): Pass array of nsnumbers to swift..maybe extend to tuples or structs
// AKSynthOneAppProtocol      Swift Conductor to Swift UI: internal app delegation



