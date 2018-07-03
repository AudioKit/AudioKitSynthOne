#  AudioKit Synth One DSP

Architecture
h1
==


* Swift wrapper
`AKSynthOne.swift`

* AudioUnit
`S1AudioUnit.h`

S1AudioUnit owns the AudioUnit instance of the kernel and facilitates communication between the Swift UI layer and the C++ DSP kernel.
It defines several structs used for communication between the render thread and the main/ui thread.
It depends on a 3rd party SDK to faciliate messaging between the main thread and the render thread.


* Kernel
`S1DSPKernel+process.mm`

* NoteState
`S1NoteState.hpp`
S1NoteState is the atomic dsp note object.  
The kernel manages a single instance for mono mode, and a managed array of count "polyphony" for polyphonic mode.
Kernel presents 2 global LFOs to every NoteState object.  This is an area we'd like to generalize while maintaining backwards compatibility.

