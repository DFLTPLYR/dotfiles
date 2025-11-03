#!/usr/bin/env zsh

# Initial base PATH
PATH="$HOME/.local/bin:$PATH"

# XDG Base Directory Specification variables with defaults
XDG_CONFIG_HOME="${XDG_CONFIG_HOME:-$HOME/.config}"
XDG_DATA_HOME="${XDG_DATA_HOME:-$HOME/.local/share}"
XDG_DATA_DIRS="${XDG_DATA_DIRS:-$XDG_DATA_HOME:/usr/local/share:/usr/share}"
XDG_STATE_HOME="${XDG_STATE_HOME:-$HOME/.local/state}"
XDG_CACHE_HOME="${XDG_CACHE_HOME:-$HOME/.cache}"

# XDG User Directories (fallback to xdg-user-dir command if available)
if command -v xdg-user-dir >/dev/null 2>&1; then
  XDG_DESKTOP_DIR="${XDG_DESKTOP_DIR:-$(xdg-user-dir DESKTOP)}"
  XDG_DOWNLOAD_DIR="${XDG_DOWNLOAD_DIR:-$(xdg-user-dir DOWNLOAD)}"
  XDG_TEMPLATES_DIR="${XDG_TEMPLATES_DIR:-$(xdg-user-dir TEMPLATES)}"
  XDG_PUBLICSHARE_DIR="${XDG_PUBLICSHARE_DIR:-$(xdg-user-dir PUBLICSHARE)}"
  XDG_DOCUMENTS_DIR="${XDG_DOCUMENTS_DIR:-$(xdg-user-dir DOCUMENTS)}"
  XDG_MUSIC_DIR="${XDG_MUSIC_DIR:-$(xdg-user-dir MUSIC)}"
  XDG_PICTURES_DIR="${XDG_PICTURES_DIR:-$(xdg-user-dir PICTURES)}"
  XDG_VIDEOS_DIR="${XDG_VIDEOS_DIR:-$(xdg-user-dir VIDEOS)}"
fi

# Less history file location
LESSHISTFILE="${LESSHISTFILE:-/tmp/less-hist}"

# Application config files
PARALLEL_HOME="$XDG_CONFIG_HOME/parallel"
SCREENRC="$XDG_CONFIG_HOME/screen/screenrc"
TERMINFO="$XDG_DATA_HOME"/terminfo
TERMINFO_DIRS="$XDG_DATA_HOME"/terminfo:/usr/share/terminfo
WGETRC="${XDG_CONFIG_HOME}/wgetrc"
PYTHON_HISTORY="$XDG_STATE_HOME/python_history"

# Custom additions
DOCKER_HOST="unix:///run/user/1000/podman/podman.sock"
COMPOSER_BIN="$XDG_CONFIG_HOME/composer/vendor/bin"
DOTFILES_SCRIPTS="$HOME/dotfiles/Scripts"
CARGO_BIN="$HOME/.cargo/bin"
EDITOR="nvim"
VISUAL="nvim"

# Updated PATH and PHP config
HERD_LITE_BIN="/home/dfltplyr/.config/herd-lite/bin:$PATH"
PATH="$HERD_LITE_BIN:$COMPOSER_BIN:$CARGO_BIN:$DOTFILES_SCRIPTS:$PATH"
PHP_INI_SCAN_DIR="$HERD_PHP_INI"

# Export all variables
export PATH \
  XDG_CONFIG_HOME XDG_DATA_HOME XDG_DATA_DIRS XDG_STATE_HOME XDG_CACHE_HOME DOCKER_HOST \
  LESSHISTFILE PARALLEL_HOME SCREENRC TERMINFO TERMINFO_DIRS WGETRC PYTHON_HISTORY \
  PHP_INI_SCAN_DIR VISUAL EDITOR
