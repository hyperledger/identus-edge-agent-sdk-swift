#!/bin/bash
set -euo pipefail
OPENAPIFOLDER=OpenAPI

# Check if we got the OpenAPI generated within the root folder,
# if not make a clone of the atala-prism-building-blocks and generate
if [ -d "$OPENAPIFOLDER" ]; then
    echo "No need to generate open API, already prepared"
else
    OPENAPIREPOFOLDER=../atala-prism-building-blocks
    if [ ! -d "$OPENAPIREPOFOLDER" ]; then
        cd .. || exit
        git clone git@github.com:input-output-hk/atala-prism-building-blocks.git --single-branch
        cd atala-prism-swift-sdk || exit
    fi

    openapi-generator generate -g swift5 -o OpenAPI/PrismAgentAPI -i ../atala-prism-building-blocks/prism-agent/api/http/prism-agent-openapi-spec.yaml --additional-properties=projectName=PrismAgentAPI
fi
