#!/bin/bash -x -u -e -v

brew bundle -v --file=.brewfile --no-upgrade

asdf plugin-add ruby
asdf install

yarn --prefer-offline

gem install bundler
bundle install
