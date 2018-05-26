//
//  Parent+ModWheelDelegate.swift
//  AudioKitSynthOne
//
//  Created by Aurelius Prochazka on 5/25/18.
//  Copyright © 2018 AudioKit. All rights reserved.
//

// Mod Wheel Settings Pop Over Delegate

extension ParentViewController: ModWheelDelegate {

    func didSelectRouting(newDestination: Int) {
        activePreset.modWheelRouting = Double(newDestination)
       guard let s = conductor.synth else { return }

        switch activePreset.modWheelRouting {
        case 0:
            // Cutoff
            conductor.updateSingleUI(.cutoff, control: nil, value: s.getAK1Parameter(.cutoff))
        case 1:
            // LFO 1 Rate
            modWheelPad.setVerticalValue01(Double(s.getAK1DependentParameter(.lfo1Rate)))
        case 2:
            // LFO 2 Rate
            modWheelPad.setVerticalValue01(Double(s.getAK1DependentParameter(.lfo2Rate)))
        default:
            break
        }

    }
}
