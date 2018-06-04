//
//  AKSynthOne.swift
//  AudioKit
//
//  Created by AudioKit Contributors, revision history on Github.
//  Join us at AudioKitPro.com, github.com/audiokit
//

import Foundation
import AudioKit

@objc open class AKSynthOne: AKPolyphonicNode, AKComponent, S1Protocol {

    public typealias AKAudioUnitType = S1AudioUnit

    /// Four letter unique description of the node
    public static let ComponentDescription = AudioComponentDescription(instrument: "aks1")

    // MARK: - Properties

    public var internalAU: AKAudioUnitType?
    public var token: AUParameterObserverToken?

    fileprivate var waveformArray = [AKTable]()
    fileprivate var auParameters: [AUParameter] = []

    ///Hard-reset of DSP...for PANIC
    open func resetDSP() {
        internalAU?.resetDSP()
    }

    open func resetSequencer() {
        internalAU?.resetSequencer()
    }

    ///Puts all playing notes into release mode.
    open func stopAllNotes() {
        internalAU?.stopAllNotes()
    }

    open func setSynthParameter(_ param: S1Parameter, _ value: Double) {
        internalAU?.setSynthParameter(param, value: Float(value))
    }

    open func getSynthParameter(_ param: S1Parameter) -> Double {
        return Double(internalAU?.getSynthParameter(param) ?? 0)
    }

    open func getDependentParameter(_ param: S1Parameter) -> Double {
        return Double(internalAU?.getDependentParameter(param) ?? 0)
    }
    open func setDependentParameter(_ param: S1Parameter, _ value: Double, _ payload: Int32) {
        internalAU?.setDependentParameter(param, value: Float(value), payload: payload)
    }

    open func getMinimum(_ param: S1Parameter) -> Double {
        return Double(internalAU?.getMinimum(param) ?? 0)
    }

    open func getMaximum(_ param: S1Parameter) -> Double {
        return Double(internalAU?.getMaximum(param) ?? 1)
    }

    open func getRange(_ param: S1Parameter) -> ClosedRange<Double> {
        let min = Double(internalAU?.getMinimum(param) ?? 0)
        let max = Double(internalAU?.getMaximum(param) ?? 1)
        return min ... max
    }

    open func getDefault(_ param: S1Parameter) -> Double {
        return Double(internalAU?.getDefault(param) ?? 0)
    }

    open func getPattern(forIndex inputIndex: Int) -> Int {
        let index = (0...15).clamp(inputIndex)
        let aspi = Int32(Int(S1Parameter.arpSeqPattern00.rawValue) + index)
        guard let aspp = S1Parameter(rawValue: aspi) else { return 0 }
        return Int(getSynthParameter(aspp))
    }

    open func setPattern(forIndex inputIndex: Int, _ value: Int) {
        let index = Int32((0...15).clamp(inputIndex))
        let aspi = Int32(S1Parameter.arpSeqPattern00.rawValue + index)
        guard let aspp = S1Parameter(rawValue: aspi) else { return }
        internalAU?.setSynthParameter(aspp, value: Float(value) )
    }

    open func getOctaveBoost(forIndex inputIndex: Int) -> Bool {
        let index = (0...15).clamp(inputIndex)
        let asni = Int32(Int(S1Parameter.arpSeqOctBoost00.rawValue) + index)
        guard let asnp = S1Parameter(rawValue: asni) else { return false }
        return getSynthParameter(asnp) > 0 ? true : false
    }

    open func setOctaveBoost(forIndex inputIndex: Int, _ value: Double) {
        let index = Int32((0...15).clamp(inputIndex))
        let aspi = Int32(S1Parameter.arpSeqOctBoost00.rawValue + index)
        guard let aspp = S1Parameter(rawValue: aspi) else { return }
        internalAU?.setSynthParameter(aspp, value: Float(value) )
    }

    open func isNoteOn(forIndex inputIndex: Int) -> Bool {
        let index = (0...15).clamp(inputIndex)
        let asoi = Int32(Int(S1Parameter.arpSeqNoteOn00.rawValue) + index)
        guard let asop = S1Parameter(rawValue: asoi) else { return false }
        return ( getSynthParameter(asop) > 0 ) ? true : false
    }

    open func setNoteOn(forIndex inputIndex: Int, _ value: Bool) {
        let index = Int32((0...15).clamp(inputIndex))
        let aspi = Int32(S1Parameter.arpSeqNoteOn00.rawValue + index)
        guard let aspp = S1Parameter(rawValue: aspi) else { return }
        internalAU?.setSynthParameter(aspp, value: Float(value == true ? 1 : 0) )
    }

    /// "parameter[i]" syntax is inefficient...use getter/setters above
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
            internalAU?.parameters = newValue

            if internalAU?.isSetUp ?? false {
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

    /// Ramp Time represents the speed at which parameters are allowed to change
    @objc open dynamic var rampDuration: Double = 0.0 {
        willSet {
            internalAU?.rampDuration = newValue
        }
    }

    // MARK: - Initialization

    /// Initialize the synth with defaults
    public convenience override init() {
        let squareWithHighPWM = AKTable()
        let size = squareWithHighPWM.count
        for i in 0..<size {
            if i < size / 8 {
                squareWithHighPWM[i] = -1.0
            } else {
                squareWithHighPWM[i] = 1.0
            }
        }
        self.init(waveformArray: [AKTable(.triangle), AKTable(.square), squareWithHighPWM, AKTable(.sawtooth)])
    }

    /// Initialize this synth
    ///
    /// - parameter waveformArray: An array of 4 waveforms
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
            self?.internalAU?.parameters = self?.parameters
            self?.internalAU?.aks1Delegate = self
        }

        guard let tree = internalAU?.parameterTree else {
            return
        }
        auParameters = tree.allParameters

        token = tree.token(byAddingParameterObserver: { address, value in
            guard let param: S1Parameter = S1Parameter(rawValue: Int32(address)) else {
                return
            }
            self.postNotification(param, Double(value) )
        })

        internalAU?.aks1Delegate = self
    }

    @objc open weak var delegate: S1Protocol?

    internal func postNotification(_ param: S1Parameter, _ value: Double) {
        AKLog("unused")
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

    // MARK: - Passthroughs for AKSynthOneProtocol called by DSP on main thread

    @objc public func dependentParamDidChange(_ param: DependentParameter) {
        delegate?.dependentParamDidChange(param)
    }

    @objc public func arpBeatCounterDidChange(_ beat: S1ArpBeatCounter) {
        delegate?.arpBeatCounterDidChange(beat)
    }

    @objc public func heldNotesDidChange(_ heldNotes: HeldNotes) {
        delegate?.heldNotesDidChange(heldNotes)
    }

    @objc public func playingNotesDidChange(_ playingNotes: PlayingNotes) {
        delegate?.playingNotesDidChange(playingNotes)
    }
}
