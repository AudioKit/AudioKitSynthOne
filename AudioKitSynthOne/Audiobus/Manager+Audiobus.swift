//
//  Manager+Audiobus.swift
//  AudioKitSynthOne
//
//  Created by AudioKit Contributors on 5/25/18.
//  Copyright © 2018 AudioKit. All rights reserved.
//

// AudioBus MIDI Input & Preset Loading

extension Manager: ABAudiobusControllerStateIODelegate {

    func setupAudioBusInput() {
        midiInput = ABMIDIReceiverPort(name: "AudioKit Synth One MIDI",
                                       title: "AudioKit Synth One MIDI") { (_, midiPacketListPointer)  in

            let events = AKMIDIEvent.midiEventsFrom(packetListPointer: midiPacketListPointer)
            for event in events {
                guard let channel = event.channel, event.channel == self.midiChannelIn || self.omniMode else { return }

                if event.status?.type == AKMIDIStatusType.noteOn {
                    guard let noteNumber = event.noteNumber else { return }
                    if event.data[2] == 0 {
                        self.sustainer.stop(noteNumber: noteNumber)
                    } else {
                        // Prevent multiple triggers from multiple MIDI inputs
//                        guard !self.notesJustTriggered.contains(event.noteNumber!) else { return }
//
//                        self.notesJustTriggered.insert(event.noteNumber!)
//                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.01) {
//                            self.notesJustTriggered.remove(event.noteNumber!)
//                        }

                        self.sustainer.play(noteNumber: noteNumber, velocity: event.data[2])
                    }
                }

                if event.status?.type == AKMIDIStatusType.noteOff {
                    guard let noteNumber = event.noteNumber else { return }
                    self.sustainer.stop(noteNumber: noteNumber)
                }

                if event.status?.type == AKMIDIStatusType.pitchWheel {
                    let x = MIDIWord(event.data[1])
                    let y = MIDIWord(event.data[2]) << 7
                    self.receivedMIDIPitchWheel(y + x, channel: channel)
                }

                if event.status?.type == AKMIDIStatusType.programChange {
                    self.receivedMIDIProgramChange(event.data[1], channel: channel)
                }

                if event.status?.type == AKMIDIStatusType.controllerChange {
                    self.receivedMIDIController(event.data[2], value: event.data[2], channel: channel)
                }
            }
        }
        Audiobus.client?.controller.addMIDIReceiverPort(midiInput)
        Audiobus.client?.controller.stateIODelegate = self
    }

    // MARK: - AudioBus Preset Delegate

    public func audiobusStateDictionaryForCurrentState() -> [AnyHashable: Any]! {
        return [ "preset": activePreset.position]
    }

    public func loadState(fromAudiobusStateDictionary dictionary: [AnyHashable: Any]!,
                          responseMessage outResponseMessage: AutoreleasingUnsafeMutablePointer<NSString?>!) {

        if let abDictionary = dictionary as? [String: Any] {
            activePreset.position = abDictionary["preset"] as? Int ?? 0
            DispatchQueue.main.async {
                self.presetsViewController.didSelectPreset(index: self.activePreset.position)
            }
        }
    }
}
