#!/bin/bash

set -e

docker run \
  --name tilapp \
  --rm \
  -it \
  -p 8080:8080 \
  --env-file .env \
  -v $(pwd):/build \
  -w /build \
  swift:5.4 \
  bash
