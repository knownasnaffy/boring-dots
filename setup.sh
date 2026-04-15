option=$1
extra_args=""

if rpm -q stow gum &>/dev/null; then
  gum log --time kitchen --structured --level debug "Base pkgs are already available."
else
  sudo dnf install -y gum stow
  gum log --time kitchen --structured --level info "Base pkgs successfully installed."
fi

case "$option" in
  uninstall)
    extra_args+=" -D"
    gum log --time kitchen --structured --level info "Attempting to remove dotfiles..."
    ;;
  *)
    gum log --time kitchen --structured --level info "Attempting to install dotfiles..."
    ;;
esac

stow -v -t "$HOME/.config" $extra_args xdg-config
