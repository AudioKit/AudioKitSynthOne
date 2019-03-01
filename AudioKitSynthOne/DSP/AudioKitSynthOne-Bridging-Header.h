//
//  AudioKitSynthOne-Bridging-Header.h
//  AudioKitSynthOne
//
//  Created by AudioKit Contributors on 1/24/18.
//  Copyright © 2018 AudioKit. All rights reserved.
//

#pragma once

#import "S1AudioUnit.h"
#import "S1Parameter.h"
#import "AKSynthOneRate.h"
#import "Audiobus.h"

// Set the ABLETON_ENABLED user setting to 1 (at the project level) to enable Ableton Link support
// Note: you will need the files from their SDK!
#if ABLETON_ENABLED
# include "ABLLink.h"
# include "ABLLinkUtils.h"
# include "ABLLinkSettingsViewController.h"
#endif

