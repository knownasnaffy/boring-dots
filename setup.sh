option=$1

if rpm -q stow &>/dev/null; then
  echo "Stow is available"
else
  echo "Installing stow..."
  sudo dnf install -y stow
fi

default_packages=(
  aria2 brightnessctl btop git fastfetch fuse fuse-libs maim python3-xlib
  qutebrowser ripgrep slop xev zathura zathura-pdf-poppler zsh tealdeer pass
)

optional_packages=(
  pandoc texlive-schema-full sane-backends simple-scan rustup obs-studio
)

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
    ;;
esac
