//
//  KeyboardView.swift
//  AudioKitSynthOne
//
//  Created by AudioKit Contributors on 8/14/17.
//  Copyright © 2017 AudioKit. All rights reserved.
//

import AudioKit
import UIKit

/// Delegate for keyboard events
public protocol AKKeyboardDelegate: class {

    /// Note on evenets
    func noteOn(note: MIDINoteNumber, velocity: MIDIVelocity)
    
    /// Note off events
    func noteOff(note: MIDINoteNumber)
}

// MARK: -

// helper for microtonal drawing and touches
class MicrotonalBezierPath: UIBezierPath {

    var nn: MIDINoteNumber = 60
}

// MARK: -

/// Clickable keyboard mainly used for AudioKit playgrounds
@IBDesignable open class KeyboardView: UIView, AKMIDIListener {

    // MARK: - 12ET and Microtonal Properties

    /// 12ET + Microtonal: Number of octaves displayed at once
    @IBInspectable open var octaveCount: Int = 2 {
        
        didSet {
            DispatchQueue.main.async {
                self.setNeedsDisplay()
            }
        }
    }

    /// 12ET + Microtonal: Lowest octave dispayed
    @IBInspectable open var firstOctave: Int = 2 {

        didSet {
            DispatchQueue.main.async {
                self.setNeedsDisplay()
            }
        }
    }

    // 12ET + Microtonal: Key Labels: 0 = don't display, 1 = every C note, 2 = every note
    @IBInspectable open var  labelMode: Int = 2

    /// 12ET + Microtonal: Color of the polyphonic toggle button
    @IBInspectable open var polyphonicButton: UIColor = #colorLiteral(red: 1.000, green: 1.000, blue: 1.000, alpha: 1.000)

    /// 12ET + Microtonal: false ==> draw 12ET, true ==> draw microtonal
    @IBInspectable open var tuningMode: Bool = false

    // 12ET + Microtonal:
    var holdMode = false {
        
        didSet {
            if !holdMode {
                allNotesOff()
            }
        }
    }

    // 12ET + Microtonal:
    internal let baseMIDINote = 24 // MIDINote 24 is C0

    // 12ET + Microtonal:
    internal var onKeys = Set<MIDINoteNumber>()

    /// 12ET + Microtonal: Class to handle user actions
    open weak var delegate: AKKeyboardDelegate?

    // 12ET + Microtonal: persist keyboard position when presets panel is displayed
    var isShown = true

    /// 12ET + Microtonal: Allows multiple notes to play concurrently
    open var polyphonicMode = true {

        didSet {
            allNotesOff()
        }
    }

    // 12ET + Microtonal:
    internal var arpIsOn: Bool {

        return Conductor.sharedInstance.synth.getSynthParameter(.arpIsOn) > 0 ? true : false
    }

    // 12ET + Microtonal:
    internal var arpIsSequencer: Bool {

        return Conductor.sharedInstance.synth.getSynthParameter(.arpIsSequencer) > 0 ? true : false
    }

    // MARK: - 12ET Properties

    /// 12ET: Relative measure of the height of the black keys
    @IBInspectable open var topKeyHeightRatio: CGFloat = 0.55

    /// 12ET: White key color
    @IBInspectable open var  whiteKeyOff: UIColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)

    /// 12ET: Black key color
    @IBInspectable open var  blackKeyOff: UIColor = #colorLiteral(red: 0.06666666667, green: 0.06666666667, blue: 0.06666666667, alpha: 1)

    /// 12ET: Activated key color
    @IBInspectable open var  keyOnUserColor: UIColor = #colorLiteral(red: 0.9607843137, green: 0.5098039216, blue: 0, alpha: 1)

    // 12ET
    var keyOnColor: UIColor = #colorLiteral(red: 0.4549019608, green: 0.6235294118, blue: 0.7254901961, alpha: 1)

    /// 12ET: draw keys
    var darkMode: KeyboardDarkMode = .light

    // 12ET
    internal var oneOctaveSize = CGSize.zero

    // 12ET
    internal let naturalNotes = ["C", "D", "E", "F", "G", "A", "B"]

    // 12ET
    internal let notesWithSharps = ["C", "C#", "D", "D#", "E", "F", "F#", "G", "G#", "A", "A#", "B"]

    // 12ET
    internal let topKeyNotes = [0, 0, 0, 1, 1, 2, 2, 3, 3, 4, 4, 4, 5, 5, 5, 6, 6, 7, 7, 8, 8, 9, 9, 10, 10, 11, 11, 11]

    // 12ET
    internal let whiteKeyNotes = [0, 2, 4, 5, 7, 9, 11]

    // 12ET + Microtonal:
    internal var xOffset: CGFloat = 1

    // 12ET
    internal var topKeyWidthIncrease: CGFloat = 4

    // MARK: - Microtonal Properties

    // Microtonal: used for key color rendering
    var transpose: Int = 0 {

        didSet {
            DispatchQueue.main.async {
                self.setNeedsDisplay()
            }
        }
    }

    // Microtonal
    internal var microtonalKeyPaths = [MicrotonalBezierPath]()

    // MARK: - Initialization

    /// Initialize the keyboard with default info
    public override init(frame: CGRect) {

        super.init(frame: frame)
        isMultipleTouchEnabled = true
        addListeners()
    }

    /// Initialize the keyboard
    public init(width: Int, height: Int, firstOctave: Int = 4, octaveCount: Int = 3,
                polyphonic: Bool = true) {

        self.octaveCount = octaveCount
        self.firstOctave = firstOctave
        super.init(frame: CGRect(x: 0, y: 0, width: width, height: height))
        updateOneOctaveSize()
        isMultipleTouchEnabled = true
        setNeedsDisplay()
        addListeners()
    }

    /// Initialization within Interface Builder
    required public init?(coder aDecoder: NSCoder) {

        super.init(coder: aDecoder)
        isMultipleTouchEnabled = true
        addListeners()
    }

    private func addListeners() {
        
        NotificationCenter.default.removeObserver(self, name: .tuningDidChange, object: nil)
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(tuningChanged(notification:)),
                                               name: .tuningDidChange,
                                               object: nil)
    }

    @objc private func tuningChanged(notification: NSNotification) {

        DispatchQueue.main.async {
            self.setNeedsDisplay()
        }
    }

    deinit {

        NotificationCenter.default.removeObserver(self, name: .tuningDidChange, object: nil)
    }
}
