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
        
        let c = Conductor.sharedInstance
        let s = c.synth!
        
        viewType = .padView
        snapToggle.value = 1
        
        // TouchPad 1
        touchPad1.horizontalRange = 0...20.0
        touchPad1.horizontalTaper = 4
        
        lfoRate = s.getAK1Parameter(.lfo1Rate)
        lfoAmp = s.getAK1Parameter(.lfo1Amplitude)
        let pad1X = cutoff.normalized(from: touchPad1.horizontalRange, taper: touchPad1.horizontalTaper)
        touchPad1.resetToPosition(pad1X, lfoAmp)
        
        // TouchPad 2
        touchPad2.horizontalRange = s.getParameterRange(.cutoff)
        touchPad2.horizontalTaper = 4.04
        
        cutoff = s.getAK1Parameter(.cutoff)
        rez = s.getAK1Parameter(.resonance)
        let pad2X = cutoff.normalized(from: touchPad2.horizontalRange, taper: touchPad2.horizontalTaper)
        touchPad2.resetToPosition(pad2X, rez)
        
        // bindings
        snapToggle.callback = { value in
            if value == 1 {
                // Snapback TouchPad1
                self.resetTouchPad1()
            }
        }
        
        touchPad1.callback = { horizontal, vertical, touchesBegan in
            
            self.particleEmitter1.emitterPosition = CGPoint(x: (self.touchPad1.bounds.width/2), y: self.touchPad1.bounds.height/2)
            
            if touchesBegan {
                // record values before touched
                self.lfoAmp = s.getAK1Parameter(.lfo1Amplitude)
                self.lfoRate = s.getAK1Parameter(.lfo1Rate)
                
                // start particles
                self.particleEmitter1.birthRate = 1
            }
            
            // Affect parameters based on touch position
            s.setAK1Parameter(.lfo1Rate, horizontal)
            c.updateSingleUI(.lfo1Rate, control: nil, value: horizontal)
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
            
            c.updateAllUI()
        }
        
        
        touchPad2.callback = { horizontal, vertical, touchesBegan in
            
            self.particleEmitter2.emitterPosition = CGPoint(x: (self.touchPad2.bounds.width/2), y: self.touchPad2.bounds.height/2)
            
            // Particle Position
//            let x = CGFloat(self.cutoff.normalized(from: self.touchPad2.horizontalRange, taper: self.touchPad2.horizontalTaper))
//            self.particleEmitter2.emitterPosition = CGPoint(x: (self.touchPad2.bounds.width * CGFloat(x)) + self.touchPad2.bounds.minX, y: self.touchPad2.bounds.height * CGFloat(1-self.rez))
            
            if touchesBegan {
                // record values before touched
                self.cutoff = s.getAK1Parameter(.cutoff)
                self.rez = s.getAK1Parameter(.resonance)
                self.particleEmitter2.birthRate = 1
            }
            
            // Affect parameters based on touch position
            s.setAK1Parameter(.cutoff, horizontal)
            c.updateSingleUI(.cutoff, control: nil, value: horizontal)
            s.setAK1Parameter(.resonance, vertical)
            c.updateSingleUI(.resonance, control: nil, value: vertical)
        }
        
        
        touchPad2.completionHandler = { horizontal, vertical, touchesEnded, reset in
            if touchesEnded {
                self.particleEmitter2.birthRate = 0
            }
            
            if self.snapToggle.isOn && touchesEnded && !reset {
               self.resetTouchPad2()
            }
            
            c.updateAllUI()
        }
        
        createParticles()
    }
    
    override func updateUI(_ param: AKSynthOneParameter, control inputControl: AKSynthOneControl?, value: Double) {
        
        // Update TouchPad positions if corresponding knobs are turned
        switch param {
            
        case .lfo1Rate:
            let x = value.normalized(from: self.touchPad1.horizontalRange,
                                     taper: self.touchPad1.horizontalTaper)
            self.touchPad1.updateTouchPoint(x, Double(self.touchPad1.y))
        
        case .lfo1Amplitude:
            self.touchPad1.updateTouchPoint(Double(self.touchPad1.x), value)
       
        case .cutoff:
            let x = value.normalized(from: self.touchPad2.horizontalRange,
                                     taper: self.touchPad2.horizontalTaper)
            self.touchPad2.updateTouchPoint(x, Double(self.touchPad2.y))
            
        case .resonance:
            self.touchPad2.updateTouchPoint(Double(self.touchPad2.x), value)
 
          
        default:
            _ = 0
            // do nothing
        }
        
    }
    
    func resetTouchPad1() {
        self.conductor.synth.setAK1Parameter(.lfo1Rate, self.lfoRate)
        self.conductor.synth.setAK1Parameter(.lfo1Amplitude, self.lfoAmp)
        let x = self.lfoRate.normalized(from: self.touchPad1.horizontalRange,
                                       taper: self.touchPad1.horizontalTaper)
        self.touchPad1.resetToPosition(x, self.lfoAmp)
    }
    
    func resetTouchPad2() {
        self.conductor.synth.setAK1Parameter(.cutoff, self.cutoff)
        self.conductor.synth.setAK1Parameter(.resonance, self.rez)
        let x = self.cutoff.normalized(from: self.touchPad2.horizontalRange,
                                               taper: self.touchPad2.horizontalTaper)
        self.touchPad2.resetToPosition(x, self.rez)
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
