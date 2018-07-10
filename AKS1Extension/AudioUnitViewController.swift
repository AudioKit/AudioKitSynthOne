//
//  AudioUnitViewController.swift
//  AKS1Extension
//
//  Created by Aurelius Prochazka on 7/9/18.
//  Copyright © 2018 AudioKit. All rights reserved.
//

import CoreAudioKit

public class AudioUnitViewController: AUViewController, AUAudioUnitFactory {
    var audioUnit: S1AudioUnit?

    public override func viewDidLoad() {
        super.viewDidLoad()

        if audioUnit == nil {
            return
        }

        // Get the parameter tree and add observers for any parameters that the UI needs to keep in sync with the AudioUnit
    }

    public func createAudioUnit(with componentDescription: AudioComponentDescription) throws -> AUAudioUnit {
        audioUnit = try S1AudioUnit(componentDescription: componentDescription, options: [])

        let squareWithHighPWM = AKTable()
        let size = squareWithHighPWM.count
        for i in 0..<size {
            if i < size / 8 {
                squareWithHighPWM[i] = -1.0
            } else {
                squareWithHighPWM[i] = 1.0
            }
        }
        let waveformArray = [AKTable(.triangle), AKTable(.square), squareWithHighPWM, AKTable(.sawtooth)]

        for (i, waveform) in waveformArray.enumerated() {
            audioUnit?.setupWaveform(UInt32(i), size: Int32(UInt32(waveform.count)))
            for (j, sample) in waveform.enumerated() {
                audioUnit?.setWaveform(UInt32(i), withValue: sample, at: UInt32(j))
            }
        }

        return audioUnit!
    }

}
