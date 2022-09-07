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

    openapi-generator generate -g swift5 -o OpenAPI/Castor -i ../atala-prism-building-blocks/castor/api/castor-openapi-spec.yaml --additional-properties=projectName=CastorAPI

    openapi-generator generate -g swift5 -o OpenAPI/Pollux -i ../atala-prism-building-blocks/pollux/api/pollux-openapi-spec.yaml --additional-properties=projectName=PolluxAPI
fi
