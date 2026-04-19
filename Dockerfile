FROM ubuntu:24.04

# Prevent interactive prompts during package installation
ENV DEBIAN_FRONTEND=noninteractive

# Install dependencies
RUN apt-get update && apt-get install -y \
    git \
    curl \
    wget \
    ripgrep \
    fd-find \
    unzip \
    tar \
    gzip \
    python3 \
    python3-pip \
    python3-venv \
    build-essential \
    ca-certificates \
    gnupg \
    # C/C++ toolchain for clangd
    clang \
    clangd \
    cmake \
    ninja-build \
    # Clipboard support
    xclip \
    wl-clipboard \
    # Additional dev tools
    xz-utils \
    locales \
    && rm -rf /var/lib/apt/lists/*

# Set up locale
RUN locale-gen en_US.UTF-8
ENV LANG=en_US.UTF-8
ENV LANGUAGE=en_US:en
ENV LC_ALL=en_US.UTF-8

# Install Node.js 20 LTS from NodeSource
RUN curl -fsSL https://deb.nodesource.com/setup_20.x | bash - \
    && apt-get install -y nodejs \
    && rm -rf /var/lib/apt/lists/*

# Install Neovim v0.12.0-dev at specific commit (matches your Mac version: 66f02ee1fe)
# Build from source to ensure compatibility across architectures
RUN apt-get update && apt-get install -y \
    gettext \
    libtool \
    libtool-bin \
    autoconf \
    automake \
    pkg-config \
    && rm -rf /var/lib/apt/lists/* \
    && git clone https://github.com/neovim/neovim /tmp/neovim \
    && cd /tmp/neovim \
    && git checkout 66f02ee1fe \
    && make CMAKE_BUILD_TYPE=Release \
    && make install \
    && cd / \
    && rm -rf /tmp/neovim

# Install neovim python support
RUN pip3 install --no-cache-dir pynvim --break-system-packages

# Install node neovim support
RUN npm install -g neovim

# Set up a non-root user
ARG USERNAME=vimuser
ARG USER_UID=1000
ARG USER_GID=$USER_UID

# Create group only if it doesn't exist, then create user
RUN if ! getent group $USER_GID >/dev/null; then \
        groupadd --gid $USER_GID $USERNAME; \
    fi \
    && useradd --uid $USER_UID --gid $USER_GID -m $USERNAME

# Switch to non-root user
USER $USERNAME

# Set working directory to user's home
WORKDIR /home/$USERNAME

# Install Rust for the non-root user (for rust-analyzer)
RUN curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y
ENV PATH="/home/$USERNAME/.cargo/bin:${PATH}"

# Create container-specific data directory for plugins
RUN mkdir -p /home/$USERNAME/.local/share/nvim-container

# Set environment variables
ENV SHELL=/bin/bash
ENV EDITOR=nvim
# Use container-specific data directory for plugins
ENV XDG_DATA_HOME=/home/$USERNAME/.local/share-container
# Terminal color support
ENV TERM=xterm-256color
ENV COLORTERM=truecolor

# Default command
CMD ["/bin/bash"]
