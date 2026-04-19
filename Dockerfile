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

# Create group and user only if not running as root (UID 0)
RUN if [ "$USER_UID" != "0" ]; then \
        # Create group if it doesn't exist
        if ! getent group $USER_GID >/dev/null; then \
            groupadd --gid $USER_GID $USERNAME; \
        fi && \
        # Check if UID already exists, if so modify it, otherwise create new user
        if getent passwd $USER_UID >/dev/null; then \
            EXISTING_USER=$(getent passwd $USER_UID | cut -d: -f1) && \
            usermod -l $USERNAME -d /home/$USERNAME -m $EXISTING_USER && \
            groupmod -n $USERNAME $EXISTING_USER 2>/dev/null || true; \
        else \
            useradd --uid $USER_UID --gid $USER_GID -m $USERNAME; \
        fi \
    fi

# Switch to the specified user (or stay root if UID is 0)
USER $USER_UID

# Set working directory based on user
RUN if [ "$USER_UID" = "0" ]; then \
        echo "Running as root"; \
    fi

WORKDIR /root

# Install Rust for the user (for rust-analyzer)
RUN curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y
ENV PATH="/root/.cargo/bin:${PATH}"

# Create container-specific data directory for plugins
RUN mkdir -p /root/.local/share-container

# Set environment variables
ENV SHELL=/bin/bash
ENV EDITOR=nvim
# Use container-specific data directory for plugins (will be overridden at runtime)
ENV XDG_DATA_HOME=/root/.local/share-container
# Terminal color support
ENV TERM=xterm-256color
ENV COLORTERM=truecolor

# Default command
CMD ["/bin/bash"]
