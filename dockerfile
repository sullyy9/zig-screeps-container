FROM archlinux:latest

RUN pacman-key --init
RUN pacman --noconfirm -Sy
RUN pacman --noconfirm -S archlinux-keyring 

# Install basic programs and custom glibc
RUN pacman --noconfirm -Syu && \
    pacman --noconfirm -S \
    git \
    npm \
    wget \
    sudo \
    nodejs && \
    pacman --noconfirm -Scc

RUN npm install -g grunt-cli

ENV ZIG_URL=https://ziglang.org/download/0.11.0/zig-linux-x86_64-0.11.0.tar.xz
RUN mkdir ~/zig && \
    wget -c $ZIG_URL -O - | tar -xJ -C ~/zig && \
    cp -r ~/zig/*/lib /usr/lib/zig && cp ~/zig/*/zig /usr/bin/ && \
    rm -r ~/zig

RUN cd ~ && \
    git clone https://github.com/zigtools/zls && \
    cd zls && \
    git checkout 0.11.0 && \
    zig build -Doptimize=ReleaseSafe && \
    cp ./zig-out/bin/zls /usr/bin/ && \
    cd ~ && \
    rm -r ~/zls

# Setup default user
ENV USER=dev
RUN useradd --create-home -s /bin/bash -m $USER && \
    echo "$USER:archlinux" | chpasswd && \
    usermod -aG wheel $USER && \
    echo '%wheel ALL=(ALL) NOPASSWD:ALL' >> /etc/sudoers

WORKDIR /home/$USER
USER $USER
