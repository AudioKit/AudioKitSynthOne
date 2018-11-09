//
//  Audiobus.swift
//  AudioKit
//
//  Created by Daniel Clelland, revision history on Githbub.
//  Updated for AudioKit by Aurelius Prochazka.
//
//  Copyright © 2018 AudioKit. All rights reserved.
//

import Foundation
import AudioKit
import CoreAudio

class Audiobus {

    // MARK: Client
    static var client: Audiobus?

    // MARK: Actions
    static func start() {
        guard client == nil else {
            return
        }
        client = Audiobus(apiKey: Private.AudioBusAPIKey)
    }

    // MARK: Initialization

    var controller: ABAudiobusController

    // swiftlint:disable force_unwrapping
    var audioUnit: AudioUnit {
        return AudioKit.engine.outputNode.audioUnit!
    }
    // swiftlint:enable force_unwrapping

    init(apiKey: String) {
        self.controller = ABAudiobusController(apiKey: apiKey)

        var myDict: NSDictionary?
        if let path = Bundle.main.path(forResource: "Info", ofType: "plist") {
            myDict = NSDictionary(contentsOfFile: path)
        }
        if let dict = myDict {
            guard let componentDictionary = dict["AudioComponents"] as? [[String: AnyObject]] else {
                AKLog("AudioComponents is not set up correctly in your app's Info tab")
                return
            }
            for component in  componentDictionary {
                guard let typeString = component["type"] as? String,
                    let subtypeString = component["subtype"] as? String,
                    let name = component["name"] as? String,
                    let manufacturerString = component["manufacturer"] as? String else {
                        AKLog("AudioComponents is not set up correctly in your app's Info tab")
                        return
                }
                let type = fourCC(typeString)
                let subtype = fourCC(subtypeString)
                let manufacturer = fourCC(manufacturerString)

                if type == kAudioUnitType_RemoteInstrument ||
                    type == kAudioUnitType_RemoteGenerator {
                    self.controller.addAudioSenderPort(
                        ABAudioSenderPort(
                            name: name,
                            title: name,
                            audioComponentDescription: AudioComponentDescription(
                                componentType: type,
                                componentSubType: subtype,
                                componentManufacturer: manufacturer,
                                componentFlags: 0,
                                componentFlagsMask: 0
                            ),
                            audioUnit: audioUnit
                        )
                    )
                }
                if type == kAudioUnitType_RemoteEffect {
                    self.controller.addAudioFilterPort(
                        ABAudioFilterPort(
                            name: name,
                            title: name,
                            audioComponentDescription: AudioComponentDescription(
                                componentType: type,
                                componentSubType: subtype,
                                componentManufacturer: manufacturer,
                                componentFlags: 0,
                                componentFlagsMask: 0
                            ),
                            audioUnit: audioUnit
                        )
                    )
                }
            }
        }

        startObservingInterAppAudioConnections()
        startObservingAudiobusConnections()

        controller.enableReceivingCoreMIDIBlock = { _ in return }
    }

    deinit {
        stopObservingInterAppAudioConnections()
        stopObservingAudiobusConnections()
    }

    // MARK: Properties

    var isConnected: Bool {
        return controller.isConnectedToAudiobus || audioUnit.isConnectedToInterAppAudio
    }

    var isConnectedToInput: Bool {
        return controller.isConnectedToAudiobus(portOfType: ABPortTypeAudioSender) ||
            audioUnit.isConnectedToInterAppAudio(nodeOfType: kAudioUnitType_RemoteEffect)
    }

    // MARK: Connections

    private var audioUnitPropertyListener: AudioUnitPropertyListener = AudioUnitPropertyListener { (_, _) in
        // DO NOTHING
    }

    private func startObservingInterAppAudioConnections() {
        audioUnitPropertyListener = AudioUnitPropertyListener { (_, _) in
            self.updateConnections()
        }

        try! audioUnit.add(listener: audioUnitPropertyListener, toProperty: kAudioUnitProperty_IsInterAppConnected)
    }

    private func stopObservingInterAppAudioConnections() {
        audioUnit.remove(listener: self.audioUnitPropertyListener, fromProperty: kAudioUnitProperty_IsInterAppConnected)
    }

    private func startObservingAudiobusConnections() {
        _ = NotificationCenter.default.addObserver(forName: NSNotification.Name.ABConnectionsChanged,
                                                   object: nil,
                                                   queue: nil,
                                                   using: { _ in self.updateConnections() })
    }

    private func stopObservingAudiobusConnections() {
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.ABConnectionsChanged, object: nil)
    }

    private func updateConnections() {
        if isConnected {
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: "IAAConnected"), object: nil)
        } else {
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: "IAADisconnected"), object: nil)
        }
    }

}

private extension ABAudiobusController {

    var isConnectedToAudiobus: Bool {
        return connected && memberOfActiveAudiobusSession
    }

    func isConnectedToAudiobus(portOfType type: ABPortType) -> Bool {
        guard connectedPorts != nil else {
            return false
        }

        return connectedPorts.compactMap { $0 as? ABPort }.filter { $0.type == type }.isEmpty == false
    }

}

private extension AudioUnit {

    var isConnectedToInterAppAudio: Bool {
        let value: UInt32 = try! getValue(forProperty: kAudioUnitProperty_IsInterAppConnected)
        return value != 0
    }

    func isConnectedToInterAppAudio(nodeOfType type: OSType) -> Bool {
        let value: AudioComponentDescription = try! getValue(forProperty: kAudioOutputUnitProperty_NodeComponentDescription)
        return value.componentType == type
    }

}
