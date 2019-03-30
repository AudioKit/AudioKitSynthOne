//
//  HeaderViewContoller.swift
//  AudioKitSynthOne
//
//  Created by AudioKit Contributors on 7/23/17.
//  Copyright © 2017 AudioKit. All rights reserved.
//

import UIKit

protocol HeaderDelegate: AnyObject {
    func displayLabelTapped()
    func homePressed()
    func previousPresetPressed()
    func nextPresetPressed()
    func savePresetPressed()
    func randomPresetPressed()
    func panicPressed()
    func devPressed()
    func aboutPressed()
    func morePressed()
    func appsPressed()
}

public class HeaderViewController: UpdatableViewController {

    enum LFOSource: Int {
        case OFF
        case LFO1
        case LFO2
        case BOTH
    }

    @IBOutlet weak var displayLabel: UILabel!
    @IBOutlet weak var panicButton: PresetUIButton!
    @IBOutlet weak var diceButton: UIButton!
    @IBOutlet weak var saveButton: PresetUIButton!
    @IBOutlet weak var devButton: PresetUIButton!
    @IBOutlet weak var aboutButton: PresetUIButton!
    @IBOutlet weak var hostAppIcon: UIImageView!
    @IBOutlet weak var morePresetsButton: PresetUIButton!
    @IBOutlet weak var webButton: PresetUIButton!
    @IBOutlet weak var appsButton: PresetUIButton!

    weak var delegate: EmbeddedViewsDelegate?
    weak var headerDelegate: HeaderDelegate?
    var activePreset = Preset()

    func ADSRString(_ a: S1Parameter,
                    _ d: S1Parameter,
                    _ s: S1Parameter,
                    _ r: S1Parameter) -> String {
        return "A: \(conductor.synth.getSynthParameter(a).decimalString) " +
            "D: \(conductor.synth.getSynthParameter(d).decimalString) " +
            "S: \(conductor.synth.getSynthParameter(s).percentageString) " +
            "R: \(conductor.synth.getSynthParameter(r).decimalString) "
    }

