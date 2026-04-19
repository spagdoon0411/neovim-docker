#!/bin/bash
#
# Helper script to run Neovim in Docker container
# Usage: ./run.sh [file-to-edit]

IMAGE_NAME="nvim-dev:latest"
CONTAINER_NAME="nvim-dev"

# Build the image if it doesn't exist
if [[ "$(docker images -q $IMAGE_NAME 2> /dev/null)" == "" ]]; then
    echo "Building Neovim Docker image..."
    # Detect platform for Apple Silicon support
    PLATFORM=""
    if [[ "$(uname -m)" == "arm64" ]]; then
        PLATFORM="--platform linux/arm64"
    fi

    # Get actual user info (not root even if running with sudo)
    ACTUAL_USER=${SUDO_USER:-$(whoami)}
    ACTUAL_UID=${SUDO_UID:-$(id -u)}
    ACTUAL_GID=${SUDO_GID:-$(id -g)}

    docker build $PLATFORM -t $IMAGE_NAME \
        --build-arg USERNAME=$ACTUAL_USER \
        --build-arg USER_UID=$ACTUAL_UID \
        --build-arg USER_GID=$ACTUAL_GID \
        .
fi

# Run container with home directory mounted
# Detect platform for Apple Silicon support
PLATFORM=""
if [[ "$(uname -m)" == "arm64" ]]; then
    PLATFORM="--platform linux/arm64"
fi

# Get actual user info (not root even if running with sudo)
ACTUAL_USER=${SUDO_USER:-$(whoami)}
ACTUAL_HOME=$(eval echo ~$ACTUAL_USER)

docker run -it --rm \
    $PLATFORM \
    --name $CONTAINER_NAME \
    -v "$ACTUAL_HOME:$ACTUAL_HOME" \
    -w "$(pwd)" \
    -e HOME="$ACTUAL_HOME" \
    -e USER="$ACTUAL_USER" \
    -e XDG_DATA_HOME="$ACTUAL_HOME/.local/share-container" \
    -e TERM="${TERM:-xterm-256color}" \
    -e COLORTERM=truecolor \
    --network host \
    $IMAGE_NAME \
    ${@:-bash}
