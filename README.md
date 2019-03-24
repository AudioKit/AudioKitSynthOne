# AudioKit Synth One

[![Build Status](https://travis-ci.org/AudioKit/AudioKitSynthOne.svg)](https://travis-ci.org/AudioKit/AudioKitSynthOne)
[![License](https://img.shields.io/cocoapods/l/AudioKit.svg?style=flat)](https://github.com/AudioKit/AudioKitSynthOne/blob/master/LICENSE)
[![Crowdin](https://d322cqt584bo4o.cloudfront.net/audiokit-synth-one/localized.svg)](https://crowdin.com/project/audiokit-synth-one)
[![Twitter Follow](https://img.shields.io/twitter/follow/AudioKitPro.svg?style=social)](http://twitter.com/AudioKitPro)

We've open-sourced the code for this synthesizer so that everyone is able to make changes to the code,
introduce new features, fix bugs, improve efficiency, and keep the synthesizer up-to-date with all
new capabilities of the base operating system. Synth One is now Universal for iPhone/iPad!  
 
![Screenshot](http://audiokitpro.com/images/ak2.gif)

**“AudioKit Synth One is a wonderful example of how iPad can change the way music is made.”**  
– Apple, App Store Editorial Team

If you're new to [AudioKit](https://audiokitpro.com/), you can learn more: [here](https://audiokitpro.com/audiokit/). This code and app is made possible by all the contributors to AudioKit. Many of the features of Synth One are availble as modules in AudioKit, allowing you easy access to oscillators, filters, reverbs, effects, and other DSP processing: [code here](https://github.com/AudioKit/AudioKit). 

## Features & App Store Location

- Learn more about this project: [AudioKit Synth One Features](https://audiokitpro.com/synth)  
- Get app: [Download in App Store](https://itunes.apple.com/us/app/audiokit-synth-one-synthesizer/id1371050497?ls=1&mt=8)

## Master and Develop Branches

The two primary branches of this repository are intended to be used as follows:

* Master branch will work with the current release version of AudioKit - ie. AudioKit's "master" branch. Changes should not be made on this branch so that it can be kept as stable as possible.
* Develop branch is intended to be built with code from Develop branch of AudioKit.  Pull requests should be made to this branch.

## Installation

You must install the pods that we depend on before you can compile the project. To do so, run the following at the root of the project:

* `pod repo update`
* `pod install`

You may uncomment the line in `Podfile` to switch to our cutting-edge staging (unstable) releases of AudioKit, as opposed to the stable releases in the mainstream CocoaPods specs.

## Link Installation

The repository builds and runs without modification, but the Link functionality will be missing.

Because of the way Ableton distributes their Link SDK, we can not simply include the Link files here.  Instead, we include our Link wrapping files and expect you to do two things to get Link working on your machine:

* Change ABLETON_ENABLED from 0 to 1 in the Build Settings
* [Sign up for the Ableton Link SDK](https://www.ableton.com/en/link/sdk/license-request/) and download the prebuilt binary LinkKit.zip.  Uncompress it and find the include and lib directories and place the folders under our "Link" directory.  There should be three files in include and one in lib.


## Requirements

- Mac or computer running Xcode ([Free Download](https://itunes.apple.com/us/app/xcode/id497799835?mt=12))
- Knowledge of programming, specifically Swift, AudioKit, C/C++, & the iOS SDK

If you are new to iOS development, we recommend the [Ray Wenderlich](https://www.raywenderlich.com/) videos. There is also a great tutorial on basic synthesis with AudioKit [here](https://www.raywenderlich.com/145770/audiokit-tutorial-getting-started).  

Beginner? We have two additional code examples. There is a simple [Swift Synth](https://github.com/AudioKit/AnalogSynthX) and a [Sample Player](https://github.com/AudioKit/ROMPlayer). A fun exercise might be replacing the [sample player](https://github.com/AudioKit/ROMPlayer) code engine with synthesis. 

### Ableton Link Support

We now include optional support for the [Ableton Link](https://www.ableton.com/en/link/) SDK. Because files from this private SDK are required to compile this code,
it is turned off by default.

You may enable this code by copying the SDK to your copy of Synth One and setting the `ABLETON_ENABLED` user setting to 1 in the project settings in Xcode.

## Documentation

We intend to have every major section of the code placed within its own folder, with an included
README.md file, like this one. This file should explain the contents of the folder and give developers
any hints about what could be improved.

### This folder's contents

* `AudioKitSynthOne/` - This folder contains most of the source code
* `AudioKitSynthOne.xcodeproj` - This file is a part of the workspace, which you should open instead
* `AudioKitSynthOne.xcworkspace` - This is the file you should open with Xcode, it contains reference to both the project files for the synth code and associated Pods
* `OneSignalNotificationServiceExtension/` - code for a third party extension we use
* `Podfile` and `Podfile.lock` - Cocoapods configuration files
* `.swiftlint.yml` - Swiftlint configuration

### Localizations 
* See [our localization docs](AudioKitSynthOne/Translations/README.md) for more information.

## Opportunities for Contributing

Here's a few ideas for you to contribute to this historic project:

* Ability to search presets
* Midi Learn Matrix. Create a view that will allow users to easily change the MIDI Learn assignments.
* Make TouchPads assignable 
* Add an EQ Panel (8-band/16-band/etc)
* Add the ability for Sequencer to modulate more parameters
* Filter key tracking options & settings
* Filter velocity settings
* MIDI out
* Sample & Hold

✓ DONE: Create an iPhone/Universal version. Thanks to [Matthew Fecher](http://twitter.com/analogmatthew) for his contributions in creating the universal/iPhone version.  

✓ DONE: Add accessibility functionality to AudioKit Synth One. Thanks to Stanley Rosenbaum for making Synth One accessible all musicians. 


If you have audio development experience and want to be involved with contributing to the app store version of Synth One, please email [hello@audiokitpro.com](mailto:hello@audiokitpro.com)

There are a few major updates we intend for this synth:  

* AUV3 Plugin support
* MPE

## Code Usage

You are free to:

(1) Use this code as a learning tool.  
(2) Change the graphics, and include this as part of a bigger app you are building.  
(3) Re-skin this app (change all the UI graphics/controls), and upload to the app store.   
(4) Contribute code back to this project and improve the code for other people

If you use any code, it would be great if you gave this project some credit or a mention. The more love this code receives, the better we can make it for everyone. And, always give AudioKit a shout-out when you can! :) 

If you make an app with this code, please let us know! We think you're awesome, and would love to hear from you and/or feature your app.

We have most of the cool stuff (Filters, Oscillators, Effects, etc) abstracted out into the main [AudioKit](https://audiokitpro.com/audiokit/) library. Use those building blocks to create your own app!  

*SUPER IMPORTANT:* You must change the Graphics & UI if you upload this to the app store. Apple has a rule (4.1) about copycat apps in the app store. One developer has had his Developer account banned by Apple for taking advantage of this code (copying & pasting to make a Synth One clone). Don't let it happen to you. Synth One is a really popular app in the app store, and Apple has featured it in Retail Stores across the United States. If you have questions, feel free to email us at hello@audiokitpro.com, and we can give everyone a heads up that your app is okay (if it follows the rules). We don't want anyone to lose their developer account over this code. 🙏

*IMPORTANT:* You must fill in your own private API keys for AudioBus and others in the Private.swift file to match your own project. The default placeholder values are not suitable for distribution.

## Contributors

Thanks to the countless sound designers and other volunteers. Plus, the developers listed below:

<a href="https://github.com/AudioKit/AudioKit/graphs/contributors"><img src="https://opencollective.com/AudioKit/contributors.svg?width=890&button=false" /></a>

## Legal Notices

This is an open-source project intended to bring joy and music to people, and enlighten people on how to build custom instruments and iOS apps. All product names and images, trademarks and artists names are the property of their respective owners, which are in no way associated or affiliated with the creators of this app, including AudioKit, AudioKit Pro, LLC, and the other contributors. Product names and images are used solely for the purpose of identifying the specific products related to synthesizers, iOS Music, sampling, sound design, and music making. 
