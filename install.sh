#!/usr/bin/env bash
# rice installer (Arch only): Hyprland + Prism (Quickshell) + the configs in this repo.
#
#   git clone -b lith https://github.com/lithxzl04/rice.git rice && cd rice && ./install.sh
#
# What it does:
#   1. checks: Arch, not root
#   2. one pacman transaction: Hyprland, Quickshell, matugen, PipeWire, NetworkManager,
#      kitty, nautilus, fonts, icons, cava, btop, fastfetch, mpv
#   3. copies the configs from this repo into ~/.config (existing ones are backed up),
#      points matugen at your home, seeds config.json from config.example.json,
#      and adds the pam config for the lock screen
#   4. downloads wallpapers from upstream prism-shell into ~/Pictures/Wallpapers if it is empty
#
# Run it without sudo; it asks for your password when it needs it.
# Other distros: install the packages yourself and do steps 3-4 by hand (see README).

set -euo pipefail

HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CFG="${XDG_CONFIG_HOME:-$HOME/.config}"
STAMP="$(date +%Y%m%d-%H%M%S)"

C_G='\033[32m' C_Y='\033[33m' C_R='\033[31m' C_0='\033[0m'
ok()   { printf "${C_G} ✔${C_0} %s\n" "$*"; }
warn() { printf "${C_Y} !${C_0} %s\n" "$*"; }
die()  { printf "${C_R} ✘${C_0} %s\n" "$*"; exit 1; }

(( EUID )) || die "do not run this as root"
grep -qi '^ID=arch' /etc/os-release || die "this installer is for Arch only; see README for other distros"

# ---------------------------------------------------------------- packages --
PKGS=(
    # desktop
    hyprland xdg-desktop-portal-hyprland xdg-desktop-portal-gtk polkit
    qt6-wayland xdg-user-dirs xdg-utils
    pipewire wireplumber pipewire-alsa pipewire-pulse
    networkmanager bluez bluez-utils upower
    kitty nautilus gvfs pavucontrol unzip
    # shell (Prism)
    quickshell qt6-svg qt6-imageformats
    matugen awww cava
    wl-clipboard cliphist grim slurp wf-recorder hyprpicker jq
    brightnessctl playerctl imagemagick ffmpeg ffmpegthumbnailer
    hyprlock hyprsunset libnotify curl git python
    # looks
    ttf-nerd-fonts-symbols ttf-jetbrains-mono-nerd ttf-roboto adwaita-fonts
    noto-fonts noto-fonts-emoji noto-fonts-cjk
    breeze-icons papirus-icon-theme adw-gtk-theme
    # extras
    qt6ct btop fastfetch mpv
)
missing=()
for p in "${PKGS[@]}"; do pacman -Q "$p" &>/dev/null || missing+=("$p"); done
if ((${#missing[@]})); then
    echo "installing: ${missing[*]}"
    sudo pacman -S --needed --noconfirm "${missing[@]}"
else
    ok "all packages are already installed"
fi

# ---------------------------------------------------------------- configs ---
# copy each dir/file into ~/.config, backing up what is already there
copy() { # $1 = relative path in repo
    local src="$HERE/$1" dst="$CFG/$1"
    [[ -e $src ]] || { warn "$1 is not in the repo, skipping"; return; }
    if [[ -e $dst && ! -L $dst ]]; then
        mv "$dst" "$dst.bak-$STAMP"
        warn "backup: $1 -> $1.bak-$STAMP"
    fi
    mkdir -p "$(dirname "$dst")"
    cp -r "$src" "$dst"
    ok "$1"
}
for d in hypr quickshell matugen kitty gtk-3.0 gtk-4.0 qt6ct cava btop fastfetch; do copy "$d"; done
copy kdeglobals

# matugen needs absolute paths; the repo carries the author's home
sed -i "s|/home/[^/]*/\.config|$CFG|g" "$CFG/matugen/config.toml"
ok "matugen paths -> $CFG"

# ------------------------------------------------------------- config.json --
# config.json is gitignored, so a fresh clone ships without it
if [[ ! -f $CFG/quickshell/config.json ]]; then
    cp "$HERE/quickshell/config.example.json" "$CFG/quickshell/config.json"
    ok "config.json (from config.example.json)"
fi
command -v librewolf >/dev/null || warn "config.json uses librewolf as the browser; change apps.browser if you use another"

# -------------------------------------------------------------------- pam ----
# the lock screen's password path uses its own pam config; the hyprlock
# package ships one for hyprlock but not for hyprlock-password
if [[ ! -f /etc/pam.d/hyprlock-password ]]; then
    sudo tee /etc/pam.d/hyprlock-password >/dev/null <<'PAM'
# password-only auth for the Prism lock screen
auth        required    pam_unix.so
account     required    pam_unix.so
PAM
    ok "pam: /etc/pam.d/hyprlock-password"
fi

# ---------------------------------------------------------------- wallpaper --
# the shell reads ~/Pictures/Wallpapers unless config.json sets wallpaper.dir
WALL="$HOME/Pictures/Wallpapers"
if [[ -z $(ls -A "$WALL" 2>/dev/null) ]]; then
    echo "downloading wallpapers from prism-shell…"
    tmp="$(mktemp -d)"
    git clone --depth 1 https://github.com/Jack02134x/prism-shell.git "$tmp/prism"
    mkdir -p "$WALL"
    cp -r "$tmp/prism/wallpapers/." "$WALL/" 2>/dev/null || true
    rm -rf "$tmp"
    ok "wallpapers -> $WALL"
fi

xdg-user-dirs-update >/dev/null 2>&1 || true

echo
ok "done. Log in to Hyprland (the shell starts at login, not on a config reload)."
echo   "    from a tty: add 'exec Hyprland' to ~/.zprofile if it is not there yet"
echo   "    main key is ALT; ALT + / shows every keybind"
