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

# Deployment tools (fastlane) use Ruby
asdf install
gem install bundler --conservative
bundle install
asdf reshim ruby

# ignore local changes to Firebase config: https://stackoverflow.com/a/4633776
git update-index --assume-unchanged ./App/Resources/GoogleService-Info.plist
