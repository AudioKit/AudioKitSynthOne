# AudioKit Synth One

![screenshot](https://audiokitpro.com/wp-content/uploads/2018/04/top3.jpg)

We've open-sourced the code for this synthesizer so that everyone is able to make changes to the code,
introduce new features, fix bugs, improve efficiency, and keep the synthesizer up-to-date with all
new capabilities of the base operating system.  
![Screenshot](http://audiokitpro.com/images/ak1.gif)

## Master and Develop Branches

The two primary branches of this repository are intended to be used as follows:

* Master branch will work with the current release version of AudioKit - ie. AudioKit's "master" branch. Changes should not be made on this branch so that it can be kept as stable as possible.

* Develop branch is intended to be built with code from Develop branch of AudioKit.  Pull requests should be made to this branch.

## Installation

You must install the pods that we depend on before you can compile the project. To do so, run the following at the root of the project:

* `pod repo update`
* `pod install`

You may uncomment the line in `Podfile` to switch to our cutting-edge staging (unstable) releases of AudioKit, as opposed to the stable releases in the mainstream CocoaPods specs.

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

## Opportunities for Contributing

Here's a few ideas for you to contribute to this historic project:

* Write a PDF Manual. We can help answer any questions. Write a manual for Synth One in your language. 

* Have AUv3 development experience? Help with the AUv3 version! (Plus, we have a  Slack Channel for this topic)

*  Midi Learn Matrix. Create a view that will allow users to easily change the MIDI Learn assignments.

* Make TouchPads assignable 

* Add an EQ Panel (8-band/16-band/etc)

* Improve Arp (Add Gate, etc)

* Add a trance/rhythm gate panel

* Add a side chain/volume ducking panel

* Localizations


If you have audio development experience and want to be more involved with Synth One, please email [hello@audiokitpro.com](mailto:hello@audiokitpro.com)

There are a few major updates we intend for this synth:

* Storyboards are a source of bugs on large scale projects like this one.  We will replace storyboards with programmatically generated views.

* Too much business logic is inside the "Manager" view controller.  We have done our best to separate out the functions of this view controller into well defined extensions, but more work could be done with this.


