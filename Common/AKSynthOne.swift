//
//  AKSynthOne.swift
//  AudioKit
//
//  Created by Aurelius Prochazka, revision history on Github.
//  Copyright © 2017 Aurelius Prochazka. All rights reserved.
//

import AudioKit

///AKSynthOne
open class AKSynthOne: AKPolyphonicNode, AKComponent {
    
    public typealias AKAudioUnitType = AKSynthOneAudioUnit
    
    /// Four letter unique description of the node
    public static let ComponentDescription = AudioComponentDescription(instrument: "aks1")

    // MARK: - Properties

    public var internalAU: AKAudioUnitType?
    public var token: AUParameterObserverToken?

    fileprivate var waveformArray = [AKTable]()
    fileprivate var auParameters: [AUParameter] = []
    
    open func resetSequencer() {
        internalAU?.resetSequencer()
    }
    
    open func stopAllNotes() {
        internalAU?.stopAllNotes()
    }
    
    /// "parameter[i]" syntax is inefficient...use getter/setters below
    open var parameters: [Double] {
        get {
            var result: [Double] = []
            if let floatParameters = internalAU?.parameters as? [NSNumber] {
                //AKLog("getter recreates array of 115 params")
                for number in floatParameters {
                    result.append(number.doubleValue)
                }
            }
            return result
        }
        set {
            internalAU?.parameters = newValue
            
            if internalAU?.isSetUp() ?? false {
                if let existingToken = token {
                    for (index, parameter) in auParameters.enumerated() {
                        if Double(parameter.value) != newValue[index] {
                            parameter.setValue( Float( newValue[index]), originator: existingToken)
                        }
                    }
                }
            } else {
                internalAU?.parameters = newValue
            }
        }
    }

    ///These getter/setters are more efficient than using "parameter[i]"
    open func setAK1Parameter(_ inAKSynthOneParameterEnum : AKSynthOneParameter, _ value : Double) {
        let aks1p : Int32 = Int32(inAKSynthOneParameterEnum.rawValue)
        let f = Float(value)
        internalAU?.setAK1Parameter(aks1p, value: f)
    }
    open func getAK1Parameter(_ inAKSynthOneParameterEnum : AKSynthOneParameter) -> Double {
        let aks1p : Int32 = Int32(inAKSynthOneParameterEnum.rawValue)
        return Double(internalAU?.getAK1Parameter(aks1p) ?? 0)
    }

    
    open func getAK1ArpSeqPattern(forIndex inputIndex : Int) -> Int {
        let index = (0...15).clamp(inputIndex)
        let aspi = AKSynthOneParameter.arpSeqPattern00.rawValue + index
        let aspp = AKSynthOneParameter(rawValue: aspi)!
        return Int( getAK1Parameter(aspp) )
    }
    open func setAK1ArpSeqPattern(forIndex inputIndex : Int, _ value: Int) {
        let index = (0...15).clamp(inputIndex)
        let aspi = Int32(AKSynthOneParameter.arpSeqPattern00.rawValue + index)
        internalAU?.setAK1Parameter(aspi, value: Float(value) )
    }

    open func getAK1SeqOctBoost(forIndex inputIndex : Int) -> Bool {
        let index = (0...15).clamp(inputIndex)
        let asni = AKSynthOneParameter.arpSeqOctBoost00.rawValue + index
        let asnp = AKSynthOneParameter(rawValue: asni)!
        return ( getAK1Parameter(asnp) > 0 ) ? true : false
    }
    open func setAK1SeqOctBoost(forIndex inputIndex : Int, _ value: Bool) {
        let index = (0...15).clamp(inputIndex)
        let aspi = Int32(AKSynthOneParameter.arpSeqOctBoost00.rawValue + index)
        internalAU?.setAK1Parameter(aspi, value: Float(value == true ? 1 : 0) )
    }

    open func getAK1ArpSeqNoteOn(forIndex inputIndex : Int) -> Bool {
        let index = (0...15).clamp(inputIndex)
        let asoi = AKSynthOneParameter.arpSeqNoteOn00.rawValue + index
        let asop = AKSynthOneParameter(rawValue: asoi)!
        return ( getAK1Parameter(asop) > 0 ) ? true : false
    }
    open func setAK1ArpSeqNoteOn(forIndex inputIndex : Int, _ value: Bool) {
        let index = (0...15).clamp(inputIndex)
        let aspi = Int32(AKSynthOneParameter.arpSeqNoteOn00.rawValue + index)
        internalAU?.setAK1Parameter(aspi, value: Float(value == true ? 1 : 0) )
    }

    
    /// Ramp Time represents the speed at which parameters are allowed to change
    open dynamic var rampTime: Double = 0.0 {
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

        token = tree.token(byAddingParameterObserver: { address, value in

            guard let param: AKSynthOneParameter = AKSynthOneParameter(rawValue: Int(address)) else {
                return
            }

            DispatchQueue.main.async {
                for vc in Conductor.sharedInstance.viewControllers {
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
