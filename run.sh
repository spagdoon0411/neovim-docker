#!/bin/bash
#
# Helper script to run Neovim in Docker container
# Usage: ./run.sh [file-to-edit]

IMAGE_NAME="nvim-dev:latest"
CONTAINER_NAME="nvim-dev"

# Build the image if it doesn't exist
if [[ "$(docker images -q $IMAGE_NAME 2> /dev/null)" == "" ]]; then
    echo "Building Neovim Docker image..."
    docker build -t $IMAGE_NAME \
        --build-arg USERNAME=$(whoami) \
        --build-arg USER_UID=$(id -u) \
        --build-arg USER_GID=$(id -g) \
        .
fi

# Run container with home directory mounted
docker run -it --rm \
    --name $CONTAINER_NAME \
    -v "$HOME:$HOME" \
    -w "$(pwd)" \
    -e HOME="$HOME" \
    -e USER="$(whoami)" \
    --network host \
    $IMAGE_NAME \
    ${@:-bash}
