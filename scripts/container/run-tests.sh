#!/bin/sh

rubocop
RAILS_ENV=test rake db:setup
RAILS_ENV=test rake spec
