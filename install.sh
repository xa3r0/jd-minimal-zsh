#!/usr/bin/env bash
set -e

# jd-minimal-zsh bootstrap
# - Installs OMZ + plugins + jd-minimal theme
# - Handles Linux (apt/dnf/pacman) and macOS (Darwin)
# - Installs Nerd Font to the correct per-OS path unless disabled

# Flags
NO_FONT=0
for arg in "$@"; do
  case "$arg" in
    --no-font) NO_FONT=1 ;;
  esac
done
# Env override
if [ "${JD_INSTALL_FONT:-1}" = "0" ]; then NO_FONT=1; fi

# Defaults for customizations (can be overridden by env)
: "${JD_SYMBOL:=>>}"
: "${JD_PATH_MODE:=short}"        # short => %~ , full => %d
: "${JD_COLORS_USER:=cyan}"
: "${JD_COLORS_HOST:=yellow}"
: "${JD_COLORS_PATH:=green}"

echo "[*] jd-minimal-zsh installer starting..."

# Detect OS
OS="$(uname -s)"
case "$OS" in
  Linux)   PLATFORM="linux" ;;
  Darwin)  PLATFORM="macos" ;;
  *)       PLATFORM="other" ;;
esac

# Package install wrappers
pkg_install_linux() {
  if command -v apt >/dev/null 2>&1; then
    sudo apt update -y
    sudo apt install -y "$@"
  elif command -v dnf >/dev/null 2>&1; then
    sudo dnf install -y "$@"
  elif command -v pacman >/dev/null 2>&1; then
    sudo pacman -Sy --noconfirm "$@"
  else
    echo "[!] Unsupported Linux package manager. Please install: $*"
  fi
}

pkg_install_macos() {
  if ! command -v brew >/dev/null 2>&1; then
    echo "[!] Homebrew not found. Install from https://brew.sh then rerun this script."
    return 1
  fi
  brew install "$@"
}

# Ensure core deps zsh + git + curl
ensure_core_deps() {
  missing=()
  for c in zsh git curl; do
    if ! command -v "$c" >/dev/null 2>&1; then
      missing+=("$c")
    fi
  done
  if [ "${#missing[@]}" -gt 0 ]; then
    echo "[*] Installing missing deps: ${missing[*]}"
    if [ "$PLATFORM" = "linux" ]; then
      pkg_install_linux "${missing[@]}"
    elif [ "$PLATFORM" = "macos" ]; then
      pkg_install_macos "${missing[@]}"
    else
      echo "[!] Unsupported platform for automatic dependency install. Please install: ${missing[*]}"
    fi
  fi
}
ensure_core_deps

# Install Oh My Zsh if missing
if [ ! -d "$HOME/.oh-my-zsh" ]; then
  echo "[*] Installing Oh My Zsh..."
  CHSH=no RUNZSH=no KEEP_ZSHRC=yes \
  sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
fi

ZSH_CUSTOM="${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}"

# Plugins
if [ ! -d "$ZSH_CUSTOM/plugins/zsh-autosuggestions" ]; then
  echo "[*] Installing zsh-autosuggestions..."
  git clone https://github.com/zsh-users/zsh-autosuggestions "$ZSH_CUSTOM/plugins/zsh-autosuggestions"
fi
if [ ! -d "$ZSH_CUSTOM/plugins/zsh-syntax-highlighting" ]; then
  echo "[*] Installing zsh-syntax-highlighting..."
  git clone https://github.com/zsh-users/zsh-syntax-highlighting "$ZSH_CUSTOM/plugins/zsh-syntax-highlighting"
fi

# Theme install
THEME_DIR="$ZSH_CUSTOM/themes/jd-minimal"
mkdir -p "$THEME_DIR"
SCRIPT_DIR="$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)"
cp "$SCRIPT_DIR/themes/jd-minimal.zsh-theme" "$THEME_DIR/"

# Font detection + optional installation
has_nerd_font() {
  if [ "$PLATFORM" = "linux" ]; then
    command -v fc-list >/dev/null 2>&1 && fc-list | grep -qi "Nerd Font"
  elif [ "$PLATFORM" = "macos" ]; then
    # crude check - list user fonts
    ls "$HOME/Library/Fonts" 2>/dev/null | grep -qi "Nerd" || ls "$HOME/Library/Fonts/NerdFonts" 2>/dev/null | grep -qi "JetBrainsMono"
  else
    return 1
  fi
}

