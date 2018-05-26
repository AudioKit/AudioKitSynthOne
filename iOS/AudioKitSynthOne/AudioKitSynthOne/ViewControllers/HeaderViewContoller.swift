//
//  HeaderViewContoller.swift
//  AudioKitSynthOne
//
//  Created by Aurelius Prochazka on 7/23/17.
//  Copyright © 2017 AudioKit. All rights reserved.
//

import UIKit

protocol HeaderDelegate {
    func displayLabelTapped()
    func homePressed()
    func prevPresetPressed()
    func nextPresetPressed()
    func savePresetPressed()
    func randomPresetPressed()
    func panicPressed()
    func devPressed()
    func aboutPressed()
    func morePressed()
}

public class HeaderViewController: UpdatableViewController {

    enum LFOValue: Int {
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

    var delegate: EmbeddedViewsDelegate?
    var headerDelegate: HeaderDelegate?
    var activePreset = Preset()

    func ADSRString(_ a: AKSynthOneParameter,
                    _ d: AKSynthOneParameter,
                    _ s: AKSynthOneParameter,
                    _ r: AKSynthOneParameter) -> String {
        return "A: \(conductor.synth.getAK1Parameter(a).decimalString) " +
            "D: \(conductor.synth.getAK1Parameter(d).decimalString) " +
            "S: \(conductor.synth.getAK1Parameter(s).percentageString) " +
            "R: \(conductor.synth.getAK1Parameter(r).decimalString) "
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

    override func updateUI(_ param: AKSynthOneParameter, control: AKSynthOneControl?, value: Double) {
        updateDisplayLabel(param, value: value)
    }

    func updateDisplayLabel(_ param: AKSynthOneParameter, value: Double) {
        let s = conductor.synth!
        let lfoValue = LFOValue(rawValue: Int(value))

        switch param {
        case .index1:
            displayLabel.text = "OSC1 Morph: \(value.decimalString)"
        case .index2:
            displayLabel.text = "OSC2 Morph: \(value.decimalString)"
        case .morph1SemitoneOffset:
            displayLabel.text = "DCO1: \(Int(value)) semitones"
        case .morph2SemitoneOffset:
            displayLabel.text = "DCO2: \(Int(value)) semitones"
        case .morph2Detuning:
            displayLabel.text = "DCO2 Detune: \(value.decimalString)Hz"
        case .morphBalance:
            displayLabel.text = "DCO Mix: \(value.decimalString)"
        case .morph1Volume:
            displayLabel.text = "DCO1 Vol: \(value.percentageString)"
        case .morph2Volume:
            displayLabel.text = "DCO2 Vol: \(value.percentageString)"
        case .glide:
            displayLabel.text = "Glide: \(value.decimalString)"
        case .cutoff, .resonance:
            displayLabel.text = "Cutoff: \(s.getAK1Parameter(.cutoff).decimalString) Hz, " +
                                "Rez: \(s.getAK1Parameter(.resonance).decimalString)"
        case .subVolume:
            displayLabel.text = "Sub Mix: \(value.percentageString)"
        case .fmVolume:
            displayLabel.text = "FM Mix: \(value.percentageString)"
        case .fmAmount:
            displayLabel.text = "FM Mod: \(value.decimalString)"
        case .noiseVolume:
            displayLabel.text = "Noise Mix: \((value * 4).percentageString)"
        case .masterVolume:
            displayLabel.text = "Master Vol: \(value.percentageString)"
        case .attackDuration, .decayDuration, .sustainLevel, .releaseDuration:
            displayLabel.text = ADSRString(.attackDuration, .decayDuration, .sustainLevel, .releaseDuration)
        case .filterAttackDuration, .filterDecayDuration, .filterSustainLevel, .filterReleaseDuration:
            displayLabel.text = "" +
                ADSRString(.filterAttackDuration, .filterDecayDuration, .filterSustainLevel, .filterReleaseDuration)
        case .filterADSRMix:
            displayLabel.text = "Filter Envelope Amt: \(value.percentageString)"
        case .bitCrushDepth: //unused
            displayLabel.text = "Bit Crush Depth: \(value.decimalString)"
        case .bitCrushSampleRate:
            displayLabel.text = "Downsample Rate: \(Int(value)) Hz"
        case .autoPanAmount:
            displayLabel.text = "AutoPan Amp: \(value.percentageString)"
        case .autoPanFrequency:
            if s.getAK1Parameter(.tempoSyncToArpRate) > 0 {
                displayLabel.text = "AutoPan Rate: \(Rate.fromFrequency(value)), \(value.decimalString) Hz"
            } else {
                displayLabel.text = "AutoPan Rate: \(value.decimalString) Hz"
            }
        case .reverbOn:
            displayLabel.text = value == 1 ? "Reverb On" : "Reverb Off"
        case .reverbFeedback:
            displayLabel.text = "Reverb Size: \(value.percentageString)"
        case .reverbHighPass:
            displayLabel.text = "Reverb Low-cut: \(value.decimalString) Hz"
        case .reverbMix:
            displayLabel.text = "Reverb Mix: \(value.percentageString)"
        case .delayOn:
            displayLabel.text = value == 1 ? "Delay On" : "Delay Off"
        case .delayFeedback:
            displayLabel.text = "Delay Taps: \(value.percentageString)"
        case .delayTime:
            if s.getAK1Parameter(.tempoSyncToArpRate) > 0 {
                displayLabel.text = "Delay Time: \(Rate.fromTime(value)), \(value.decimalString)s"
            } else {
               displayLabel.text = "Delay Time: \(value.decimalString) s"
            }

        case .delayMix:
            displayLabel.text = "Delay Mix: \(value.percentageString)"
        case .lfo1Rate, .lfo1Amplitude:
            if s.getAK1Parameter(.tempoSyncToArpRate) > 0 {
                displayLabel.text = "LFO1 Rate: \(Rate.fromFrequency(s.getAK1Parameter(.lfo1Rate))), " +
                                    "LFO1 Amp: \(s.getAK1Parameter(.lfo1Amplitude).percentageString)"
            } else {
                displayLabel.text = "LFO1 Rate: \(s.getAK1Parameter(.lfo1Rate).decimalString)Hz, " +
                                    "LFO1 Amp: \(s.getAK1Parameter(.lfo1Amplitude).percentageString)"
            }
        case .lfo2Rate:
            if s.getAK1Parameter(.tempoSyncToArpRate) > 0 {
                displayLabel.text = "LFO 2 Rate: \(Rate.fromFrequency(value)), \(value.decimalString) Hz"
            } else {
                displayLabel.text = "LFO 2 Rate: \(value.decimalString) Hz"
            }
        case .lfo2Amplitude:
            displayLabel.text = "LFO 2 Amp: \(value.percentageString)"
        case .cutoffLFO:
            displayLabel.text = "Cutoff LFO ‣ \(lfoValue!)"
        case .resonanceLFO:
            displayLabel.text = "Resonance LFO ‣ \(lfoValue!)"
        case .oscMixLFO:
            displayLabel.text = "Osc Mix LFO ‣ \(lfoValue!)"
        case .reverbMixLFO:
            displayLabel.text = "Reverb Mix LFO ‣ \(lfoValue!)"
        case .decayLFO:
            displayLabel.text = "Decay LFO ‣ \(lfoValue!)"
        case .noiseLFO:
            displayLabel.text = "Noise LFO ‣ \(lfoValue!)"
        case .fmLFO:
            displayLabel.text = "FM LFO ‣ \(lfoValue!)"
        case .detuneLFO:
            displayLabel.text = "Detune LFO ‣ \(lfoValue!)"
        case .filterEnvLFO:
            displayLabel.text = "Filter Env LFO ‣ \(lfoValue!)"
        case .pitchLFO:
            displayLabel.text = "Pitch LFO ‣ \(lfoValue!)"
        case .bitcrushLFO:
            displayLabel.text = "Bitcrush LFO ‣ \(lfoValue!)"
        case .tremoloLFO:
            displayLabel.text = "Tremolo LFO ‣ \(lfoValue!)"
        case .filterType:
            var ftype = "Low Pass"
            if value == 1 {
                ftype = "Band Pass"
            } else if value == 2 {
                ftype = "High Pass"
            }
            displayLabel.text = "Filter Type : \(ftype)"
        case .phaserMix:
            displayLabel.text = "Phaser Mix: \(value.decimalString)"
        case .phaserRate:
            displayLabel.text = "Phaser Rate: \(value.decimalString)"
        case .phaserFeedback:
            displayLabel.text = "Phaser Feedback: \(value.decimalString)"
        case .phaserNotchWidth:
            displayLabel.text = "Phaser Notch Width: \(value.decimalString)"
        case .arpInterval:
            displayLabel.text = "Arpeggiator Interval: \(Int(value))"
        case .arpIsOn:
            displayLabel.text = value == 1 ? "Arp/Sequencer On" : "Arpeggiator/Sequencer Off"
        case .arpIsSequencer:
            displayLabel.text = value == 1 ? "Sequencer Mode" : "Arpeggiator Mode"
        case .arpRate:
            displayLabel.text = "Arp/Sequencer Tempo: \(value) BPM"
        case .widen:
            displayLabel.text = "Widen: \(value.decimalString)"

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
            displayLabel.text = "Delay Input Rez: \(s.getAK1Parameter(.delayInputResonance).decimalString)"

        case .delayInputCutoffTrackingRatio:
            displayLabel.text = "Delay Input Cutoff Tracking Ratio: " +
                                "\(s.getAK1Parameter(.delayInputCutoffTrackingRatio).decimalString)"

        case .frequencyA4:
            displayLabel.text = "Master Frequency at A4: \(s.getAK1Parameter(.frequencyA4).decimalString)"

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

    @IBAction func prevPresetPressed(_ sender: UIButton) {
         headerDelegate?.prevPresetPressed()
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

        webButton.callback = { _ in
            if let url = URL(string: "http://audiokitpro.com/") {
                UIApplication.shared.open(url)
            }
        }
    }

    @IBAction func openHostApp(_ sender: AnyObject) {

        var url: CFURL = CFURLCreateWithString(nil, "" as CFString?, nil)
        var size = UInt32(MemoryLayout<CFURL>.size)
        let result = AudioUnitGetProperty(
            AudioKit.engine.outputNode.audioUnit!,
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
            morePresetsButton.setTitle("Apps", for: .normal)
            morePresetsButton.setTitleColor(#colorLiteral(red: 0.6666666667, green: 0.6666666667, blue: 0.6666666667, alpha: 1), for: .normal)
            morePresetsButton.backgroundColor = #colorLiteral(red: 0.1764705882, green: 0.1764705882, blue: 0.1764705882, alpha: 1)
        } else {
            morePresetsButton.setTitle("More", for: .normal)
            morePresetsButton.setTitleColor(#colorLiteral(red: 1, green: 1, blue: 1, alpha: 1), for: .normal)
            morePresetsButton.backgroundColor = #colorLiteral(red: 0.7607843137, green: 0.5137254902, blue: 0.1098039216, alpha: 1)
        }

    }
}
