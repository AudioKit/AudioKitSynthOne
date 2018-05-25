//
//  TouchPadViewController.swift
//  AudioKitSynthOne
//
//  Created by Matthew Fecher on 7/25/17.
//  Copyright © 2017 AudioKit. All rights reserved.
//

import UIKit

class TouchPadViewController: SynthPanelController {

    @IBOutlet weak var touchPad1: AKTouchPadView!
    @IBOutlet weak var touchPad2: AKTouchPadView!

    @IBOutlet weak var touchPad1Label: UILabel!
    @IBOutlet weak var snapToggle: SynthUIButton!

    let particleEmitter1 = CAEmitterLayer()
    let particleEmitter2 = CAEmitterLayer()

    var cutoff: Double = 0.0
    var rez: Double = 0.0
    var lfoRate: Double = 0.0
    var lfoAmp: Double = 0.0

    override func viewDidLoad() {
        super.viewDidLoad()

        let s = conductor.synth!

        viewType = .padView
        snapToggle.value = 1

        // TouchPad 1
        touchPad1.horizontalRange = 0...1
        touchPad1.horizontalTaper = 1
        lfoRate = s.getAK1DependentParameter(.lfo1Rate)
        lfoAmp = s.getAK1Parameter(.lfo1Amplitude)

        // TouchPad 2
        touchPad2.horizontalRange = s.getParameterRange(.cutoff)
        touchPad2.horizontalTaper = 4.04
        cutoff = s.getAK1Parameter(.cutoff)
        rez = s.getAK1Parameter(.resonance)
        let pad2X = cutoff.normalized(from: touchPad2.horizontalRange, taper: touchPad2.horizontalTaper)

        setupCallbacks()

        touchPad1.resetToPosition(lfoRate, lfoAmp)
        touchPad2.resetToPosition(pad2X, rez)
    }

