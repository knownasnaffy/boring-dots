option=$1

ZSH_DIR="$HOME/.oh-my-zsh"
ZSH_CUSTOM="$ZSH_DIR/custom"

if command -v stow &>/dev/null; then
  echo "Stow is available!"
else
  echo "Installing stow..."
  if command -v dnf >/dev/null; then
    echo "Installing prerequisites with DNF..."
    sudo dnf install -y stow

  elif command -v pacman >/dev/null; then
    echo "Installing prerequisites with Pacman..."
    sudo pacman -Syu --noconfirm stow

  else
    echo "WARNING: Unsupported distribution. Install prerequisities manually"
  fi
fi

default_packages=(
  aria2 brightnessctl btop git fastfetch fuse fuse-libs maim python3-xlib
  qutebrowser ripgrep slop xev zathura zathura-pdf-poppler zsh tealdeer pass
)

optional_packages=(
  pandoc texlive-schema-full sane-backends simple-scan rustup obs-studio
)

install_omz() {
    if [ ! -d "$ZSH_DIR" ]; then
        echo "Installing Oh My Zsh..."
        git clone https://github.com/ohmyzsh/ohmyzsh.git "$ZSH_DIR/"
    fi
}

uninstall_omz() {
    if [ -d "$ZSH_DIR" ]; then
        echo "Uninstalling Oh My Zsh..."
        rm -rf "$ZSH_DIR"
    fi
}

install_omz_plugins() {
    declare -A plugins=(
        ["zsh-autosuggestions"]="https://github.com/zsh-users/zsh-autosuggestions"
        ["zsh-abbr"]="https://github.com/olets/zsh-abbr"
    )

    for plugin in "${!plugins[@]}"; do
        local plugin_path="$ZSH_CUSTOM/plugins/$plugin"
        [ ! -d "$plugin_path" ] && echo "Installing plugin '$plugin' for omz..." && git clone "${plugins[$plugin]}" "$plugin_path" --recurse-submodules
    done
}

case "$option" in
  uninstall)
    echo "Attempting to remove dotfiles..."
    stow -v -t "$HOME" --dotfiles -D user-config
    stow -v -t "$HOME/.local/bin" --dotfiles -D bin
    ;;

  *)
    echo "Attempting to install dotfiles..."

    mkdir -p "$HOME/.config" "$HOME/.local/bin"
    stow -v -t "$HOME" --dotfiles user-config
    stow -v -t "$HOME/.local/bin" --dotfiles bin

    install_omz
    install_omz_plugins

    echo "Done!"
    ;;
esac
