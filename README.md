# Neovim Docker Container

A Docker container with Neovim that mounts your home directory, allowing you to seamlessly edit files with your existing Neovim configuration.

## Features

- Ubuntu 24.04 base
- Latest stable Neovim (installed from GitHub releases)
- Node.js 20 LTS (from NodeSource)
- Python 3 with pip and venv
- Rust toolchain (rustup, cargo, rust-analyzer)
- C/C++ toolchain (clang, clangd, cmake, ninja)
- Essential development tools (git, ripgrep, fd-find, curl, wget)
- Clipboard support (xclip, wl-clipboard)
- Mounts your entire home directory preserving paths
- Preserves your existing `~/.config/nvim` configuration
- Runs as your user (not root) with matching UID/GID
- Container-specific plugin directory to avoid host/container conflicts

## Quick Start

### Clone and Build

```bash
git clone <your-repo-url> nvim-docker
cd nvim-docker
chmod +x run.sh

# If Docker requires sudo on your system
sudo ./run.sh

# Otherwise
./run.sh
```

The first run will build the image (takes ~10-15 minutes), clone the Neovim config, and pre-install all plugins.

### Usage

Once inside the container:

```bash
# Your host home directory is mounted at /host
cd /host/your-project

# Edit files with Neovim
nvim file.txt

# All your files are accessible under /host
ls /host
```

**Pass commands directly:**
```bash
./run.sh nvim /host/file.txt
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
# On Apple Silicon (M1/M2/M3)
docker build --platform linux/arm64 -t nvim-dev:latest \
  --build-arg USERNAME=$(whoami) \
  --build-arg USER_UID=$(id -u) \
  --build-arg USER_GID=$(id -g) \
  .

# On Intel/AMD (x86_64)
docker build --platform linux/amd64 -t nvim-dev:latest \
  --build-arg USERNAME=$(whoami) \
  --build-arg USER_UID=$(id -u) \
  --build-arg USER_GID=$(id -g) \
  .
```

**Run:**
```bash
# On Apple Silicon (M1/M2/M3)
docker run -it --rm \
  --platform linux/arm64 \
  -v $HOME:$HOME \
  -w $(pwd) \
  -e HOME=$HOME \
  -e USER=$(whoami) \
  --network host \
  nvim-dev:latest

# On Intel/AMD (x86_64)
docker run -it --rm \
  --platform linux/amd64 \
  -v $HOME:$HOME \
  -w $(pwd) \
  -e HOME=$HOME \
  -e USER=$(whoami) \
  --network host \
  nvim-dev:latest
```

## How It Works

- Neovim configuration is baked into the container (cloned from https://github.com/spagdoon0411/nvim)
- Your host home directory is mounted at `/host` inside the container
- The container starts in `/host` so you can immediately access your files
- The container runs as a user matching your UID/GID for proper file permissions
- Plugins are pre-installed during the image build
- LSP servers are installed on-demand via Mason when you open files
- Network access is available for updates and additional tools

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
- On Linux, either:
  - Add your user to the `docker` group: `sudo usermod -aG docker $USER && newgrp docker`
  - Or run the script with `sudo`

## Notes

- The container is ephemeral (`--rm` flag) - it's removed after exit
- All your files persist because they're on the mounted host filesystem
- LSP servers and other tools installed in the container won't persist between runs
- For persistent tool installations, add them to the Dockerfile and rebuild
