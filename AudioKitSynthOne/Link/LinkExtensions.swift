//
//  LinkExtensions.swift
//  AudioKitSynthOne
//
//  Created by Aurelius Prochazka on 7/19/18.
//  Copyright © 2018 AudioKit. All rights reserved.
//

#if ABLETON_ENABLED_1

extension Manager {
    override func setupLinkStuff() {
        let freezeIt = ABLLinkManager.shared.isConnected || ABLLinkManager.shared.isEnabled
        linkButton.value = freezeIt ? 1 : 0
        appSettings.freezeArpRate = freezeIt

        // Subscribe activation events
        ABLLinkManager.shared.add(listener: .activation({ isActivated in
            AKLog("Link Activated =  \(isActivated)")
            self.appSettings.freezeArpRate = isActivated
            self.linkButton.value = isActivated ? 1 : 0
        }))

        ABLLinkManager.shared.add(listener: .connection({ isConnected in
            AKLog("Link Connected =  \(isConnected)")
            self.appSettings.freezeArpRate = isConnected
            self.linkButton.value = isConnected ? 1 : 0
        }))
    }
}


extension GeneratorsPanelController {
    override func setupLinkStuff() {
        tempoStepper.callback = { value in
            ABLLinkManager.shared.bpm = value
            ABLLinkManager.shared.update()
        }

        // Setup Link
        ABLLinkManager.shared.setup(bpm: tempoStepper.value, quantum: ABLLinkManager.QUANTUM_DEFAULT)

        // Subscribe tempo change events
        ABLLinkManager.shared.add(listener: .tempo({ bpm, quantum in
            self.tempoStepper.value = bpm
            self.conductor.synth.setSynthParameter(.arpRate, bpm)
        }))
    }
}

extension DevViewController {
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
