#!/bin/sh

rubocop
RAILS_ENV=test rake db:setup
sleep 2
rake spec
