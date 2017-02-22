#!/bin/sh

rubocop
RAILS_ENV=test rake db:create
RAILS_ENV=test rake db:migrate
rake spec
