#!/bin/bash

set -eo pipefail

xcodebuild clean build test \
           -project Meme-Ory.xcodeproj \
           -scheme "Meme-Ory" \
           CODE_SIGN_IDENTITY="" \
           CODE_SIGNING_REQUIRED=NO \
           -sdk iphonesimulator \
           -destination "platform=iOS Simulator,name=iPhone 13 Pro" \
           ONLY_ACTIVE_ARCH=YES | xcpretty
