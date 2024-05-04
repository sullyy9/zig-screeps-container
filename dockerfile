FROM archlinux:latest

RUN pacman-key --init && \
    pacman --noconfirm -Sy && \
    pacman --noconfirm -S archlinux-keyring && \
    pacman --noconfirm -Syu && \
    pacman --noconfirm -S \
    git \
    npm \
    wget \
    nodejs \
    sudo && \
    pacman --noconfirm -Scc

ENV ZVM_URL=https://github.com/tristanisham/zvm/releases/download/v0.6.7/zvm-linux-amd64.tar
RUN mkdir ~/zvm && \
    wget -c $ZVM_URL -O ~/zvm.tar && \
    tar -xf ~/zvm.tar -C /usr/bin/ && \
    rm ~/zvm.tar

RUN npm install -g grunt-cli

# Setup default user
ENV USER=dev
RUN useradd --create-home -s /bin/bash -m $USER && \
    echo "$USER:archlinux" | chpasswd && \
    usermod -aG wheel $USER && \
    echo '%wheel ALL=(ALL) NOPASSWD:ALL' >> /etc/sudoers

WORKDIR /home/$USER
USER $USER

ENV PATH="/home/$USER/.zvm/bin:$PATH"

# ZLS V0.12 not yet available so install master and copy into 0.12.0 directory.
RUN zvm install -D=zls 0.12.0 && \
    zvm use 0.12.0 && \
    # Zig fmt needs to be built the first time it's run. Do that here.
    zig fmt --help
