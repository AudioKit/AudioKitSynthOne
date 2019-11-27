//
//  GeneratorPanel.swift
//  AudioKitSynthOne
//
//  Created by AudioKit Contributors on 7/23/17.
//  Copyright © 2017 AudioKit. All rights reserved.
//

import AudioKit
import AudioKitUI
import UIKit

class GeneratorsPanelController: PanelController, AudioRecorderViewDelegate {

    @IBOutlet weak var morph1Selector: MorphSelector!

    @IBOutlet weak var morph2Selector: MorphSelector!

    @IBOutlet weak var morph1SemitoneOffset: MIDIKnob!

    @IBOutlet weak var morph2SemitoneOffset: MIDIKnob!

    @IBOutlet weak var morph2Detuning: MIDIKnob!

    @IBOutlet weak var morphBalance: MIDIKnob!

    @IBOutlet weak var morph1Volume: MIDIKnob!

    @IBOutlet weak var morph2Volume: MIDIKnob!

    @IBOutlet weak var glideKnob: MIDIKnob!

    @IBOutlet weak var cutoff: MIDIKnob!

    @IBOutlet weak var resonance: MIDIKnob!

    @IBOutlet weak var subVolume: MIDIKnob!

    @IBOutlet weak var subOctaveDown: ToggleButton!

    @IBOutlet weak var subIsSquare: ToggleButton!

    @IBOutlet weak var isMonoToggle: ToggleButton!

    @IBOutlet weak var fmVolume: MIDIKnob!

    @IBOutlet weak var fmAmount: MIDIKnob!

    @IBOutlet weak var noiseVolume: MIDIKnob!

    @IBOutlet weak var masterVolume: MIDIKnob!

    @IBOutlet weak var filterTypeToggle: FilterTypeButton!

    @IBOutlet weak var displayContainer: UIView!

    @IBOutlet weak var sequencerToggle: FlatToggleButton!

    @IBOutlet weak var tempoStepper: TempoStepper!

    @IBOutlet weak var legatoModeToggle: ToggleButton!

    @IBOutlet weak var widenToggle: FlatToggleButton!

    @IBOutlet weak var oscBandlimitEnable: ToggleButton!
    
    @IBOutlet weak var cutoffKnobLabel: UILabel!
    
    @IBOutlet weak var rezKnobLabel: UILabel!

    @IBOutlet weak var recordButton: MIDIRecordButton!

    @IBOutlet weak var recordStatus: UILabel!

    var isAudioPlotFilled: Bool = false

    public override func viewDidLoad() {
        super.viewDidLoad()
        currentPanel = .generators

        // Defaults, limits
        guard let s = conductor.synth else {
            AKLog("GeneratorsPanel view state is invalid because synth is not instantiated")
            return
        }
        morph1SemitoneOffset.onlyIntegers = true
        morph1SemitoneOffset.range = s.getRange(.morph1SemitoneOffset)
        morph1SemitoneOffset.knobSensitivity = 0.004
        morph2SemitoneOffset.knobSensitivity = 0.004
        morph2SemitoneOffset.onlyIntegers = true
        morph2SemitoneOffset.range = s.getRange(.morph2SemitoneOffset)
        morph2Detuning.range = s.getRange(.morph2Detuning)
        morphBalance.range = s.getRange(.morphBalance)
        morph1Volume.range = s.getRange(.morph1Volume)
        morph2Volume.range = s.getRange(.morph2Volume)
        glideKnob.range = s.getRange(.glide)
        glideKnob.taper = 2
        cutoff.range = s.getRange(.cutoff)
        cutoff.taper = 2
        resonance.range = s.getRange(.resonance)
        subVolume.range = s.getRange(.subVolume)
        fmVolume.range = s.getRange(.fmVolume)
        fmAmount.range = s.getRange(.fmAmount)
        noiseVolume.range = s.getRange(.noiseVolume)
        masterVolume.range = s.getRange(.masterVolume)
        masterVolume.taper = 2
        tempoStepper.maxValue = s.getMaximum(.arpRate)
        tempoStepper.minValue = s.getMinimum(.arpRate)
        conductor.bind(morph1Selector, to: .index1)
        conductor.bind(morph2Selector, to: .index2)
        conductor.bind(morph1SemitoneOffset, to: .morph1SemitoneOffset)
        conductor.bind(morph2SemitoneOffset, to: .morph2SemitoneOffset)
        conductor.bind(morph2Detuning, to: .morph2Detuning)
        conductor.bind(morphBalance, to: .morphBalance)
        conductor.bind(morph1Volume, to: .morph1Volume)
        conductor.bind(morph2Volume, to: .morph2Volume)
        conductor.bind(cutoff, to: .cutoff)
        conductor.bind(resonance, to: .resonance)
        conductor.bind(subVolume, to: .subVolume)
        conductor.bind(subOctaveDown, to: .subOctaveDown)
        conductor.bind(subIsSquare, to: .subIsSquare)
        conductor.bind(fmVolume, to: .fmVolume)
        conductor.bind(fmAmount, to: .fmAmount)
        conductor.bind(noiseVolume, to: .noiseVolume)
        conductor.bind(isMonoToggle, to: .isMono)
        conductor.bind(glideKnob, to: .glide)
        conductor.bind(filterTypeToggle, to: .filterType)
        conductor.bind(masterVolume, to: .masterVolume)
        conductor.bind(legatoModeToggle, to: .monoIsLegato)
        conductor.bind(widenToggle, to: .widen)
        conductor.bind(sequencerToggle, to: .arpIsOn)
        conductor.bind(tempoStepper, to: .arpRate)
        conductor.bind(oscBandlimitEnable, to: .oscBandlimitEnable)

        // Setup Audio Plot Display
        setupAudioPlot()
        setupLinkStuff()
        conductor.audioRecorder?.viewDelegate = self

        recordButton.setValueCallback = { value in
            self.recordToggled(value: value)
        }

		// Sets the read order for VoiceOver
		view.accessibilityElements = [
			morph1Selector!,
			morph1SemitoneOffset!,
			morph2Selector!,
			morph2SemitoneOffset!,
			morph2Detuning!,
			subVolume!,
			subOctaveDown!,
			subIsSquare!,
			morph1Volume!,
			morph2Volume!,
			morphBalance!,
			masterVolume!,
			fmVolume!,
			fmAmount!,
			filterTypeToggle!,
			cutoff!,
			resonance!,
			noiseVolume!,
			glideKnob!,
			isMonoToggle!,
			legatoModeToggle!,
			oscBandlimitEnable!,
			widenToggle!,
			sequencerToggle!,
			tempoStepper!,
			leftNavButton!,
			rightNavButton!
		]
    }

