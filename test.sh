#!/bin/bash
set -o errexit
set -o nounset

IMG="$REGISTRY/$REPOSITORY:$TAG"

docker run -i --rm "$IMG" '/tmp/test/test-runner'

echo "Test OK!"
