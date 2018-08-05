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

    open func setSynthParameter(_ parameter: S1Parameter, _ value: Double) {
        internalAU?.setSynthParameter(parameter, value: Float(value))
    }

    open func getSynthParameter(_ parameter: S1Parameter) -> Double {
        return Double(internalAU?.getSynthParameter(parameter) ?? 0)
    }

    open func getDependentParameter(_ parameter: S1Parameter) -> Double {
        return Double(internalAU?.getDependentParameter(parameter) ?? 0)
    }
    open func setDependentParameter(_ parameter: S1Parameter, _ value: Double, _ payload: Int32) {
        internalAU?.setDependentParameter(parameter, value: Float(value), payload: payload)
    }

    open func getMinimum(_ parameter: S1Parameter) -> Double {
        return Double(internalAU?.getMinimum(parameter) ?? 0)
    }

    open func getMaximum(_ parameter: S1Parameter) -> Double {
        return Double(internalAU?.getMaximum(parameter) ?? 1)
    }

    open func getRange(_ parameter: S1Parameter) -> ClosedRange<Double> {
        let min = Double(internalAU?.getMinimum(parameter) ?? 0)
        let max = Double(internalAU?.getMaximum(parameter) ?? 1)
        return min ... max
    }

    open func getDefault(_ parameter: S1Parameter) -> Double {
        return Double(internalAU?.getDefault(parameter) ?? 0)
    }

    open func getPattern(forIndex inputIndex: Int) -> Int {
        let index = (0...15).clamp(inputIndex)
        let aspi = Int32(Int(S1Parameter.sequencerPattern00.rawValue) + index)
        guard let aspp = S1Parameter(rawValue: aspi) else { return 0 }
        return Int(getSynthParameter(aspp))
    }

    open func setPattern(forIndex inputIndex: Int, _ value: Int) {
        let index = Int32((0...15).clamp(inputIndex))
        let aspi = Int32(S1Parameter.sequencerPattern00.rawValue + index)
        guard let aspp = S1Parameter(rawValue: aspi) else { return }
        internalAU?.setSynthParameter(aspp, value: Float(value) )
    }

    open func getOctaveBoost(forIndex inputIndex: Int) -> Bool {
        let index = (0...15).clamp(inputIndex)
        let asni = Int32(Int(S1Parameter.sequencerOctBoost00.rawValue) + index)
        guard let asnp = S1Parameter(rawValue: asni) else { return false }
        return getSynthParameter(asnp) > 0 ? true : false
    }

    open func setOctaveBoost(forIndex inputIndex: Int, _ value: Double) {
        let index = Int32((0...15).clamp(inputIndex))
        let aspi = Int32(S1Parameter.sequencerOctBoost00.rawValue + index)
        guard let aspp = S1Parameter(rawValue: aspi) else { return }
        internalAU?.setSynthParameter(aspp, value: Float(value) )
    }

    open func isNoteOn(forIndex inputIndex: Int) -> Bool {
        let index = (0...15).clamp(inputIndex)
        let asoi = Int32(Int(S1Parameter.sequencerNoteOn00.rawValue) + index)
        guard let asop = S1Parameter(rawValue: asoi) else { return false }
        return ( getSynthParameter(asop) > 0 ) ? true : false
    }

    open func setNoteOn(forIndex inputIndex: Int, _ value: Bool) {
        let index = Int32((0...15).clamp(inputIndex))
        let aspi = Int32(S1Parameter.sequencerNoteOn00.rawValue + index)
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

//        DispatchQueue.global(qos: .background).async {
//            let analysisPitch = AKTable.harmonicPitchRange()
//            AKLog("harmonicPitchRange:\(analysisPitch)")
//
//            let analysisFrequency = AKTable.harmonicFrequencyRange(wavetableCount: 10)
//            AKLog("harmonicFrequencyRange:\(analysisFrequency)")
//
//            let analysisFrequency00 = AKTable.harmonicFrequencyRange(f0: 65.40639132515, f1: 9807, wavetableCount: 10)
//            AKLog("harmonicFrequencyRange:\(analysisFrequency00)")
//        }

        let printStats = {(wt: AKTable) -> Void in
            let s = wt.minMax()
            AKLog("min:\(s.0), max:\(s.1), abs:\(s.2)")
        }
        
        let t0 = Date().timeIntervalSinceReferenceDate
        AKLog("initializing oscillators: \(t0)")

        //TODO: production code
        #if false
        let squareWithHighPWM = AKTable()
        let size = squareWithHighPWM.count
        for i in 0..<size {
            if i < size / 8 {
                squareWithHighPWM[i] = -1.0
            } else {
                squareWithHighPWM[i] = 1.0
            }
        }

        let triangleFilename = String(format: "triangle_%.4d", 9_999)
        let triangleTable = AKTable(.triangle)
        printStats(triangleTable)
        try! triangleTable.write(triangleFilename)

        let squareFilename = String(format: "square_%.4d", 9_999)
        let squareTable = AKTable(.square)
        printStats(squareTable)
        try! squareTable.write(squareFilename)

        let pwmFilename = String(format: "pwm_%.4d", 9_999)
        try! squareWithHighPWM.write(pwmFilename)
        printStats(squareWithHighPWM)
        try! squareWithHighPWM.write(pwmFilename)

        let sawtoothFilename = String(format: "sawtooth_%.4d", 9_999)
        let sawtoothTable = AKTable(.sawtooth)
        printStats(sawtoothTable)
        try! sawtoothTable.write(sawtoothFilename)

        let t1 = Date().timeIntervalSinceReferenceDate - t0
        AKLog("initializing 4 oscillators COMPLETE: \(t1)")
        self.init(waveformArray: [AKTable(.triangle), AKTable(.square), squareWithHighPWM, AKTable(.sawtooth)])

        #else

        let analysisPitch = AKTable.harmonicPitchRange()
        AKLog("harmonicPitchRange:\(analysisPitch)\n")

        var triangles = [AKTable]()
        var trianglesFrequency = [Double]()
        var squares = [AKTable]()
        var squaresFrequency = [Double]()
        var pwms = [AKTable]()
        var pwmsFrequency = [Double]()
        var sawtooths = [AKTable]()
        var sawtoothsFrequency = [Double]()
        var validateTable = AKTable()
        var msd: Float = 0

        for ap in analysisPitch {
            let f = ap.0
            let h = ap.1
            AKLog("synthesizing 4 tables for f=\(f), h=\(h)\n")

            let triangle = AKTable(.zero)
            let triangleFilename = String(format: "triangle_%.4d", h)
            triangle.triangle(harmonicCount: h, clear: true)
            triangle.normalize()
            triangle.phase(offset: 0.25)
            AKLog("\(triangleFilename)\n")
            triangles.append(triangle)
            trianglesFrequency.append(f)
            try! triangle.write(triangleFilename)
//            let turl = URL(string: triangleFilename)!
//            validateTable = AKTable.fromAudioFile(turl)!
//            msd = triangle.msd(t: validateTable)
//            AKLog("TRIANGLE: validating table: write vs. read: msd = \(msd)")

            let square = AKTable(.zero)
            let squareFilename = String(format: "square_%.4d", h)
            square.square(harmonicCount: h, clear: true)
            square.normalize()
            square.reverse()
            AKLog("\(squareFilename)\n")
            squares.append(square)
            squaresFrequency.append(f)
            try! square.write(squareFilename)
//            let squrl = URL.init(string: squareFilename)!
//            validateTable = AKTable.fromAudioFile(squrl)!
//            msd = square.msd(t: validateTable)
//            AKLog("SQUARE: validating table: write vs. read: msd = \(msd)")

            let pwm = AKTable(.zero)
            let pwmFilename = String(format: "pwm_%.4d", h)
            pwm.pwm(harmonicCount: h, period: 1 / 8)
            pwm.normalize()
            pwm.reverse()
            pwm.invert()
            AKLog("\(pwmFilename)\n")
            pwms.append(pwm)
            pwmsFrequency.append(f)
            try! pwm.write(pwmFilename)
//            let purl = URL.init(string: pwmFilename)!
//            validateTable = AKTable.fromAudioFile(purl)!
//            msd = pwm.msd(t: validateTable)
//            AKLog("PWM: validating table: write vs. read: msd = \(msd)")

            let sawtooth = AKTable(.zero)
            let sawtoothFilename = String(format: "sawtooth_%.4d", h)
            sawtooth.sawtooth(harmonicCount: h, clear: true)
            sawtooth.normalize()
            sawtooth.reverse()
            AKLog("\(sawtoothFilename)\n")
            sawtooths.append(sawtooth)
            sawtoothsFrequency.append(f)
            try! sawtooth.write(sawtoothFilename)
//            let surl = URL.init(string: sawtoothFilename)!
//            validateTable = AKTable.fromAudioFile(surl)!
//            msd = sawtooth.msd(t: validateTable)
//            AKLog("SAWTOOTH: validating table: write vs. read: msd = \(msd)")
        }
        let t1 = Date().timeIntervalSinceReferenceDate - t0
        AKLog("Initializing #\(analysisPitch.count * 4) oscillators: COMPLETE IN SEC: \(t1)\n")
        self.init(waveformArray: [triangles[0], squares[0], pwms[0], sawtooths[0]])
        #endif

        let dd = NSTemporaryDirectory()
        AKLog("Files written to \(dd)\n")
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
            self?.internalAU?.s1Delegate = self
        }

        guard let tree = internalAU?.parameterTree else {
            return
        }
        auParameters = tree.allParameters

        token = tree.token(byAddingParameterObserver: { address, value in
            guard let parameter: S1Parameter = S1Parameter(rawValue: Int32(address)) else {
                return
            }
            self.postNotification(parameter, Double(value) )
        })

        internalAU?.s1Delegate = self
    }

    @objc open weak var delegate: S1Protocol?

    internal func postNotification(_ parameter: S1Parameter, _ value: Double) {
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

    @objc public func dependentParameterDidChange(_ parameter: DependentParameter) {
        delegate?.dependentParameterDidChange(parameter)
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
