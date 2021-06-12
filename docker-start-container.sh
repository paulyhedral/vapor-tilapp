#!/bin/bash

set -e

scriptdir="$(cd "$(dirname "${BASH_SOURCE[0]}")" >/dev/null 2>&1 && pwd)"

name=${1:-tilapp}
running=$(docker container ls | grep ${name} | wc -l | xargs)
echo "Container 'tilapp' running? ${running}"

if [ "${running}" = 0 ]; then
  echo "Starting container '${name}'..."
  docker run \
    --name ${name} \
    -d \
    --rm \
    -it \
    -p 8080:8080 \
    --env-file .env \
    -v $(pwd):/build \
    -w /build \
    swift:5.4 \
    bash
fi
