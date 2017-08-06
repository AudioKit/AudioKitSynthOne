//
//  TouchPadViewController.swift
//  AudioKitSynthOne
//
//  Created by Matthew Fecher on 7/25/17.
//  Copyright © 2017 AudioKit. All rights reserved.
//

import UIKit

class TouchPadViewController: UpdatableViewController {
    
    @IBOutlet weak var touchPad1: AKTouchPadView!
    @IBOutlet weak var touchPad2: AKTouchPadView!
    
    @IBOutlet weak var touchPad1Label: UILabel!
    @IBOutlet weak var touchPad2Label: UILabel!
    
    let particleEmitter1 = CAEmitterLayer()
    let particleEmitter2 = CAEmitterLayer()
    
    var cutoff: Double = 0.0
    var rez: Double = 0.0
    var oscBalance: Double = 0.0
    var detuningMultiplier: Double = 0.0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        touchPad1.verticalRange = 0.5 ... 2
        touchPad1.verticalTaper = log(3) / log(2)
        
        touchPad2.verticalRange = 120 ... 28000
        touchPad2.verticalTaper = 4.04
        
        updateCallbacks()
        createParticles()
    }
  
    override func updateCallbacks() {
        touchPad1.callback = { horizontal, vertical in
            self.conductor.synth.parameters[AKSynthOneParameter.morphBalance.rawValue] = horizontal
            self.conductor.synth.parameters[AKSynthOneParameter.detuningMultiplier.rawValue] = vertical
            
            self.particleEmitter1.emitterPosition = CGPoint(x: (self.touchPad1.bounds.width * CGFloat(horizontal)), y: self.touchPad2.bounds.height/2)
            self.particleEmitter1.birthRate = 1
            self.touchPad1Label.textColor = #colorLiteral(red: 0.8549019608, green: 0.8549019608, blue: 0.8549019608, alpha: 1)
        }

        touchPad1.completionHandler = { horizontal, _, touchesEnded, reset in
            if touchesEnded && !reset {
                self.touchPad1.resetToPosition(self.oscBalance, 0.5)
                self.particleEmitter1.birthRate = 0
                self.touchPad1Label.textColor = #colorLiteral(red: 0.3058823529, green: 0.3058823529, blue: 0.3254901961, alpha: 1)
            }
        }

        touchPad2.callback = { horizontal, vertical in
            self.conductor.synth.parameters[AKSynthOneParameter.resonance.rawValue] = horizontal
            self.conductor.synth.parameters[AKSynthOneParameter.cutoff.rawValue] = vertical
            
            let y = CGFloat(vertical.normalized(range: self.touchPad2.verticalRange,
                                                taper: self.touchPad2.verticalTaper))
            self.particleEmitter2.emitterPosition = CGPoint(x: (self.touchPad2.bounds.width * CGFloat(horizontal)) + self.touchPad2.bounds.minX, y: self.touchPad2.bounds.height * CGFloat(1-y))
            
            self.particleEmitter2.birthRate = 1
            self.touchPad2Label.textColor = #colorLiteral(red: 0.8549019608, green: 0.8549019608, blue: 0.8549019608, alpha: 1)
        }

        touchPad2.completionHandler = { _, _, touchesEnded, _ in
            if touchesEnded {
                self.particleEmitter2.birthRate = 0
                self.touchPad2Label.textColor = #colorLiteral(red: 0.3058823529, green: 0.3058823529, blue: 0.3254901961, alpha: 1)
            }
        }
      
    }
    
    override func updateUI(_ param: AKSynthOneParameter, value: Double) {
        
        switch param {
        case .morphBalance:
            oscBalance = value
        case .detuningMultiplier:
            detuningMultiplier = value
        case .cutoff:
            cutoff = value
        case .resonance:
            rez = value
        default:
            _ = 0
            // do nothin
        }
        
        updateLabels()
    }
    
    func updateLabels() {
        touchPad1Label.text = "Pitch Bend: \(detuningMultiplier.decimalString), DCO Balance: \(oscBalance.decimalString)"
        touchPad2Label.text = "Cutoff: \(cutoff.decimalString) Hz, Rez: \(rez.decimalString)"
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
        cell.birthRate = 100
        cell.lifetime = 1.20
        cell.alphaSpeed = 1.0
        cell.lifetimeRange = 0
        cell.color = color.cgColor
        cell.velocity = 200
        cell.velocityRange = 50
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
