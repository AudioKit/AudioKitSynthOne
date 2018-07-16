#  DEV panel


Parameters (saved with presets):
There are 3 compressors:

1) reverb input compressor, 
2) compressor on 100% wet reverb output before mixing, 
3) the final final master compressor (default settings are more like a limiter).  

We've carefully set the defaults to minimize distortion and provide a baseline loudness...note that all the sound designers who created the bundled presets used these default settings.  Users can change these but it can be a rabbit hole.

DelFCut: We have a low-pass butterworth filter on the delay input that tracks the oscillator filter cutoff.  It defaults to 0.75.  If your oscillator cutoff is 10_000HZ the delay input cutoff will be 7_500HZ.  This way the input to the delay will always have a lower cutoff frequency than the oscillator's cutoff frequency.  It gives a beautiful separation between the oscillators and delay.

DelFRes: Doesn't have an effect because we currently have the resonance of the delay input filter set to 0.

Master Volume is is the gain on the input to the final master compressor.  It is the same "master volume" on the "Main" panel.

DSPParamHalftime: Almost all dsp parameters are "smoothed" to reduce artifacts when switching presets, or zippering when consuming UI events.  You can make this a fast or sllloooooowwww smooth with this parameter.

Settings (stored in settings, not saved with presets):

LockArpRate: OFF by default.  When enabled: loading a preset will ignore the preset's tempo.  This is great for when you want to jam at a constant tempo and blaze through presets.  When we add tempo sync (i.e., Ableton Link) we might have to change how this works.

LockReverb: OFF by default: When enabled: Loading a preset will ignore the preset's reverb parameters in favor of the current parameters.

LockDelay: OFF by default: When enabled: Loading a preset will ignore the preset's delay parameters in favor of the current parameters.

Lock Arp+Seq: OFF by default.  When enabled: Loading a preset will ignore the preset's following parameters:
arpIsOn
arpIsSequencer
arpDirection
arpInterval
arpOctave
arpTotalSteps
sequencerPattern00, ..., sequencerPattern15
sequencerOctBoost00, ..., sequencerOctBoost15
sequencerNoteOn00, ..., sequencerNoteOn15

