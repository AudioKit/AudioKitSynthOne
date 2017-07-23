//
//  AKSynthOne.swift
//  AudioKit
//
//  Created by Aurelius Prochazka, revision history on Github.
//  Copyright © 2017 Aurelius Prochazka. All rights reserved.
//

import AudioKit

/// Pulse-Width Modulating Oscillator Bank
///
open class AKSynthOne: AKPolyphonicNode, AKComponent {
    public typealias AKAudioUnitType = AKSynthOneAudioUnit
    /// Four letter unique description of the node
    public static let ComponentDescription = AudioComponentDescription(instrument: "aks1")

    // MARK: - Properties

    public var internalAU: AKAudioUnitType?
    public var token: AUParameterObserverToken?
    public var viewControllers: Set<SynthOneViewController> = []

    fileprivate var waveformArray = [AKTable]()

    fileprivate var auParameters: [AUParameter] = []
    open var parameters: [Double] {
        get {
            var result: [Double] = []
            if let floatParameters = internalAU?.parameters as? [NSNumber] {
                for number in floatParameters {
                    result.append(number.doubleValue)
                }
            }
            return result
        }
        set {
            if internalAU?.isSetUp() ?? false {
                    if let existingToken = token {
                        for (index, parameter) in auParameters.enumerated() {
                            if Double(parameter.value) != newValue[index] {
                                parameter.setValue(Float(newValue[index]), originator: existingToken)
                            }
                        }
                    }
                } else {
                    AKLog("Setting directly")
                    internalAU?.parameters = newValue
                }
        }
    }


    
//    open var parameterValues: [Double] = []


    /// Ramp Time represents the speed at which parameters are allowed to change
    open dynamic var rampTime: Double = AKSettings.rampTime {
        willSet {
            internalAU?.rampTime = newValue
        }
    }

    // MARK: - Initialization

    /// Initialize the synth with defaults
    public convenience override init() {
        self.init(waveformArray: [AKTable(.triangle), AKTable(.square), AKTable(.sine), AKTable(.sawtooth)])
    }

    /// Initialize this synth
    ///
    /// - Parameters:
    ///   - waveformArray:      An array of 4 waveforms
    ///
    public init(waveformArray: [AKTable]) {
        
        self.waveformArray = waveformArray
        _Self.register()

        super.init()
        AVAudioUnit._instantiate(with: _Self.ComponentDescription) { [weak self] avAudioUnit in

            self?.avAudioNode = avAudioUnit
            self?.midiInstrument = avAudioUnit as? AVAudioUnitMIDIInstrument
            self?.internalAU = avAudioUnit.auAudioUnit as? AKAudioUnitType
            
            for (i, waveform) in waveformArray.enumerated() {
                self?.internalAU?.setupWaveform(UInt32(i), size: Int32(UInt32(waveform.count)))
                for (j, sample) in waveform.enumerated() {
                    self?.internalAU?.setWaveform(UInt32(i), withValue: sample, at: UInt32(j))
                }
            }
        }

        guard let tree = internalAU?.parameterTree else {
            return
        }
        auParameters = tree.allParameters

        token = tree.token(byAddingParameterObserver: { [weak self] address, value in

            guard let param: AKSynthOneParameter = AKSynthOneParameter(rawValue: Int(address)) else {
                return
            }

            DispatchQueue.main.async {
                for vc in self!.viewControllers {
                    vc.updateUI(param, value: Double(value))
                }
            }
        })
        internalAU?.parameters = parameters
    }

    /// stops all notes
    open func reset() {
        internalAU?.reset()
    }

    // MARK: - AKPolyphonic

    // Function to start, play, or activate the node at frequency
    open override func play(noteNumber: MIDINoteNumber, velocity: MIDIVelocity, frequency: Double) {
        internalAU?.startNote(noteNumber, velocity: velocity, frequency: Float(frequency))
    }

    /// Function to stop or bypass the node, both are equivalent
    open override func stop(noteNumber: MIDINoteNumber) {
        internalAU?.stopNote(noteNumber)
    }
}
