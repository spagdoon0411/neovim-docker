FROM ubuntu:24.04

# Prevent interactive prompts during package installation
ENV DEBIAN_FRONTEND=noninteractive

# Install dependencies and Neovim
RUN apt-get update && apt-get install -y \
    neovim \
    git \
    curl \
    wget \
    ripgrep \
    fd-find \
    unzip \
    tar \
    gzip \
    nodejs \
    npm \
    python3 \
    python3-pip \
    build-essential \
    && rm -rf /var/lib/apt/lists/*

# Install neovim python support
RUN pip3 install --no-cache-dir pynvim --break-system-packages

# Install node neovim support
RUN npm install -g neovim

# Set up a non-root user
ARG USERNAME=vimuser
ARG USER_UID=1000
ARG USER_GID=$USER_UID

RUN groupadd --gid $USER_GID $USERNAME \
    && useradd --uid $USER_UID --gid $USER_GID -m $USERNAME

# Switch to non-root user
USER $USERNAME

# Set working directory to user's home
WORKDIR /home/$USERNAME

# Set environment variables
ENV SHELL=/bin/bash
ENV EDITOR=nvim

# Default command
CMD ["/bin/bash"]
