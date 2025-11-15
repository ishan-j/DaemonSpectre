#!/bin/bash
# install_spectre.sh - DaemonSpectre Installation Script

echo "--- 🛡️ DaemonSpectre Installation ---"

# 1. Determine the script's current directory (where the DaemonSpectre files are located)
# This is a robust way to find the absolute path of the directory containing the script.
INSTALL_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"

# Define the paths for the wrapper and the global command
WRAPPER_SCRIPT="$INSTALL_DIR/spectre_wrapper.sh"
GLOBAL_COMMAND="/usr/local/bin/spectre"
WHITELIST_FILE="/etc/daemonspectre_whitelist.txt"
SPECTRE_LOG_DIR="/var/log/daemonspectre"

echo "Installation directory detected: $INSTALL_DIR"

# 2. Check for required permissions
if [[ $EUID -ne 0 ]]; then
    echo "🚨 This script must be run with sudo or as root to create global links and configuration files."
    exit 1
fi

# 3. Set permissions for the wrapper
echo "Setting executable permission on wrapper..."
chmod +x "$WRAPPER_SCRIPT"

# 4. Create the global symbolic link
if [ -L "$GLOBAL_COMMAND" ]; then
    echo "Removing existing global link..."
    rm "$GLOBAL_COMMAND"
fi

echo "Creating global link: $GLOBAL_COMMAND -> $WRAPPER_SCRIPT"
ln -s "$WRAPPER_SCRIPT" "$GLOBAL_COMMAND"

# 5. Initialize the central Whitelist file in /etc/ (needs root permissions)
if [ ! -f "$WHITELIST_FILE" ]; then
    echo "Creating central whitelist file: $WHITELIST_FILE"
    touch "$WHITELIST_FILE"
fi

# 6. Setup necessary log directory (optional but good practice)
if [ ! -d "$SPECTRE_LOG_DIR" ]; then
    echo "Creating log directory: $SPECTRE_LOG_DIR"
    mkdir -p "$SPECTRE_LOG_DIR"
fi

echo ""
echo "--- ✅ DaemonSpectre Installation Complete! ---"
echo "You can now run 'spectre ls' or 'spectre wlist -e' globally."
