#!/bin/sh

# In rubymine goto Run -> Edit Configurations
# name: ruby-api
# remote host: 0.0.0.0
# remote port: 1234
# remote root folder: /app
# local port: 26162
# local root folder /Users/....../zanza/app/src
#
# launch this script in the docker container
# in Rubymine Run -> Debug -> ruby-api
# use breakpoints as you need

rake db:create
rake db:migrate

bundle exec rdebug-ide --host 0.0.0.0 --port 1234 --dispatcher-port 26162 -- /app/bin/rails server -b0.0.0.0
