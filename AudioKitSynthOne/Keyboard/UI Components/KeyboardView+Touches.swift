//
//  KeyboardView+Touches.swift
//  AudioKitSynthOne
//
//  Created by Marcus W. Hobbs on 7/17/19.
//  Copyright © 2019 AudioKit. All rights reserved.
//

extension KeyboardView {

    // MARK: - Touch Handling

    func notesFromTouches(_ touches: Set<UITouch>) -> [MIDINoteNumber] {

        var notes = [MIDINoteNumber]()
        for touch in touches {
            if let note = noteFromTouchLocation(touch.location(in: self)) {
                notes.append(note)
            }
        }
        return notes
    }

    func noteFromTouchLocation(_ location: CGPoint ) -> MIDINoteNumber? {

        guard bounds.contains(location) else { return nil }

        if tuningMode {
            return noteFromTouchLocationMicrotonal(location)
        } else {
            return noteFromTouchLocation12ET(location)
        }
    }

    func noteFromTouchLocation12ET(_ location: CGPoint ) -> MIDINoteNumber? {

        let x = location.x - xOffset
        let y = location.y
        var note = 0
        if y > oneOctaveSize.height * topKeyHeightRatio {
            let octNum = Int(x / oneOctaveSize.width)
            let scaledX = x - CGFloat(octNum) * oneOctaveSize.width
            note = (firstOctave + octNum) * 12 + whiteKeyNotes[max(0, Int(scaledX / whiteKeySize.width))] + baseMIDINote
        } else {
            let octNum = Int(x / oneOctaveSize.width)
            let scaledX = x - CGFloat(octNum) * oneOctaveSize.width
            note = (firstOctave + octNum) * 12 + topKeyNotes[max(0, Int(scaledX / topKeySize.width))] + baseMIDINote
        }
        if note >= 0 {
            return MIDINoteNumber(note)
        } else {
            return nil
        }
    }

    func noteFromTouchLocationMicrotonal(_ location: CGPoint ) -> MIDINoteNumber? {

        let microtonalPaths = microtonalKeyPaths
        for path in microtonalPaths {
            if path.contains(location) {
                return path.nn
            }
        }
        return nil
    }

    /// Handle new touches
    override open func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {

        let notes = notesFromTouches(touches)
        for note in notes {
            pressAdded(note)
        }
        if !holdMode { verifyTouches(event?.allTouches) }
        setNeedsDisplay()
    }

    /// Handle touches completed
    override open func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {

        guard !holdMode else { return }

        for touch in touches {
            if let note = noteFromTouchLocation(touch.location(in: self)) {
                // verify that there isn't still a touch remaining on same key from another finger
                if var otherTouches = event?.allTouches {
                    otherTouches.remove(touch)
                    if ❗️notesFromTouches(otherTouches).contains(note) {
                        pressRemoved(note, touches: event?.allTouches)
                    }
                }
            }
        }
        verifyTouches(event?.allTouches)
        setNeedsDisplay()
    }

    /// Handle moved touches
    override open func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {

        guard !holdMode else { return }

        for touch in touches {
            if let key = noteFromTouchLocation(touch.location(in: self)),
                key != noteFromTouchLocation(touch.previousLocation(in: self)) {
                pressAdded(key)
                setNeedsDisplay()
            }
        }
        verifyTouches(event?.allTouches)
    }

    /// Handle stopped touches
    override open func touchesCancelled(_ touches: Set<UITouch>?, with event: UIEvent?) {

        verifyTouches(event?.allTouches)
    }

    // MARK: - Executing Key Presses

    func pressAdded(_ newNote: MIDINoteNumber, velocity: MIDIVelocity = 127) {

        var noteIsAlreadyOn = false
        if holdMode {
            for key in onKeys where key == newNote {
                noteIsAlreadyOn = true
                pressRemoved(key)
            }
        }
        if ❗️polyphonicMode {
            for key in onKeys where key != newNote {
                pressRemoved(key)
            }
        }
        if ❗️onKeys.contains(newNote) && !noteIsAlreadyOn {
            onKeys.insert(newNote)
            delegate?.noteOn(note: newNote, velocity: velocity)
        }
        setNeedsDisplay()
    }

    func pressRemoved(_ note: MIDINoteNumber, touches: Set<UITouch>? = nil, isFromMIDI: Bool = false) {

        guard onKeys.contains(note) else { return }

        onKeys.remove(note)
        if !isFromMIDI {
            delegate?.noteOff(note: note)
        }
        if ❗️polyphonicMode {
            // in mono mode, replace with note from highest remaining touch, if it exists
            var remainingNotes = notesFromTouches(touches ?? Set<UITouch>())
            remainingNotes = remainingNotes.filter { $0 != note }
            if let highest = remainingNotes.max() {
                pressAdded(highest)
            }
        }
        setNeedsDisplay()
    }

    private func verifyTouches(_ touches: Set<UITouch>?) {

        // check that current touches conforms to onKeys, remove stuck notes
        let notes = notesFromTouches(touches ?? Set<UITouch>() )
        let disjunct = onKeys.subtracting(notes)
        if !disjunct.isEmpty {
            for note in disjunct {
                pressRemoved(note)
            }
        }
    }

    func allNotesOff() {

        for note in onKeys {
            delegate?.noteOff(note: note)
        }
        onKeys.removeAll()
        setNeedsDisplay()
    }
}
