//
//  LinkExtensions.swift
//  AudioKitSynthOne
//
//  Created by Aurelius Prochazka on 7/19/18.
//  Copyright © 2018 AudioKit. All rights reserved.
//

#if ABLETON_ENABLED_1

extension Manager {

    // Link
    override func setupLinkStuff() {

        // Link
        let freezeIt = ABLLinkManager.shared.isConnected || ABLLinkManager.shared.isEnabled
        linkButton.value = freezeIt ? 1 : 0
        appSettings.freezeArpRate = freezeIt

        // Subscribe activation events
        ABLLinkManager.shared.add(listener: .activation({ isActivated in
            AKLog("Link Activated =  \(isActivated)")
            self.appSettings.freezeArpRate = isActivated
            self.linkButton.value = isActivated ? 1 : 0
        }))

        // Link Listener
        ABLLinkManager.shared.add(listener: .connection({ isConnected in
            AKLog("Link Connected =  \(isConnected)")
            self.appSettings.freezeArpRate = isConnected
            self.linkButton.value = isConnected ? 1 : 0
        }))
    }
}


extension GeneratorsPanelController {

    // Link
    override func setupLinkStuff() {

        // Link changes the way the tempoStepper behaves
        tempoStepper.setValueCallback = { value in
            ABLLinkManager.shared.bpm = value
            ABLLinkManager.shared.update()
        }

        // Setup Link
        ABLLinkManager.shared.setup(bpm: tempoStepper.value, quantum: ABLLinkManager.QUANTUM_DEFAULT)

        // Subscribe to tempo change events
        ABLLinkManager.shared.add(listener: .tempo({ bpm, quantum in
            self.tempoStepper.value = bpm
            self.conductor.synth.setSynthParameter(.arpRate, bpm)
        }))
    }
}

extension DevViewController {

    // Link
    override func setupLinkStuff() {
        ABLLinkManager.shared.add(listener: .activation({ isActivated in
            self.freezeArpRate.value = isActivated ? 1 : 0
        }))
        ABLLinkManager.shared.add(listener: .connection({ isConnected in
            self.freezeArpRate.value = isConnected ? 1 : 0
        }))
    }
}
#endif
