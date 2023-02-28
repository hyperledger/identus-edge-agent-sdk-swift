#!/bin/sh

# Sourcekitten all modules so we can merge them
sourcekitten doc -- -scheme AtalaPrismSDK -destination "name=iPhone 14" > AtalaPrismSDK.json
sourcekitten doc -- -scheme Domain -destination "name=iPhone 14" > Domain.json
sourcekitten doc -- -scheme Apollo -destination "name=iPhone 14" > Apollo.json
sourcekitten doc -- -scheme Mercury -destination "name=iPhone 14" > Mercury.json
sourcekitten doc -- -scheme Pluto -destination "name=iPhone 14" > Pluto.json
sourcekitten doc -- -scheme Pollux -destination "name=iPhone 14" > Pollux.json
sourcekitten doc -- -scheme PrismAgent -destination "name=iPhone 14" > PrismAgent.json

# Copy all the *.md files to the Documentation folder
bash ./.scripts/prepareDocumentation.sh
# Replace every <doc:XxYy> by [Xx Yy](xxyy.html)
ruby ./.scripts/preDoc.rb

# It needs to be castor module since the sourcekitten is adding the Protobuf files.
jazzy --module Castor --sourcekitten-sourcefile AtalaPrismSDK.json,Domain.json,Apollo.json,Mercury.json,Pluto.json,Pollux.json,PrismAgent.json --theme fullwidth --hide-documentation-coverage
# Replace in the index the Castor references by Atala Prism SDK
ruby ./.scripts/prepareIndex.rb
