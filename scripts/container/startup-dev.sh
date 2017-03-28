#!/bin/sh
rake db:create
rake db:migrate
bundle exec rails server -b0.0.0.0
