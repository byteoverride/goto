#!/bin/bash

GOTO_SRC_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
BIN_DIR="$HOME/.local/bin"
CONFIG_DIR="$HOME/.config/goto"

# Colors
GREEN="\033[1;32m"
BLUE="\033[1;34m"
RESET="\033[0m"

echo -e "${BLUE}Installing goto...${RESET}"

# 1. Install binary
mkdir -p "$BIN_DIR"
cp "$GOTO_SRC_DIR/goto" "$BIN_DIR/goto"
chmod +x "$BIN_DIR/goto"
echo -e "${GREEN}✅ Installed 'goto' to $BIN_DIR/goto${RESET}"

# 2. Install shell script
cp "$GOTO_SRC_DIR/goto.sh" "$BIN_DIR/goto.sh"
echo -e "${GREEN}✅ Installed 'goto.sh' to $BIN_DIR/goto.sh${RESET}"

# 3. Create config dir
mkdir -p "$CONFIG_DIR"

# 4. Instructions
echo -e "\n${BLUE}To finish installation, add the following to your shell config (~/.bashrc or ~/.zshrc):${RESET}"
echo -e "\n  source $BIN_DIR/goto.sh"
echo -e "\n${BLUE}Then restart your shell or source your config file.${RESET}"