install_nerd_font() {
  local font_zip_url="https://github.com/ryanoasis/nerd-fonts/releases/download/v3.2.1/JetBrainsMono.zip"
  local tmpd ; tmpd="$(mktemp -d)"
  echo "[*] Downloading JetBrainsMono Nerd Font..."
  (cd "$tmpd" && curl -fL -o JetBrainsMono.zip "$font_zip_url")
  if [ "$PLATFORM" = "linux" ]; then
    local dest="$HOME/.local/share/fonts/NerdFonts/JetBrainsMono"
    mkdir -p "$dest"
    unzip -o "$tmpd/JetBrainsMono.zip" -d "$dest" >/dev/null
    if command -v fc-cache >/dev/null 2>&1; then
      fc-cache -f "$HOME/.local/share/fonts" || true
    fi
    echo "[*] Installed Nerd Font to $dest"
  elif [ "$PLATFORM" = "macos" ]; then
    local dest="$HOME/Library/Fonts/NerdFonts/JetBrainsMono"
    mkdir -p "$dest"
    unzip -o "$tmpd/JetBrainsMono.zip" -d "$dest" >/dev/null
    echo "[*] Installed Nerd Font to $dest"
    echo "[i] Set this font in your terminal profile to see glyphs."
  else
    echo "[!] Font install for platform '$PLATFORM' is not implemented."
  fi
  rm -rf "$tmpd"
}

if [ "$NO_FONT" -eq 0 ]; then
  if has_nerd_font; then
    echo "[*] Nerd Font detected."
  else
    echo "[*] No Nerd Font detected."
    # unzip may be missing
    if ! command -v unzip >/dev/null 2>&1; then
      if [ "$PLATFORM" = "linux" ]; then
        pkg_install_linux unzip
      elif [ "$PLATFORM" = "macos" ]; then
        pkg_install_macos unzip
      fi
    fi
    install_nerd_font
  fi
else
  echo "[*] Skipping Nerd Font detection and install (--no-font or JD_INSTALL_FONT=0)."
fi

# Patch ~/.zshrc
ZSHRC="$HOME/.zshrc"
touch "$ZSHRC"

# Ensure OMZ path
if ! grep -q '^export ZSH=' "$ZSHRC"; then
  echo 'export ZSH="$HOME/.oh-my-zsh"' >> "$ZSHRC"
fi

# Set theme
if grep -q '^ZSH_THEME=' "$ZSHRC"; then
  sed -i.bak 's|^ZSH_THEME=.*|ZSH_THEME="jd-minimal/jd-minimal"|' "$ZSHRC"
else
  echo 'ZSH_THEME="jd-minimal/jd-minimal"' >> "$ZSHRC"
fi

# Ensure plugins line
if grep -q '^plugins=' "$ZSHRC"; then
  sed -i.bak 's|^plugins=.*|plugins=(git zsh-autosuggestions zsh-syntax-highlighting)|' "$ZSHRC"
else
  echo 'plugins=(git zsh-autosuggestions zsh-syntax-highlighting)' >> "$ZSHRC"
fi

# Ensure OMZ sourced
if ! grep -q 'oh-my-zsh\.sh' "$ZSHRC"; then
  echo 'source "$ZSH/oh-my-zsh.sh"' >> "$ZSHRC"
fi

# Add or update jd-minimal config block (idempotent)
if grep -q '# jd-minimal options' "$ZSHRC"; then
  # update existing keys in place
  sed -i.bak "s|^export JD_SYMBOL=.*|export JD_SYMBOL=\"${JD_SYMBOL}\"|" "$ZSHRC" || true
  sed -i.bak "s|^export JD_PATH_MODE=.*|export JD_PATH_MODE=\"${JD_PATH_MODE}\"|" "$ZSHRC" || true
  sed -i.bak "s|^export JD_COLORS_USER=.*|export JD_COLORS_USER=\"${JD_COLORS_USER}\"|" "$ZSHRC" || true
  sed -i.bak "s|^export JD_COLORS_HOST=.*|export JD_COLORS_HOST=\"${JD_COLORS_HOST}\"|" "$ZSHRC" || true
  sed -i.bak "s|^export JD_COLORS_PATH=.*|export JD_COLORS_PATH=\"${JD_COLORS_PATH}\"|" "$ZSHRC" || true
else
  cat >> "$ZSHRC" <<EOF

# jd-minimal options (edit to taste)
export JD_SYMBOL="${JD_SYMBOL}"           # try ">>" or "❯❯"
export JD_PATH_MODE="${JD_PATH_MODE}"     # "short" => %~ , "full" => %d
export JD_COLORS_USER="${JD_COLORS_USER}" # zsh color name
export JD_COLORS_HOST="${JD_COLORS_HOST}"
export JD_COLORS_PATH="${JD_COLORS_PATH}"
EOF
fi

echo
echo "[*] Done. Open a new terminal or run: exec zsh
"
