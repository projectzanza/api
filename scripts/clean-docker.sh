#!/bin/bash -x

# if some commands fail, you may have to rerun this

docker stop $(docker ps -q)
docker rm -f $(docker ps -aq)
docker rmi -f $(docker images -q)
docker volume prune -f
