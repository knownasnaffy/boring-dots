FROM fedora:43

RUN dnf -y copr enable agriffis/neovim-nightly
    && dnf install -y \
    git \
    python3 pkg-config \
    neovim python3-neovim lua5.1 \
    zsh \
    curl wget \
    gcc gcc-c++ \
    make \
    podman \
    nodejs20 \
    fzf ripgrep fd-find zoxide ranger \
    unzip zip tar gzip \
    which \
    openssh-clients \
    procps-ng \
    util-linux-user ImageMagick tree \
    sqlite openssl \
    && dnf clean all

ARG USERNAME=dev
ARG UID=1000
ARG GID=1000

RUN groupadd -g $GID $USERNAME && \
    useradd -m -u $UID -g $GID -s /bin/zsh $USERNAME && \
    usermod -aG wheel $USERNAME && \
    echo '%wheel ALL=(ALL) NOPASSWD:ALL' >> /etc/sudoers

USER $USERNAME
WORKDIR /home/$USERNAME

RUN curl -fsSL https://bun.sh/install | bash
ENV PATH="/home/$USERNAME/.bun/bin:$PATH"

RUN npm install --global pnpm@latest-9
# RUN pnpm config --global set store-dir /pnpm-store
ENV PNPM_HOME="/home/$USERNAME/.local/share/pnpm"
ENV PATH="$PNPM_HOME:$PATH"

