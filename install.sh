#!/bin/sh
# goto - User-local installer
# Installs to ~/.local/bin (user-local install)
# For system-wide install, use: make install

# shellcheck disable=SC2059

GOTO_SRC_DIR="$(cd "$(dirname "$0")" && pwd)"
BIN_DIR="$HOME/.local/bin"
CONFIG_DIR="${XDG_CONFIG_HOME:-$HOME/.config}/goto"

GREEN="\033[1;32m"
BLUE="\033[1;34m"
RESET="\033[0m"

printf "${BLUE}Installing goto...${RESET}\n"

# Install binary
mkdir -p "$BIN_DIR"
cp "$GOTO_SRC_DIR/goto" "$BIN_DIR/goto"
chmod +x "$BIN_DIR/goto"
printf "${GREEN}[ok] Installed 'goto' to %s/goto${RESET}\n" "$BIN_DIR"

# Install shell integration
cp "$GOTO_SRC_DIR/goto.sh" "$BIN_DIR/goto.sh"
printf "${GREEN}[ok] Installed 'goto.sh' to %s/goto.sh${RESET}\n" "$BIN_DIR"

# Install Fish integration (if Fish config dir exists)
FISH_DIR="${XDG_CONFIG_HOME:-$HOME/.config}/fish"
if [ -d "$FISH_DIR" ]; then
    mkdir -p "$FISH_DIR/functions" "$FISH_DIR/completions"
    cp "$GOTO_SRC_DIR/completions/goto.fish" "$FISH_DIR/functions/goto.fish"
    printf "${GREEN}[ok] Installed Fish integration${RESET}\n"
fi

# Create config dir
mkdir -p "$CONFIG_DIR"

# Instructions
printf "\n${BLUE}To finish setup, add to your shell config:${RESET}\n"
printf "\n  ${GREEN}Bash${RESET} (~/.bashrc):    source %s/goto.sh\n" "$BIN_DIR"
printf "  ${GREEN}Zsh${RESET}  (~/.zshrc):     source %s/goto.sh\n" "$BIN_DIR"
printf "  ${GREEN}Fish${RESET} (auto-loaded if installed above)\n"
printf "\n${BLUE}Then restart your shell or source your config file.${RESET}\n"
