//
//  PopUpMIDIViewController.swift
//  AudioKitSynthOne
//
//  Created by Matthew Fecher on 12/26/17.
//  Copyright © 2017 AudioKit. All rights reserved.
//


import UIKit

protocol MIDISettingsPopOverDelegate {
    func resetMIDILearn()
    func didSelectMIDIChannel(newChannel: Int)
    func didSetBackgroundAudio()
}

class PopUpMIDIViewController: UIViewController {

    @IBOutlet weak var channelStepper: Stepper!
    @IBOutlet weak var channelLabel: UILabel!
    @IBOutlet weak var resetButton: SynthUIButton!
    @IBOutlet weak var inputTable: UITableView!
    @IBOutlet weak var sleepToggle: ToggleSwitch!
    @IBOutlet weak var energyLabel: UILabel!
    @IBOutlet weak var backgroundAudioToggle: ToggleSwitch!
    
    var delegate: MIDISettingsPopOverDelegate?
    
    var midiSources = [MIDIInput]() {
        didSet {
            displayMIDIInputs()
        }
    }
    var userChannelIn: Int = 1
    
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
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        displayMIDIInputs()
        
        sleepToggle.value = conductor.neverSleep ? 1:0
        backgroundAudioToggle.value = conductor.backgroundAudioOn ? 1:0
        
        if sleepToggle.isOn {
            self.backgroundAudioToggle.alpha = 0.5
            self.energyLabel.alpha = 0.5
        }
    }
    
    func displayMIDIInputs() {
        if self.isViewLoaded && (self.view.window != nil) {
            // viewController is visible
            inputTable.reloadData()
        }
    }
    
    // **********************************************************
    // MARK: - Callbacks
    // **********************************************************
    
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
            self.displayAlertController("MIDI Learn Reset", message: "All MIDI learn knob assignments have been removed.")
        }
        
        sleepToggle.callback = { value in
          
            if value == 1 {
                self.conductor.neverSleep = true
                self.conductor.backgroundAudioOn = true
                self.backgroundAudioToggle.alpha = 0.5
                self.backgroundAudioToggle.isUserInteractionEnabled = false
                self.energyLabel.alpha = 0.5
                
                self.displayAlertController("Info", message: "This mode is great for playing live. Note: it will use more power and could drain your battery faster")
            } else {
                self.conductor.neverSleep = false
                self.backgroundAudioToggle.alpha = 1.0
                self.backgroundAudioToggle.isUserInteractionEnabled = true
                self.energyLabel.alpha = 1.0
                
                self.conductor.backgroundAudioOn = (self.backgroundAudioToggle.value == 1)
            }
        }
        
        backgroundAudioToggle.callback = { value in
            if value == 1 {
                self.conductor.backgroundAudioOn = true
            } else {
                self.conductor.backgroundAudioOn = false
                self.displayAlertController("Info", message: "Turning background audio off could cause this app to work improperly with other apps using IAA or Audiobus. You may need to restart AB3 after turning background audio back on")
            }
            self.delegate?.didSetBackgroundAudio()
        }
    }
    
    func updateChannelLabel() {
        if userChannelIn == 0 {
            self.channelLabel.text = "MIDI Channel In: Omni"
        } else {
            self.channelLabel.text = "MIDI Channel In: \(userChannelIn)"
        }
    }
    
    // **********************************************************
    // MARK: - Actions
    // **********************************************************
    
    @IBAction func closeButton(_ sender: UIButton) {
        dismiss(animated: true, completion: nil)
    }
    
}


// *****************************************************************
// MARK: - TableViewDataSource
// *****************************************************************

extension PopUpMIDIViewController: UITableViewDataSource {
    
    func numberOfSections(in categoryTableView: UITableView) -> Int {
        return 1
    }
    
    @objc(tableView:heightForRowAtIndexPath:) func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
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

//*****************************************************************
// MARK: - TableViewDelegate
//*****************************************************************

extension PopUpMIDIViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        tableView.deselectRow(at: indexPath, animated: false)
        
        // presetIndex = (indexPath as NSIndexPath).row
        
        // Get cell
        let cell = tableView.cellForRow(at: indexPath) as? MIDICell
        guard let midiInput = cell?.currentInput else { return }
        
        // Toggle Cell
        midiInput.isOpen = !midiInput.isOpen
        inputTable.reloadData()
      
        /*
        // Open / Close MIDI Input
        if midiInput.isOpen {
            conductor.midi.openInput(midiInput.name)
        } else {
            conductor.midi.closeInput(midiInput.name)
            
        }
        */
    }
    
}

