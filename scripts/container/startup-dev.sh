#!/bin/sh
rake db:setup
rake db:migrate
bundle exec rails server -b0.0.0.0
