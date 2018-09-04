#!/bin/bash -x -u -e

# Homebrew manifest
# https://github.com/Homebrew/homebrew-bundle
brew bundle --file=.brewfile --no-upgrade

asdf install

gem install bundler
bundle install
