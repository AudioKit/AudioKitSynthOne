//
//  MIDISynthButton.swift
//  AudioKitSynthOne
//
//  Created by Marcus W. Hobbs on 3/31/19.
//  Copyright © 2019 AudioKit. All rights reserved.
//

class MIDISynthButton: SynthButton, MIDILearnable {
    
    let conductor = Conductor.sharedInstance

    override public func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        if midiLearnMode {
            isActive = !isActive
            updateDisplayLabel()
        }
    }

    //MARK: - MIDILearnable

    var midiByteRange: ClosedRange<MIDIByte> = 0...127

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
                showHotspot()
            } else {
                hideHotspot()
                isActive = false
            }
        }
    }

    func addHotspot() {
        hotspotView = UIView(frame: CGRect(x: 0, y: 0, width: self.bounds.width, height: self.bounds.height))
        hotspotView.backgroundColor = (midiCC == 255) ? #colorLiteral(red: 0.8705882353, green: 0.9098039216, blue: 0.9176470588, alpha: 0.1977002641) : #colorLiteral(red: 0.8705882353, green: 0.9098039216, blue: 0.9176470588, alpha: 0.5)
        hotspotView.layer.borderColor = #colorLiteral(red: 0.2431372549, green: 0.2431372549, blue: 0.262745098, alpha: 1)
        hotspotView.layer.borderWidth = 2
        hotspotView.layer.cornerRadius = 10
        hotspotView.isHidden = true
        addSubview(hotspotView)
    }

    func hideHotspot() {
        hotspotView.isHidden = true
    }

    func showHotspot() {
        hotspotView.isHidden = false
    }

    func setControlValueFrom(midiValue: MIDIByte) {
        let min = Double(midiByteRange.lowerBound)
        let max = Double(midiByteRange.upperBound)
        let v = Double(midiValue).normalized(from: min...max)
        let previousValue = value
        value = v < 0.5 ? 0 : 1
        if previousValue != value {
            callback(value)
            setNeedsDisplay()
        }
    }
    
    func updateDisplayLabel() {
        if isActive {
            let message = NSLocalizedString("Twist knob on your MIDI Controller", comment: "MIDI Learn Instructions")
            conductor.updateDisplayLabel(message)
        }
    }
    
}
