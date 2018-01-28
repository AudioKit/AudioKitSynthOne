//
//  AudioUnitViewController.swift
//  SynthOne
//
//  Created by Aurelius Prochazka on 7/9/17.
//  Copyright © 2017 AudioKit. All rights reserved.
//

import CoreAudioKit
import AudioKit

public class AudioUnitViewController: AUViewController, AUAudioUnitFactory, AKSynthOneProtocol {
//    var conductor = Conductor.sharedInstance

    var audioUnit: AKSynthOneAudioUnit? {
        didSet {
            DispatchQueue.main.async {
                if self.isViewLoaded {
                    self.connectViewWithAU()
                }
            }
        }
    }

//    override func changeParameter(_ param: AKSynthOneParameter) -> ((_: Double) -> Void) {
//        return { value in
//            guard let au = self.audioUnit,
//                let parameter = au.parameterTree?.parameter(withAddress: AUParameterAddress(param.rawValue))
//                else { return }
//            parameter.value = Float(value)
//        }
//    }

    public override func viewDidLoad() {
        super.viewDidLoad()
        guard audioUnit != nil else { return }
        connectViewWithAU()
    }

    public func createAudioUnit(with componentDescription: AudioComponentDescription) throws -> AUAudioUnit {
        audioUnit = try AKSynthOneAudioUnit(componentDescription: componentDescription, options: [])
        
        audioUnit?.delegate = self
        
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

        _ = tree.token(byAddingParameterObserver: { [weak self] address, value in

            guard let param: AKSynthOneParameter = AKSynthOneParameter(rawValue: Int32(address)) else {
                return
            }

            DispatchQueue.main.async {
//                for vc in (self?.conductor.viewControllers)! {
//                    vc.updateUI(param, value: Double(value))
//                }
            }
        })
        return audioUnit!
    }

    func connectViewWithAU() {
//        conductor.changeParameter = { param in
//            return { value in
//                guard let au = self.audioUnit,
//                    let parameter = au.parameterTree?.parameter(withAddress: AUParameterAddress(param.rawValue))
//                    else { return }
//                parameter.value = Float(value)
//            }
//        }
    }

    //MARK: - AKSynthOneProtocol passthroughs
    @objc public func paramDidChange(_ param: AKSynthOneParameter, _ value: Double) {
        //delegate?.paramDidChange(param, value)
    }
    
    @objc public func arpBeatCounterDidChange(_ beat: Int) {
        //delegate?.arpBeatCounterDidChange(beat)
    }
    
    @objc public func heldNotesDidChange() {
        //delegate?.heldNotesDidChange()
    }
    
    @objc public func playingNotesDidChange() {
        //delegate?.playingNotesDidChange()
    }

}

