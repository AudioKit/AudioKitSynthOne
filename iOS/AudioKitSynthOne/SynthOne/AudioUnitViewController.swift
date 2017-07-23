//
//  AudioUnitViewController.swift
//  SynthOne
//
//  Created by Aurelius Prochazka on 7/9/17.
//  Copyright © 2017 AudioKit. All rights reserved.
//

import CoreAudioKit
import AudioKit

public class AudioUnitViewController: AUViewController, AUAudioUnitFactory {
    var audioUnit: AKSynthOneAudioUnit?
    public var token: AUParameterObserverToken?

    // Connect anything that gets its data from the AU here

    @IBOutlet weak var displayLabel: UILabel!
    @IBOutlet weak var sub24Toggle: ToggleButton!
    @IBOutlet weak var subSqrToggle: ToggleButton!

    @IBOutlet weak var osc1SemiKnob: Knob!
    @IBOutlet weak var osc2SemiKnob: Knob!
    @IBOutlet weak var osc2DetuneKnob: Knob!
    @IBOutlet weak var oscMixKnob: Knob!
    @IBOutlet weak var osc1VolKnob: Knob!
    @IBOutlet weak var osc2VolKnob: Knob!
    @IBOutlet weak var cutoffKnob: CutoffKnob!
    @IBOutlet weak var rezKnob: Knob!
    @IBOutlet weak var subMixKnob: Knob!
    @IBOutlet weak var fmMixKnob: Knob!
    @IBOutlet weak var fmModKnob: Knob!
    @IBOutlet weak var noiseMixKnob: Knob!
    @IBOutlet weak var masterVolKnob: Knob!

    public override func viewDidLoad() {
        super.viewDidLoad()

        osc1SemiKnob.callback = changeParameter(.morph1PitchOffset)
        osc2SemiKnob.callback = changeParameter(.morph2PitchOffset)
        osc2DetuneKnob.callback = changeParameter(.detuningMultiplier)
        oscMixKnob.callback = changeParameter(.morphBalance)
        osc1VolKnob.callback = changeParameter(.morph1Mix)
        osc2VolKnob.callback = changeParameter(.morph2Mix)
        rezKnob.callback = changeParameter(.resonance)
        subMixKnob.callback = changeParameter(.subOscMix)
        fmMixKnob.callback = changeParameter(.fmMix)
        fmModKnob.callback = changeParameter(.fmMod)
        noiseMixKnob.callback = changeParameter(.noiseMix)

        if audioUnit == nil {
            return
        }
    }

    func changeParameter(_ param: AKSynthOneParameter) -> ((_: Double) -> Void) {
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
                switch param {
                case .morph1PitchOffset:
                    self?.osc1SemiKnob.value = Double(value)
                    self?.displayLabel.text = self?.osc1SemiKnob.statusText
                case .morph2PitchOffset:
                    self?.osc2SemiKnob.value = Double(value)
                    self?.displayLabel.text = self?.osc2SemiKnob.statusText
                case .detuningMultiplier:
                    self?.osc2DetuneKnob.value = Double(value)
                    self?.displayLabel.text = self?.osc2DetuneKnob.statusText
                case .morphBalance:
                    self?.oscMixKnob.value = Double(value)
                    self?.displayLabel.text = self?.oscMixKnob.statusText
                case .morph1Mix:
                    self?.osc1VolKnob.value = Double(value)
                    self?.displayLabel.text = self?.osc1VolKnob.statusText
                case .morph2Mix:
                    self?.osc2VolKnob.value = Double(value)
                    self?.displayLabel.text = self?.osc2VolKnob.statusText
                case .resonance:
                    self?.rezKnob.value = Double(value)
                    self?.displayLabel.text = self?.rezKnob.statusText
                case .subOscMix:
                    self?.subMixKnob.value = Double(value)
                    self?.displayLabel.text = self?.subMixKnob.statusText
                case .fmMix:
                    self?.fmMixKnob.value = Double(value)
                    self?.displayLabel.text = self?.fmMixKnob.statusText
                case .fmMod:
                    self?.fmModKnob.value = Double(value)
                    self?.displayLabel.text = self?.fmModKnob.statusText
                case .noiseMix:
                    self?.noiseMixKnob.value = Double(value)
                    self?.displayLabel.text = self?.noiseMixKnob.statusText
                default:
                    _ = 0
                    // do nothing
                }
            }
        })

        
        return audioUnit!
    }
    
}
