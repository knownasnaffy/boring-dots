FROM fedora:43

# Core system
RUN --mount=type=cache,target=/var/cache/dnf \
    --mount=type=cache,target=/var/lib/dnf \
    dnf install -y \
    git \
    curl wget \
    unzip zip tar gzip \
    which \
    procps-ng \
    util-linux-user ImageMagick tree \
    openssh-clients

# Dev tools
RUN --mount=type=cache,target=/var/cache/dnf \
    --mount=type=cache,target=/var/lib/dnf \
    dnf install -y \
    gcc gcc-c++ \
    make \
    podman \
    python3 pkg-config \
    sqlite openssl

# Terminal workflow stuff
RUN --mount=type=cache,target=/var/cache/dnf \
    --mount=type=cache,target=/var/lib/dnf \
    dnf install -y \
    zsh \
    fzf ripgrep fd-find zoxide ranger jq


# Editor/runtime layer
RUN --mount=type=cache,target=/var/cache/dnf \
    --mount=type=cache,target=/var/lib/dnf \
    dnf -y copr enable agriffis/neovim-nightly

RUN --mount=type=cache,target=/var/cache/dnf \
    --mount=type=cache,target=/var/lib/dnf \
    dnf install -y \
    neovim python3-neovim lua5.1 \
    nodejs20

RUN npm install --global pnpm@latest-11

ARG USERNAME=barinr
ARG UID=1000
ARG GID=1000

RUN groupadd -g $GID $USERNAME && \
    useradd -m -u $UID -g $GID -s /bin/zsh $USERNAME && \
    usermod -aG wheel $USERNAME && \
    echo '%wheel ALL=(ALL) NOPASSWD:ALL' >> /etc/sudoers

USER $USERNAME
WORKDIR /home/$USERNAME

ENV XDG_CONFIG_HOME=/home/$USERNAME/.config
ENV XDG_CACHE_HOME=/home/$USERNAME/.cache
ENV XDG_DATA_HOME=/home/$USERNAME/.local/share

RUN mkdir -p $XDG_CONFIG_HOME $XDG_CACHE_HOME $XDG_DATA_HOME

RUN curl -fsSL https://bun.sh/install | bash
ENV PATH="/home/$USERNAME/.bun/bin:$PATH"

ENV PNPM_HOME="/home/$USERNAME/.local/share/pnpm"
ENV PATH="$PNPM_HOME:$PATH"
