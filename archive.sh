#!/bin/bash

# Create archive and upload to App Store,
# or export `.ipa`file - see `ExportOptions.plist`

# Do not forget to make this file executable with `chmod +x the_file_name`

# `set -o pipefail` causes a pipeline (for example,
# `curl -s https://sipb.mit.edu/ | grep foo`) to produce
# a failure return code if any command errors.
# Normally, pipelines only return a failure if the last command errors.
# In combination with `set -e`, this will make your script exit
# if any command in a pipeline errors.
set -eo pipefail

xcodebuild archive \
           -scheme "Meme-Ory" \
           -configuration Release \
           -archivePath "Meme-Ory.xcarchive"

xcodebuild -exportArchive \
           -archivePath Meme-Ory.xcarchive \
           -exportOptionsPlist "ExportOptions.plist" \
           -exportPath .
