#!/bin/bash -x -u -e

# Homebrew manifest
# https://github.com/Homebrew/homebrew-bundle
brew bundle -v --file=.brewfile --no-upgrade

# Mint manifest for swift dev binaries
# https://github.com/yonaskolb/Mint
mint bootstrap

# Carthage for iOS deps
carthage bootstrap --platform ios --cache-builds --verbose

# Deployment tools (fastlane) use Ruby
asdf install
command -v ruby >/dev/null 2>&1 || { asdf plugin-add ruby; }

gem install bundler --conservative
bundle install

# ignore local changes to Firebase config: https://stackoverflow.com/a/4633776
git update-index --assume-unchanged ./App/Resources/GoogleService-Info.plist
