//
//  TouchPadPanelController.swift
//  AudioKitSynthOne
//
//  Created by AudioKit Contributors on 7/25/17.
//  Copyright © 2017 AudioKit. All rights reserved.
//

import UIKit

class TouchPadPanelController: PanelController {

    @IBOutlet weak var touchPad1: AKTouchPadView!
    @IBOutlet weak var touchPad2: AKTouchPadView!

    @IBOutlet weak var touchPad1Label: UILabel!
    @IBOutlet weak var snapToggle: SynthButton!

    let particleEmitter1 = CAEmitterLayer()
    let particleEmitter2 = CAEmitterLayer()

    var cutoff: Double = 0.0
    var rez: Double = 0.0
    var lfoRate: Double = 0.0
    var lfoAmp: Double = 0.0

    override func viewDidLoad() {
        super.viewDidLoad()

        guard let s = conductor.synth else { return }

        currentPanel = .touchPad
        snapToggle.value = 1

        // TouchPad 1
        touchPad1.horizontalRange = 0...1
        touchPad1.horizontalTaper = 1
        lfoRate = s.getDependentParameter(.lfo1Rate)
        lfoAmp = s.getSynthParameter(.lfo1Amplitude)

        // TouchPad 2
        touchPad2.horizontalRange = s.getRange(.cutoff)
        touchPad2.horizontalTaper = 4.04
        cutoff = s.getSynthParameter(.cutoff)
        rez = s.getSynthParameter(.resonance)
        let pad2X = cutoff.normalized(from: touchPad2.horizontalRange, taper: touchPad2.horizontalTaper)

        setupCallbacks()

        touchPad1.resetToPosition(lfoRate, lfoAmp)
        touchPad2.resetToPosition(pad2X, rez)

		// Sets the read order for VoiceOver
		view.accessibilityElements = [
			touchPad1 as Any,
			snapToggle as Any,
			touchPad2 as Any,
			leftNavButton as Any,
			rightNavButton as Any
		]
    }

