#!/bin/bash -x -u -e -v

brew bundle -v --file=.brewfile --no-upgrade --no-lock

asdf plugin-add ruby
asdf install

yarn --prefer-offline

gem install bundler
bundle install
