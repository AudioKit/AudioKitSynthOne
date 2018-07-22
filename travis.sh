#!/bin/bash
# Run tests in Travis CI

set -o pipefail

xcodebuild -workspace AudioKitSynthOne.xcworkspace -scheme AudioKitSynthOne -sdk iphonesimulator | xcpretty || return 1
