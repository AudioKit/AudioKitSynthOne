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

    @IBOutlet weak var testSlider: UISlider!
    
    @IBAction func changeTestSlider(_ sender: UISlider) {
        let v = sender.value
        let p: AKSynthOneParameter = .cutoff
        guard let au = self.audioUnit else {
            printDebug("audio unit is nil")
            return
        }
        if let param = au.parameterTree?.parameter(withAddress: AUParameterAddress(p.rawValue))! {
            let min = param.minValue
            let max = param.maxValue
            let value = min + (max - min) * v
            param.value = value
            au.setAK1Parameter(p, value: value)
            printDebug("slider: parameter:\(p.rawValue), value:\(value)")
        }
    }

    @IBOutlet weak var debugLabel: UILabel!
    
    @objc open var delegate: AKSynthOneProtocol?

    public func printDebug(_ text: String) {
        debugLabel.text = text
    }

    var audioUnit: AKSynthOneAudioUnit? {
        didSet {
            DispatchQueue.main.async {
                if self.isViewLoaded {
                    self.connectViewWithAU()
                }
            }
        }
    }
    
    /// A token for our registration to observe parameter value changes.
    var parameterObserverToken: AUParameterObserverToken!
    

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

        //
        audioUnit?.createParameters()
                
        return audioUnit!
    }
    
    func connectViewWithAU() {
        printDebug("Hook up connectViewWithAU()")
    }

    
    //MARK: - AKSynthOneProtocol passthroughs
    @objc public func paramDidChange(_ param: AKSynthOneParameter, value: Double) {
        //delegate?.paramDidChange(param, value)
    }
    
    @objc public func arpBeatCounterDidChange(_ beat: Int) {
        //delegate?.arpBeatCounterDidChange(beat)
    }
    
    @objc public func heldNotesDidChange() {
        //delegate?.heldNotesDidChange()
    }
    
    func playingNotesDidChange(_ playingNotes: PlayingNotes) {
        ///TODO:Route this to keyboard view controller (I'll change this to return the current array of playing notes)
        ///TODO:See https://trello.com/c/lQZMyF0V
        //AKLog("Conductor.swift:playingNotesDidChange")
    }
}

