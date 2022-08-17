#!/bin/bash

# Run Xcode clean build and test according to provided parameters

# Do not forget to make this file executable with `chmod +x the_file_name`

# `set -o pipefail` causes a pipeline (for example,
# `curl -s https://sipb.mit.edu/ | grep foo`) to produce
# a failure return code if any command errors.
# Normally, pipelines only return a failure if the last command errors.
# In combination with `set -e`, this will make your script exit
# if any command in a pipeline errors.
set -eo pipefail

xcodebuild clean build test \
           -project Meme-Ory.xcodeproj \
           -scheme "CI" \
           -sdk iphonesimulator \
           -destination "platform=iOS Simulator,name=iPhone 13 Pro" \
           CODE_SIGN_IDENTITY="" \
           CODE_SIGNING_REQUIRED=NO \
           ONLY_ACTIVE_ARCH=YES | xcpretty
