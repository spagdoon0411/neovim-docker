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
    docker build $PLATFORM -t $IMAGE_NAME \
        --build-arg USERNAME=$(whoami) \
        --build-arg USER_UID=$(id -u) \
        --build-arg USER_GID=$(id -g) \
        .
fi

# Run container with home directory mounted
# Detect platform for Apple Silicon support
PLATFORM=""
if [[ "$(uname -m)" == "arm64" ]]; then
    PLATFORM="--platform linux/arm64"
fi

docker run -it --rm \
    $PLATFORM \
    --name $CONTAINER_NAME \
    -v "$HOME:$HOME" \
    -w "$(pwd)" \
    -e HOME="$HOME" \
    -e USER="$(whoami)" \
    -e XDG_DATA_HOME="$HOME/.local/share-container" \
    -e TERM="${TERM:-xterm-256color}" \
    -e COLORTERM=truecolor \
    --network host \
    $IMAGE_NAME \
    ${@:-bash}
