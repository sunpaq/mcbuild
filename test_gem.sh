#!/bin/sh

rm *.gem
gem build *.gemspec
sudo gem install *.gem