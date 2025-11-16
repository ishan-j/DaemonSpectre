#!/bin/bash
# install_spectre.sh - Simplified DaemonSpectre Installation

echo "--- 🛡️ DaemonSpectre Installation ---"

# Define global names and paths
GLOBAL_COMMAND_NAME="spectre"
GLOBAL_INSTALL_PATH="/usr/local/bin/$GLOBAL_COMMAND_NAME"
WHITELIST_FILE="/etc/daemonspectre_wlist.txt"
CORE_SCRIPT_LOCAL="spectre.sh"

# 1. Check for required permissions
if [[ $EUID -ne 0 ]]; then
    echo "🚨 This script must be run with sudo or as root."
    exit 1
fi

# 2. **PORTABILITY FIX:** Clean the core script before copying it (fixes the \r issue)
echo "Sanitizing core script for Linux compatibility..."
tr -d '\r' < "$CORE_SCRIPT_LOCAL" > "$CORE_SCRIPT_LOCAL.clean"
mv "$CORE_SCRIPT_LOCAL.clean" "$CORE_SCRIPT_LOCAL"

# 3. Copy core script to a global PATH location
echo "Installing $GLOBAL_COMMAND_NAME to $GLOBAL_INSTALL_PATH..."
cp "$CORE_SCRIPT_LOCAL" "$GLOBAL_INSTALL_PATH"

# 4. Ensure it is executable
chmod +x "$GLOBAL_INSTALL_PATH"

# 5. Initialize central configuration file
if [ ! -f "$WHITELIST_FILE" ]; then
    echo "Creating central whitelist file: $WHITELIST_FILE"
    touch "$WHITELIST_FILE"
fi

echo ""
echo "--- ✅ DaemonSpectre Installation Complete! ---"
echo "You can now run 'spectre ls' or 'spectre wlist -e' globally."