    public override func viewDidLoad() {
        super.viewDidLoad()

        // Add Gesture Recognizer to Display Label
        let tap = UITapGestureRecognizer(target: self, action: #selector(HeaderViewController.displayLabelTapped))
        tap.numberOfTapsRequired = 1
        displayLabel.addGestureRecognizer(tap)
        displayLabel.isUserInteractionEnabled = true

        // DEV panel
        #if true
        devButton.isHidden = true
        #else
        devButton.isHidden = false
        #endif

        //
        setupCallbacks()
    }

    override func updateUI(_ parameter: S1Parameter, control: S1Control?, value: Double) {
        updateDisplayLabel(parameter, value: value)
    }

    func updateDisplayLabel(_ parameter: S1Parameter, value: Double) {
        guard let s = conductor.synth else {
            AKLog("Can't update header displayLabel because synth is not instantiated")
            return
        }
        let lfoSource = LFOSource(rawValue: Int(value))
        switch parameter {
        case .index1:
            let message = NSLocalizedString("DCO 1 Morph: \(value.decimalString)", comment: "Oscillator 1 Waveform Morph Index")
            displayLabel.text = message
        case .index2:
            let message = NSLocalizedString("DCO 2 Morph: \(value.decimalString)", comment: "Oscillator 2 Waveform Morph Index")
            displayLabel.text = message
        case .morph1SemitoneOffset:
            let message = NSLocalizedString("DCO 1: \(Int(value)) semitones", comment: "Oscillator 1 semitone offset")
            displayLabel.text = message
        case .morph2SemitoneOffset:
            let message = NSLocalizedString("DCO 2: \(Int(value)) semitones", comment: "Oscillator 2 semitone offset")
            displayLabel.text = message
        case .morph2Detuning:
            let message = NSLocalizedString("DCO 2: \(value.decimalString) detune", comment: "Oscillator 2 detune")
            displayLabel.text = message
        case .morphBalance:
            let message = NSLocalizedString("DCO Mix: \(value.decimalString)", comment: "Oscillator 1 & 2 Mix")
            displayLabel.text = message
        case .morph1Volume:
            let message = NSLocalizedString("DCO 1 Volume: \(value.percentageString)", comment: "Oscillator 1 Volume")
            displayLabel.text = message
        case .morph2Volume:
            let message = NSLocalizedString("DCO 2 Volume: \(value.percentageString)", comment: "Oscillator 2 Volume")
            displayLabel.text = message
        case .glide:
            let message = NSLocalizedString("Glide: \(value.decimalString)", comment: "Mono Glide Amount")
            displayLabel.text = message
        case .cutoff, .resonance:
            let message = NSLocalizedString("Cutoff: \(s.getSynthParameter(.cutoff).decimalString) Hz, " +
                "Resonance: \(s.getSynthParameter(.resonance).decimalString)", comment: "Filter Cutoff & Resonance")
            displayLabel.text = message
        case .subVolume:
            let message = NSLocalizedString("Sub Osc Volume: \(value.decimalString)", comment: "Sub Oscillator Volume")
            displayLabel.text = message
        case .fmVolume:
            let message = NSLocalizedString("FM Volume: \(value.percentageString)", comment: "FM Oscillator Volume")
            displayLabel.text = message
        case .fmAmount:
            let message = NSLocalizedString("FM Mod: \(value.decimalString)", comment: "FM Modulation Amount")
            displayLabel.text = message
        case .noiseVolume:
            let message = NSLocalizedString("Noise Volume: \((value * 4).percentageString)", comment: "Noise Volume")
            displayLabel.text = message
        case .masterVolume:
            let message = NSLocalizedString("Master Volume: \(value.percentageString)", comment: "Master Volume")
            displayLabel.text = message
        case .attackDuration, .decayDuration, .sustainLevel, .releaseDuration:
            displayLabel.text = ADSRString(.attackDuration, .decayDuration, .sustainLevel, .releaseDuration)
        case .filterAttackDuration, .filterDecayDuration, .filterSustainLevel, .filterReleaseDuration:
            displayLabel.text = "" +
                ADSRString(.filterAttackDuration, .filterDecayDuration, .filterSustainLevel, .filterReleaseDuration)
        case .filterADSRMix:
            let message = NSLocalizedString("Filter Envelope: \(value.percentageString)", comment: "Filter Envelope Amount")
            displayLabel.text = message
        case .bitCrushDepth: //unused
            displayLabel.text = "Bitcrush Depth: \(value.decimalString)"
        case .bitCrushSampleRate:
            let message = NSLocalizedString("Sample Rate: \(Int(value)) Hz", comment: "Bitcrush Sample Rate")
            displayLabel.text = message
        case .autoPanAmount:
            let message = NSLocalizedString("AutoPan Strength: \(value.percentageString)", comment: "AutoPan Amount/Strength")
            displayLabel.text = message
        case .autoPanFrequency:
            let message = NSLocalizedString("AutoPan Rate: \(Rate.fromFrequency(value)), \(value.decimalString) Hz", comment: "AutoPan Rate tempo-syncd")
            let message2 = NSLocalizedString("AutoPan Rate: \(value.decimalString) Hz", comment: "AutoPan Rate")
            if s.getSynthParameter(.tempoSyncToArpRate) > 0 {
                displayLabel.text = message
            } else {
                displayLabel.text = message2
            }
        case .reverbOn:
            let message = NSLocalizedString("Reverb On", comment: "Reverb On")
            let message2 = NSLocalizedString("Reverb Off", comment: "Reverb Off")
            displayLabel.text = value == 1 ? message : message2
        case .reverbFeedback:
            let message = NSLocalizedString("Reverb Size: \(value.percentageString)", comment: "Reverb Size")
            displayLabel.text = message
        case .reverbHighPass:
            let message = NSLocalizedString("Reverb Low-cut: \(value.decimalString) Hz", comment: "Reverb Low-cut/Highpass")
            displayLabel.text = message
        case .reverbMix:
            let message = NSLocalizedString("Reverb Mix: \(value.percentageString)", comment: "Reverb Mix")
            displayLabel.text = message
        case .delayOn:
            let message = NSLocalizedString("Delay On", comment: "Delay On")
            let message2 = NSLocalizedString("Delay  Off", comment: "Delay Off")
            displayLabel.text = value == 1 ? message : message2
        case .delayFeedback:
            let message = NSLocalizedString("Delay Feedback/Taps: \(value.percentageString)", comment: "Delay Feedback")
            displayLabel.text = message
        case .delayTime:
            if s.getSynthParameter(.tempoSyncToArpRate) > 0 {
                displayLabel.text = NSLocalizedString("Delay Time: \(Rate.fromTime(value)), \(value.decimalString)s", comment: "Delay Time tempo-syncd")
            } else {
                displayLabel.text = NSLocalizedString("Delay Time: \(value.decimalString) s", comment: "Delay Time")
            }
        case .arpSeqTempoMultiplier:
            displayLabel.text = NSLocalizedString("Divisions: \(Rate.fromFactor(value))", comment: "Divisions")
        case .delayMix:
            let message = NSLocalizedString("Delay Mix: \(value.percentageString)", comment: "Delay Mix")
            displayLabel.text = message
        case .lfo1Rate, .lfo1Amplitude:
            let message = NSLocalizedString("LFO1 Rate: \(Rate.fromFrequency(s.getSynthParameter(.lfo1Rate))), " +
                "LFO1 Amp: \(s.getSynthParameter(.lfo1Amplitude).percentageString)", comment: "LFO [low frequency oscillator] Amplitude & Rate tempo-syncd")
            let message2 = NSLocalizedString("LFO1 Rate: \(s.getSynthParameter(.lfo1Rate).decimalString)Hz, " +
                "LFO1 Amp: \(s.getSynthParameter(.lfo1Amplitude).percentageString)", comment: "LFO [low frequency oscillator] Amplitude & Rate")
            if s.getSynthParameter(.tempoSyncToArpRate) > 0 {
                displayLabel.text = message
            } else {
                displayLabel.text = message2
            }
        case .lfo2Rate:
            let message = NSLocalizedString("LFO 2 Rate: \(Rate.fromFrequency(value)), \(value.decimalString) Hz", comment: "LFO 2 [low frequency oscillator] Rate tempo-syncd")
            let message2 = NSLocalizedString("LFO 2 Rate: \(value.decimalString) Hz", comment: "LFO 2 [low frequency oscillator] Rate tempo-syncd")
            if s.getSynthParameter(.tempoSyncToArpRate) > 0 {
                displayLabel.text = message
            } else {
                displayLabel.text = message2
            }
        // swiftlint:disable force_unwrapping
        case .lfo2Amplitude:
            let message = NSLocalizedString("LFO 2 Amp: \(value.percentageString)", comment: "LFO 2 [low frequency oscillator] Amplitude")
            displayLabel.text = message
        case .cutoffLFO:
            let message = NSLocalizedString("Cutoff LFO ‣ \(lfoSource!)", comment: "LFO [low frequency oscillator] Cutoff")
            displayLabel.text = message
        case .resonanceLFO:
            let message = NSLocalizedString("Resonance LFO ‣ \(lfoSource!)", comment: "LFO [low frequency oscillator] Resonance")
            displayLabel.text = message
        case .oscMixLFO:
            let message = NSLocalizedString("Osc Mix LFO ‣ \(lfoSource!)", comment: "LFO [low frequency oscillator] Oscillator Mix")
            displayLabel.text = message
        case .reverbMixLFO:
             let message = NSLocalizedString("Reverb Mix LFO ‣ \(lfoSource!)", comment: "LFO [low frequency oscillator] Reverb Mix")
            displayLabel.text = message
        case .decayLFO:
            let message = NSLocalizedString("Decay LFO ‣ \(lfoSource!)", comment: "LFO [low frequency oscillator] Decay")
            displayLabel.text = message
        case .noiseLFO:
            let message = NSLocalizedString("Noise LFO ‣ \(lfoSource!)", comment: "LFO [low frequency oscillator] Noise")
            displayLabel.text = message
        case .fmLFO:
            let message = NSLocalizedString("FM LFO ‣ \(lfoSource!)", comment: "LFO [low frequency oscillator] FM Modulation")
            displayLabel.text = message
        case .detuneLFO:
            let message = NSLocalizedString("Detune LFO ‣ \(lfoSource!)", comment: "LFO [low frequency oscillator] Detune")
            displayLabel.text = message
        case .filterEnvLFO:
            let message = NSLocalizedString("Filter Env LFO ‣ \(lfoSource!)", comment: "LFO [low frequency oscillator] Filter Envelope")
            displayLabel.text = message
        case .pitchLFO:
            let message = NSLocalizedString("Pitch LFO ‣ \(lfoSource!)", comment: "LFO [low frequency oscillator] Pitch")
            displayLabel.text = message
        case .bitcrushLFO:
            let message = NSLocalizedString("Bitcrush LFO ‣ \(lfoSource!)", comment: "LFO [low frequency oscillator] Bitcrush")
            displayLabel.text = message
        case .tremoloLFO:
            let message = NSLocalizedString("Tremolo LFO ‣ \(lfoSource!)", comment: "LFO [low frequency oscillator] Tremolo")
            displayLabel.text = message
        case .filterType:
            let message = NSLocalizedString("Low Pass", comment: "Low Pass Filter")
            let message2 = NSLocalizedString("Band Pass", comment: "Band Pass Filter")
            let message3 = NSLocalizedString("High Pass", comment: "High Pass Filter")
            
            var ftype = message
            if value == 1 {
                ftype = message2
            } else if value == 2 {
                ftype = message3
            }
            
            let message4 = NSLocalizedString("Filter Type: \(ftype)", comment: "Main Filter Type")
            displayLabel.text = message4
        case .phaserMix:
            let message = NSLocalizedString("Phaser Mix: \(value.decimalString)", comment: "Phaser Mix")
            displayLabel.text = message
        case .phaserRate:
            let message = NSLocalizedString("Phaser Rate: \(value.decimalString)", comment: "Phaser Rate")
            displayLabel.text = message
        case .phaserFeedback:
            let message = NSLocalizedString("Phaser Feedback: \(value.decimalString)", comment: "Phaser Feedback")
            displayLabel.text = message
        case .phaserNotchWidth:
            let message = NSLocalizedString("Phaser Notch Width: \(value.decimalString)", comment: "Phaser Notch Width")
            displayLabel.text = message
        case .arpInterval:
            let npo = AKPolyphonicNode.tuningTable.npo
            let npo1 = Int(Double(npo) * Double(value)/12.0)
            let message = NSLocalizedString("Arpeggiator Interval: \(npo1) of \(npo)", comment: "Arpeggiator Interval")
//            let message = NSLocalizedString("Interval: value:\(value.decimalString), npo1:\(npo1) of:\(npo)", comment: "Interval")
            displayLabel.text = message
        case .transpose:
            //TODO: localize
            let message = "Transpose: \(Int(value))"
            displayLabel.text = message
        case .arpIsOn:
            let message = NSLocalizedString("Arp/Sequencer On", comment: "Arpeggiator On")
            let message2 = NSLocalizedString("Arp/Sequencer Off", comment: "Arpeggiator Off")
            displayLabel.text = value == 1 ? message : message2
        case .arpIsSequencer:
            let message = NSLocalizedString("Sequencer Mode", comment: "Sequencer Mode On")
            let message2 = NSLocalizedString("Arpeggiator Mode", comment: "Arpeggiator Mode On")
            displayLabel.text = value == 1 ? message : message2
        case .arpRate:
            let message = NSLocalizedString("Tempo: \(value) BPM", comment: "Tempo (Beats Per Minute)")
            displayLabel.text = message
        case .widen:
            let stateDisplay = value == 1 ? "On" : "Off"
            let message = NSLocalizedString("Stereo Widen: \(stateDisplay)", comment: "Stereo Widen")
            displayLabel.text = message

        // visible on dev panel only
        case .compressorMasterRatio:
            displayLabel.text = "compressorMasterRatio: \(value.decimalString)"
        case .compressorReverbInputRatio:
            displayLabel.text = "compressorReverbInputRatio: \(value.decimalString)"
        case .compressorReverbWetRatio:
            displayLabel.text = "compressorReverbWetRatio: \(value.decimalString)"

        case .compressorMasterThreshold:
            displayLabel.text = "compressorMasterThreshold: \(value.decimalString)"
        case .compressorReverbInputThreshold:
            displayLabel.text = "compressorReverbInputThreshold: \(value.decimalString)"
        case .compressorReverbWetThreshold:
            displayLabel.text = "compressorReverbWetThreshold: \(value.decimalString)"

        case .compressorMasterAttack:
            displayLabel.text = "compressorMasterAttack: \(value.decimalString)"
        case .compressorReverbInputAttack:
            displayLabel.text = "compressorReverbInputAttack: \(value.decimalString)"
        case .compressorReverbWetAttack:
            displayLabel.text = "compressorReverbWetAttack: \(value.decimalString)"

        case .compressorMasterRelease:
            displayLabel.text = "compressorMasterRelease: \(value.decimalString)"
        case .compressorReverbInputRelease:
            displayLabel.text = "compressorReverbInputRelease: \(value.decimalString)"
        case .compressorReverbWetRelease:
            displayLabel.text = "compressorReverbWetRelease: \(value.decimalString)"

        case .compressorMasterMakeupGain:
            displayLabel.text = "compressorMasterMakeupGain: \(value.decimalString)"
        case .compressorReverbInputMakeupGain:
            displayLabel.text = "compressorReverbInputMakeupGain: \(value.decimalString)"
        case .compressorReverbWetMakeupGain:
            displayLabel.text = "compressorReverbWetMakeupGain: \(value.decimalString)"

        case .delayInputResonance:
            displayLabel.text = "Delay Input Rez: \(s.getSynthParameter(.delayInputResonance).decimalString)"

        case .delayInputCutoffTrackingRatio:
            displayLabel.text = "Delay Input Cutoff Tracking Ratio: " +
                                "\(s.getSynthParameter(.delayInputCutoffTrackingRatio).decimalString)"

        case .frequencyA4:
            displayLabel.text = "Master Frequency at A4: \(s.getSynthParameter(.frequencyA4).decimalString)"
        case .portamentoHalfTime:
            displayLabel.text = "Portamento Half-time: \(s.getSynthParameter(.portamentoHalfTime).decimalString)"
        case .oscBandlimitEnable:
            let obe = s.getSynthParameter(.oscBandlimitEnable) > 0 ? "On" : "Off"
            displayLabel.text = "Anti-Aliasing: \(obe)"

        case .adsrPitchTracking:
            displayLabel.text = "ADSR Pitch Tracking: \(s.getSynthParameter(.adsrPitchTracking).decimalString)"
        default:
            _ = 0
            // do nothing
        }
        displayLabel.setNeedsDisplay()
    }

    @objc func displayLabelTapped() {
        headerDelegate?.displayLabelTapped()
    }

    @IBAction func homePressed(_ sender: UIButton) {
        headerDelegate?.homePressed()
    }

    @IBAction func previousPresetPressed(_ sender: UIButton) {
         headerDelegate?.previousPresetPressed()
    }

    @IBAction func nextPresetPressed(_ sender: UIButton) {
         headerDelegate?.nextPresetPressed()
    }

    @IBAction func morePressed(_ sender: UIButton) {

    }

    @IBAction func randomPressed(_ sender: UIButton) {
        // Animate Dice
        UIView.animate(withDuration: 0.4, animations: {
            for _ in 0 ... 1 {
                self.diceButton.transform = self.diceButton.transform.rotated(by: CGFloat(Double.pi))
            }
        })

        headerDelegate?.randomPresetPressed()
    }

    func setupCallbacks() {

        panicButton.callback = { _ in
            self.headerDelegate?.panicPressed()
        }

        saveButton.callback = { _ in
            self.headerDelegate?.savePresetPressed()
        }

        devButton.callback = { _ in
            self.headerDelegate?.devPressed()
        }

        aboutButton.callback = { _ in
            self.headerDelegate?.aboutPressed()
        }

        morePresetsButton.callback = { _ in
            self.headerDelegate?.morePressed()
        }
        
        appsButton.callback = { _ in
            self.headerDelegate?.appsPressed()
        }

        webButton.callback = { _ in
            if let url = URL(string: "http://audiokitpro.com/synth") {
                UIApplication.shared.open(url)
            }
        }
    }

    @IBAction func openHostApp(_ sender: AnyObject) {

        var url: CFURL = CFURLCreateWithString(nil, "" as CFString?, nil)
        var size = UInt32(MemoryLayout<CFURL>.size)

        guard let outputAudioUnit = AudioKit.engine.outputNode.audioUnit else { return }
        let result = AudioUnitGetProperty(
            outputAudioUnit,
            AudioUnitPropertyID(kAudioUnitProperty_PeerURL),
            AudioUnitScope(kAudioUnitScope_Global),
            0,
            &url,
            &size)

        if result == noErr {
            UIApplication.shared.open(url as URL)
        }
    }

    func updateMailingListButton(_ signedMailingList: Bool) {
        // Mailing List Button
        if signedMailingList {
            morePresetsButton.setTitle("More", for: .normal)
            morePresetsButton.setTitleColor(#colorLiteral(red: 0.6666666667, green: 0.6666666667, blue: 0.6666666667, alpha: 1), for: .normal)
            morePresetsButton.backgroundColor = #colorLiteral(red: 0.1764705882, green: 0.1764705882, blue: 0.1764705882, alpha: 1)
        } else {
            morePresetsButton.setTitle("More", for: .normal)
            morePresetsButton.setTitleColor(#colorLiteral(red: 1, green: 1, blue: 1, alpha: 1), for: .normal)
            morePresetsButton.backgroundColor = #colorLiteral(red: 0.7607843137, green: 0.5137254902, blue: 0.1098039216, alpha: 1)
        }

    }
}
