//
//  AKSynthOne.swift
//  AudioKit
//
//  Created by Aurelius Prochazka, revision history on Github.
//  Copyright © 2017 Aurelius Prochazka. All rights reserved.
//

/// Parameter lookup
public enum AKSynthOneParameter: Int {
    case index1 = 0, index2 = 1,
    morphBalance = 2,
    morph1PitchOffset = 3, morph2PitchOffset = 4,
    morph1Mix = 5, morph2Mix = 6,
    subOscMix = 7,
    subOscOctavesDown = 8,
    subOscIsSquare = 9,
    fmMix = 10,
    fmMod = 11,
    noiseMix = 12,
    lfoIndex = 13,
    lfoAmplitude = 14,
    lfoRate = 15,
    cutoffFrequency = 16,
    resonance = 17,
    filterMix = 18,
    filterADSRMix = 19,
    isMono = 20,
    glide = 21,
    filterAttackDuration = 22,
    filterDecayDuration = 23,
    filterSustainLevel = 24,
    filterReleaseDuration = 25,
    attackDuration = 26,
    decayDuration = 27,
    sustainLevel = 28,
    releaseDuration = 29,
    detuningOffset = 30,
    detuningMultiplier = 31
}

/// Pulse-Width Modulating Oscillator Bank
///
open class AKSynthOne: AKPolyphonicNode, AKComponent {
    public typealias AKAudioUnitType = AKSynthOneAudioUnit
    /// Four letter unique description of the node
    public static let ComponentDescription = AudioComponentDescription(instrument: "aks1")

    // MARK: - Properties

    public var internalAU: AKAudioUnitType?
    public var token: AUParameterObserverToken?

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
//            internalAU?.parameters = newValue
            // for each parameter, check if it has changed and then see about changing via parameter tree
//            if parameters != newValue {
                if internalAU?.isSetUp() ?? false {
                    if let existingToken = token {
                        for (index, parameter) in auParameters.enumerated() {
                            if index == 31 {
                                AKLog("setting via AU p\(index) = \(newValue[index])")
                            }
                            parameter.setValue(Float(newValue[index]), originator: existingToken)
                        }
                    }
                } else {
                    AKLog("Setting directly")
                    internalAU?.parameters = newValue
                }
//            }
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

        token = tree.token (byAddingParameterObserver: { [weak self] _, _ in

            DispatchQueue.main.async {
//                   self?.parameters[Int(address)] = Double(value)
            }
        })
        for index in 0 ..< parameters.count {
//            parameters[index] = Double(auParameters[index].value)
        }
        internalAU?.parameters = parameters
//        internalAU?.index1 = Float(index1)
// ...
//        internalAU?.detuningMultiplier = Float(detuningMultiplier)
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