    public override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        // super's updateAllUI call is causing race conditions in updating UI in this class
        //conductor.updateAllUI()
    }

    // *********************************************************
    // MARK: - Touch Pad Callbacks
    // *********************************************************

    func setupCallbacks() {
        let c = conductor
        let s = c.synth!

        touchPad1.callback = { horizontal, vertical, touchesBegan in
            self.particleEmitter1.emitterPosition = CGPoint(x: (self.touchPad1.bounds.width/2), y: self.touchPad1.bounds.height/2)

            if touchesBegan {
                // record values before touched
                self.lfoRate = s.getAK1DependentParameter(.lfo1Rate)
                self.lfoAmp = s.getAK1Parameter(.lfo1Amplitude)

                // start particles
                self.particleEmitter1.birthRate = 1
            }

            s.setAK1DependentParameter(.lfo1Rate, horizontal, c.lfo1RateTouchPadID)
            s.setAK1Parameter(.lfo1Amplitude, vertical)
            c.updateSingleUI(.lfo1Amplitude, control: nil, value: vertical)
        }

        touchPad1.completionHandler = { horizontal, vertical, touchesEnded, reset in
            if touchesEnded {
                self.particleEmitter1.birthRate = 0
            }

            if self.snapToggle.isOn && touchesEnded && !reset {
                self.resetTouchPad1()
            }
            c.updateSingleUI(.lfo1Amplitude, control: nil, value: s.getAK1Parameter(.lfo1Amplitude))
        }

        touchPad2.callback = { horizontal, vertical, touchesBegan in
            self.particleEmitter2.emitterPosition = CGPoint(x: (self.touchPad2.bounds.width/2), y: self.touchPad2.bounds.height/2)

            // Particle Position
            if touchesBegan {
                // record values before touched
                self.cutoff = s.getAK1Parameter(.cutoff)
                self.rez = s.getAK1Parameter(.resonance)
                self.particleEmitter2.birthRate = 1
            }

            let scaledVertical = Double.scaleRange(vertical,
                                                   rangeMin: self.conductor.synth.getParameterMin(.resonance),
                                                   rangeMax: self.conductor.synth.getParameterMax(.resonance))

            // Affect parameters based on touch position
            s.setAK1Parameter(.cutoff, horizontal)
            c.updateSingleUI(.cutoff, control: nil, value: horizontal)
            s.setAK1Parameter(.resonance, scaledVertical )
            c.updateSingleUI(.resonance, control: nil, value: scaledVertical)
        }

        touchPad2.completionHandler = { horizontal, vertical, touchesEnded, reset in
            if touchesEnded {
                self.particleEmitter2.birthRate = 0
            }

            if self.snapToggle.isOn && touchesEnded && !reset {
               self.resetTouchPad2()
            }

            c.updateSingleUI(.cutoff, control: nil, value: s.getAK1Parameter(.cutoff))
            c.updateSingleUI(.resonance, control: nil, value: s.getAK1Parameter(.resonance))
        }

        createParticles()
    }

    // *********************************************************
    // MARK: - Reset Touch Pads
    // *********************************************************

    func resetTouchPad1() {
        conductor.synth.setAK1DependentParameter(.lfo1Rate, lfoRate, conductor.lfo1RateTouchPadID)
        conductor.synth.setAK1Parameter(.lfo1Amplitude, lfoAmp)
        touchPad1.resetToPosition(lfoRate, lfoAmp)
    }

    func resetTouchPad2() {
        conductor.synth.setAK1Parameter(.cutoff, cutoff)
        conductor.synth.setAK1Parameter(.resonance, rez)
        let x = cutoff.normalized(from: touchPad2.horizontalRange, taper: touchPad2.horizontalTaper)
        touchPad2.resetToPosition(x, rez)
    }

    // *********************************************************
    // MARK: - Update UI
    // *********************************************************

    override func updateUI(_ param: AKSynthOneParameter, control inputControl: AKSynthOneControl?, value: Double) {

        // Update TouchPad positions if corresponding knobs are turned
        switch param {

        case .lfo1Amplitude:
            touchPad1.updateTouchPoint(Double(conductor.synth.getAK1DependentParameter(.lfo1Rate)), value)

        case .cutoff:
            let x = value.normalized(from: touchPad2.horizontalRange, taper: touchPad2.horizontalTaper)
            touchPad2.updateTouchPoint(x, Double(touchPad2.y))

        case .resonance:
            let scaledY = Double.scaleRangeZeroToOne(value,
                                                     rangeMin: conductor.synth.getParameterMin(.resonance),
                                                     rangeMax: conductor.synth.getParameterMax(.resonance))
            touchPad2.updateTouchPoint(Double(touchPad2.x), scaledY)

        default:
            _ = 0
        }
    }

    func dependentParamDidChange(_ param: DependentParam) {
        if param.payload == conductor.lfo1RateTouchPadID {
            return
        }
        switch param.param {
        case .lfo1Rate:
            let val = Double(param.value01)
            touchPad1.updateTouchPoint(val, Double(conductor.synth.getAK1Parameter(.lfo1Amplitude)))
        default:
            _ = 0
        }
    }

    // *********************************************************
    // MARK: - Particles
    // *********************************************************

    func createParticles() {
        particleEmitter1.frame = touchPad1.bounds
        particleEmitter1.renderMode = kCAEmitterLayerAdditive
        particleEmitter1.emitterPosition = CGPoint(x: -400, y: -400)

        particleEmitter2.frame = touchPad2.bounds
        particleEmitter2.renderMode = kCAEmitterLayerAdditive
        particleEmitter2.emitterPosition = CGPoint(x: -400, y: -400)

        let particleCell = makeEmitterCellWithColor(UIColor(red: 230/255, green: 136/255, blue: 2/255, alpha: 1.0))

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

        cell.contents = UIImage(named: "spark")?.cgImage
        return cell
    }
}
