# Neovim Docker Container

A Docker container with Neovim that mounts your home directory, allowing you to seamlessly edit files with your existing Neovim configuration.

## Features

- Ubuntu 24.04 base
- Latest Neovim with Python and Node.js support
- Essential development tools (git, ripgrep, fd-find, curl, wget)
- Mounts your entire home directory preserving paths
- Preserves your existing `~/.config/nvim` configuration
- Runs as your user (not root) with matching UID/GID

## Quick Start

### Clone and Build

```bash
git clone <your-repo-url> nvim-docker
cd nvim-docker
chmod +x run.sh
./run.sh
```

### Usage

**Open a bash shell in the container:**
```bash
./run.sh
```

**Run Neovim directly with a file:**
```bash
./run.sh nvim myfile.txt
```

**Run any command:**
```bash
./run.sh ls -la
./run.sh git status
```

### Using Docker Compose

```bash
# Build and start
docker-compose up -d

# Enter the container
docker-compose exec nvim bash

# Stop the container
docker-compose down
```

### Manual Docker Commands

**Build:**
```bash
docker build -t nvim-dev:latest \
  --build-arg USERNAME=$(whoami) \
  --build-arg USER_UID=$(id -u) \
  --build-arg USER_GID=$(id -g) \
  .
```

**Run:**
```bash
docker run -it --rm \
  -v $HOME:$HOME \
  -w $(pwd) \
  -e HOME=$HOME \
  -e USER=$(whoami) \
  --network host \
  nvim-dev:latest
```

## How It Works

- Your home directory (`~`) is mounted at the same path inside the container
- Your Neovim config at `~/.config/nvim` is automatically available
- All file paths remain consistent between host and container
- The container runs as your user, so file permissions are preserved
- Network access is available for installing plugins, LSP servers, etc.

## Customization

### Add More Tools

Edit the `Dockerfile` and add packages to the `apt-get install` line:

```dockerfile
RUN apt-get update && apt-get install -y \
    neovim \
    git \
    your-package-here \
    && rm -rf /var/lib/apt/lists/*
```

### Change Base Image

Replace `ubuntu:24.04` with another base like `ubuntu:22.04` or `debian:bookworm`

## Requirements

- Docker installed on your system
- Your Neovim configuration at `~/.config/nvim` (or will use Neovim defaults)

## Notes

- The container is ephemeral (`--rm` flag) - it's removed after exit
- All your files persist because they're on the mounted host filesystem
- LSP servers and other tools installed in the container won't persist between runs
- For persistent tool installations, add them to the Dockerfile and rebuild
