#!/bin/bash

# Build Docker image using package.json details.
#
# This script builds a Docker image from the Dockerfile in the current directory, tagging it with the name and version specified in package.json. It validates required files exist before proceeding.

# Check if package.json exists
if [ ! -f "package.json" ]; then
    echo "Error: package.json file does not exist in the current directory." >&2
    exit 1
fi

# Check if Dockerfile exists
if [ ! -f "Dockerfile" ]; then
    echo "Error: Dockerfile does not exist in the current directory." >&2
    exit 1
fi

# Extract name and version from package.json
# NAME: Docker image name extracted from 'name' field in package.json
NAME=$(jq -r '.name' package.json 2>/dev/null)
# VERSION: Image version extracted from 'version' field in package.json
VERSION=$(jq -r '.version' package.json 2>/dev/null)

# Check if name and version were extracted successfully
if [ "$NAME" = "null" ] || [ -z "$NAME" ]; then
    echo "Error: 'name' field not found or is empty in package.json." >&2
    exit 1
fi

if [ "$VERSION" = "null" ] || [ -z "$VERSION" ]; then
    echo "Error: 'version' field not found or is empty in package.json." >&2
    exit 1
fi

# Build the Docker image with the name and version from package.json
IMAGE_NAME="$NAME:$VERSION"
echo "Building Docker image: $IMAGE_NAME"

if docker build -t "$IMAGE_NAME" .; then
    echo "Success: Docker image $IMAGE_NAME built successfully."
else
    echo "Error: Failed to build Docker image $IMAGE_NAME." >&2
    exit 1
fi