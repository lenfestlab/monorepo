#!/bin/bash -x -u -e -v

brew bundle -v --file=.brewfile --no-upgrade --no-lock

asdf plugin-add ruby
asdf plugin-add nodejs
asdf install

yarn install --prefer-offline --check-files

gem install bundler
bundle install
