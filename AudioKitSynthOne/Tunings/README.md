#  Tunings Panel

![Tunings Panel](http://audiokit.io/synthone/tuningsPanel.png)

### This folder's contents
* Tuning.swift - a Codable object used to store a single tuning
* Tunings.swift - Manager for loading/saving tuning presets (analogous to PresetDataManager and Preset)
* Tunings+Harmonic.swift - 1,000 harmonic approximations of log2(frequency)
* Tunings+Math.swift - helpers for harmonic series and combination product sets.  These should be moved to AudioKit library.
* TuningsPanelController/TuningsPanelController.swift - ViewController for Tunings panel
* TuningsPanelController/TuningsPanel+UITableViewDataSource.swift
* TuningsPanelController/TuningsPanel+UITableViewDelegate.swift
* UI Components/TuningCell.swift
* UI Components/TuningsPitchWheelView.swift - This UI element can be reused in any AudioKit application because it draws itself based on AKPolyphonicNode's global tuning table.  It displays one octave of the tuning table as log2(frequency) modulo 1.  12 o'clock is middle C, one rotation = 1 octave.

### Scope of Synth One microtonal functionality
* Synth One is not a scale design tool, although there are discussions about adding more design and metadata functionality.
* The tuning library is curated from a panel of microtonalists with nearly 200 collective years of experience.
* Tunings are stored in a tuning table of size 128 (a mapping from midi note number to frequency)
* Synth One tunings are octave-based, so there is always a well-defined notion of "notes-per-octave" used to scale sequencer patterns.  However, AudioKit AKTuningTable is generalized and has no limitation on whether a tuning is octave-based or not.
* The keyboard has no metadata of the scale and is simply note-number-based. Every note on the keyboard maps to all 128 note numbers which maps to 128 frequencies of the tuning table.
* The "pitch wheel" is a log2(frequency) modulo 1 representation of the frequencies of one octave of the tuning table with middle C (note number 60) as 12 o'clock
* The "master tuning" control modifies middle C's frequency based on what an A in 12ET would be. i.e., assume 12 et, adjust middle C based on the "master tuning" of A, then apply that to the 0th degree of the scale as if that was middle C. The code looks like this:
AKPolyphonicNode.tuningTable.middleCFrequency = getSynthParameter(frequencyA4) * exp2((60.f - 69.f)/12.f)
* The Synth One tuning library is static for this first release, but under the hood the library is dynamic and will import new scales as they are shared via presets. As we add new presets with new scales, or add Scala file support, user's libraries will be updated. More work needs to be done here, but it has a rudimentary future-proofing.

### Common Microtonal Feature Requests
* Add Scala support.  AudioKit does have Scala file support, but we have not implemented file import/management in Synth One.  Would love someone to implement this.
* Add MPE support.  AudioKit implements the math to map an arbitrary frequency to a 12et note number plus pitch bend (search for "etNNPitchBend").  Next steps are to implement an MPE MIDI mode/configuration, local off, etc.



### Microtonal resources used in the implementation of Synth One Tuning panel

* [Wilson](http://anaphoria.com/wilson.html)
* [Wilson Basic](http://anaphoria.com/wilsonbasic.html)
* [Wilson Calte Tree](http://anaphoria.com/wilsonscaletree.html)
* [Wilson Diamond Coprime](http://anaphoria.com/wilsondiamondcoprime.html)
* [Wilson CPS](http://anaphoria.com/wilsoncps.html)
* [Wilson Meru](http://anaphoria.com/wilsonmeru.html)


