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
    var oscBalance: Double = 0.0
    var detuningMultiplier: Double = 1.0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        touchPad1.verticalRange = 0.5 ... 2
        touchPad1.verticalTaper = log(3) / log(2)
        
        touchPad2.verticalRange = 120 ... 28000
        touchPad2.verticalTaper = 4.04
        
        // snapToggle.isSelected = true
        
        updateCallbacks()
        createParticles()
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        
        oscBalance = conductor.synth.parameters[AKSynthOneParameter.morphBalance.rawValue]
        touchPad1.resetToPosition(oscBalance, 0.5)
        
        rez = conductor.synth.parameters[AKSynthOneParameter.resonance.rawValue]
        cutoff = conductor.synth.parameters[AKSynthOneParameter.cutoff.rawValue]
        
        let y = cutoff.normalized(from: touchPad2.verticalRange,
                                  taper: touchPad2.verticalTaper)
        touchPad2.resetToPosition(rez, y)
    }
    
    override func updateCallbacks() {
        
        snapToggle.callback = { value in
            if value == 1 {
               // Snapback TouchPad1
               self.resetTouchPad1()
            }
        }
        
        touchPad1.callback = { horizontal, vertical, touchesBegan in
            if touchesBegan {
                // record values before touched
                self.oscBalance = self.conductor.synth.parameters[AKSynthOneParameter.morphBalance.rawValue]
                
                // start particles
                self.particleEmitter1.emitterPosition = CGPoint(x: (self.touchPad1.bounds.width * CGFloat(horizontal)), y: self.touchPad2.bounds.height/2)
                self.particleEmitter1.birthRate = 1
                // self.touchPad1Label.textColor = #colorLiteral(red: 0.8549019608, green: 0.8549019608, blue: 0.8549019608, alpha: 1)
            }
            
            // Affect parameters based on touch position
            self.conductor.synth.parameters[AKSynthOneParameter.morphBalance.rawValue] = horizontal
            self.conductor.synth.parameters[AKSynthOneParameter.detuningMultiplier.rawValue] = vertical
        }
        
        touchPad1.completionHandler = { horizontal, vertical, touchesEnded, reset in
            
            if touchesEnded {
                self.particleEmitter1.birthRate = 0
                self.touchPad1Label.textColor = #colorLiteral(red: 0.3058823529, green: 0.3058823529, blue: 0.3254901961, alpha: 0)
            }
            
            if self.snapToggle.isOn && touchesEnded && !reset {
                self.resetTouchPad1()
            }
            
        }
        
        touchPad2.callback = { horizontal, vertical, touchesBegan in
            if touchesBegan {
                // record values before touched
                self.rez = self.conductor.synth.parameters[AKSynthOneParameter.resonance.rawValue]
                self.cutoff = self.conductor.synth.parameters[AKSynthOneParameter.cutoff.rawValue]
                
                // start particles
                let y = CGFloat(self.cutoff.normalized(from: self.touchPad2.verticalRange,
                                                       taper: self.touchPad2.verticalTaper))
                
                self.particleEmitter2.emitterPosition = CGPoint(x: (self.touchPad2.bounds.width * CGFloat(self.rez)) + self.touchPad2.bounds.minX, y: self.touchPad2.bounds.height * CGFloat(1-y))
                
                self.particleEmitter2.birthRate = 1
            }
            
            // Affect parameters based on touch position
            self.conductor.synth.parameters[AKSynthOneParameter.resonance.rawValue] = horizontal
            self.conductor.synth.parameters[AKSynthOneParameter.cutoff.rawValue] = vertical
        }
        
        touchPad2.completionHandler = { horizontal, vertical, touchesEnded, reset in
            
            if touchesEnded {
                self.particleEmitter2.birthRate = 0
            }
            
            if self.snapToggle.isOn && touchesEnded && !reset {
                self.conductor.synth.parameters[AKSynthOneParameter.resonance.rawValue] = self.rez
                self.conductor.synth.parameters[AKSynthOneParameter.cutoff.rawValue] = self.cutoff
                
                let y = self.cutoff.normalized(from: self.touchPad2.verticalRange,
                                               taper: self.touchPad2.verticalTaper)
                self.touchPad2.resetToPosition(self.rez, y)
           
            }
        }
    }
    
    func resetTouchPad1() {
        self.conductor.synth.parameters[AKSynthOneParameter.morphBalance.rawValue] = self.oscBalance
        self.conductor.synth.parameters[AKSynthOneParameter.detuningMultiplier.rawValue] = 1.0
        self.touchPad1.resetToPosition(self.oscBalance, 0.5)
    }
    
    override func updateUI(_ param: AKSynthOneParameter, value: Double) {
        
        switch param {
        case .detuningMultiplier:
            // detuningMultiplier = value
            break
        default:
            _ = 0
            // do nothin
        }
        
        updateLabels()
    }
    
    func updateLabels() {
        // touchPad1Label.text = "Bend: \(detuningMultiplier.decimalString)x octave"
        
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
