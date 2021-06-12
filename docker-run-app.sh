#!/bin/bash

set -e

name=${1:-tilapp}
scriptdir="$(cd "$(dirname "${BASH_SOURCE[0]}")" >/dev/null 2>&1 && pwd)"

${scriptdir}/docker-start-container.sh

echo "Running application '${name}'..."
docker exec \
  -it \
  -w /build \
  ${name} \
  swift run Run
