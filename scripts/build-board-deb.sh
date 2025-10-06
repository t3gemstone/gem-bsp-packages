#!/bin/bash

set -e

BOARD=$1

if [ -z "$BOARD" ]; then
    echo "Usage: $0 <board-name>"
    echo "Available boards:"
    for dir in */debian; do
        board=$(dirname "$dir")
        echo "  - $board"
    done
    exit 1
fi

if [ ! -d "$BOARD" ]; then
    echo "Error: Board directory '$BOARD' not found"
    exit 1
fi

if [ ! -d "$BOARD/debian" ]; then
    echo "Error: $BOARD/debian directory not found"
    exit 1
fi

echo "Building DEB package for board: $BOARD"

# Change to board directory
cd "$BOARD"

# Verify required files exist
echo "Checking for required files..."
REQUIRED_FILES="tiboot3.bin gemstone-image-rd-${BOARD}.cpio.gz k3-am67a-${BOARD}.dtb"
MISSING_FILES=""

for file in $REQUIRED_FILES; do
    if [ ! -f "$file" ]; then
        MISSING_FILES="$MISSING_FILES $file"
    fi
done

overlays=$(find . -name '*'"${BOARD}.dtbo"'')

mkdir -p overlays

for overlay_file in $overlays; do
    cp "$overlay_file" "overlays/${overlay_file%-${BOARD}.dtbo}.dtbo"
done

if [ -n "$MISSING_FILES" ]; then
    echo "[Error] Missing required files: $MISSING_FILES"
    echo "Please place Yocto artifacts in $BOARD/ directory"
    exit 1
fi

echo "All required files found"
echo "Building package..."

# Make rules executable
chmod +x debian/rules

# Build the package
dpkg-buildpackage -us -uc -b

echo "Build complete!"
echo "Package created in parent directory:"
cd ..
ls -lh *.deb 2>/dev/null | tail -1 || echo "No .deb file found"
