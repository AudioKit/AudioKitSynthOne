//
//  MIDIKnob.swift
//  RomPlayer
//
//  Created by Matthew Fecher on 10/18/17.
//  Copyright © 2017 Matthew Fecher. All rights reserved.
//

import AudioKit

@IBDesignable
public class MIDIKnob: Knob, MIDILearnable {
    
    var midiLearnCallback: ()->Void = { }
    var hotspotView = UIView()
    
    var isActive = false {
        didSet {
            // toggle the border color if a user touches knob
            hotspotView.layer.borderColor = isActive ? #colorLiteral(red: 0.4549019608, green: 0.6235294118, blue: 0.7254901961, alpha: 1) : #colorLiteral(red: 0.2431372549, green: 0.2431372549, blue: 0.262745098, alpha: 1)
        }
    }
    
    var midiCC: MIDIByte = 255 {
        didSet {
           // toggle color of assigned knobs
           hotspotView.backgroundColor = (midiCC == 255) ? #colorLiteral(red: 0.8705882353, green: 0.9098039216, blue: 0.9176470588, alpha: 0.1977002641) : #colorLiteral(red: 0.8705882353, green: 0.9098039216, blue: 0.9176470588, alpha: 0.5)
        }
    }
    
    var midiLearnMode = false {
        didSet {
            if midiLearnMode {
                addHotspot()
            } else {
                removeHotspot()
                isActive = false
            }
        }
    }
    
    // **********************************************************
    // MIDIKnob
    // **********************************************************
    
    override public func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        
        if midiLearnMode {
            isActive = !isActive // Toggles knob to be active & ready to receive CC
            
            // Callback to update display label in AUMainController
            // MIDIKnob does not require a callback to work
            if isActive { midiLearnCallback() }
        }
        
    }
    
    // **********************************************************
    // UI Helper
    // **********************************************************
    
    func addHotspot() {
        hotspotView = UIView(frame: CGRect(x: 0, y: 0, width: self.bounds.width, height: self.bounds.height))
        hotspotView.backgroundColor = (midiCC == 255) ? #colorLiteral(red: 0.8705882353, green: 0.9098039216, blue: 0.9176470588, alpha: 0.1977002641) : #colorLiteral(red: 0.8705882353, green: 0.9098039216, blue: 0.9176470588, alpha: 0.5)
        hotspotView.layer.borderColor = #colorLiteral(red: 0.2431372549, green: 0.2431372549, blue: 0.262745098, alpha: 1)
        hotspotView.layer.borderWidth = 2
        hotspotView.layer.cornerRadius = 10
        self.addSubview(hotspotView)
    }
    
    func removeHotspot() {
        hotspotView.removeFromSuperview()
    }
    
    // **********************************************************
    // Helper Function
    // **********************************************************
    
    // Linear Scale MIDI 0...127 to 0.0...1.0
    func setKnobValueFrom(midiValue: MIDIByte) {
        knobValue = CGFloat(Double.scaleRangeZeroToOne(Double(midiValue), rangeMin: 0, rangeMax: 127))
    }
    
}

