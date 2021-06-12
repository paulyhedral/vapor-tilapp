#!/bin/bash

set -e

#docker build \
#  -t tilapp:latest \
#  .

docker exec \
  -it \
  -w /build \
  tilapp \
  swift build
