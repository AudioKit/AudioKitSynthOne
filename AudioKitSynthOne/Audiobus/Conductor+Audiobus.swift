//
//  Conductor+Audiobus.swift
//  AudioKitSynthOne
//
//  Created by Matthias Frick on 26/10/2019.
//  Copyright © 2019 AudioKit. All rights reserved.
//

import Foundation

extension Conductor {

  func setupAudioBusInput() {
        midiInput = ABMIDIReceiverPort(name: "AudioKit Synth One MIDI",
                                       title: "AudioKit Synth One MIDI") { (_, midiPacketListPointer)  in

            let events = AKMIDIEvent.midiEventsFrom(packetListPointer: midiPacketListPointer)
            for event in events {
                guard let channel = event.channel, event.channel == self.midiInChannel || self.isOmniMode else { return }

                if event.status?.type == AKMIDIStatusType.noteOn {
                    guard let noteNumber = event.noteNumber else { return }
                    if event.data[2] == 0 {
                        self.sustainer.stop(noteNumber: noteNumber)
                    } else {
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
                    self.audioBusMidiDelegate?.receivedMIDIPitchWheel(y + x, channel: channel)
                }

                if event.status?.type == AKMIDIStatusType.programChange {
                    self.audioBusMidiDelegate?.receivedMIDIProgramChange(event.data[1], channel: channel)
                }

                if event.status?.type == AKMIDIStatusType.controllerChange {
                    self.audioBusMidiDelegate?.receivedMIDIController(event.data[2], value: event.data[2], channel: channel)
                }
            }
        }
        Audiobus.client?.controller.addMIDIReceiverPort(midiInput)
    }
}
