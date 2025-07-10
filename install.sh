#!/bin/bash
set -euo pipefail

DOTFILES_DIR="$HOME/.dotfiles"
REPO_URL="https://github.com/roman-xo/dot-test.git"

echo ">>> Updating system..."
sudo pacman -Syu --noconfirm

echo ">>> Installing official packages..."
sudo pacman -S --needed --noconfirm \
  bspwm sxhkd polybar rofi dunst nitrogen picom feh \
  kitty zsh \
  xorg xorg-xinit networkmanager sddm \
  noto-fonts noto-fonts-cjk noto-fonts-emoji \
  ttf-nerd-fonts-symbols ttf-nerd-fonts-symbols-mono \
  git curl unzip wget brightnessctl pamixer playerctl bc \
  ffmpeg dolphin npm yazi python-pywal btop

echo ">>> Installing yay AUR helper (if not installed)..."
if ! command -v yay &> /dev/null; then
  git clone https://aur.archlinux.org/yay.git /tmp/yay
  cd /tmp/yay
  makepkg -si --noconfirm
fi

echo ">>> Installing AUR packages..."
yay -S --noconfirm geist-font neofetch

echo ">>> Cloning dotfiles repo..."
if [ ! -d "$DOTFILES_DIR" ]; then
  git clone "$REPO_URL" "$DOTFILES_DIR"
fi

echo ">>> Linking dotfiles..."
mkdir -p "$HOME/.config"
cp -r "$DOTFILES_DIR/.config/"* "$HOME/.config/"
ln -sf "$DOTFILES_DIR/.zshrc" "$HOME/.zshrc"
[ -f "$DOTFILES_DIR/.xinitrc" ] && ln -sf "$DOTFILES_DIR/.xinitrc" "$HOME/.xinitrc"

echo ">>> Making script files executable..."
find "$HOME/.config/bspwm/scripts" -type f -iname "*.sh" -exec chmod +x {} \;
chmod +x "$HOME/.config/rofi/launchers/type-6/launcher.sh"

echo ">>> Setting up default wallpaper..."
mkdir -p "$HOME/wallpapers"
cp "$DOTFILES_DIR/wallpapers/default.jpg" "$HOME/wallpapers/default.jpg"
wal -i "$HOME/wallpapers/default.jpg"

echo ">>> Creating .xprofile for pywal + wallpaper autoload..."
cat << 'EOF' > "$HOME/.xprofile"
[ -f "$HOME/.cache/wal/colors.sh" ] && source "$HOME/.cache/wal/colors.sh"
feh --bg-scale "$(cat "$HOME/.cache/wal/wal")"
EOF

echo ">>> Installing oh-my-zsh (unattended)..."
export RUNZSH=no
export CHSH=no
if [ ! -d "$HOME/.oh-my-zsh" ]; then
  sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended
fi

echo ">>> Setting default shell to zsh..."
chsh -s "$(which zsh)"

echo ">>> Enabling system services..."
sudo systemctl enable --now sddm
sudo systemctl enable --now NetworkManager

echo -e "\n✅ Install complete!"
echo "→ You can now reboot into your fully configured desktop 😎"
