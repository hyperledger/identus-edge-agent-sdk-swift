#!/bin/bash

set -e

DERIVED_DATA_DIR="$HOME/.derivedData"
DESTINATION="platform=iOS Simulator,name=IPhone 14"
SCHEME="AtalaPRISMSDK-Package"
LCOV_DIR="$DERIVED_DATA_DIR/lcov"

echo "Derived data directory: $DERIVED_DATA_DIR"
echo "lcov partials directory: $LCOV_DIR"

# Clean derived data dir
echo "Cleaning derived data directory"
rm -rf "$DERIVED_DATA_DIR"
mkdir "$DERIVED_DATA_DIR"

# Clean lcov dir
echo "Cleaning lcov partials directory"
rm -rf "$LCOV_DIR"
mkdir "$LCOV_DIR"

# Run build and test
echo "Running build and test"
xcodebuild -scheme "AtalaPRISMSDK-Package" \
    -destination "$DESTINATION" \
    -derivedDataPath "$DERIVED_DATA_DIR" \
    -enableCodeCoverage YES \
    -quiet clean build test
echo "Execution completed"

# Find profdata
PROF_DATA=$(find "$DERIVED_DATA_DIR" -name Coverage.profdata)
echo "Profdata found: $PROF_DATA"

# Find all binaries
BINARIES=$(find ~/.derivedData -type f -name "*Tests")

# Print all binaries found
for BINARY in $BINARIES; do
  echo "Binary found: $BINARY"
done

# Generate lcov for each target
for BINARY in $BINARIES; do
  BASE_NAME=$(basename "$BINARY")
  echo "Generating coverage for $BASE_NAME"
  LCOV_NAME="${BASE_NAME}.lcov"
  xcrun llvm-cov export --format=lcov \
    -instr-profile "$PROF_DATA" "$BINARY" > "$LCOV_DIR/$LCOV_NAME"
done

# Merge all coverage
echo "Merging partials to lcov.info"
lcov -o lcov.info -a "$LCOV_DIR/*.lcov" --include AtalaPrismSDK/ --exclude Tests > /dev/null
