//
//  AKSynthOneProtocol.h
//  AudioKitSynthOne
//
//  Created by Marcus W. Hobbs on 3/10/18.
//  Copyright © 2018 AudioKit. All rights reserved.
//

#ifndef AKSynthOneProtocol_h
#define AKSynthOneProtocol_h

@protocol AKSynthOneProtocol
-(void)paramDidChange:(AKSynthOneParameter)param value:(double)value;
-(void)arpBeatCounterDidChange: (NSInteger)beat;
-(void)heldNotesDidChange;
-(void)playingNotesDidChange;
@end


#endif /* AKSynthOneProtocol_h */
