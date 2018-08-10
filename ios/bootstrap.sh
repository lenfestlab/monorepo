#!/bin/bash -x -u -e

# Homebrew manifest
# https://github.com/Homebrew/homebrew-bundle
brew bundle --file=.brewfile --no-upgrade

# Mint manifest for swift dev binaries
# https://github.com/yonaskolb/Mint
mint bootstrap

# Carthage for iOS deps
# NOTE: omit --verbose flag, causes build error:
# https://github.com/Carthage/Carthage/issues/2249
carthage bootstrap --platform ios --cache-builds
