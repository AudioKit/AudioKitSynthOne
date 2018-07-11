//
//  MIDISettingsViewController.swift
//  AudioKitSynthOne
//
//  Created by AudioKit Contributors on 12/26/17.
//  Copyright © 2017 AudioKit. All rights reserved.
//

import UIKit

protocol MIDISettingsPopOverDelegate: AnyObject {
    func resetMIDILearn()
    func didSelectMIDIChannel(newChannel: Int)
    func didToggleVelocity()
    func storeTuningWithPresetDidChange(_ value: Bool)
    func didToggleBackgroundAudio(_ value: Bool)
    func didChangeMIDISources(_ midiSources: [MIDIInput])
}

class MIDISettingsViewController: UIViewController {

    @IBOutlet weak var channelStepper: Stepper!
    @IBOutlet weak var channelLabel: UILabel!
    @IBOutlet weak var resetButton: SynthButton!
    @IBOutlet weak var inputTable: UITableView!
    @IBOutlet weak var sleepToggle: ToggleSwitch!
    @IBOutlet weak var velocityToggle: ToggleSwitch!
    @IBOutlet weak var saveTuningToggle: ToggleSwitch!
    @IBOutlet weak var backgroundAudioToggle: ToggleSwitch!
    
    weak var delegate: MIDISettingsPopOverDelegate?

    var midiSources = [MIDIInput]() {
        didSet {
            displayMIDIInputs()
        }
    }

    var userChannelIn: Int = 1
    var velocitySensitive = true
    var saveTuningWithPreset = false

    let conductor = Conductor.sharedInstance

    override func viewDidLoad() {
        super.viewDidLoad()

        view.layer.borderColor = #colorLiteral(red: 0.06666666667, green: 0.06666666667, blue: 0.06666666667, alpha: 1)
        view.layer.borderWidth = 2
        inputTable.separatorColor = #colorLiteral(red: 0.368627451, green: 0.368627451, blue: 0.3882352941, alpha: 1)

        // setup channel stepper
        channelStepper.maxValue = 16
        userChannelIn += 1 // Internal MIDI Channels start at 0...15, Users see 1...16
        channelStepper.value = Double(userChannelIn)
        updateChannelLabel()

        // Setup Callbacks
        setupCallbacks()

        // Toggles
        sleepToggle.value = conductor.neverSleep ? 1 : 0
        velocityToggle.value = velocitySensitive ? 1 : 0
        saveTuningToggle.value = saveTuningWithPreset ? 1 : 0
        backgroundAudioToggle.value = conductor.backgroundAudio ? 1:0
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        displayMIDIInputs()

    }

    func displayMIDIInputs() {
        if self.isViewLoaded && (self.view.window != nil) {
            // viewController is visible
            inputTable.reloadData()
        }
    }

    // MARK: - Callbacks

    func setupCallbacks() {
        // Setup Callback
        channelStepper.callback = { value in
            self.userChannelIn = Int(value)
            self.updateChannelLabel()
            self.delegate?.didSelectMIDIChannel(newChannel: self.userChannelIn - 1)
        }

        resetButton.callback = { value in
            self.delegate?.resetMIDILearn()
            self.resetButton.value = 0
            self.displayAlertController("MIDI Learn Reset",
                                        message: "All MIDI learn knob assignments have been removed.")
        }

        sleepToggle.callback = { value in

            if value == 1 {
                self.conductor.neverSleep = true
                self.displayAlertController("Don't Sleep Mode", message: "This mode is great for playing live. Background audio will also stay on. " +
                    "Note: It will use more power and could drain your battery faster")
            } else {
                self.conductor.neverSleep = false
            
            }
        }
        
        backgroundAudioToggle.callback = { value in
            self.conductor.backgroundAudio = value == 1
            self.delegate?.didToggleBackgroundAudio(value == 1 ? true : false)
        }

        velocityToggle.callback = { value in
            self.delegate?.didToggleVelocity()
        }

        saveTuningToggle.callback = { value in
            self.delegate?.storeTuningWithPresetDidChange(value == 1 ? true : false)
        }

    }

    func updateChannelLabel() {
        if userChannelIn == 0 {
            self.channelLabel.text = "MIDI Channel In: Omni"
        } else {
            self.channelLabel.text = "MIDI Channel In: \(userChannelIn)"
        }
    }

    // MARK: - Actions

    @IBAction func closeButton(_ sender: UIButton) {
        dismiss(animated: true, completion: nil)
    }

}

// MARK: - TableViewDataSource

extension MIDISettingsViewController: UITableViewDataSource {

    func numberOfSections(in categoryTableView: UITableView) -> Int {
        return 1
    }

    @objc(tableView:heightForRowAtIndexPath:) func tableView(_ tableView: UITableView,
                                                             heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 44
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if midiSources.isEmpty {
            return 0
        } else {
            return midiSources.count
        }
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        if let cell = tableView.dequeueReusableCell(withIdentifier: "MIDICell") as? MIDICell {

            let midiInput = midiSources[indexPath.row]

            cell.configureCell(midiInput: midiInput)

            return cell

        } else {
            return MIDICell()
        }
    }
}

// MARK: - TableViewDelegate

extension MIDISettingsViewController: UITableViewDelegate {

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {

        tableView.deselectRow(at: indexPath, animated: false)

        // presetIndex = (indexPath as NSIndexPath).row

        // Get cell
        let cell = tableView.cellForRow(at: indexPath) as? MIDICell
        guard let midiInput = cell?.currentInput else { return }

        // Toggle Cell
        midiInput.isOpen = !midiInput.isOpen
        inputTable.reloadData()

        // Open / Close MIDI Input
        if midiInput.isOpen {
            AudioKit.midi.openInput(midiInput.name)
        } else {
            AudioKit.midi.closeInput(midiInput.name)
        }

        delegate?.didChangeMIDISources(midiSources)
    }

}
