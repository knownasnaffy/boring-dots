option=$1

if rpm -q stow gum &>/dev/null; then
  gum log --time kitchen --structured --level debug "Base pkgs are already available."
else
  sudo dnf install -y gum stow
  gum log --time kitchen --structured --level info "Base pkgs successfully installed."
fi

default_packages=(
    aria2 brightnessctl btop git fastfetch fuse fuse-libs maim python3-xlib qutebrowser ripgrep slop xev zathura zathura-pdf-poppler zsh tealdeer pass
)

optional_packages=(
    pandoc texlive-schema-full sane-backends simple-scan rustup obs-studio
)

case "$option" in
  uninstall)
    gum log --time kitchen --structured --level info "Attempting to remove dotfiles..."
    stow -v -t "$HOME" --dotfiles -D user-config
    stow -v -t "$HOME/.local/bin" --dotfiles -D bin
    ;;

  *)
    gum log --time kitchen --structured --level info "Attempting to install dotfiles..."

    mkdir -p "$HOME/.config" "$HOME/.local/bin"
    stow -v -t "$HOME" --dotfiles user-config
    stow -v -t "$HOME/.local/bin" --dotfiles bin

    if rpm -q stow gum idk &>/dev/null; then
      gum log --time kitchen --structured --level debug "Default pkgs are already available."
    else
      gum log --time kitchen --structured --level warn "Missing default packages. Continue to install?"

      option1="Yes (Install default pkgs)"
      option2="No (Don't install anything)"
      option3="IDK (Customize installation)"
      selection=$(gum choose "$option1" "$option2" "$option3")

      case "$selection" in
        "$option1")
          gum log --time kitchen --structured --level info "Configuring repositories"
          ;;

        "$option3")
          gum log --time kitchen --structured --level info "Choose repositories to be installed"
          ;;

        *)
          gum log --time kitchen --structured --level warn "Skipping package installation. This may result in a weird behaviour if some packages are not present."
          ;;
      esac
    fi
    ;;
esac

