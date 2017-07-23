//
//  AudioUnitViewController.swift
//  SynthOne
//
//  Created by Aurelius Prochazka on 7/9/17.
//  Copyright © 2017 AudioKit. All rights reserved.
//

import CoreAudioKit
import AudioKit

public class AudioUnitViewController: SynthOneViewController, AUAudioUnitFactory {
    var audioUnit: AKSynthOneAudioUnit?
    public var token: AUParameterObserverToken?

    public override func viewDidLoad() {
        super.viewDidLoad()

        if audioUnit == nil {
            return
        }
    }

    override func changeParameter(_ param: AKSynthOneParameter) -> ((_: Double) -> Void) {
        return { value in
            guard let au = self.audioUnit,
                let parameter = au.parameterTree?.parameter(withAddress: AUParameterAddress(param.rawValue))
                else { return }
            parameter.value = Float(value)
        }
    }

    public func createAudioUnit(with componentDescription: AudioComponentDescription) throws -> AUAudioUnit {
        audioUnit = try AKSynthOneAudioUnit(componentDescription: componentDescription, options: [])
        
        let waveformArray = [AKTable(.triangle), AKTable(.square), AKTable(.sine), AKTable(.sawtooth)]
        for (i, waveform) in waveformArray.enumerated() {
            audioUnit?.setupWaveform(UInt32(i), size: Int32(UInt32(waveform.count)))
            for (j, sample) in waveform.enumerated() {
                audioUnit?.setWaveform(UInt32(i), withValue: sample, at: UInt32(j))
            }
        }

        guard let tree = audioUnit?.parameterTree else {
            return audioUnit!
        }

        token = tree.token (byAddingParameterObserver: { [weak self] address, value in

            guard let param: AKSynthOneParameter = AKSynthOneParameter(rawValue: Int(address)) else {
                return
            }

            DispatchQueue.main.async {
                self?.updateUI(param, value: Double(value))
            }
        })

        
        return audioUnit!
    }
    
}