    func setupAudioPlot() {
        conductor.audioPlotter.frame = CGRect(x: 0, y: 0, width: 172, height: 93)
        conductor.audioPlotter.backgroundColor = #colorLiteral(red: 0.2431372549, green: 0.2431372549, blue: 0.262745098, alpha: 0)
        conductor.audioPlotter.color = #colorLiteral(red: 0.9611048102, green: 0.509832561, blue: 0, alpha: 1)
        conductor.audioPlotter.gain = 0.8
        conductor.audioPlotter.shouldFill = false
        displayContainer.addSubview(conductor.audioPlotter)

        // Add Tap Gesture Recognizer to AudioPlot
        let audioPlotTap = UITapGestureRecognizer(target: self,
                                                  action: #selector(GeneratorsPanelController.audioPlotToggled))
        conductor.audioPlotter.addGestureRecognizer(audioPlotTap)
    }

    @objc func audioPlotToggled() {
        isAudioPlotFilled = !isAudioPlotFilled
        conductor.audioPlotter.shouldFill = isAudioPlotFilled
    }

    @objc func recordToggled(value: Double) {
        conductor.audioRecorder?.toggleRecord(value: value)
    }

    func updateRecorderView(state: RecorderState, time: Double?) {
        if state == .Idle || state == .Exporting {
            recordStatus.text = state == .Idle ?
                NSLocalizedString("Record", comment: "Record Audio") :
                NSLocalizedString("Exporting", comment: "Audio is exporting")
        } else {
            recordStatus.text = TimeInterval(time!).stringFromTimeInterval()
        }
    }

    override func updateUI(_ parameter: S1Parameter, control: S1Control?, value: Double) {
        switch parameter {
        case .filterType:
            switch value {
            case 0:
                // Low Pass
                cutoffKnobLabel.text = "Frequency"
                rezKnobLabel.text = "Resonance"
            case 1:
                // Band Pass
                cutoffKnobLabel.text = "Center"
                rezKnobLabel.text = "Width"
            case 2:
                // High Pass
                cutoffKnobLabel.text = "Frequency"
                rezKnobLabel.text = "Off"
            default:
                break
            }
        default:
            _ = 0
        }
    }
}

extension TimeInterval {
    func stringFromTimeInterval() -> String {
        let time = NSInteger(self)
        let seconds = time % 60
        let minutes = (time / 60) % 60
        let hours = (time / 3600)

        return String(format: "%0.2d:%0.2d:%0.2d",hours,minutes,seconds)
    }
}
