//
//  Parent+Audiobus.swift
//  AudioKitSynthOne
//
//  Created by Aurelius Prochazka on 5/25/18.
//  Copyright © 2018 AudioKit. All rights reserved.
//

// AudioBus MIDI Input & Preset Loading

extension ParentViewController: ABAudiobusControllerStateIODelegate {

    func setupAudioBusInput() {
        midiInput = ABMIDIReceiverPort(name: "AudioKit Synth One MIDI", title: "AudioKit Synth One MIDI") { (_, midiPacketListPointer)  in

            let events = AKMIDIEvent.midiEventsFrom(packetListPointer: midiPacketListPointer)
            for event in events {
                guard event.channel == self.midiChannelIn || self.omniMode else { return }

                if event.status == AKMIDIStatus.noteOn {
                    if event.internalData[2] == 0 {
                        self.sustainer.stop(noteNumber: event.noteNumber!)

                    } else {
                        // Prevent multiple triggers from multiple MIDI inputs
                        //                        guard !self.notesJustTriggered.contains(event.noteNumber!) else { return }
                        //
                        //                        self.notesJustTriggered.insert(event.noteNumber!)
                        //                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.01) {
                        //                            self.notesJustTriggered.remove(event.noteNumber!)
                        //                        }

                        self.sustainer.play(noteNumber: event.noteNumber!, velocity: event.internalData[2])
                    }
                }

                if event.status == AKMIDIStatus.noteOff {
                    guard event.channel == self.midiChannelIn || self.omniMode else { return }
                    self.sustainer.stop(noteNumber: event.noteNumber!)
                }

                if event.status == AKMIDIStatus.pitchWheel {
                    guard event.channel == self.midiChannelIn || self.omniMode else { return }
                    let x = MIDIWord(event.internalData[1])
                    let y = MIDIWord(event.internalData[2]) << 7
                    self.receivedMIDIPitchWheel(y + x, channel: event.channel!)
                }

                if event.status == AKMIDIStatus.programChange {
                    guard event.channel == self.midiChannelIn || self.omniMode else { return }
                    self.receivedMIDIProgramChange(event.data1, channel: event.channel!)
                }

                if event.status == AKMIDIStatus.controllerChange {
                    guard event.channel == self.midiChannelIn || self.omniMode else { return }
                    self.receivedMIDIController(event.data1, value: event.data2, channel: event.channel!)
                }
            }
        }
        Audiobus.client?.controller.addMIDIReceiverPort(midiInput)
        Audiobus.client?.controller.stateIODelegate = self
    }

    //*****************************************************************
    // MARK: - AudioBus Preset Delegate
    //*****************************************************************

    public func audiobusStateDictionaryForCurrentState() -> [AnyHashable: Any]! {
        return [ "preset": activePreset.position]
    }

    public func loadState(fromAudiobusStateDictionary dictionary: [AnyHashable: Any]!, responseMessage outResponseMessage: AutoreleasingUnsafeMutablePointer<NSString?>!) {

        if let abDictionary = dictionary as? [String: Any] {
            activePreset.position = abDictionary["preset"] as? Int ?? 0
            DispatchQueue.main.async {
                self.presetsViewController.didSelectPreset(index: self.activePreset.position)
            }
        }
    }
}