    public override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        // super's updateAllUI call is causing race conditions in updating UI in this class
        //conductor.updateAllUI()
       
    }

    // MARK: - Touch Pad Callbacks

    func setupCallbacks() {
        let c = conductor
        guard let s = c.synth else { return }

        touchPad1.callback = { horizontal, vertical, touchesBegan in
            self.particleEmitter1.emitterPosition = CGPoint(x: (self.touchPad1.bounds.width / 2),
                                                            y: self.touchPad1.bounds.height / 2)

            if touchesBegan {
                // record values before touched
                self.lfoRate = s.getDependentParameter(.lfo1Rate)
                self.lfoAmp = s.getSynthParameter(.lfo1Amplitude)

                // start particles
                self.particleEmitter1.birthRate = 1
            }

            s.setDependentParameter(.lfo1Rate, horizontal, c.lfo1RateTouchPadID)
            s.setSynthParameter(.lfo1Amplitude, vertical)
            c.updateSingleUI(.lfo1Amplitude, control: nil, value: vertical)
        }

        touchPad1.completionHandler = { horizontal, vertical, touchesEnded, reset in
            if touchesEnded {
                self.particleEmitter1.birthRate = 0
            }

            if self.snapToggle.isOn && touchesEnded && !reset {
                self.resetTouchPad1()
            }
            c.updateSingleUI(.lfo1Amplitude, control: nil, value: s.getSynthParameter(.lfo1Amplitude))
        }

        touchPad2.callback = { horizontal, vertical, touchesBegan in
            self.particleEmitter2.emitterPosition = CGPoint(x: (self.touchPad2.bounds.width / 2),
                                                            y: self.touchPad2.bounds.height / 2)

            // Particle Position
            if touchesBegan {
                // record values before touched
                self.cutoff = s.getSynthParameter(.cutoff)
                self.rez = s.getSynthParameter(.resonance)
                self.particleEmitter2.birthRate = 1
            }

            let minimumResonance = self.conductor.synth.getMinimum(.resonance)
            let maximumResonance = self.conductor.synth.getMaximum(.resonance)
            let scaledVertical = vertical.denormalized(to: minimumResonance...maximumResonance)

            // Affect parameters based on touch position
            s.setSynthParameter(.cutoff, horizontal)
            c.updateSingleUI(.cutoff, control: nil, value: horizontal)
            s.setSynthParameter(.resonance, scaledVertical )
            c.updateSingleUI(.resonance, control: nil, value: scaledVertical)
        }

        touchPad2.completionHandler = { horizontal, vertical, touchesEnded, reset in
            if touchesEnded {
                self.particleEmitter2.birthRate = 0
            }

            if self.snapToggle.isOn && touchesEnded && !reset {
               self.resetTouchPad2()
            }

            c.updateSingleUI(.cutoff, control: nil, value: s.getSynthParameter(.cutoff))
            c.updateSingleUI(.resonance, control: nil, value: s.getSynthParameter(.resonance))
        }

        createParticles()
    }

    // MARK: - Reset Touch Pads

    func resetTouchPad1() {
        conductor.synth.setDependentParameter(.lfo1Rate, lfoRate, conductor.lfo1RateTouchPadID)
        conductor.synth.setSynthParameter(.lfo1Amplitude, lfoAmp)
        touchPad1.resetToPosition(lfoRate, lfoAmp)
    }

    func resetTouchPad2() {
        conductor.synth.setSynthParameter(.cutoff, cutoff)
        conductor.synth.setSynthParameter(.resonance, rez)
        let x = cutoff.normalized(from: touchPad2.horizontalRange, taper: touchPad2.horizontalTaper)
        touchPad2.resetToPosition(x, rez)
    }

    // MARK: - Update UI

    override func updateUI(_ parameter: S1Parameter, control inputControl: S1Control?, value: Double) {

        // Update TouchPad positions if corresponding knobs are turned
        switch parameter {

        case .lfo1Amplitude:
            touchPad1.updateTouchPoint(Double(conductor.synth.getDependentParameter(.lfo1Rate)), value)

        case .cutoff:
            let x = value.normalized(from: touchPad2.horizontalRange, taper: touchPad2.horizontalTaper)
            touchPad2.updateTouchPoint(x, Double(touchPad2.y))

        case .resonance:
            let minimumResonance = self.conductor.synth.getMinimum(.resonance)
            let maximumResonance = self.conductor.synth.getMaximum(.resonance)
            let scaledY = value.normalized(from: minimumResonance...maximumResonance)
            touchPad2.updateTouchPoint(Double(touchPad2.x), scaledY)

        default:
            _ = 0
        }
    }

    func dependentParameterDidChange(_ dependentParameter: DependentParameter) {
        if dependentParameter.payload == conductor.lfo1RateTouchPadID {
            return
        }
        switch dependentParameter.parameter {
        case .lfo1Rate:
            let val = Double(dependentParameter.normalizedValue)
            touchPad1.updateTouchPoint(val, Double(conductor.synth.getSynthParameter(.lfo1Amplitude)))
        default:
            _ = 0
        }
    }

    // MARK: - Particles

    func createParticles() {
        particleEmitter1.frame = touchPad1.bounds
        particleEmitter1.renderMode = CAEmitterLayerRenderMode.additive
        particleEmitter1.emitterPosition = CGPoint(x: -400, y: -400)

        particleEmitter2.frame = touchPad2.bounds
        particleEmitter2.renderMode = CAEmitterLayerRenderMode.additive
        particleEmitter2.emitterPosition = CGPoint(x: -400, y: -400)

        let particleCell = makeEmitterCellWithColor(#colorLiteral(red: 0.9019607843, green: 0.5333333333, blue: 0.007843137255, alpha: 1))

        particleEmitter1.emitterCells = [particleCell]
        particleEmitter2.emitterCells = [particleCell]
        touchPad1.layer.addSublayer(particleEmitter1)
        touchPad2.layer.addSublayer(particleEmitter2)
    }

    func makeEmitterCellWithColor(_ color: UIColor) -> CAEmitterCell {
        let cell = CAEmitterCell()
        cell.birthRate = 80
        cell.lifetime = 1.70
        cell.alphaSpeed = 1.0
        cell.lifetimeRange = 0
        cell.color = color.cgColor
        cell.velocity = 190
        cell.velocityRange = 60
        cell.emissionRange = CGFloat(Double.pi) * 2.0
        cell.spin = 15
        cell.spinRange = 3
        cell.scale = 0.05
        cell.scaleRange = 0.1
        cell.scaleSpeed = 0.15

        cell.contents = #imageLiteral(resourceName: "spark").cgImage
        return cell
    }
}
