#!/bin/bash

set -e

#docker run \
#  -it \
#  --env-file .env \
#  -p 8080:8080 \
#  tilapp:latest

docker exec \
  -it \
  -w /build \
  tilapp \
  swift run Run
