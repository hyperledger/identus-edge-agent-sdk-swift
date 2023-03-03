#!/bin/bash

cd "$(dirname "${BASH_SOURCE[0]}")" || exit 126
VERSION=0.0.1
docker build -t ghcr.io/input-output-hk/prism-swift-docs:${VERSION} .
docker push ghcr.io/input-output-hk/prism-swift-docs:${VERSION}
