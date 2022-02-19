#  AudioKit Synth One DSP

Architecture
h1
==

* Global enums
`S1Parameter.h`
Enums for every kernel parameter are defined here, and exposed to Swift, ObjC, and C++.


* Swift wrapper
`AKSynthOne.swift`

* ObjC++ AudioUnit
`S1AudioUnit.h`

S1AudioUnit owns the AudioUnit instance of the kernel and facilitates communication between the Swift UI layer and the C++ DSP kernel.
It defines several structs used for communication between the render thread and the main/ui thread.
It depends on a 3rd party SDK to facilitate messaging between the main thread and the render thread.


* Kernel
`S1DSPKernel.hpp`
Note that this header defines the values for the array of S1ParameterInfo objects, which define the min, default, max for every parameter to the kernel.

`S1DSPKernel+process.mm`
Kernel Process
The architecture of this application is to prepare objects for the kernel's real-time render thread consumption, then message those state changes to the ui-thread.
This render thread code is 75% of the application's cpu.  This code must be continuously tested and optimized.
This code must not block, which also means no allocation of objects.
Much consideration was given to Michael Tyson's render thread analysis: [Four common mistakes in audio development](http://atastypixel.com/blog/four-common-mistakes-in-audio-development/)
Great care was given to manage incoming midi events outside of process()
The Sequencer and Arpeggiator code is inside process() but it is computationally trivial.


* NoteState
`S1NoteState.hpp`
S1NoteState is the atomic dsp note object.  
The kernel manages a single instance for mono mode, and a managed array of count "polyphony" for polyphonic mode.
Kernel presents 2 global LFOs to every NoteState object.  This is an area we'd like to generalize while maintaining backwards compatibility.  Brice Beasly has some excellent designs.

